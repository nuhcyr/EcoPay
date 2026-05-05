package com.ecopay.dto.response;

import com.ecopay.entity.UserLevel;
import java.math.BigDecimal;

public record ReportSummaryResponse(
        String email,
        Integer totalPoints,
        UserLevel level,
        long totalActivities,
        BigDecimal totalCarbonEmissionKg
) {
}
