package com.ecopay.service.company.impl;

import com.ecopay.dto.request.CreateCompanyRequest;
import com.ecopay.dto.response.CompanyMemberResponse;
import com.ecopay.dto.response.CompanyResponse;
import com.ecopay.dto.response.CompanyStandingResponse;
import com.ecopay.entity.Company;
import com.ecopay.entity.User;
import com.ecopay.repository.CompanyRepository;
import com.ecopay.repository.UserRepository;
import com.ecopay.service.company.CompanyService;
import java.security.SecureRandom;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CompanyServiceImpl implements CompanyService {

    private static final String INVITE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final int INVITE_LENGTH = 8;

    private final CompanyRepository companyRepository;
    private final UserRepository userRepository;
    private final SecureRandom random = new SecureRandom();

    @Override
    @Transactional
    public CompanyResponse create(String userEmail, CreateCompanyRequest request) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("Kullanıcı bulunamadı"));
        if (user.getCompany() != null) {
            throw new IllegalArgumentException("Zaten bir şirkete bağlısınız");
        }
        String domain = normalizeDomain(request.emailDomain());
        if (!emailMatchesDomain(user.getEmail(), domain)) {
            throw new IllegalArgumentException("Şirket alanı hesabınızdaki e-posta ile eşleşmiyor");
        }
        if (companyRepository.existsByEmailDomainIgnoreCase(domain)) {
            throw new IllegalArgumentException("Bu e-posta alanı için zaten bir şirket var");
        }

        Company company = new Company();
        company.setName(request.name().trim());
        company.setEmailDomain(domain);
        company.setInviteCode(generateUniqueInviteCode());
        company.setOwner(user);
        company = companyRepository.save(company);

        user.setCompany(company);
        userRepository.save(user);

        return toResponse(company, user.getId());
    }

    @Override
    @Transactional
    public CompanyResponse joinByInvite(String userEmail, String inviteCode) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("Kullanıcı bulunamadı"));
        if (user.getCompany() != null) {
            throw new IllegalArgumentException("Zaten bir şirkete bağlısınız");
        }
        String code = inviteCode == null ? "" : inviteCode.trim();
        Company company = companyRepository.findByInviteCodeIgnoreCase(code)
                .orElseThrow(() -> new IllegalArgumentException("Geçersiz davet kodu"));
        if (!emailMatchesDomain(user.getEmail(), company.getEmailDomain())) {
            throw new IllegalArgumentException(
                    "Bu şirkete yalnızca @" + company.getEmailDomain() + " adresleri katılabilir");
        }
        user.setCompany(company);
        userRepository.save(user);
        return toResponse(company, user.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<CompanyResponse> getMyCompany(String userEmail) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("Kullanıcı bulunamadı"));
        Company company = user.getCompany();
        if (company == null) {
            return Optional.empty();
        }
        return Optional.of(toResponse(company, user.getId()));
    }

    @Override
    @Transactional(readOnly = true)
    public List<CompanyMemberResponse> listMyCompanyMembers(String userEmail) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("Kullanıcı bulunamadı"));
        Company company = user.getCompany();
        if (company == null) {
            throw new IllegalArgumentException("Şirket üyesi değilsiniz");
        }
        return userRepository.findByCompany_IdOrderByTotalPointsDesc(company.getId()).stream()
                .map(u -> new CompanyMemberResponse(
                        u.getEmail(),
                        u.getTotalPoints(),
                        u.getLevel().name()))
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<CompanyStandingResponse> companyStandings() {
        return companyRepository.findAll().stream()
                .map(c -> new CompanyStandingResponse(
                        c.getId(),
                        c.getName(),
                        userRepository.sumTotalPointsByCompanyId(c.getId())))
                .sorted(Comparator.comparingLong(CompanyStandingResponse::totalPointsSum).reversed())
                .toList();
    }

    private CompanyResponse toResponse(Company company, Long currentUserId) {
        boolean owner = company.getOwner().getId().equals(currentUserId);
        return new CompanyResponse(
                company.getId(),
                company.getName(),
                company.getEmailDomain(),
                company.getInviteCode(),
                owner);
    }

    private String generateUniqueInviteCode() {
        for (int attempt = 0; attempt < 20; attempt++) {
            StringBuilder sb = new StringBuilder(INVITE_LENGTH);
            for (int i = 0; i < INVITE_LENGTH; i++) {
                sb.append(INVITE_ALPHABET.charAt(random.nextInt(INVITE_ALPHABET.length())));
            }
            String code = sb.toString();
            if (companyRepository.findByInviteCodeIgnoreCase(code).isEmpty()) {
                return code;
            }
        }
        throw new IllegalStateException("Davet kodu üretilemedi");
    }

    static String normalizeDomain(String raw) {
        String s = raw.trim().toLowerCase();
        if (s.contains("@")) {
            s = s.substring(s.lastIndexOf('@') + 1);
        }
        if (!s.matches("[a-z0-9][a-z0-9.-]*\\.[a-z]{2,}")) {
            throw new IllegalArgumentException("Geçerli e-posta alanı girin (örn: sirket.com)");
        }
        return s;
    }

    static boolean emailMatchesDomain(String email, String domain) {
        if (email == null || domain == null) {
            return false;
        }
        String e = email.trim().toLowerCase();
        String d = domain.trim().toLowerCase();
        return e.endsWith("@" + d);
    }
}
