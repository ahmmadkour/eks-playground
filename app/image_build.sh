#!/bin/bash

set -e

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
AWS_REGION=$1

if [[ $# -gt 1 ]]
then
    echo "wrong arguments supplied"
    echo "usage:"
    echo -e "\t image_build.sh [AWS_REGION]"
    exit 1
fi

if [[ -z "$1" ]]
then
    AWS_REGION="us-east-1"
fi

echo "AWS account id: $AWS_ACCOUNT_ID"
echo "AWS region region: $AWS_REGION"
echo

echo "Logging to AWS ECR"
aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "Build the docker image ..."
docker build --tag app .
echo

ecr="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/app:v1.0"

echo "Tag the image to $ecr"
docker image tag app:latest $ecr
echo

echo "Push the image to docker push $ecr"
docker push $ecr
