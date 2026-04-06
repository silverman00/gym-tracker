package com.gymtracker.userservice.controller;

import com.gymtracker.userservice.dto.*;
import com.gymtracker.userservice.security.JwtTokenProvider;
import com.gymtracker.userservice.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider;

    // ── Auth endpoints (public) ──────────────────────────────────────────────

    @PostMapping("/auth/signup")
    public ResponseEntity<UserProfileResponse> signUp(@Valid @RequestBody SignUpRequest request) {
        UserProfileResponse response = userService.signUp(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/auth/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = userService.login(request);
        return ResponseEntity.ok(response);
    }

    // ── User profile endpoints (protected) ──────────────────────────────────

    @GetMapping("/users/{id}")
    public ResponseEntity<UserProfileResponse> getProfile(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getProfile(id));
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<UserProfileResponse> updateProfile(
            @PathVariable Long id,
            @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(userService.updateProfile(id, request));
    }

    // ── Token validation endpoint (called by API Gateway) ───────────────────

    @GetMapping("/auth/validate")
    public ResponseEntity<Boolean> validateToken(@RequestParam String token) {
        return ResponseEntity.ok(jwtTokenProvider.validateToken(token));
    }

    @GetMapping("/users/me")
    public ResponseEntity<UserProfileResponse> getCurrentUser(
            @AuthenticationPrincipal UserDetails userDetails) {
        // Extract user id from the JWT loaded into the security context
        String username = userDetails.getUsername();
        // We re-use the service layer's loadUserByUsername which returns the User entity
        com.gymtracker.userservice.entity.User user =
                (com.gymtracker.userservice.entity.User) userDetails;
        return ResponseEntity.ok(UserProfileResponse.fromUser(user));
    }
}
