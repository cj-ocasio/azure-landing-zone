#!/usr/bin/env bash
# Copy to scripts/env.local.sh (gitignored), replace every <placeholder>, then:
#   source scripts/env.local.sh

export PREFIX="<prefix>"

# Tenant
export ARM_TENANT_ID="<tenant-guid>"
export TF_VAR_tenant_id="${ARM_TENANT_ID}"

# Subscriptions. ARM_SUBSCRIPTION_ID is the platform subscription that holds Terraform state.
export ARM_SUBSCRIPTION_ID="<platform-subscription-guid>"
export TF_VAR_platform_subscription_id="${ARM_SUBSCRIPTION_ID}"
export TF_VAR_lz_dev_subscription_id="<lz-dev-subscription-guid>"
export TF_VAR_lz_prod_subscription_id="<lz-prod-subscription-guid>"

# Remote state. Fill these in after Phase B1 has produced its outputs.
export TF_VAR_tfstate_resource_group_name="rg-${PREFIX}-tfstate"
export TF_VAR_tfstate_storage_account_name="<state-storage-account-name>"
export TF_VAR_tfstate_container_name="tfstate"
