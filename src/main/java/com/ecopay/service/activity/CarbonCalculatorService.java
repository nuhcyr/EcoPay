package com.ecopay.service.activity;

import com.ecopay.entity.ActivityType;
import java.math.BigDecimal;

public interface CarbonCalculatorService {
    BigDecimal calculate(ActivityType type, BigDecimal distance);
}
