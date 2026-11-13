#!/usr/bin/env bash
# Run every repository's own gate, in order, and say which passed. Nothing here calls a model or spends
# anything: each build uses scripted replies or fakes. Expects the five repositories beside this one.
set -uo pipefail
cd "$(dirname "$0")/.."

repos=(
  claude-code-governed-workflow
  claude-structured-extraction
  mcp-server-dotnet
  agent-sdk-orchestrator
  ticket-intake-service
)

failed=0
for repo in "${repos[@]}"; do
  if [[ ! -x "$repo/build.sh" ]]; then
    echo "MISSING  $repo"
    failed=1
    continue
  fi

  if [[ "$repo" == agent-sdk-orchestrator && ! -d "$repo/node_modules" ]]; then
    (cd "$repo" && npm install --silent >/dev/null 2>&1)
  fi

  if output="$("$repo/build.sh" 2>&1)"; then
    tests="$(echo "$output" | grep -oE '(succeeded: [0-9]+|ℹ pass [0-9]+|pass [0-9]+)' | grep -oE '[0-9]+' | tail -n 1)"
    echo "PASSED   $repo${tests:+ ($tests tests)}"
  else
    echo "FAILED   $repo"
    echo "$output" | tail -n 20 | sed 's/^/         /'
    failed=1
  fi
done

exit $failed
