package com.ecopay.service.auth.impl;

import com.ecopay.dto.request.AuthLoginRequest;
import com.ecopay.dto.request.AuthRegisterRequest;
import com.ecopay.dto.request.RefreshTokenRequest;
import com.ecopay.dto.response.AuthResponse;
import com.ecopay.entity.RefreshToken;
import com.ecopay.entity.User;
import com.ecopay.repository.RefreshTokenRepository;
import com.ecopay.repository.UserRepository;
import com.ecopay.security.JwtTokenProvider;
import com.ecopay.service.auth.AuthService;
import java.time.Instant;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @Override
    @Transactional
    public AuthResponse register(AuthRegisterRequest request) {
        if (userRepository.findByEmail(request.email()).isPresent()) {
            throw new IllegalArgumentException("Email already exists");
        }

        User user = new User();
        user.setEmail(request.email());
        user.setPassword(passwordEncoder.encode(request.password()));
        userRepository.save(user);

        return createTokens(user.getEmail());
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse login(AuthLoginRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new IllegalArgumentException("Invalid credentials"));

        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new IllegalArgumentException("Invalid credentials");
        }

        return createTokens(user.getEmail());
    }

    @Override
    @Transactional
    public AuthResponse refresh(RefreshTokenRequest request) {
        String refreshTokenValue = request.refreshToken();
        if (!jwtTokenProvider.isValid(refreshTokenValue)) {
            throw new IllegalArgumentException("Invalid refresh token");
        }
        if (!"refresh".equals(jwtTokenProvider.extractTokenType(refreshTokenValue))) {
            throw new IllegalArgumentException("Invalid token type");
        }

        String tokenId = jwtTokenProvider.extractTokenId(refreshTokenValue);
        RefreshToken savedToken = refreshTokenRepository.findByTokenId(tokenId)
                .orElseThrow(() -> new IllegalArgumentException("Refresh token is not recognized"));
        if (savedToken.getRevokedAt() != null) {
            throw new IllegalArgumentException("Refresh token already revoked");
        }
        if (savedToken.getExpiresAt().isBefore(Instant.now())) {
            throw new IllegalArgumentException("Refresh token expired");
        }

        savedToken.setRevokedAt(Instant.now());
        refreshTokenRepository.save(savedToken);
        return createTokens(savedToken.getUserEmail());
    }

    @Override
    @Transactional
    public void logout(RefreshTokenRequest request) {
        String refreshTokenValue = request.refreshToken();
        if (!jwtTokenProvider.isValid(refreshTokenValue)) {
            return;
        }
        if (!"refresh".equals(jwtTokenProvider.extractTokenType(refreshTokenValue))) {
            return;
        }
        String tokenId = jwtTokenProvider.extractTokenId(refreshTokenValue);
        refreshTokenRepository.findByTokenId(tokenId).ifPresent(token -> {
            token.setRevokedAt(Instant.now());
            refreshTokenRepository.save(token);
        });
    }

    private AuthResponse createTokens(String email) {
        String accessToken = jwtTokenProvider.generateAccessToken(email);
        String refreshTokenValue = jwtTokenProvider.generateRefreshToken(email);

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setTokenId(jwtTokenProvider.extractTokenId(refreshTokenValue));
        refreshToken.setUserEmail(email);
        refreshToken.setExpiresAt(jwtTokenProvider.extractExpiration(refreshTokenValue));
        refreshTokenRepository.save(refreshToken);

        return new AuthResponse(accessToken, refreshTokenValue);
    }
}
