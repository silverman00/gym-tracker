package com.gymtracker.apigateway.filter;

import com.gymtracker.apigateway.security.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Slf4j
@Component
public class JwtAuthenticationGatewayFilterFactory extends AbstractGatewayFilterFactory<JwtAuthenticationGatewayFilterFactory.Config> {

    private final JwtUtil jwtUtil;

    public JwtAuthenticationGatewayFilterFactory(JwtUtil jwtUtil) {
        super(Config.class);
        this.jwtUtil = jwtUtil;
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            String token = extractToken(exchange);

            if (!StringUtils.hasText(token)) {
                log.warn("Missing Authorization header for {}", exchange.getRequest().getPath());
                return unauthorized(exchange, "Missing Authorization header");
            }

            if (!jwtUtil.validateToken(token)) {
                log.warn("Invalid JWT token for {}", exchange.getRequest().getPath());
                return unauthorized(exchange, "Invalid or expired token");
            }

            // Inject user identity headers for downstream services
            Long userId = jwtUtil.extractUserId(token);
            String username = jwtUtil.extractUsername(token);

            ServerWebExchange mutatedExchange = exchange.mutate()
                    .request(r -> r
                            .header("X-User-Id", String.valueOf(userId))
                            .header("X-Username", username))
                    .build();

            log.debug("JWT validated for user: {} (id: {})", username, userId);
            return chain.filter(mutatedExchange);
        };
    }

    private String extractToken(ServerWebExchange exchange) {
        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (StringUtils.hasText(authHeader) && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }

    private Mono<Void> unauthorized(ServerWebExchange exchange, String message) {
        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
        exchange.getResponse().getHeaders().add("Content-Type", "application/json");
        var body = exchange.getResponse().bufferFactory()
                .wrap(("{\"error\":\"" + message + "\"}").getBytes());
        return exchange.getResponse().writeWith(Mono.just(body));
    }

    public static class Config {
        // No config needed
    }
}
