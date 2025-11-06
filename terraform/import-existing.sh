#!/bin/bash

echo "🔍 Checking for existing resources..."

# Get AWS region from variables
REGION="eu-north-1"
KEY_NAME="devops-automation-key"
SG_NAME="devops-automation-sg"

# Check if security group exists
SG_ID=$(aws ec2 describe-security-groups \
  --region $REGION \
  --filters "Name=group-name,Values=$SG_NAME" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null)

if [ "$SG_ID" != "None" ] && [ "$SG_ID" != "" ]; then
  echo "✅ Found existing security group: $SG_ID"
  echo "📥 Importing into Terraform state..."
  terraform import aws_security_group.app_sg "$SG_ID" 2>/dev/null || echo "Already in state"
else
  echo "ℹ️  No existing security group found"
fi

# Check if key pair exists
KEY_EXISTS=$(aws ec2 describe-key-pairs \
  --region $REGION \
  --key-names "$KEY_NAME" \
  --query 'KeyPairs[0].KeyName' \
  --output text 2>/dev/null)

if [ "$KEY_EXISTS" == "$KEY_NAME" ]; then
  echo "✅ Found existing key pair: $KEY_NAME"
  echo "📥 Importing into Terraform state..."
  terraform import aws_key_pair.app_key "$KEY_NAME" 2>/dev/null || echo "Already in state"
else
  echo "ℹ️  No existing key pair found"
fi

echo "✅ Import check complete!"
