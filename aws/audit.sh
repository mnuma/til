#!/bin/bash

function list_policies() {
    POLICIES=$(aws iam list-policies --only-attached --query "Policies[*].{name: PolicyName, version: DefaultVersionId, arn: Arn}")

    echo $POLICIES | jq -c '.[]' | \
    while read policy; do
        POLICY_NAME=$(echo $policy | jq -r '.name')
        POLICY_ARN=$(echo $policy | jq -r '.arn')
        POLICY_VERSION=$(echo $policy | jq -r '.version')

        echo "[DEBUG]" $POLICY_NAME, $POLICY_ARN, $POLICY_VERSION
        POLICY=$(aws iam get-policy-version --policy-arn $POLICY_ARN --version-id $POLICY_VERSION --query "PolicyVersion.Document.Statement[?Effect == 'Allow' && contains(Resource, '*') && contains (Action, '*')]" --output text)
        
        if [[ -n $POLICY ]]; then
            echo "[INFO]" $POLICY_NAME, $POLICY_ARN, $POLICY_VERSION
            echo $POLICY
        fi
        
        # break;
    done
}

list_policies
