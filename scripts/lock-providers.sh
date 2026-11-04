#!/usr/bin/env bash
# Usage: scripts/lock-providers.sh <root-module-dir>
set -euo pipefail

dir="${1:?usage: lock-providers.sh <root-module-dir>}"

terraform -chdir="${dir}" providers lock \
  -platform=linux_amd64 \
  -platform=darwin_arm64 \
  -platform=darwin_amd64 \
  -platform=windows_amd64
