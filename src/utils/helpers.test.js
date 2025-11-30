/**
 * Tests for Helper utilities
 */

const { test, describe } = require('node:test');
const assert = require('node:assert');
const {
  generateOrderId,
  validateAmount,
  formatCurrency,
  validateEmail,
  validateKoreanPhone,
  maskCardNumber
} = require('./helpers');

describe('Helper utilities', () => {
  describe('generateOrderId', () => {
    test('should generate unique order IDs', () => {
      const id1 = generateOrderId();
      const id2 = generateOrderId();
      assert.notStrictEqual(id1, id2);
    });

    test('should start with ORD-', () => {
      const id = generateOrderId();
      assert.ok(id.startsWith('ORD-'));
    });

    test('should be uppercase', () => {
      const id = generateOrderId();
      assert.strictEqual(id, id.toUpperCase());
    });
  });

  describe('validateAmount', () => {
    test('should return true for positive numbers', () => {
      assert.strictEqual(validateAmount(100), true);
      assert.strictEqual(validateAmount(1), true);
      assert.strictEqual(validateAmount(99999), true);
    });

    test('should return false for zero', () => {
      assert.strictEqual(validateAmount(0), false);
    });

    test('should return false for negative numbers', () => {
      assert.strictEqual(validateAmount(-1), false);
      assert.strictEqual(validateAmount(-100), false);
    });

    test('should return false for non-numbers', () => {
      assert.strictEqual(validateAmount('100'), false);
      assert.strictEqual(validateAmount(null), false);
      assert.strictEqual(validateAmount(undefined), false);
    });

    test('should return false for Infinity', () => {
      assert.strictEqual(validateAmount(Infinity), false);
      assert.strictEqual(validateAmount(-Infinity), false);
    });

    test('should return false for NaN', () => {
      assert.strictEqual(validateAmount(NaN), false);
    });
  });

  describe('formatCurrency', () => {
    test('should format KRW correctly', () => {
      const formatted = formatCurrency(10000, 'KRW');
      assert.ok(formatted.includes('10,000'));
    });

    test('should use KRW as default currency', () => {
      const formatted = formatCurrency(5000);
      assert.ok(formatted.includes('5,000'));
    });
  });

  describe('validateEmail', () => {
    test('should return true for valid emails', () => {
      assert.strictEqual(validateEmail('test@example.com'), true);
      assert.strictEqual(validateEmail('user.name@domain.co.kr'), true);
    });

    test('should return false for invalid emails', () => {
      assert.strictEqual(validateEmail('invalid'), false);
      assert.strictEqual(validateEmail('missing@domain'), false);
      assert.strictEqual(validateEmail('@nodomain.com'), false);
    });
  });

  describe('validateKoreanPhone', () => {
    test('should return true for valid Korean phone numbers', () => {
      assert.strictEqual(validateKoreanPhone('010-1234-5678'), true);
      assert.strictEqual(validateKoreanPhone('01012345678'), true);
      assert.strictEqual(validateKoreanPhone('010 1234 5678'), true);
    });

    test('should return false for invalid phone numbers', () => {
      assert.strictEqual(validateKoreanPhone('123-456-7890'), false);
      assert.strictEqual(validateKoreanPhone('02-1234-5678'), false);
    });
  });

  describe('maskCardNumber', () => {
    test('should mask middle digits of card number', () => {
      const masked = maskCardNumber('1234567890123456');
      assert.ok(masked.startsWith('1234'));
      assert.ok(masked.endsWith('3456'));
      assert.ok(masked.includes('*'));
    });

    test('should handle short card numbers', () => {
      const masked = maskCardNumber('1234');
      assert.strictEqual(masked, '****');
    });
  });
});
