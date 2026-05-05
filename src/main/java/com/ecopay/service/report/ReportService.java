package com.ecopay.service.report;

import com.ecopay.dto.response.ReportSummaryResponse;

public interface ReportService {
    ReportSummaryResponse getMySummary(String userEmail);
}
