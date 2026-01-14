import * as https from 'node:https';
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';


/**
 * Pass the data to send as `event.data`, and the request options as
 * `event.options`. For more information see the HTTPS module documentation
 * at https://nodejs.org/api/https.html.
 *
 * Will succeed with the response body.
 */

export const handler = async (event, context) => {
    const client = new SecretsManagerClient({ region: process.env.AWS_REGION || 'us-east-1' });

    const secretName = event.secretName ?? 'secrets'; // Change to your secret name
    let secretValue;

    try {
        const command = new GetSecretValueCommand({ SecretId: secretName });
        const response = await client.send(command);
        secretValue = response.SecretString; // Use SecretBinary if it's binary
        console.log('Secret retrieved successfully', secretValue);
    } catch (error) {
        console.error('Error retrieving secret:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Failed to retrieve secret' })
        };
    }

    // add secretValue to headers in APIKey (event.options.headers)
    event.options.headers = {
        ...event.options.headers,
        'APIKey': secretValue,
        "EX-Tenant-Id": "120"
    };

    return new Promise((resolve, reject) => {
        const req = https.request(event.options, (res) => {
            let body = '';
            console.log('Status:', res.statusCode);
            console.log('Headers:', JSON.stringify(res.headers));        
            res.setEncoding('utf8');
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                console.log('Successfully processed HTTPS response');
                // If we know it's JSON, parse it
                if (res.headers['content-type'] === 'application/json') {
                    body = JSON.parse(body);
                }
                console.log('Response JSON:', JSON.stringify(body, null, 2));
                resolve(body);
            });
        });
        req.on('error', (error) => { 
            console.error('Request error:', error);
            reject(error);
        });
        // Fix: Only write data if it exists and is not null
        if (event?.data !== null && event?.data !== undefined) {
            const dataToWrite = JSON.stringify(event.data);
            if (dataToWrite && dataToWrite !== 'null') {
                req.write(dataToWrite);
            }
        }
        req.end();
    });
};
