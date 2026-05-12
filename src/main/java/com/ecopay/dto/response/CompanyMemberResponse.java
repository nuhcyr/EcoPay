package com.ecopay.dto.response;

public record CompanyMemberResponse(
        String email,
        Integer totalPoints,
        String level
) {
}
