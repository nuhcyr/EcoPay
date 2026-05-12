package com.ecopay.service.report.impl;

import com.ecopay.dto.response.DailyCarbonBar;
import com.ecopay.dto.response.ReportSummaryResponse;
import com.ecopay.dto.response.WeeklyReportResponse;
import com.ecopay.entity.Activity;
import com.ecopay.entity.User;
import com.ecopay.repository.ActivityRepository;
import com.ecopay.repository.UserRepository;
import com.ecopay.service.report.ReportService;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private static final ZoneId REPORT_ZONE = ZoneId.of("Europe/Istanbul");
    private static final int WEEKLY_GOAL_ACTIVITIES = 3;
    private static final int STREAK_LOOKBACK_DAYS = 180;

    private final UserRepository userRepository;
    private final ActivityRepository activityRepository;

    @Override
    @Transactional(readOnly = true)
    public ReportSummaryResponse getMySummary(String userEmail) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        long totalActivities = activityRepository.countByUserId(user.getId());
        BigDecimal totalCarbon = activityRepository.sumCarbonEmissionByUserId(user.getId());

        return new ReportSummaryResponse(
                user.getEmail(),
                user.getTotalPoints(),
                user.getLevel(),
                totalActivities,
                totalCarbon
        );
    }

    @Override
    @Transactional(readOnly = true)
    public WeeklyReportResponse getMyWeekly(String userEmail) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Instant weekStart = Instant.now().minus(7, ChronoUnit.DAYS);
        List<Activity> lastWeek = activityRepository.findByUserIdAndCreatedAtGreaterThanEqualOrderByCreatedAtAsc(
                user.getId(), weekStart);

        LocalDate today = LocalDate.now(REPORT_ZONE);
        Map<LocalDate, List<Activity>> byDay = lastWeek.stream()
                .collect(Collectors.groupingBy(a -> LocalDate.ofInstant(a.getCreatedAt(), REPORT_ZONE)));

        List<DailyCarbonBar> bars = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            List<Activity> dayActs = byDay.getOrDefault(d, List.of());
            BigDecimal carbon = dayActs.stream()
                    .map(Activity::getCarbonEmission)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            bars.add(new DailyCarbonBar(d.toString(), dayActs.size(), carbon));
        }

        int weeklyCount = lastWeek.size();
        boolean goalMet = weeklyCount >= WEEKLY_GOAL_ACTIVITIES;

        Instant streakSince = Instant.now().minus(STREAK_LOOKBACK_DAYS, ChronoUnit.DAYS);
        List<Activity> streakWindow = activityRepository.findByUserIdAndCreatedAtGreaterThanEqualOrderByCreatedAtAsc(
                user.getId(), streakSince);
        Set<LocalDate> activeDays = streakWindow.stream()
                .map(a -> LocalDate.ofInstant(a.getCreatedAt(), REPORT_ZONE))
                .collect(Collectors.toCollection(HashSet::new));
        int streak = computeStreakDays(activeDays, today);

        return new WeeklyReportResponse(streak, weeklyCount, WEEKLY_GOAL_ACTIVITIES, goalMet, bars);
    }

    /**
     * Bugün kayıt yoksa dünü “devam” kabul eder; ikisi de boşsa seri 0.
     */
    private static int computeStreakDays(Set<LocalDate> activeDays, LocalDate today) {
        LocalDate start;
        if (activeDays.contains(today)) {
            start = today;
        } else if (activeDays.contains(today.minusDays(1))) {
            start = today.minusDays(1);
        } else {
            return 0;
        }
        int streak = 0;
        LocalDate d = start;
        while (activeDays.contains(d)) {
            streak++;
            d = d.minusDays(1);
        }
        return streak;
    }
}
