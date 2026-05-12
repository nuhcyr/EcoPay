package com.ecopay.repository;

import com.ecopay.entity.Activity;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ActivityRepository extends JpaRepository<Activity, Long> {
    List<Activity> findByUserIdOrderByCreatedAtDesc(Long userId);

    List<Activity> findByUserIdAndCreatedAtGreaterThanEqualOrderByCreatedAtAsc(Long userId, Instant since);

    long countByUserId(Long userId);

    @Query("select coalesce(sum(a.carbonEmission), 0) from Activity a where a.user.id = :userId")
    BigDecimal sumCarbonEmissionByUserId(Long userId);
}
