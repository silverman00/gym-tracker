package com.gymtracker.pointsservice.controller;

import com.gymtracker.pointsservice.dto.AddPointsRequest;
import com.gymtracker.pointsservice.dto.LeaderboardEntry;
import com.gymtracker.pointsservice.entity.PointsTransaction;
import com.gymtracker.pointsservice.entity.UserPoints;
import com.gymtracker.pointsservice.service.PointsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/points")
@RequiredArgsConstructor
public class PointsController {

    private final PointsService pointsService;

    @PostMapping
    public ResponseEntity<UserPoints> addPoints(@Valid @RequestBody AddPointsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(pointsService.addPoints(request));
    }

    @PostMapping("/workout-complete")
    public ResponseEntity<UserPoints> workoutComplete(
            @RequestHeader("X-User-Id") Long userId,
            @RequestHeader(value = "X-Username", required = false) String username,
            @RequestParam Long workoutId) {
        return ResponseEntity.ok(
                pointsService.addWorkoutCompletionPoints(userId, username, workoutId));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<UserPoints> getUserPoints(@PathVariable Long userId) {
        return ResponseEntity.ok(pointsService.getUserPoints(userId));
    }

    @GetMapping("/leaderboard")
    public ResponseEntity<List<LeaderboardEntry>> getLeaderboard() {
        return ResponseEntity.ok(pointsService.getLeaderboard());
    }

    @GetMapping("/user/{userId}/transactions")
    public ResponseEntity<List<PointsTransaction>> getUserTransactions(@PathVariable Long userId) {
        return ResponseEntity.ok(pointsService.getUserTransactions(userId));
    }
}
