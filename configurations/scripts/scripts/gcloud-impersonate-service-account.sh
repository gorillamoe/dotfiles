#!/usr/bin/env bash

# First argument is wheter to activate or deactivate impersonation.
# Possible values are "true", "1", "false" and "0". Default value is "false".
#
# Second argument is the service account email to impersonate
# Example:
# ./gcloud-impersonate-service-account.sh true tsm-prod-sa@tb-web-werp-prod.iam.gserviceaccount.com
# ./gcloud-impersonate-service-account.sh false

IMPERSONATE=${1:-"false"}
SA_EMAIL=${2:-""}

help() {
  echo "Usage: $0 [true|1|false|0] [service-account-email]"
  echo
  echo "Example to use impersonation:"
  echo "  $0 true tsm-prod-sa@tb-web-werp-prod.iam.gserviceaccount.com"
  echo
  echo "Example to stop impersonation:"
  echo "  $0 false"
}

if [[ "$IMPERSONATE" == "false" ]] || [[ "$IMPERSONATE" == "0" ]]; then
  echo "Deactivating impersonation"
  gcloud config unset auth/impersonate_service_account
  read -p "Do you want to re-authenticate with your user credentials? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    gcloud auth application-default login
  else
    echo
    gcloud auth application-default revoke
  fi
  exit 0
fi

if [[ -z "$SA_EMAIL" ]]; then
  echo "Service account email is required when impersonation is activated"
  echo
  help
  exit 1
fi

gcloud config set auth/impersonate_service_account "$SA_EMAIL"
gcloud auth application-default login --impersonate-service-account "$SA_EMAIL"
