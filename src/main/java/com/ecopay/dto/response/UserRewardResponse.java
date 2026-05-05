package com.ecopay.dto.response;

import java.time.Instant;

public record UserRewardResponse(
        Long id,
        RewardResponse reward,
        Instant claimedAt,
        Instant usedAt
) {
}
