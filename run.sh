#!/usr/bin/env bash
set -euo pipefail

# Some environments set -u and do not export JAVA_HOME even though 'java' is on PATH.
# Avoid unbound variable errors by referencing JAVA_HOME only if defined.
: "${JAVA_HOME:=}" 2>/dev/null || true

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR_PATH="${PROJECT_ROOT}/stocky-api/target/stocky-api.jar"
PROFILE="offline"
JAVA_OPTS=""
COMMAND=${1:-start}

function ensure_java() {
  if ! command -v java >/dev/null 2>&1; then
    echo "[ERROR] Java 17 is required but 'java' not found in PATH" >&2
    exit 1
  fi
  VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  MAJOR=${VERSION%%.*}
  if [[ ${MAJOR} != 17 ]]; then
    cat >&2 <<EOF
[ERROR] Detected Java version ${VERSION}.
This project currently requires JDK 17 (tooling/plugins are not yet aligned with ${VERSION}).

Fix options (macOS examples):
  1. Install Temurin 17 (Adoptium) and set it active:
     brew install --cask temurin17
     export JAVA_HOME=$(/usr/libexec/java_home -v 17)
     export PATH="$JAVA_HOME/bin:$PATH"
  2. Use SDKMAN:
     curl -s "https://get.sdkman.io" | bash
     sdk install java 17.0.10-tem
     sdk use java 17.0.10-tem

Then re-run: ./run.sh start
EOF
    exit 1
  fi
}

function setup() {
  echo "[INFO] Building project (frontend + backend) ..."
  (cd "${PROJECT_ROOT}/stocky-api" && ./mvnw -q -DskipTests package)
  echo "[INFO] Build complete: ${JAR_PATH}";
}

function start() {
  if [[ ! -f "${JAR_PATH}" ]]; then
    echo "[INFO] JAR not found. Running setup first..."
    setup
  fi
  mkdir -p "${PROJECT_ROOT}/stocky-api/data/h2"
  echo "[INFO] Starting Stocky (profile=${PROFILE}) on http://localhost:8080"
  exec java ${JAVA_OPTS} -jar "${JAR_PATH}" --spring.profiles.active=${PROFILE}
}

function clean() {
  echo "[INFO] Cleaning build artifacts & local data"
  (cd "${PROJECT_ROOT}/stocky-api" && ./mvnw -q clean)
  rm -rf "${PROJECT_ROOT}/stocky-api/data" || true
  echo "[INFO] Clean complete"
}

function help_cmd() {
  cat <<EOF
Usage: ./run.sh [command]
Commands:
  setup   Build everything (downloads dependencies) without starting
  start   Build if needed then run the self-contained server (default)
  clean   Remove build outputs and local H2 data
  help    Show this help

Examples:
  ./run.sh            # start
  ./run.sh setup      # just build
  ./run.sh clean      # reset
EOF
}

ensure_java
case "${COMMAND}" in
  setup) setup ;;
  start) start ;;
  clean) clean ;;
  help|--help|-h) help_cmd ;;
  *) echo "Unknown command: ${COMMAND}"; help_cmd; exit 1 ;;
esac