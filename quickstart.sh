#!/usr/bin/env bash
set -euo pipefail

# quickstart.sh - Opinionated ultra-short bootstrap.
# Goals:
#  1. Ensure Java 17 (install lightweight local JDK if missing or wrong version)
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
  [[ "${major}" != "17" ]]
}

install_local_jdk() {
  echo "[quickstart] Installing local Temurin JDK 17 (portable) ..."
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
  # Temurin 17 LTS GA build (adjust version if needed later)
  local version="17.0.10+7"
  if [[ "$os" == "mac" ]]; then
    archive="OpenJDK17U-jdk_${arch}_mac_hotspot_17.0.10_7.tar.gz"
  else
    archive="OpenJDK17U-jdk_${arch}_linux_hotspot_17.0.10_7.tar.gz"
  fi
  url="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/${archive}"
  curl -L --fail -o .jdk/${archive} "$url"
  tar -xf .jdk/${archive} -C .jdk
  local extracted
  extracted=$(tar -tf .jdk/${archive} | head -1 | cut -d/ -f1)
  export JAVA_HOME="${PROJECT_ROOT}/.jdk/${extracted}"
  export PATH="$JAVA_HOME/bin:$PATH"
  echo "[quickstart] Local JDK installed at $JAVA_HOME"
}

if need_jdk_install; then
  install_local_jdk || {
    echo "[quickstart][ERROR] Could not auto-install JDK 17. Please install manually then rerun ./quickstart.sh" >&2
    exit 1
  }
else
  # Re-check version equals 17; enforce
  v=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  major=${v%%.*}
  if [[ "$major" != "17" ]]; then
    echo "[quickstart][ERROR] Detected Java $v; need 17. Remove conflicting JDK from PATH or rely on local install by temporarily moving java binary." >&2
    exit 1
  fi
fi

chmod +x run.sh || true
exec ./run.sh start
