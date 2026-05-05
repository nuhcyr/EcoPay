package com.ecopay.controller;

import com.ecopay.dto.request.ActivityCreateRequest;
import com.ecopay.dto.response.ActivityResponse;
import com.ecopay.service.activity.ActivityService;
import java.security.Principal;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/activities")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;

    @PostMapping
    public ResponseEntity<ActivityResponse> create(
            Principal principal,
            @Valid @RequestBody ActivityCreateRequest request
    ) {
        return ResponseEntity.ok(activityService.create(principal.getName(), request));
    }

    @GetMapping("/me")
    public ResponseEntity<List<ActivityResponse>> getMyActivities(Principal principal) {
        return ResponseEntity.ok(activityService.getMyActivities(principal.getName()));
    }
}
