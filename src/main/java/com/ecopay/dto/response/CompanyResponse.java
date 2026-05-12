package com.ecopay.dto.response;

public record CompanyResponse(
        Long id,
        String name,
        String emailDomain,
        String inviteCode,
        boolean owner
) {
}
