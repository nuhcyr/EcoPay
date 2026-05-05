package com.ecopay.service.report.impl;

import com.ecopay.dto.response.ReportSummaryResponse;
import com.ecopay.entity.User;
import com.ecopay.repository.ActivityRepository;
import com.ecopay.repository.UserRepository;
import com.ecopay.service.report.ReportService;
import java.math.BigDecimal;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final UserRepository userRepository;
    private final ActivityRepository activityRepository;

    @Override
    @Transactional(readOnly = true)
    public ReportSummaryResponse getMySummary(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
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
}
