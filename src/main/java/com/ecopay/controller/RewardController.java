package com.ecopay.controller;

import com.ecopay.dto.response.RewardResponse;
import com.ecopay.dto.response.UserRewardResponse;
import com.ecopay.service.gamification.BadgeService;
import java.security.Principal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/rewards")
@RequiredArgsConstructor
public class RewardController {

    private final BadgeService badgeService;

    @GetMapping
    public ResponseEntity<List<RewardResponse>> getAllRewards() {
        return ResponseEntity.ok(badgeService.getAllRewards());
    }

    @PostMapping("/{rewardId}/claim")
    public ResponseEntity<UserRewardResponse> claimReward(
            Principal principal,
            @PathVariable Long rewardId
    ) {
        return ResponseEntity.ok(badgeService.claimReward(principal.getName(), rewardId));
    }

    @GetMapping("/me")
    public ResponseEntity<List<UserRewardResponse>> getMyRewards(Principal principal) {
        return ResponseEntity.ok(badgeService.getMyRewards(principal.getName()));
    }

    @PatchMapping("/me/{userRewardId}/use")
    public ResponseEntity<UserRewardResponse> useReward(
            Principal principal,
            @PathVariable Long userRewardId
    ) {
        return ResponseEntity.ok(badgeService.useReward(principal.getName(), userRewardId));
    }
}
