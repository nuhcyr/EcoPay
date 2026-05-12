package com.ecopay.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record JoinCompanyRequest(
        @NotBlank @Size(min = 6, max = 16) String inviteCode
) {
}
