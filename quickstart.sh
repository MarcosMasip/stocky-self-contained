#!/usr/bin/env bash
set -euo pipefail

# quickstart.sh - Opinionated ultra-short bootstrap.
# Goals:
#  1. Ensure Java 21 (install lightweight local JDK if missing or wrong version)
#  2. Ensure run.sh executable
#  3. Run ./run.sh start
# Local JDK (if needed) is placed under .jdk/ and prepended to PATH for this session only.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

need_jdk_install() {
  if ! command -v java >/dev/null 2>&1; then
    return 0
  fi
  local v
  v=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  local major=${v%%.*}
  (( major < 21 ))
}

install_local_jdk() {
  echo "[quickstart] Installing local Temurin JDK 21 (portable) ..."
  mkdir -p .jdk
  local url os arch archive
  arch="$(uname -m)"
  case "$(uname -s)" in
    Darwin) os="mac" ;;
    Linux) os="linux" ;;
    *) echo "[quickstart][WARN] Unsupported OS for automatic JDK fetch. Install JDK 17 manually."; return 1 ;;
  esac
  case "$arch" in
    x86_64|amd64) arch="x64" ;;
    arm64|aarch64) arch="aarch64" ;;
    *) echo "[quickstart][WARN] Unsupported architecture ($arch). Install JDK 17 manually."; return 1 ;;
  esac
  # Temurin 21 LTS GA build (adjust version if needed later)
  local version="21.0.2+13"
  if [[ "$os" == "mac" ]]; then
    archive="OpenJDK21U-jdk_${arch}_mac_hotspot_21.0.2_13.tar.gz"
  else
    archive="OpenJDK21U-jdk_${arch}_linux_hotspot_21.0.2_13.tar.gz"
  fi
  url="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/${archive}"
  curl -L --fail -o .jdk/${archive} "$url"
  tar -xf .jdk/${archive} -C .jdk
  local extracted
  extracted=$(tar -tf .jdk/${archive} | head -1 | cut -d/ -f1)
  export JAVA_HOME="${PROJECT_ROOT}/.jdk/${extracted}"
  export PATH="$JAVA_HOME/bin:$PATH"
  echo "[quickstart] Local JDK installed at $JAVA_HOME (Java $(java -version 2>&1 | awk -F '"' '/version/ {print $2}'))"
}

if need_jdk_install; then
  install_local_jdk || {
    echo "[quickstart][ERROR] Could not auto-install JDK 21. Please install manually then rerun ./quickstart.sh" >&2
    exit 1
  }
else
  # Warn if not 21+ (should have been caught earlier, but safeguard)
  v=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  major=${v%%.*}
  if (( major < 21 )); then
    echo "[quickstart][ERROR] Detected Java $v; need at least 21. Remove conflicting JDK from PATH or rely on local install by temporarily moving java binary." >&2
    exit 1
  fi
fi

chmod +x run.sh || true
exec ./run.sh start
