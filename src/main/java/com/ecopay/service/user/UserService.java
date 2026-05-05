package com.ecopay.service.user;

import com.ecopay.dto.response.UserProfileResponse;

public interface UserService {
    UserProfileResponse getMyProfile(String userEmail);
}
