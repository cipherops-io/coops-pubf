#!/bin/sh

set -e

TEMPLATE_URL="https://raw.githubusercontent.com/cipherops-io/coops-pubf/main/coops-roles.yaml"

usage() {
  echo "Usage: $0 <iac_role_arn> <unique_id> <external_id_uuid> <stack_name>"
  echo "Example: $0 arn:aws:iam::1234567890:role/coops-12345-xxxx-iac-role 12345 123e4567-e89b-12d3-a456-426614174000 coops-orchestrator"
  exit 1
}

if [ "$#" -ne 4 ]; then
  usage
fi

IAC_ROLE_ARN="$1"
UNIQUE_ID="$2"
EXTERNAL_ID="$3"
STACK_NAME="$4"

TEMPLATE_FILE="cf-template-$$.yaml"

echo "Downloading CloudFormation template from $TEMPLATE_URL..."
curl -fsSL "$TEMPLATE_URL" -o "$TEMPLATE_FILE"

echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    IacRoleArn="$IAC_ROLE_ARN" \
    UniqueId="$UNIQUE_ID" \
    ExternalId="$EXTERNAL_ID"

echo "Cleaning up..."
rm -f "$TEMPLATE_FILE"

# Fetch and print the Orchestrator Role ARN for user copy-paste
ORCH_ARN=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='OrchestratorRoleArn'].OutputValue" --output text)

echo ""
echo "=============================="
echo "Orchestrator Role ARN: $ORCH_ARN"
echo "=============================="
echo ""
echo "Copy and paste the above ARN into the UI as instructed."
