#!/usr/bin/env bash
# Usage: STACK=stacks/10-governance [VAR_FILE=env/dev.tfvars] [TF_ACTION=destroy] scripts/tf-plan.sh
# Exit codes from terraform -detailed-exitcode: 0 = no changes, 1 = error, 2 = changes present.
set -uo pipefail

: "${STACK:?STACK must point at a root module directory}"

args=(plan -input=false -lock-timeout=5m -detailed-exitcode -no-color -out=tfplan)
if [[ -n "${VAR_FILE:-}" ]]; then
  args+=("-var-file=${VAR_FILE}")
fi
if [[ "${TF_ACTION:-apply}" == "destroy" ]]; then
  args+=("-destroy")
fi

terraform -chdir="${STACK}" "${args[@]}" | tee "${STACK}/plan.txt"
exit_code=${PIPESTATUS[0]}

case "${exit_code}" in
  0) has_changes=false ;;
  2) has_changes=true ;;
  *)
    echo "terraform plan failed with exit code ${exit_code}" >&2
    exit "${exit_code}"
    ;;
esac

echo "has_changes=${has_changes}"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "has_changes=${has_changes}" >> "${GITHUB_OUTPUT}"
fi

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "### ${STACK}: ${TF_ACTION:-apply} plan"
    echo
    echo '```'
    grep -E '^(Plan:|No changes\.|Changes to Outputs:)' "${STACK}/plan.txt" || echo "See the job log for the full plan."
    echo '```'
  } >> "${GITHUB_STEP_SUMMARY}"
fi
