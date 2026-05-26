package com.atlas.platform.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "app")
public class AppConfig {

    private String environment;
    private String secretsName;
    private FeatureFlags featureFlags = new FeatureFlags();

    public String getEnvironment() { return environment; }
    public void setEnvironment(String environment) { this.environment = environment; }

    public String getSecretsName() { return secretsName; }
    public void setSecretsName(String secretsName) { this.secretsName = secretsName; }

    public FeatureFlags getFeatureFlags() { return featureFlags; }
    public void setFeatureFlags(FeatureFlags featureFlags) { this.featureFlags = featureFlags; }

    public static class FeatureFlags {
        private boolean debugMode;
        private int rateLimit;

        public boolean isDebugMode() { return debugMode; }
        public void setDebugMode(boolean debugMode) { this.debugMode = debugMode; }

        public int getRateLimit() { return rateLimit; }
        public void setRateLimit(int rateLimit) { this.rateLimit = rateLimit; }
    }
}