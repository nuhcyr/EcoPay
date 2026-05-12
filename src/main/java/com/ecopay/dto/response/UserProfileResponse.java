package com.ecopay.dto.response;

import com.ecopay.entity.UserLevel;

public record UserProfileResponse(
        Long id,
        String email,
        Integer totalPoints,
        UserLevel level,
        Long companyId,
        String companyName,
        String companyInviteCode,
        Boolean companyOwner
) {
}
