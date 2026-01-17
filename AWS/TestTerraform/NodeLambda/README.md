# Node.js AWS Lambda

This folder contains a simple AWS Lambda function written in Node.js.

## Handler
- Entry point: `index.js`
- Handler: `exports.handler`

## Usage
Package the code as a zip file for deployment:

```sh
zip -r node_lambda.zip index.js package.json
```

Update your Terraform configuration to deploy this Lambda if needed.
