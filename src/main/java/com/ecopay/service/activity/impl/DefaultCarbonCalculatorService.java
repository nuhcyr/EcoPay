package com.ecopay.service.activity.impl;

import com.ecopay.entity.ActivityType;
import com.ecopay.service.activity.CarbonCalculatorService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class DefaultCarbonCalculatorService implements CarbonCalculatorService {

    /**
     * kg CO₂ / km — gösterim ve oyunlaştırma için sadeleştirilmiş katsayılar (bilimsel rapor değildir).
     */
    private static final Map<ActivityType, BigDecimal> FACTORS = Map.ofEntries(
            Map.entry(ActivityType.CAR, new BigDecimal("0.21")),
            Map.entry(ActivityType.BUS, new BigDecimal("0.08")),
            Map.entry(ActivityType.BIKE, BigDecimal.ZERO),
            Map.entry(ActivityType.WALK, BigDecimal.ZERO),
            Map.entry(ActivityType.METRO, new BigDecimal("0.03")),
            Map.entry(ActivityType.TRAIN, new BigDecimal("0.04")),
            Map.entry(ActivityType.E_SCOOTER, new BigDecimal("0.02")),
            Map.entry(ActivityType.EV_CAR, new BigDecimal("0.05"))
    );

    @Override
    public BigDecimal calculate(ActivityType type, BigDecimal distance) {
        BigDecimal factor = FACTORS.getOrDefault(type, BigDecimal.ZERO);
        return factor.multiply(distance).setScale(2, RoundingMode.HALF_UP);
    }
}
