const express = require('express');
const { v4: uuidv4 } = require('uuid');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const port = 3000;
const HEARTBEAT_INTERVAL = 10000; // 30 seconds

// Create HTTP server and WebSocket server
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Middleware to parse JSON requests
app.use(express.json());

// In-memory data store
let activeSessions = {};
let colorSelections = {};

// Endpoint to register a user (increment active users)
app.post('/api/register', (req, res) => {
  const userId = req.body.userId || uuidv4(); // Generate or use provided UUID

  if (!activeSessions[userId]) {
    activeSessions[userId] = {
      color: null,
      lastHeartbeat: Date.now(),
    };
    broadcastActiveUsersCount(); // Broadcast the updated active users count
  }

  res.json({ userId }); // Return the userId to the client
});

// Endpoint to deregister a user (decrement active users)
app.post('/api/deregister', (req, res) => {
  const { userId } = req.body;

  if (userId && activeSessions[userId]) {
    delete activeSessions[userId];
    broadcastActiveUsersCount(); // Broadcast the updated active users count
  }

  res.sendStatus(200);
});

// Endpoint to submit color selection
app.post('/api/color', (req, res) => {
  const { userId, color } = req.body;

  if (userId && activeSessions[userId]) {
    const previousColor = activeSessions[userId].color;

    if (previousColor) {
      // Decrement the previous color count
      colorSelections[previousColor] = Math.max(0, (colorSelections[previousColor] || 1) - 1);
      if (colorSelections[previousColor] === 0) {
        delete colorSelections[previousColor];
      }
    }

    // Set the new color for the user
    activeSessions[userId].color = color;
    activeSessions[userId].lastHeartbeat = Date.now(); // Update the heartbeat time

    // Increment the new color count
    colorSelections[color] = (colorSelections[color] || 0) + 1;

    // Broadcast the updated color selections to all connected clients
    broadcastColorSelections();

    res.sendStatus(200);
  } else {
    res.status(400).send('User ID is required and must be registered');
  }
});

// Endpoint to receive heartbeat
app.post('/api/heartbeat', (req, res) => {
  const { userId } = req.body;

  if (userId && activeSessions[userId]) {
    activeSessions[userId].lastHeartbeat = Date.now();
    res.sendStatus(200);
  } else {
    res.status(400).send('User ID is required and must be registered');
  }
});

// Endpoint to get statistics
app.get('/api/statistics', (req, res) => {
  res.json({
    activeUsers: Object.keys(activeSessions).length,
    colorSelections,
  });
});

// WebSocket connection handler
wss.on('connection', (ws) => {
  console.log('New WebSocket connection');

  // Send current color selections and active users count to new client
  ws.send(JSON.stringify({ type: 'colorSelections', data: colorSelections }));
  ws.send(JSON.stringify({ type: 'activeUsers', data: Object.keys(activeSessions).length }));

  // Handle incoming messages (not needed in this case)
  ws.on('message', (message) => {
    console.log('Received:', message);
  });

  // Handle client disconnect
  ws.on('close', () => {
    console.log('WebSocket connection closed');
  });
});

// Broadcast the updated color selections to all connected clients
function broadcastColorSelections() {
  const message = JSON.stringify({ type: 'colorSelections', data: colorSelections });
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
}

// Broadcast the updated active users count to all connected clients
function broadcastActiveUsersCount() {
  const message = JSON.stringify({ type: 'activeUsers', data: Object.keys(activeSessions).length });
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
}

// Clean up inactive sessions (users that have not sent a heartbeat recently)
setInterval(() => {
  const now = Date.now();
  let usersChanged = false;
  for (const userId in activeSessions) {
    if (now - activeSessions[userId].lastHeartbeat > HEARTBEAT_INTERVAL) {
      // Remove inactive users
      const color = activeSessions[userId].color;
      if (color) {
        colorSelections[color] = Math.max(0, (colorSelections[color] || 1) - 1);
        if (colorSelections[color] === 0) {
          delete colorSelections[color];
        }
      }
      delete activeSessions[userId];
      usersChanged = true;
    }
  }

  if (usersChanged) {
    broadcastColorSelections(); // Update clients after cleanup
    broadcastActiveUsersCount(); // Broadcast the updated active users count
  }
}, HEARTBEAT_INTERVAL);

// Start the server
server.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${port}`);
});
