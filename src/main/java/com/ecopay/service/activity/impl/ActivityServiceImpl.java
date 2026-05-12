package com.ecopay.service.activity.impl;

import com.ecopay.dto.request.ActivityCreateRequest;
import com.ecopay.dto.response.ActivityResponse;
import com.ecopay.entity.Activity;
import com.ecopay.entity.User;
import com.ecopay.mapper.ActivityMapper;
import com.ecopay.repository.ActivityRepository;
import com.ecopay.repository.UserRepository;
import com.ecopay.service.activity.ActivityService;
import com.ecopay.service.activity.CarbonCalculatorService;
import com.ecopay.service.gamification.LevelService;
import com.ecopay.service.gamification.PointsService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ActivityServiceImpl implements ActivityService {

    private final ActivityRepository activityRepository;
    private final UserRepository userRepository;
    private final CarbonCalculatorService carbonCalculatorService;
    private final PointsService pointsService;
    private final LevelService levelService;
    private final ActivityMapper activityMapper;

    @Override
    @Transactional
    public ActivityResponse create(String userEmail, ActivityCreateRequest request) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Activity activity = new Activity();
        activity.setUser(user);
        activity.setType(request.type());
        activity.setDistance(request.distance());
        activity.setCarbonEmission(carbonCalculatorService.calculate(request.type(), request.distance()));
        activity.setEarnedPoints(pointsService.calculateEarnedPoints(activity.getCarbonEmission()));
        activityRepository.save(activity);

        int newPoints = user.getTotalPoints() + activity.getEarnedPoints();
        user.setTotalPoints(newPoints);
        user.setLevel(levelService.determineLevel(newPoints));
        userRepository.save(user);

        return activityMapper.toResponse(activity);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ActivityResponse> getMyActivities(String userEmail) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return activityRepository.findByUserIdOrderByCreatedAtDesc(user.getId()).stream()
                .map(activityMapper::toResponse)
                .toList();
    }
}
