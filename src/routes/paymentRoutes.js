/**
 * Payment Routes
 * HTTP route handlers for payment operations
 */

const PaymentService = require('../services/paymentService');

const paymentService = new PaymentService();

/**
 * Parse JSON body from request
 * @param {Object} req - HTTP request
 * @returns {Promise<Object>} Parsed JSON body
 */
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (error) {
        reject(new Error('Invalid JSON body'));
      }
    });
    req.on('error', reject);
  });
}

/**
 * Send JSON response
 * @param {Object} res - HTTP response
 * @param {number} statusCode - HTTP status code
 * @param {Object} data - Response data
 */
function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data));
}

/**
 * Handle incoming HTTP requests
 * @param {Object} req - HTTP request
 * @param {Object} res - HTTP response
 */
async function handleRequest(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const path = url.pathname;
  const method = req.method;

  try {
    // Health check endpoint
    if (path === '/health' && method === 'GET') {
      return sendJson(res, 200, { status: 'healthy', timestamp: new Date().toISOString() });
    }

    // Get supported gateways
    if (path === '/api/gateways' && method === 'GET') {
      const gateways = paymentService.getSupportedGateways();
      return sendJson(res, 200, { success: true, gateways });
    }

    // Initialize payment
    if (path === '/api/payment/initialize' && method === 'POST') {
      const body = await parseBody(req);
      const result = await paymentService.initializePayment(body);
      return sendJson(res, 200, result);
    }

    // Process payment
    if (path === '/api/payment/process' && method === 'POST') {
      const body = await parseBody(req);
      const { transactionId, ...paymentDetails } = body;
      const result = await paymentService.processPayment(transactionId, paymentDetails);
      return sendJson(res, 200, result);
    }

    // Get transaction status
    if (path.startsWith('/api/payment/status/') && method === 'GET') {
      const transactionId = path.split('/').pop();
      const result = await paymentService.getTransactionStatus(transactionId);
      return sendJson(res, 200, { success: true, transaction: result });
    }

    // Cancel payment
    if (path === '/api/payment/cancel' && method === 'POST') {
      const body = await parseBody(req);
      const { transactionId, reason } = body;
      const result = await paymentService.cancelPayment(transactionId, reason);
      return sendJson(res, 200, result);
    }

    // API documentation
    if (path === '/' && method === 'GET') {
      return sendJson(res, 200, {
        name: 'Korea Payment API',
        version: '1.0.0',
        endpoints: [
          { method: 'GET', path: '/health', description: 'Health check' },
          { method: 'GET', path: '/api/gateways', description: 'Get supported payment gateways' },
          { method: 'POST', path: '/api/payment/initialize', description: 'Initialize a payment' },
          { method: 'POST', path: '/api/payment/process', description: 'Process a payment' },
          { method: 'GET', path: '/api/payment/status/:transactionId', description: 'Get transaction status' },
          { method: 'POST', path: '/api/payment/cancel', description: 'Cancel a payment' }
        ]
      });
    }

    // 404 Not Found
    sendJson(res, 404, { error: 'Not Found', message: 'Endpoint not found' });
  } catch (error) {
    console.error('Request error:', error.message);
    sendJson(res, 400, { error: 'Bad Request', message: error.message });
  }
}

module.exports = { handleRequest };
