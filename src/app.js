const express = require('express');
const app = express();

app.use(express.json());

// Health check endpoint (used by Docker and Jenkins)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0',
  });
});

// Home route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to MyApp API',
    env: process.env.NODE_ENV || 'development',
  });
});

// Sample API route
app.get('/api/users', (req, res) => {
  res.json([
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' },
  ]);
});

module.exports = app;
