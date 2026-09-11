// AI Attribution Block: AI-assisted mock payment gateway HTTP server.
const http = require('http');

const PORT = process.env.PORT || 8088;

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (req.method === 'POST' && url.pathname === '/v2/authorizations') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const amount = payload.amount || 0;

        // Deterministic mock behavior: amounts > 50000 trigger decline
        if (amount > 50000) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            status: 'DECLINED',
            reason: 'EXCEEDS_TRANSACTION_LIMIT',
            timestamp: new Date().toISOString()
          }));
          return;
        }

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          gatewayReference: `GW-MOCK-${Math.floor(Math.random() * 900000) + 100000}`,
          status: 'APPROVED',
          authorizationCode: `AUTH-${Math.floor(Math.random() * 900000) + 100000}`,
          timestamp: new Date().toISOString()
        }));
      } catch (err) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'INVALID_JSON_PAYLOAD' }));
      }
    });
  } else if (req.method === 'GET' && url.pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'UP', service: 'mock-payment-gateway' }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'NOT_FOUND' }));
  }
});

server.listen(PORT, () => {
  console.log(`Mock Payment Gateway listening on port ${PORT}`);
});
