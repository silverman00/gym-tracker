package com.gymtracker.workoutservice.repository;

import com.gymtracker.workoutservice.entity.Workout;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface WorkoutRepository extends JpaRepository<Workout, Long> {

    List<Workout> findByUserIdOrderByCreatedAtDesc(Long userId);

    List<Workout> findByUserIdAndWorkoutDateBetweenOrderByWorkoutDateDesc(
            Long userId, LocalDate start, LocalDate end);

    List<Workout> findByUserIdAndCompletedTrueOrderByCreatedAtDesc(Long userId);

    @Query("SELECT COUNT(w) FROM Workout w WHERE w.userId = :userId AND w.completed = true")
    Long countCompletedByUserId(Long userId);
}
