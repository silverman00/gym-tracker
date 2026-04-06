package com.gymtracker.pointsservice.dto;

import com.gymtracker.pointsservice.entity.PointsTransaction.TransactionType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddPointsRequest {

    @NotNull
    private Long userId;

    private String username;

    @NotNull
    @Min(value = 1, message = "Points must be at least 1")
    private Integer points;

    private String reason;

    private Long workoutId;

    private TransactionType type;
}
