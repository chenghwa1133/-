/**
 * Payment Service
 * Handles Korean payment gateway integrations
 */

const { generateOrderId, validateAmount, formatCurrency } = require('../utils/helpers');

class PaymentService {
  constructor() {
    this.supportedGateways = ['inicis', 'kg', 'nice', 'toss', 'kakao'];
    this.transactions = new Map();
  }

  /**
   * Initialize a payment request
   * @param {Object} paymentData - Payment request data
   * @returns {Object} Payment initialization result
   */
  async initializePayment(paymentData) {
    const { gateway, amount, currency = 'KRW', orderId, productName, customerName } = paymentData;

    if (!this.supportedGateways.includes(gateway)) {
      throw new Error(`Unsupported payment gateway: ${gateway}`);
    }

    if (!validateAmount(amount)) {
      throw new Error('Invalid payment amount');
    }

    const transactionId = generateOrderId();
    const transaction = {
      transactionId,
      orderId: orderId || generateOrderId(),
      gateway,
      amount,
      currency,
      productName,
      customerName,
      status: 'initialized',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    this.transactions.set(transactionId, transaction);

    return {
      success: true,
      transactionId,
      orderId: transaction.orderId,
      formattedAmount: formatCurrency(amount, currency),
      message: 'Payment initialized successfully'
    };
  }

  /**
   * Process a payment
   * @param {string} transactionId - Transaction ID
   * @param {Object} paymentDetails - Payment details from gateway
   * @returns {Object} Payment processing result
   */
  async processPayment(transactionId, paymentDetails) {
    const transaction = this.transactions.get(transactionId);

    if (!transaction) {
      throw new Error('Transaction not found');
    }

    if (transaction.status !== 'initialized') {
      throw new Error('Invalid transaction status for processing');
    }

    // Simulate payment processing
    transaction.status = 'processing';
    transaction.updatedAt = new Date().toISOString();
    transaction.paymentDetails = paymentDetails;

    // In a real implementation, this would call the actual payment gateway API
    transaction.status = 'completed';
    transaction.completedAt = new Date().toISOString();
    transaction.updatedAt = new Date().toISOString();

    return {
      success: true,
      transactionId,
      status: transaction.status,
      message: 'Payment processed successfully'
    };
  }

  /**
   * Get transaction status
   * @param {string} transactionId - Transaction ID
   * @returns {Object} Transaction status
   */
  async getTransactionStatus(transactionId) {
    const transaction = this.transactions.get(transactionId);

    if (!transaction) {
      throw new Error('Transaction not found');
    }

    return {
      transactionId,
      orderId: transaction.orderId,
      status: transaction.status,
      amount: transaction.amount,
      currency: transaction.currency,
      gateway: transaction.gateway,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt
    };
  }

  /**
   * Cancel a payment
   * @param {string} transactionId - Transaction ID
   * @param {string} reason - Cancellation reason
   * @returns {Object} Cancellation result
   */
  async cancelPayment(transactionId, reason) {
    const transaction = this.transactions.get(transactionId);

    if (!transaction) {
      throw new Error('Transaction not found');
    }

    if (transaction.status === 'cancelled') {
      throw new Error('Transaction already cancelled');
    }

    transaction.status = 'cancelled';
    transaction.cancellationReason = reason;
    transaction.cancelledAt = new Date().toISOString();
    transaction.updatedAt = new Date().toISOString();

    return {
      success: true,
      transactionId,
      status: 'cancelled',
      message: 'Payment cancelled successfully'
    };
  }

  /**
   * Get list of supported payment gateways
   * @returns {Array} List of supported gateways
   */
  getSupportedGateways() {
    return this.supportedGateways.map(gateway => ({
      id: gateway,
      name: this.getGatewayDisplayName(gateway)
    }));
  }

  /**
   * Get display name for gateway
   * @param {string} gateway - Gateway ID
   * @returns {string} Gateway display name
   */
  getGatewayDisplayName(gateway) {
    const names = {
      inicis: 'KG이니시스',
      kg: 'KG모빌리언스',
      nice: 'NICE페이먼츠',
      toss: '토스페이먼츠',
      kakao: '카카오페이'
    };
    return names[gateway] || gateway;
  }
}

module.exports = PaymentService;
