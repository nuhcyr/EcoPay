package com.ecopay.service.activity;

import com.ecopay.dto.request.ActivityCreateRequest;
import com.ecopay.dto.response.ActivityResponse;
import java.util.List;

public interface ActivityService {
    ActivityResponse create(String userEmail, ActivityCreateRequest request);
    List<ActivityResponse> getMyActivities(String userEmail);
}
