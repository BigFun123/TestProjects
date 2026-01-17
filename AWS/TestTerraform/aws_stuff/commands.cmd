aws iam list-user-policies --user-name dev
aws iam list-attached-user-policies --user-name dev
aws iam list-policies --scope Local --query 'Policies[?contains(PolicyName, `Lambda`) || contains(PolicyName, `Terraform`)]'