package com.ecopay.repository;

import com.ecopay.entity.Company;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CompanyRepository extends JpaRepository<Company, Long> {

    Optional<Company> findByInviteCodeIgnoreCase(String inviteCode);

    boolean existsByEmailDomainIgnoreCase(String emailDomain);
}
