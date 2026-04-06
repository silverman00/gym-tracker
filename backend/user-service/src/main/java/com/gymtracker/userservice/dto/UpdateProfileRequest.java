package com.gymtracker.userservice.dto;

import lombok.Data;

@Data
public class UpdateProfileRequest {

    private String fullName;

    private Integer age;

    private Double weight;

    private Double height;

    private String profilePicture;
}
