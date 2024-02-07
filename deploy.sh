#!/usr/bin/env bash

set -euo pipefail

function usage {
  echo "Usage: $0 <env>" >&2
  exit 1
}

service=foundation

[[ $# -ge 1 ]] || usage
environment=$1
shift

echo "Deploying $service-$environment... " >&2
echo >&2

stateBucket="$environment-$service-terraform"
stateKey="$service/$environment.tfstate"

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

tfCliArgsInit=(
	"-backend-config=region=${AWS_REGION:-"$(aws configure get region)"}"
	"-backend-config=bucket=$stateBucket"
	"-backend-config=key=$stateKey"
)

export TF_CLI_ARGS=-input=false
export TF_CLI_ARGS_init="${tfCliArgsInit[@]}"

echo -n "- Initialising terraform with backend s3://$stateBucket/$stateKey... " >&2
if ! result="$(terraform init -reconfigure)"; then
	echo 'failed' >&2
	echo >&2
	echo "$result" >&2
	exit 1
fi
echo 'done' >&2

echo -n "- Running terraform apply... " >&2
if ! result="$(terraform apply)"; then
	echo 'failed' >&2
	echo >&2
	echo "$result" >&2
	exit 1
fi
echo 'done' >&2

echo >&2
echo 'Deployment complete' >&2
