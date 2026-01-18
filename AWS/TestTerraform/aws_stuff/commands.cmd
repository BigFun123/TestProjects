aws iam list-user-policies --user-name dev
aws iam list-attached-user-policies --user-name dev
aws iam list-policies --scope Local --query 'Policies[?contains(PolicyName, `Lambda`) || contains(PolicyName, `Terraform`)]'

terraform fmt -check -recursive
terraform validate

// checks with AWS but does not make changes
terraform plan
terraform plan -out=tfplan
terraform apply "tfplan"

aws lambda invoke \
  --region eu-west-1 \
  --function-name node_lambda \
  response.json
