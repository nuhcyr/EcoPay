package com.ecopay.service.gamification.impl;

import com.ecopay.entity.UserLevel;
import com.ecopay.service.gamification.LevelService;
import org.springframework.stereotype.Service;

@Service
public class DefaultLevelService implements LevelService {

    @Override
    public UserLevel determineLevel(int totalPoints) {
        if (totalPoints >= 1000) {
            return UserLevel.ECO_HERO;
        }
        if (totalPoints >= 300) {
            return UserLevel.ECO_RISER;
        }
        return UserLevel.GREEN_STARTER;
    }
}
