package com.ecopay.dto.response;

public record CompanyStandingResponse(
        Long companyId,
        String companyName,
        long totalPointsSum
) {
}
