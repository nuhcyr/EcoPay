package com.ecopay.controller;

import com.ecopay.dto.request.CreateCompanyRequest;
import com.ecopay.dto.request.JoinCompanyRequest;
import com.ecopay.dto.response.CompanyMemberResponse;
import com.ecopay.dto.response.CompanyResponse;
import com.ecopay.dto.response.CompanyStandingResponse;
import com.ecopay.service.company.CompanyService;
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/companies")
@RequiredArgsConstructor
public class CompanyController {

    private final CompanyService companyService;

    @PostMapping
    public ResponseEntity<CompanyResponse> create(
            @Valid @RequestBody CreateCompanyRequest request,
            Principal principal
    ) {
        return ResponseEntity.ok(companyService.create(principal.getName(), request));
    }

    @PostMapping("/join")
    public ResponseEntity<CompanyResponse> join(
            @Valid @RequestBody JoinCompanyRequest request,
            Principal principal
    ) {
        return ResponseEntity.ok(companyService.joinByInvite(principal.getName(), request.inviteCode()));
    }

    @GetMapping("/me")
    public ResponseEntity<CompanyResponse> me(Principal principal) {
        return companyService
                .getMyCompany(principal.getName())
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.noContent().build());
    }

    @GetMapping("/me/members")
    public ResponseEntity<List<CompanyMemberResponse>> members(Principal principal) {
        return ResponseEntity.ok(companyService.listMyCompanyMembers(principal.getName()));
    }

    @GetMapping("/standings")
    public ResponseEntity<List<CompanyStandingResponse>> standings() {
        return ResponseEntity.ok(companyService.companyStandings());
    }
}
