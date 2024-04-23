# dagster_deployment_aws_ecs
Deploy multiple Dagster data pipelines on Docker environment 

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text | cut -f1)
export AWS_REGION=eu-central-1
export REGISTRY_URL=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REGISTRY_URL
