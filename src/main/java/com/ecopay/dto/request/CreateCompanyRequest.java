package com.ecopay.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateCompanyRequest(
        @NotBlank @Size(max = 120) String name,
        @NotBlank @Size(max = 255) String emailDomain
) {
}
