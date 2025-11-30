/**
 * Korea Payment Application
 * Main entry point for the Korean payment processing service
 */

const http = require('http');
const PaymentService = require('./services/paymentService');
const PaymentRoutes = require('./routes/paymentRoutes');

const PORT = process.env.PORT || 3000;

/**
 * Simple HTTP server for handling payment requests
 */
const server = http.createServer((req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Route handling
  PaymentRoutes.handleRequest(req, res);
});

server.listen(PORT, () => {
  console.log(`Korea Payment Server running on port ${PORT}`);
});

module.exports = server;
