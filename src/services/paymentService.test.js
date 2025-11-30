/**
 * Tests for Payment Service
 */

const { test, describe } = require('node:test');
const assert = require('node:assert');
const PaymentService = require('./paymentService');

describe('PaymentService', () => {
  describe('initializePayment', () => {
    test('should initialize payment successfully', async () => {
      const service = new PaymentService();
      const result = await service.initializePayment({
        gateway: 'toss',
        amount: 10000,
        productName: 'Test Product',
        customerName: 'Test Customer'
      });

      assert.strictEqual(result.success, true);
      assert.ok(result.transactionId);
      assert.ok(result.orderId);
    });

    test('should throw error for unsupported gateway', async () => {
      const service = new PaymentService();
      await assert.rejects(
        service.initializePayment({
          gateway: 'unsupported',
          amount: 10000
        }),
        /Unsupported payment gateway/
      );
    });

    test('should throw error for invalid amount', async () => {
      const service = new PaymentService();
      await assert.rejects(
        service.initializePayment({
          gateway: 'toss',
          amount: -100
        }),
        /Invalid payment amount/
      );
    });
  });

  describe('processPayment', () => {
    test('should process payment successfully', async () => {
      const service = new PaymentService();
      const initResult = await service.initializePayment({
        gateway: 'kakao',
        amount: 5000,
        productName: 'Test'
      });

      const processResult = await service.processPayment(
        initResult.transactionId,
        { cardNumber: '****' }
      );

      assert.strictEqual(processResult.success, true);
      assert.strictEqual(processResult.status, 'completed');
    });

    test('should throw error for non-existent transaction', async () => {
      const service = new PaymentService();
      await assert.rejects(
        service.processPayment('non-existent-id', {}),
        /Transaction not found/
      );
    });
  });

  describe('getTransactionStatus', () => {
    test('should return transaction status', async () => {
      const service = new PaymentService();
      const initResult = await service.initializePayment({
        gateway: 'nice',
        amount: 15000
      });

      const status = await service.getTransactionStatus(initResult.transactionId);
      assert.strictEqual(status.status, 'initialized');
      assert.strictEqual(status.amount, 15000);
    });
  });

  describe('cancelPayment', () => {
    test('should cancel payment successfully', async () => {
      const service = new PaymentService();
      const initResult = await service.initializePayment({
        gateway: 'inicis',
        amount: 20000
      });

      const cancelResult = await service.cancelPayment(
        initResult.transactionId,
        'Customer request'
      );

      assert.strictEqual(cancelResult.success, true);
      assert.strictEqual(cancelResult.status, 'cancelled');
    });

    test('should throw error for already cancelled transaction', async () => {
      const service = new PaymentService();
      const initResult = await service.initializePayment({
        gateway: 'kg',
        amount: 8000
      });

      await service.cancelPayment(initResult.transactionId, 'First cancel');

      await assert.rejects(
        service.cancelPayment(initResult.transactionId, 'Second cancel'),
        /Transaction already cancelled/
      );
    });
  });

  describe('getSupportedGateways', () => {
    test('should return list of supported gateways', () => {
      const service = new PaymentService();
      const gateways = service.getSupportedGateways();

      assert.ok(Array.isArray(gateways));
      assert.ok(gateways.length > 0);
      assert.ok(gateways.some(g => g.id === 'toss'));
      assert.ok(gateways.some(g => g.id === 'kakao'));
    });
  });
});
