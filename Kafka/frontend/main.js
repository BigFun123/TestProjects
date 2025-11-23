async function sendMessageToKafka(topic, message) {
    try {
        const response = await fetch('http://localhost:3000/api/send', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                topic,
                message
            })
        });

        const data = await response.json();
        
        if (response.ok) {
            console.log('Message sent successfully:', data);
            return data;
        } else {
            console.error('Error sending message:', data);
            throw new Error(data.error);
        }
    } catch (error) {
        console.error('Failed to send message:', error);
        throw error;
    }
}

function showStatus(message, isError = false) {
    const statusDiv = document.getElementById('status');
    statusDiv.textContent = message;
    statusDiv.className = isError ? 'error' : 'success';
    setTimeout(() => {
        statusDiv.textContent = '';
        statusDiv.className = '';
    }, 5000);
}

async function sendMessage() {
    const topic = document.getElementById('topic').value;
    const messageText = document.getElementById('message').value;
    
    if (!topic || !messageText) {
        showStatus('Please fill in both topic and message', true);
        return;
    }
    
    try {
        // Try to parse as JSON, otherwise send as string
        let message;
        try {
            message = JSON.parse(messageText);
        } catch {
            message = { text: messageText, timestamp: new Date().toISOString() };
        }
        
        await sendMessageToKafka(topic, message);
        showStatus('Message sent successfully to Kafka!');
        document.getElementById('message').value = '';
    } catch (error) {
        showStatus('Failed to send message: ' + error.message, true);
    }
}
