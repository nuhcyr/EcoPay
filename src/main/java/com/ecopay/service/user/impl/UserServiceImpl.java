package com.ecopay.service.user.impl;

import com.ecopay.dto.response.UserProfileResponse;
import com.ecopay.entity.User;
import com.ecopay.repository.UserRepository;
import com.ecopay.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public UserProfileResponse getMyProfile(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        return new UserProfileResponse(
                user.getId(),
                user.getEmail(),
                user.getTotalPoints(),
                user.getLevel()
        );
    }
}
