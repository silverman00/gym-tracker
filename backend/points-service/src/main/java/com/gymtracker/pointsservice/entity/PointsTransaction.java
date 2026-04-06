package com.gymtracker.pointsservice.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "points_transactions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PointsTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Integer points;

    private String reason;

    private Long workoutId;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private TransactionType type = TransactionType.EARNED;

    @Column(nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum TransactionType {
        EARNED, BONUS, DEDUCTED
    }
}
