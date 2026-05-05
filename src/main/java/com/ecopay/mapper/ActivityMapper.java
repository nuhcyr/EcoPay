package com.ecopay.mapper;

import com.ecopay.dto.response.ActivityResponse;
import com.ecopay.entity.Activity;
import org.springframework.stereotype.Component;

@Component
public class ActivityMapper {

    public ActivityResponse toResponse(Activity activity) {
        return new ActivityResponse(
                activity.getId(),
                activity.getUser().getId(),
                activity.getType(),
                activity.getDistance(),
                activity.getCarbonEmission(),
                activity.getEarnedPoints(),
                activity.getCreatedAt()
        );
    }
}
