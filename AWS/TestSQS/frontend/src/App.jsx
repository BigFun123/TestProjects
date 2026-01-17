import { useState, useEffect, useCallback } from 'react';
import {
  ThemeProvider,
  createTheme,
  CssBaseline,
  Container,
  Grid,
  List,
  ListItem,
  ListItemText,
  TextField,
  Button,
  Typography,
  Box,
  Paper,
} from '@mui/material';
import RefreshIcon from '@mui/icons-material/Refresh';
import SendIcon from '@mui/icons-material/Send';

const theme = createTheme();

function App() {
  const [messages, setMessages] = useState([]);
  const [selectedMessage, setSelectedMessage] = useState(null);
  const [editedBody, setEditedBody] = useState('');
  const [newMessageBody, setNewMessageBody] = useState('');
  const [deleting, setDeleting] = useState(false);
  // Delete selected message from the queue
  const handleDeleteMessage = async () => {
    if (!selectedMessage) return;
    setDeleting(true);
    try {
      // Adjust endpoint as needed for your backend
      const response = await fetch('/api/SQS/delete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ receiptHandle: selectedMessage.receiptHandle })
      });
      if (response.ok) {
        setMessages((msgs) => msgs.filter(m => m.receiptHandle !== selectedMessage.receiptHandle));
        setSelectedMessage(null);
      } else {
        alert('Failed to delete message.');
      }
    } catch (err) {
      alert('Error deleting message.');
    } finally {
      setDeleting(false);
    }
  };

  const fetchMessages = useCallback(async () => {
    try {
      const response = await fetch('/api/SQS/messages');
      const data = await response.json();
      console.log(data);
      setMessages(data);
    } catch (error) {
      console.error('Error fetching messages:', error);
    }
  }, []);


  useEffect(() => {
    fetchMessages();
  }, [fetchMessages]);

  const handleSelectMessage = (message) => {
    setSelectedMessage(message);
    setEditedBody(message.body || '');
  };

  const handleSendEditedMessage = async () => {
    if (!editedBody.trim()) return;
    try {
      await fetch('/api/SQS/sendmessage', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ Body: editedBody }),
      });
      setEditedBody('');
      setSelectedMessage(null);
      fetchMessages(); // Refresh
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  const handleSendNewMessage = async () => {
    if (!newMessageBody.trim()) return;
    try {
      await fetch('/api/SQS/sendmessage', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ Body: newMessageBody }),
      });
      setNewMessageBody('');
      fetchMessages(); // Refresh
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Typography variant="h4" gutterBottom>
          SQS Message Manager
        </Typography>
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 2 }}>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                <Typography variant="h6">Messages</Typography>
                <Button
                  variant="outlined"
                  startIcon={<RefreshIcon />}
                  onClick={fetchMessages}
                >
                  Refresh
                </Button>
              </Box>
              <List>
                {messages.map((msg, index) => (
                  <ListItem
                    key={msg.messageId || index}
                    button
                    selected={selectedMessage?.messageId === msg.messageId}
                    onClick={() => handleSelectMessage(msg)}
                  >
                    <ListItemText
                      primary={msg.body ? (msg.body.substring(0, 50) + (msg.body.length > 50 ? '...' : '')) : 'No body'}
                      secondary={`ID: ${msg.messageId || 'Unknown'}`}
                    />
                  </ListItem>
                ))}
              </List>
            </Paper>
          </Grid>
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 2 }}>
              {selectedMessage ? (
                <>
                  <Typography variant="h6" gutterBottom>
                    Edit Selected Message
                  </Typography>
                  <TextField
                    fullWidth
                    multiline
                    rows={4}
                    value={editedBody}
                    onChange={(e) => setEditedBody(e.target.value)}
                    variant="outlined"
                    sx={{ mb: 2 }}
                  />
                  <Box display="flex" gap={2}>
                    <Button
                      variant="contained"
                      startIcon={<SendIcon />}
                      onClick={handleSendEditedMessage}
                    >
                      Send as New Message
                    </Button>
                    <Button
                      variant="outlined"
                      color="error"
                      onClick={handleDeleteMessage}
                      disabled={deleting}
                    >
                      {deleting ? 'Deleting...' : 'Delete Message'}
                    </Button>
                  </Box>
                </>
              ) : (
                <>
                  <Typography variant="h6" gutterBottom>
                    Send New Message
                  </Typography>
                  <TextField
                    fullWidth
                    multiline
                    rows={4}
                    value={newMessageBody}
                    onChange={(e) => setNewMessageBody(e.target.value)}
                    variant="outlined"
                    sx={{ mb: 2 }}
                  />
                  <Button
                    variant="contained"
                    startIcon={<SendIcon />}
                    onClick={handleSendNewMessage}
                  >
                    Send Message
                  </Button>
                </>
              )}
            </Paper>
          </Grid>
        </Grid>
      </Container>
    </ThemeProvider>
  );
}

export default App;
