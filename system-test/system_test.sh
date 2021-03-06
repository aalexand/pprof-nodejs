#!/bin/bash

retry() {
  for i in {1..3}; do
    "${@}" && return 0
  done
  return 1
}

# Fail on any error.
set -eo pipefail

# Display commands being run.
set -x

# Record directory of pprof-nodejs.
cd $(dirname $0)/..
BASE_DIR=$(pwd)

RUN_ONLY_V8_CANARY_TEST="${RUN_ONLY_V8_CANARY_TEST:-false}"
echo "$RUN_ONLY_V8_CANARY_TEST"

# Install nvm.
retry curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash &>/dev/null
export NVM_DIR="$HOME/.nvm" &>/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" &>/dev/null

# Move system test to separate directory to run.
TESTDIR="$BASE_DIR/run-system-test"
cp -R "system-test" "$TESTDIR"

# Run test.
cd "$TESTDIR"
retry go get -t -d .
go test -v -timeout=10m -run TestAgentIntegration -pprof_nodejs_path="$BASE_DIR" -run_only_v8_canary_test="$RUN_ONLY_V8_CANARY_TEST" -binary_host="$BINARY_HOST"

# Remove directory where test was run.
rm -r $TESTDIR
