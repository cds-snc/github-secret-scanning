#!/bin/sh
#!/bin/sh
echo "Retrieving environment parameters"
aws ssm get-parameters --region ca-central-1 --with-decryption --names github-secret-scanning-config --query 'Parameters[*].Value' --output text > ".env"

echo "Starting lambda handler"
exec /usr/local/bin/python -m awslambdaric "$1"
