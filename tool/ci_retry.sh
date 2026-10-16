#!/usr/bin/env bash
# Runs a build command; if it failed only because the Android SDK manager could
# not download a package (e.g. "Error on ZipFile unknown archive" for the NDK,
# seen on CI runners), clears the partial download and tries again (3 times).
# Any other failure is returned at once.
#
#   bash tool/ci_retry.sh flutter build appbundle --release --flavor nailvi
set -u
log="${RUNNER_TEMP:-/tmp}/ci_retry.log"
for i in 1 2 3; do
  "$@" 2>&1 | tee "$log"
  rc=${PIPESTATUS[0]}
  [ "$rc" -eq 0 ] && exit 0
  if ! grep -qE "sdkmanager.*finished with non-zero exit value|An error occurred while preparing SDK package" "$log"; then
    exit "$rc"
  fi
  echo "::warning::Android SDK package download failed (attempt $i), retrying"
  sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  [ -n "$sdk" ] && rm -rf "$sdk/.temp" "$sdk/.downloadIntermediates"
  sleep 15
done
exit "$rc"
