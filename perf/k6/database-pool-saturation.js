// AI Attribution Block: AI-assisted k6 database pool stress testing scenario.
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 100 }, // Concurrently open 100 long-lived DB transactions
    { duration: '1m', target: 200 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'],
  },
};

const BASE_URL = __ENV.TARGET_URL || 'http://localhost:8080';

export default function () {
  const res = http.get(`${BASE_URL}/api/v1/simulation/db-hold-query`);
  check(res, {
    'transaction handled': (r) => r.status === 200 || r.status === 429 || r.status === 503,
  });
  sleep(0.02);
}
