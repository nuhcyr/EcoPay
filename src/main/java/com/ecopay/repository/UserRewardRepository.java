package com.ecopay.repository;

import com.ecopay.entity.UserReward;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRewardRepository extends JpaRepository<UserReward, Long> {
    List<UserReward> findByUserId(Long userId);

    boolean existsByUserIdAndRewardId(Long userId, Long rewardId);

    Optional<UserReward> findByIdAndUserId(Long id, Long userId);
}
