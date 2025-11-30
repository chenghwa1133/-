/**
 * Helper utilities for Korea Payment application
 */

const crypto = require('crypto');

/**
 * Generate a unique order ID
 * @returns {string} Unique order ID
 */
function generateOrderId() {
  const timestamp = Date.now().toString(36);
  const randomPart = crypto.randomBytes(4).toString('hex');
  return `ORD-${timestamp}-${randomPart}`.toUpperCase();
}

/**
 * Validate payment amount
 * @param {number} amount - Payment amount
 * @returns {boolean} True if valid
 */
function validateAmount(amount) {
  if (typeof amount !== 'number') {
    return false;
  }
  if (amount <= 0) {
    return false;
  }
  if (!Number.isFinite(amount)) {
    return false;
  }
  return true;
}

/**
 * Format currency for display
 * @param {number} amount - Amount to format
 * @param {string} currency - Currency code (default: KRW)
 * @returns {string} Formatted currency string
 */
function formatCurrency(amount, currency = 'KRW') {
  const formatter = new Intl.NumberFormat('ko-KR', {
    style: 'currency',
    currency: currency,
    minimumFractionDigits: 0
  });
  return formatter.format(amount);
}

/**
 * Validate email format
 * @param {string} email - Email to validate
 * @returns {boolean} True if valid email format
 */
function validateEmail(email) {
  if (typeof email !== 'string') {
    return false;
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate Korean phone number
 * @param {string} phone - Phone number to validate
 * @returns {boolean} True if valid Korean phone format
 */
function validateKoreanPhone(phone) {
  if (typeof phone !== 'string') {
    return false;
  }
  // Accepts formats: 010-1234-5678, 01012345678, 010 1234 5678
  const phoneRegex = /^01[0-9][-\s]?[0-9]{3,4}[-\s]?[0-9]{4}$/;
  return phoneRegex.test(phone);
}

/**
 * Mask card number for display
 * @param {string} cardNumber - Full card number
 * @returns {string} Masked card number in format XXXX-****-****-XXXX
 */
function maskCardNumber(cardNumber) {
  if (typeof cardNumber !== 'string') {
    return '';
  }
  const cleaned = cardNumber.replace(/\D/g, '');
  if (cleaned.length < 8) {
    return '*'.repeat(cleaned.length);
  }
  const first4 = cleaned.slice(0, 4);
  const last4 = cleaned.slice(-4);
  // Always use consistent 4-digit grouping with asterisks for middle sections
  return `${first4}-****-****-${last4}`;
}

module.exports = {
  generateOrderId,
  validateAmount,
  formatCurrency,
  validateEmail,
  validateKoreanPhone,
  maskCardNumber
};
