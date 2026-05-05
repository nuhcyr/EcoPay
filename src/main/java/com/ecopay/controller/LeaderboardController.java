package com.ecopay.controller;

import com.ecopay.dto.response.LeaderboardEntryResponse;
import com.ecopay.service.ranking.LeaderboardService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/leaderboard")
@RequiredArgsConstructor
public class LeaderboardController {

    private final LeaderboardService leaderboardService;

    @GetMapping
    public ResponseEntity<List<LeaderboardEntryResponse>> getTop(
            @RequestParam(defaultValue = "10") int limit
    ) {
        return ResponseEntity.ok(leaderboardService.getTopUsers(limit));
    }
}
