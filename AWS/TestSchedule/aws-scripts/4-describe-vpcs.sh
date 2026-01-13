# or go to VPC in console
aws ec2 describe-vpcs --query 'Vpcs[*].{ID:VpcId, Name:Tags[?Key==`Name`].Value|[0], CIDR:CidrBlock, State:State}' --output table