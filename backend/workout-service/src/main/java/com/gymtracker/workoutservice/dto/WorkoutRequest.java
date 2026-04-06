package com.gymtracker.workoutservice.dto;

import com.gymtracker.workoutservice.entity.Workout.DifficultyLevel;
import com.gymtracker.workoutservice.entity.Workout.WorkoutType;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class WorkoutRequest {

    @NotBlank(message = "Workout name is required")
    private String name;

    private String description;

    private WorkoutType type;

    private DifficultyLevel difficulty;

    private Integer durationMinutes;

    private LocalDate workoutDate;

    private Boolean completed;

    private Integer caloriesBurned;

    private String notes;

    private List<ExerciseDto> exercises;

    @Data
    public static class ExerciseDto {
        private String name;
        private Integer sets;
        private Integer reps;
        private Double weight;
        private Integer durationSeconds;
        private String notes;
    }
}
