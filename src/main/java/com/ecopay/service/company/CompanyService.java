package com.ecopay.service.company;

import com.ecopay.dto.request.CreateCompanyRequest;
import com.ecopay.dto.response.CompanyMemberResponse;
import com.ecopay.dto.response.CompanyResponse;
import com.ecopay.dto.response.CompanyStandingResponse;
import java.util.List;
import java.util.Optional;

public interface CompanyService {

    CompanyResponse create(String userEmail, CreateCompanyRequest request);

    CompanyResponse joinByInvite(String userEmail, String inviteCode);

    Optional<CompanyResponse> getMyCompany(String userEmail);

    List<CompanyMemberResponse> listMyCompanyMembers(String userEmail);

    List<CompanyStandingResponse> companyStandings();
}
