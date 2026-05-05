package com.ecopay.service.ranking;

import com.ecopay.dto.response.LeaderboardEntryResponse;
import java.util.List;

public interface LeaderboardService {
    List<LeaderboardEntryResponse> getTopUsers(int limit);
}
