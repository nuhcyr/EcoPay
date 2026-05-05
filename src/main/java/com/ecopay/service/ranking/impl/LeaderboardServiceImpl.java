package com.ecopay.service.ranking.impl;

import com.ecopay.dto.response.LeaderboardEntryResponse;
import com.ecopay.repository.UserRepository;
import com.ecopay.service.ranking.LeaderboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LeaderboardServiceImpl implements LeaderboardService {

    private final UserRepository userRepository;

    @Override
    public List<LeaderboardEntryResponse> getTopUsers(int limit) {
        return userRepository.findAll().stream()
                .sorted(Comparator.comparingInt(user -> -user.getTotalPoints()))
                .limit(limit)
                .map(user -> new LeaderboardEntryResponse(
                        user.getId(),
                        user.getEmail(),
                        user.getTotalPoints(),
                        user.getLevel()
                ))
                .toList();
    }
}
