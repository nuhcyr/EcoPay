package com.ecopay.dto.response;

public record AuthResponse(
        String accessToken,
        String refreshToken
) {
}
