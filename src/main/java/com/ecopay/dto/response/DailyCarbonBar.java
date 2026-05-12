package com.ecopay.dto.response;

import java.math.BigDecimal;

public record DailyCarbonBar(
        String date,
        int activityCount,
        BigDecimal carbonKg
) {
}
