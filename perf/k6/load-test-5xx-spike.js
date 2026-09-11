// AI Attribution Block: AI-assisted k6 synthetic 5xx error injection and threshold verification test.
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    // Assert that rollout abort threshold (> 5%) triggers accurately
    'http_req_failed{status:500}': ['rate>0.05'],
  },
};

const BASE_URL = __ENV.TARGET_URL || 'http://localhost:8080';

export default function () {
  // Trigger synthetic error simulation route for analysis template validation
  const res = http.get(`${BASE_URL}/api/v1/simulation/error-spike`);
  check(res, {
    'received error response': (r) => r.status >= 500,
  });
  sleep(0.05);
}
