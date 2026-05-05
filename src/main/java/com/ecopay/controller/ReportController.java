package com.ecopay.controller;

import com.ecopay.dto.response.ReportSummaryResponse;
import com.ecopay.service.report.ReportService;
import java.security.Principal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/me/summary")
    public ResponseEntity<ReportSummaryResponse> getMySummary(Principal principal) {
        return ResponseEntity.ok(reportService.getMySummary(principal.getName()));
    }
}
