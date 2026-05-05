package com.ecopay.service.gamification.impl;

import com.ecopay.service.gamification.PointsService;
import java.math.BigDecimal;
import org.springframework.stereotype.Service;

@Service
public class DefaultPointsService implements PointsService {

    @Override
    public int calculateEarnedPoints(BigDecimal carbonEmission) {
        if (carbonEmission.compareTo(BigDecimal.ZERO) == 0) {
            return 30;
        }
        return Math.max(5, 30 - carbonEmission.intValue());
    }
}
