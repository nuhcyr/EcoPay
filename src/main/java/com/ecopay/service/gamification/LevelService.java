package com.ecopay.service.gamification;

import com.ecopay.entity.UserLevel;

public interface LevelService {
    UserLevel determineLevel(int totalPoints);
}
