package com.ecopay.service.auth;

import com.ecopay.dto.request.AuthLoginRequest;
import com.ecopay.dto.request.AuthRegisterRequest;
import com.ecopay.dto.request.RefreshTokenRequest;
import com.ecopay.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse register(AuthRegisterRequest request);
    AuthResponse login(AuthLoginRequest request);
    AuthResponse refresh(RefreshTokenRequest request);
    void logout(RefreshTokenRequest request);
}
