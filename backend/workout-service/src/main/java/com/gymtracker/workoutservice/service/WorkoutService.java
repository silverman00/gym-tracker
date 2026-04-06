package com.gymtracker.workoutservice.service;

import com.gymtracker.workoutservice.dto.WorkoutRequest;
import com.gymtracker.workoutservice.entity.Exercise;
import com.gymtracker.workoutservice.entity.Workout;
import com.gymtracker.workoutservice.repository.WorkoutRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

@Slf4j
@Service
@RequiredArgsConstructor
public class WorkoutService {

    private final WorkoutRepository workoutRepository;

    @Transactional
    public Workout createWorkout(Long userId, WorkoutRequest request) {
        Workout workout = Workout.builder()
                .userId(userId)
                .name(request.getName())
                .description(request.getDescription())
                .type(request.getType() != null ? request.getType() : Workout.WorkoutType.STRENGTH)
                .difficulty(request.getDifficulty() != null ? request.getDifficulty() : Workout.DifficultyLevel.INTERMEDIATE)
                .durationMinutes(request.getDurationMinutes())
                .workoutDate(request.getWorkoutDate())
                .completed(request.getCompleted() != null ? request.getCompleted() : false)
                .caloriesBurned(request.getCaloriesBurned())
                .notes(request.getNotes())
                .exercises(new ArrayList<>())
                .build();

        if (request.getExercises() != null) {
            request.getExercises().forEach(exDto -> {
                Exercise exercise = Exercise.builder()
                        .workout(workout)
                        .name(exDto.getName())
                        .sets(exDto.getSets())
                        .reps(exDto.getReps())
                        .weight(exDto.getWeight())
                        .durationSeconds(exDto.getDurationSeconds())
                        .notes(exDto.getNotes())
                        .build();
                workout.getExercises().add(exercise);
            });
        }

        Workout saved = workoutRepository.save(workout);
        log.info("Workout '{}' created for user {}", saved.getName(), userId);
        return saved;
    }

    public List<Workout> getUserWorkouts(Long userId) {
        return workoutRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public Workout getWorkout(Long workoutId) {
        return workoutRepository.findById(workoutId)
                .orElseThrow(() -> new NoSuchElementException("Workout not found with id: " + workoutId));
    }

    @Transactional
    public Workout updateWorkout(Long workoutId, Long userId, WorkoutRequest request) {
        Workout workout = getWorkoutByIdAndUserId(workoutId, userId);

        if (request.getName() != null)           workout.setName(request.getName());
        if (request.getDescription() != null)    workout.setDescription(request.getDescription());
        if (request.getType() != null)           workout.setType(request.getType());
        if (request.getDifficulty() != null)     workout.setDifficulty(request.getDifficulty());
        if (request.getDurationMinutes() != null) workout.setDurationMinutes(request.getDurationMinutes());
        if (request.getWorkoutDate() != null)    workout.setWorkoutDate(request.getWorkoutDate());
        if (request.getCompleted() != null)      workout.setCompleted(request.getCompleted());
        if (request.getCaloriesBurned() != null) workout.setCaloriesBurned(request.getCaloriesBurned());
        if (request.getNotes() != null)          workout.setNotes(request.getNotes());

        if (request.getExercises() != null) {
            workout.getExercises().clear();
            request.getExercises().forEach(exDto -> {
                Exercise exercise = Exercise.builder()
                        .workout(workout)
                        .name(exDto.getName())
                        .sets(exDto.getSets())
                        .reps(exDto.getReps())
                        .weight(exDto.getWeight())
                        .durationSeconds(exDto.getDurationSeconds())
                        .notes(exDto.getNotes())
                        .build();
                workout.getExercises().add(exercise);
            });
        }

        return workoutRepository.save(workout);
    }

    @Transactional
    public void deleteWorkout(Long workoutId, Long userId) {
        Workout workout = getWorkoutByIdAndUserId(workoutId, userId);
        workoutRepository.delete(workout);
        log.info("Workout {} deleted by user {}", workoutId, userId);
    }

    public Long countCompletedWorkouts(Long userId) {
        return workoutRepository.countCompletedByUserId(userId);
    }

    private Workout getWorkoutByIdAndUserId(Long workoutId, Long userId) {
        Workout workout = getWorkout(workoutId);
        if (!workout.getUserId().equals(userId)) {
            throw new SecurityException("You are not authorized to modify this workout");
        }
        return workout;
    }
}
