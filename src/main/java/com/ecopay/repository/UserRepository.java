package com.ecopay.repository;

import com.ecopay.entity.User;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    Optional<User> findByEmailIgnoreCase(String email);

    List<User> findByCompany_IdOrderByTotalPointsDesc(Long companyId);

    @Query("select coalesce(sum(u.totalPoints), 0) from User u where u.company.id = :companyId")
    long sumTotalPointsByCompanyId(@Param("companyId") Long companyId);
}
