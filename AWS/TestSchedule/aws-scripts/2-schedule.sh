#!/bin/bash

#get vpc and subjets from aws-scripts/4-describe-vpcs.sh and aws-scripts/3-describesubnets.sh

REGION=us-east-1
ACCOUNT_ID=984778981719
CLUSTER=hello-cluster
TASK_DEF=hello-task
SUBNET_ID=subnet-09c66d8a572fbdf4a
SG_ID=sg-0c053c4e6ff1074f2

# Create EventBridge rule
aws events put-rule --name "run-hello-daily" --schedule-expression "rate(24 hours)" --state ENABLED --region ${REGION}

# Add target
TARGETS_JSON=$(cat <<EOF
[
    {
        "Id": "1",
        "Arn": "arn:aws:ecs:${REGION}:${ACCOUNT_ID}:cluster/${CLUSTER}",
        "RoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ecsEventsRole",
        "EcsParameters": {
            "TaskDefinitionArn": "arn:aws:ecs:${REGION}:${ACCOUNT_ID}:task-definition/${TASK_DEF}",
            "TaskCount": 1,
            "LaunchType": "FARGATE",
            "NetworkConfiguration": {
                "awsvpcConfiguration": {
                    "Subnets": [
                        "${SUBNET_ID}"
                    ],
                    "SecurityGroups": [
                        "${SG_ID}"
                    ],
                    "AssignPublicIp": "ENABLED"
                }
            }
        }
    }
]
EOF
)

aws events put-targets --rule "run-hello-daily" --targets "$TARGETS_JSON" --region ${REGION}