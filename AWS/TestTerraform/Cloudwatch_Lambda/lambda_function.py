import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    Process messages from SQS queue
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    for record in event['Records']:
        try:
            # Process the message
            message_body = record['body']
            logger.info(f"Processing message: {message_body}")
            
            # Add your message processing logic here
            
            logger.info(f"Successfully processed message")
            
        except Exception as e:
            logger.error(f"Error processing message: {str(e)}")
            raise e
    
    return {
        'statusCode': 200,
        'body': json.dumps('Messages processed successfully')
    }
