// AI Attribution Block: AI-assisted k6 load test script for ForgePay canary traffic generation.
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50 },   // Ramp-up to 50 RPS
    { duration: '5m', target: 100 },  // Sustained load at 100 RPS
    { duration: '1m', target: 0 },    // Ramp-down
  ],
  thresholds: {
    http_req_failed: ['rate<0.01'],    // Error rate must be < 1%
    http_req_duration: ['p(99)<300'],  // 99% of requests must complete under 300ms
  },
};

const BASE_URL = __ENV.TARGET_URL || 'http://localhost:8080';

export default function () {
  const payload = JSON.stringify({
    amount: 500.00,
    currency: 'INR',
    accountId: 'ACC-1001',
    merchantId: 'MERCHANT-CANARY-01',
    idempotencyKey: `idem-${Date.now()}-${Math.floor(Math.random() * 100000)}`,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'X-Correlation-ID': `corr-k6-${Date.now()}`,
    },
  };

  const res = http.post(`${BASE_URL}/api/v1/payments`, payload, params);

  check(res, {
    'status is 200 or 201': (r) => r.status === 200 || r.status === 201,
    'latency is within SLO': (r) => r.timings.duration < 300,
  });

  sleep(0.1);
}
