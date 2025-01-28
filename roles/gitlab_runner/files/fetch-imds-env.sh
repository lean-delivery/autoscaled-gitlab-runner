#!/bin/sh

# This script fetches the IMDSv2 token and writes variables to /etc/default/monitor-jobs

# 1. Fetch the IMDSv2 token
TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
       -s http://169.254.169.254/latest/api/token)

# 2. Write environment variables
cat <<EOF > /etc/default/monitor-jobs
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
                http://169.254.169.254/latest/dynamic/instance-identity/document \
              | jq -r .instanceId)

INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
                  http://169.254.169.254/latest/dynamic/instance-identity/document \
                | jq -r .instanceType)

ASG=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
       http://169.254.169.254/latest/meta-data/tags/instance/aws:autoscaling:groupName)
EOF