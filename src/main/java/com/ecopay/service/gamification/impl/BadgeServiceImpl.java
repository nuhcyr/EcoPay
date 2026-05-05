package com.ecopay.service.gamification.impl;

import com.ecopay.dto.response.RewardResponse;
import com.ecopay.dto.response.UserRewardResponse;
import com.ecopay.entity.Reward;
import com.ecopay.entity.User;
import com.ecopay.entity.UserReward;
import com.ecopay.repository.RewardRepository;
import com.ecopay.repository.UserRepository;
import com.ecopay.repository.UserRewardRepository;
import com.ecopay.service.gamification.BadgeService;
import com.ecopay.service.gamification.LevelService;
import java.time.Instant;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class BadgeServiceImpl implements BadgeService {

    private final RewardRepository rewardRepository;
    private final UserRepository userRepository;
    private final UserRewardRepository userRewardRepository;
    private final LevelService levelService;

    @Override
    @Transactional(readOnly = true)
    public List<RewardResponse> getAllRewards() {
        return rewardRepository.findAll().stream()
                .map(this::toRewardResponse)
                .toList();
    }

    @Override
    @Transactional
    public UserRewardResponse claimReward(String userEmail, Long rewardId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        Reward reward = rewardRepository.findById(rewardId)
                .orElseThrow(() -> new IllegalArgumentException("Reward not found"));

        if (user.getTotalPoints() < reward.getRequiredPoints()) {
            throw new IllegalArgumentException("Not enough points for this reward");
        }
        if (userRewardRepository.existsByUserIdAndRewardId(user.getId(), reward.getId())) {
            throw new IllegalArgumentException("Reward already claimed");
        }

        int newPoints = user.getTotalPoints() - reward.getRequiredPoints();
        user.setTotalPoints(newPoints);
        user.setLevel(levelService.determineLevel(newPoints));
        userRepository.save(user);

        UserReward userReward = new UserReward();
        userReward.setUser(user);
        userReward.setReward(reward);
        userRewardRepository.save(userReward);

        return toUserRewardResponse(userReward);
    }

    @Override
    @Transactional(readOnly = true)
    public List<UserRewardResponse> getMyRewards(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return userRewardRepository.findByUserId(user.getId()).stream()
                .map(this::toUserRewardResponse)
                .toList();
    }

    @Override
    @Transactional
    public UserRewardResponse useReward(String userEmail, Long userRewardId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        UserReward userReward = userRewardRepository.findByIdAndUserId(userRewardId, user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Reward claim not found"));

        if (userReward.getUsedAt() != null) {
            throw new IllegalArgumentException("Reward already used");
        }

        userReward.setUsedAt(Instant.now());
        userRewardRepository.save(userReward);
        return toUserRewardResponse(userReward);
    }

    private RewardResponse toRewardResponse(Reward reward) {
        return new RewardResponse(
                reward.getId(),
                reward.getName(),
                reward.getRequiredPoints(),
                reward.getDescription()
        );
    }

    private UserRewardResponse toUserRewardResponse(UserReward userReward) {
        return new UserRewardResponse(
                userReward.getId(),
                toRewardResponse(userReward.getReward()),
                userReward.getCreatedAt(),
                userReward.getUsedAt()
        );
    }
}
