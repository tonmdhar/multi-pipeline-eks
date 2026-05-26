package com.atlas.platform.controller;

import com.atlas.platform.config.AppConfig;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    private final AppConfig appConfig;
    private final Instant startTime = Instant.now();

    public HealthController(AppConfig appConfig) {
        this.appConfig = appConfig;
    }

    @GetMapping("/info")
    public Map<String, Object> info() {
        return Map.of(
                "service", "atlas-platform",
                "environment", appConfig.getEnvironment(),
                "uptime", java.time.Duration.between(startTime, Instant.now()).toString(),
                "debugMode", appConfig.getFeatureFlags().isDebugMode(),
                "rateLimit", appConfig.getFeatureFlags().getRateLimit()
        );
    }

    @GetMapping("/health/deep")
    public Map<String, Object> deepHealth() {
        return Map.of(
                "status", "UP",
                "environment", appConfig.getEnvironment(),
                "timestamp", Instant.now().toString(),
                "checks", Map.of(
                        "memory", getMemoryStatus(),
                        "uptime", java.time.Duration.between(startTime, Instant.now()).toString()
                )
        );
    }

    private Map<String, Object> getMemoryStatus() {
        Runtime runtime = Runtime.getRuntime();
        long totalMb = runtime.totalMemory() / (1024 * 1024);
        long freeMb = runtime.freeMemory() / (1024 * 1024);
        long usedMb = totalMb - freeMb;

        return Map.of(
                "totalMb", totalMb,
                "usedMb", usedMb,
                "freeMb", freeMb
        );
    }
}