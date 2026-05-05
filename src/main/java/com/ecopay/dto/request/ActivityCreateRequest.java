package com.ecopay.dto.request;

import com.ecopay.entity.ActivityType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public record ActivityCreateRequest(
        @NotNull ActivityType type,
        @NotNull @DecimalMin("0.1") BigDecimal distance
) {
}
