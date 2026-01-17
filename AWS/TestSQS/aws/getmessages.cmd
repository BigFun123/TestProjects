REM Get messages from AWS SQS queue

REM Set your queue URL here
set QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/984778981719/testquee

REM Get messages from the queue
aws sqs receive-message ^
    --queue-url %QUEUE_URL% ^
    --region eu-west-1 ^
    --max-number-of-messages 10 ^
    --visibility-timeout 30 ^
    --wait-time-seconds 20 ^
    --attribute-names All ^
    --message-attribute-names All

REM Optional: Parse and display messages more cleanly
REM aws sqs receive-message --queue-url %QUEUE_URL% --query "Messages[*].[MessageId,Body]" --output table