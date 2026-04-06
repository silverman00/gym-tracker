package com.gymtracker.workoutservice.controller;

import com.gymtracker.workoutservice.dto.WorkoutRequest;
import com.gymtracker.workoutservice.entity.Workout;
import com.gymtracker.workoutservice.service.WorkoutService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/workouts")
@RequiredArgsConstructor
public class WorkoutController {

    private final WorkoutService workoutService;

    // Header injected by API Gateway after JWT validation
    private static final String USER_ID_HEADER = "X-User-Id";

    @PostMapping
    public ResponseEntity<Workout> createWorkout(
            @RequestHeader(USER_ID_HEADER) Long userId,
            @Valid @RequestBody WorkoutRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(workoutService.createWorkout(userId, request));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Workout>> getUserWorkouts(@PathVariable Long userId) {
        return ResponseEntity.ok(workoutService.getUserWorkouts(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Workout> getWorkout(@PathVariable Long id) {
        return ResponseEntity.ok(workoutService.getWorkout(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Workout> updateWorkout(
            @PathVariable Long id,
            @RequestHeader(USER_ID_HEADER) Long userId,
            @RequestBody WorkoutRequest request) {
        return ResponseEntity.ok(workoutService.updateWorkout(id, userId, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteWorkout(
            @PathVariable Long id,
            @RequestHeader(USER_ID_HEADER) Long userId) {
        workoutService.deleteWorkout(id, userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/user/{userId}/completed/count")
    public ResponseEntity<Long> countCompleted(@PathVariable Long userId) {
        return ResponseEntity.ok(workoutService.countCompletedWorkouts(userId));
    }
}
