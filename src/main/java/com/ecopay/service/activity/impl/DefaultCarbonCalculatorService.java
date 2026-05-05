package com.ecopay.service.activity.impl;

import com.ecopay.entity.ActivityType;
import com.ecopay.service.activity.CarbonCalculatorService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class DefaultCarbonCalculatorService implements CarbonCalculatorService {

    private static final Map<ActivityType, BigDecimal> FACTORS = Map.of(
            ActivityType.CAR, new BigDecimal("0.21"),
            ActivityType.BUS, new BigDecimal("0.08"),
            ActivityType.BIKE, BigDecimal.ZERO,
            ActivityType.WALK, BigDecimal.ZERO
    );

    @Override
    public BigDecimal calculate(ActivityType type, BigDecimal distance) {
        BigDecimal factor = FACTORS.getOrDefault(type, BigDecimal.ZERO);
        return factor.multiply(distance).setScale(2, RoundingMode.HALF_UP);
    }
}
