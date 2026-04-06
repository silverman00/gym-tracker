package com.gymtracker.userservice.dto;

import com.gymtracker.userservice.entity.User;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class UserProfileResponse {

    private Long id;
    private String username;
    private String email;
    private String fullName;
    private String profilePicture;
    private Integer age;
    private Double weight;
    private Double height;
    private LocalDateTime createdAt;

    public static UserProfileResponse fromUser(User user) {
        return UserProfileResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .profilePicture(user.getProfilePicture())
                .age(user.getAge())
                .weight(user.getWeight())
                .height(user.getHeight())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
