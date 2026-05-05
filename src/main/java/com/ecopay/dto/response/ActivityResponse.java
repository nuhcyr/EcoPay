package com.ecopay.dto.response;

import com.ecopay.entity.ActivityType;
import java.math.BigDecimal;
import java.time.Instant;

public record ActivityResponse(
        Long id,
        Long userId,
        ActivityType type,
        BigDecimal distance,
        BigDecimal carbonEmission,
        Integer earnedPoints,
        Instant createdAt
) {
}
