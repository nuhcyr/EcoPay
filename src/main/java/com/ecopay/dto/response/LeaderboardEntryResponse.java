package com.ecopay.dto.response;

import com.ecopay.entity.UserLevel;

public record LeaderboardEntryResponse(
        Long userId,
        String email,
        Integer totalPoints,
        UserLevel level
) {
}
