package com.gymtracker.pointsservice.repository;

import com.gymtracker.pointsservice.entity.UserPoints;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserPointsRepository extends JpaRepository<UserPoints, Long> {

    Optional<UserPoints> findByUserId(Long userId);

    @Query("SELECT u FROM UserPoints u ORDER BY u.totalPoints DESC")
    List<UserPoints> findLeaderboard();

    @Query("SELECT u FROM UserPoints u ORDER BY u.totalPoints DESC LIMIT :limit")
    List<UserPoints> findTopUsers(int limit);
}
