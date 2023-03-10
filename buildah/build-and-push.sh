#!/bin/bash

set -eo pipefail
source ../aws/utils.sh

ensure_aws_cli() {
    if ! which aws >/dev/null 2>&1; then
        echo "AWS CLI not installed, exiting.";
        exit 1;
    fi
}

# Registry must be deployed already. This registry name is an example.
REGISTRY=0000000000000.dkr.ecr.us-east-1.amazonaws.com
REPOSITORY=${REGISTRY}/$(get_physical_resource_id artifacts-stack ArtifactsRepository)
IMAGE=${REPOSITORY}:some-image

ensure_aws_cli
# Login to the registry with buildah
aws ecr get-login-password --region us-east-1 | buildah login --tls-verify=false -u AWS --password-stdin ${REGISTRY}

# Run the following in the folder containing the Dockerfile
buildah bud -t ${IMAGE} -f Dockerfile --format docker .
buildah push --tls-verify=false ${IMAGE}

