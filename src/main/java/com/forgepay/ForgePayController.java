package com.forgepay;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ForgePayController {

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of(
                "service", "ForgePay",
                "status", "UP"
        );
    }

    @GetMapping("/accounts")
    public List<Map<String, Object>> accounts() {
        return List.of(
                Map.of(
                        "id", "FP-1001",
                        "name", "Demo Customer",
                        "balance", 125000
                ),
                Map.of(
                        "id", "FP-1002",
                        "name", "Test Merchant",
                        "balance", 87500
                )
        );
    }

    @GetMapping("/transactions")
    public List<Map<String, Object>> transactions() {
        return List.of(
                Map.of(
                        "id", "TXN-001",
                        "type", "CREDIT",
                        "amount", 50000,
                        "status", "SUCCESS"
                ),
                Map.of(
                        "id", "TXN-002",
                        "type", "DEBIT",
                        "amount", 12500,
                        "status", "SUCCESS"
                )
        );
    }

    @PostMapping("/payments")
    public ResponseEntity<Map<String, Object>> createPayment(
            @RequestBody Map<String, Object> payment) {

        return ResponseEntity.ok(
                Map.of(
                        "paymentId", "PAY-" + System.currentTimeMillis(),
                        "status", "SUCCESS",
                        "message", "Payment processed successfully",
                        "request", payment
                )
        );
    }
}