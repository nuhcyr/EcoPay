package com.ecopay.service.report;

import com.ecopay.dto.response.ReportSummaryResponse;
import com.ecopay.dto.response.WeeklyReportResponse;

public interface ReportService {
    ReportSummaryResponse getMySummary(String userEmail);

    WeeklyReportResponse getMyWeekly(String userEmail);
}
