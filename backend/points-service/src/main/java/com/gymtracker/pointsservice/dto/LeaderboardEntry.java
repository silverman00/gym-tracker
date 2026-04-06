package com.gymtracker.pointsservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaderboardEntry {

    private Integer rank;
    private Long userId;
    private String username;
    private Integer totalPoints;
    private Integer workoutsCompleted;
}
