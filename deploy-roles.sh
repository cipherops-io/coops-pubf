#!/bin/sh

set -e

TEMPLATE_URL="https://raw.githubusercontent.com/cipherops-io/coops-pubf/main/coops-roles.yaml"

usage() {
  echo "Usage: $0 <iac_role_arn> <unique_id> <external_id> <stack_name>"
  echo "Example: $0 arn:aws:iam::1234567890:role/coops-12345-xxxx-iac-role 12345 MTIzNDU= coops-roles"
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
echo "  IacRoleArn: $IAC_ROLE_ARN"
echo "  UniqueId: $UNIQUE_ID"
echo "  ExternalId: $EXTERNAL_ID"
echo "  StackName: $STACK_NAME"
echo "  TemplateFile: $TEMPLATE_FILE"

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

echo "Deployment complete."
