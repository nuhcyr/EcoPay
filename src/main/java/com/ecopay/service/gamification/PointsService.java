package com.ecopay.service.gamification;

import java.math.BigDecimal;

public interface PointsService {
    int calculateEarnedPoints(BigDecimal carbonEmission);
}
