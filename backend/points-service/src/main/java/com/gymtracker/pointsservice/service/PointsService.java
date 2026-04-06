package com.gymtracker.pointsservice.service;

import com.gymtracker.pointsservice.dto.AddPointsRequest;
import com.gymtracker.pointsservice.dto.LeaderboardEntry;
import com.gymtracker.pointsservice.entity.PointsTransaction;
import com.gymtracker.pointsservice.entity.UserPoints;
import com.gymtracker.pointsservice.repository.PointsTransactionRepository;
import com.gymtracker.pointsservice.repository.UserPointsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class PointsService {

    private final UserPointsRepository userPointsRepository;
    private final PointsTransactionRepository transactionRepository;

    // Points per workout completion
    private static final int WORKOUT_COMPLETION_POINTS = 10;

    @Transactional
    public UserPoints addPoints(AddPointsRequest request) {
        UserPoints userPoints = userPointsRepository.findByUserId(request.getUserId())
                .orElseGet(() -> UserPoints.builder()
                        .userId(request.getUserId())
                        .username(request.getUsername())
                        .totalPoints(0)
                        .workoutsCompleted(0)
                        .build());

        // Update username if provided
        if (request.getUsername() != null) {
            userPoints.setUsername(request.getUsername());
        }

        PointsTransaction.TransactionType type =
                request.getType() != null ? request.getType() : PointsTransaction.TransactionType.EARNED;

        if (type == PointsTransaction.TransactionType.DEDUCTED) {
            userPoints.setTotalPoints(Math.max(0, userPoints.getTotalPoints() - request.getPoints()));
        } else {
            userPoints.setTotalPoints(userPoints.getTotalPoints() + request.getPoints());
        }

        if (request.getWorkoutId() != null) {
            userPoints.setWorkoutsCompleted(userPoints.getWorkoutsCompleted() + 1);
        }

        PointsTransaction transaction = PointsTransaction.builder()
                .userId(request.getUserId())
                .points(request.getPoints())
                .reason(request.getReason() != null ? request.getReason() : "Workout completed")
                .workoutId(request.getWorkoutId())
                .type(type)
                .build();

        transactionRepository.save(transaction);
        UserPoints saved = userPointsRepository.save(userPoints);

        log.info("Added {} points for user {}. Total: {}", request.getPoints(),
                request.getUserId(), saved.getTotalPoints());
        return saved;
    }

    @Transactional
    public UserPoints addWorkoutCompletionPoints(Long userId, String username, Long workoutId) {
        AddPointsRequest request = new AddPointsRequest();
        request.setUserId(userId);
        request.setUsername(username);
        request.setPoints(WORKOUT_COMPLETION_POINTS);
        request.setReason("Completed workout");
        request.setWorkoutId(workoutId);
        request.setType(PointsTransaction.TransactionType.EARNED);
        return addPoints(request);
    }

    public UserPoints getUserPoints(Long userId) {
        return userPointsRepository.findByUserId(userId)
                .orElseThrow(() -> new NoSuchElementException("Points not found for user: " + userId));
    }

    public List<LeaderboardEntry> getLeaderboard() {
        List<UserPoints> allPoints = userPointsRepository.findLeaderboard();
        AtomicInteger rank = new AtomicInteger(1);

        return allPoints.stream()
                .map(up -> LeaderboardEntry.builder()
                        .rank(rank.getAndIncrement())
                        .userId(up.getUserId())
                        .username(up.getUsername())
                        .totalPoints(up.getTotalPoints())
                        .workoutsCompleted(up.getWorkoutsCompleted())
                        .build())
                .collect(Collectors.toList());
    }

    public List<PointsTransaction> getUserTransactions(Long userId) {
        return transactionRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }
}
