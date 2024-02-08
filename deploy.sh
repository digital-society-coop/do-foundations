#!/usr/bin/env bash

set -euo pipefail

function usage {
  echo "Usage: $0 <env>" >&2
  exit 1
}

service=do-foundations

[[ $# -ge 1 ]] || usage
environment=$1
shift

echo "Deploying $service-$environment... " >&2
echo >&2

eval "$(./terraform-env.sh "$service" "$environment")"

# shellcheck disable=SC2154
echo -n "- Creating $stateBucket... " >&2
if ! result="$(aws s3api create-bucket --bucket "$stateBucket" 2>&1)" ; then
  if [[ "$result" =~ BucketAlreadyExists ]]; then
		: # continue
  else
    echo 'failed' >&2
    echo >&2
    echo "$result" >&2
    exit 1
  fi
fi
echo 'done' >&2

echo -n "- Initialising terraform... " >&2
if ! result="$(terraform init -input=false -lockfile=readonly)"; then
	echo 'failed' >&2
	echo >&2
	echo "$result" >&2
	exit 1
fi
echo 'done' >&2

echo -n "- Running terraform apply... " >&2
if ! result="$(terraform apply -auto-approve -input=false)"; then
	echo 'failed' >&2
	echo >&2
	echo "$result" >&2
	exit 1
fi
echo 'done' >&2

echo >&2
echo 'Deployment complete' >&2
