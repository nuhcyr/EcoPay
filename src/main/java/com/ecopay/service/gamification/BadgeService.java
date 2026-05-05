package com.ecopay.service.gamification;

import com.ecopay.dto.response.RewardResponse;
import com.ecopay.dto.response.UserRewardResponse;
import java.util.List;

public interface BadgeService {
    List<RewardResponse> getAllRewards();
    UserRewardResponse claimReward(String userEmail, Long rewardId);
    List<UserRewardResponse> getMyRewards(String userEmail);
    UserRewardResponse useReward(String userEmail, Long userRewardId);
}
