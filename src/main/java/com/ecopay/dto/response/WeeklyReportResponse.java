package com.ecopay.dto.response;

import java.util.List;

public record WeeklyReportResponse(
        int streakDays,
        int weeklyActivityCount,
        int weeklyGoal,
        boolean weeklyGoalMet,
        List<DailyCarbonBar> lastSevenDays
) {
}
