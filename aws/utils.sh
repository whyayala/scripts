#!/bin/bash

get_physical_resource_id() {
    STACK_NAME="$1"
    LOGICAL_RESOURCE_ID="$2"
    aws cloudformation describe-stack-resources \
        --stack-name=$STACK_NAME \
        --logical-resource-id=$LOGICAL_RESOURCE_ID \
        --query='StackResources[0].PhysicalResourceId' \
        --output=text
}

get_admin_public_dns() {
    aws ec2 describe-network-interfaces \
    --network-interface-ids "$(get_physical_resource_id contact-center-sbc PrimaryAdminNic)" \
    --query='NetworkInterfaces[*].PrivateIpAddresses[].Association.PublicDnsName | [0]' \
    --output=text
}
