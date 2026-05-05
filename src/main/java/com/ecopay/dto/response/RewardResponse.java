package com.ecopay.dto.response;

public record RewardResponse(
        Long id,
        String name,
        Integer requiredPoints,
        String description
) {
}
