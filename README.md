# GymTracker — Microservices + Flutter

A complete Gym Tracker application built with **Spring Boot microservices** backend and a **Flutter** mobile app.

---

## Project Structure

```
GymTracker/
├── backend/
│   ├── api-gateway/          ← Spring Cloud Gateway  (port 8080)
│   ├── user-service/         ← Auth + profiles        (port 8081)
│   ├── workout-service/      ← Workout CRUD           (port 8082)
│   ├── points-service/       ← Points + Leaderboard   (port 8083)
│   ├── docker-compose.yml
│   └── .env.example
└── mobile/
    └── gym_tracker/          ← Flutter app
```

---

## Prerequisites

| Tool | Version |
|---|---|
| Java | 17+ |
| Maven | 3.9+ |
| Docker + Docker Compose | latest |
| Flutter | 3.x |
| Dart | 3.x |

---

## Step 1 — Set Up Neon PostgreSQL

1. Go to [console.neon.tech](https://console.neon.tech) and create a project
2. Create **3 databases**: `user_db`, `workout_db`, `points_db`
3. Copy the connection details (host, username, password)

---

## Step 2 — Configure Environment Variables

```bash
cd backend
cp .env.example .env
```

Edit `.env`:

```env
# Generate a 32-byte hex secret:  openssl rand -hex 32
JWT_SECRET=your_jwt_secret_here

DB_USERNAME=your_neon_username
DB_PASSWORD=your_neon_password

USER_DB_URL=jdbc:postgresql://ep-xxx.us-east-1.aws.neon.tech/user_db?sslmode=require
WORKOUT_DB_URL=jdbc:postgresql://ep-xxx.us-east-1.aws.neon.tech/workout_db?sslmode=require
POINTS_DB_URL=jdbc:postgresql://ep-xxx.us-east-1.aws.neon.tech/points_db?sslmode=require
```

---

## Step 3 — Run with Docker

```bash
cd backend
docker-compose up --build
```

All 4 services start automatically. The API is available at `http://localhost:8080`.

---

## Step 4 — Run Flutter App

```bash
cd mobile/gym_tracker
flutter pub get
flutter run
```

> **Physical device**: Update `baseUrl` in `lib/utils/constants.dart` to your machine's local IP (e.g., `http://192.168.1.10:8080`).

---

## API Reference

All requests go through the **API Gateway** on port `8080`.

### Authentication (public — no JWT needed)

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/signup` | Register new user |
| POST | `/api/auth/login` | Login, returns JWT token |

### Users (requires `Authorization: Bearer <token>`)

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/users/{id}` | Get user profile |
| PUT | `/api/users/{id}` | Update profile |
| GET | `/api/users/me` | Get current user |

### Workouts (requires JWT)

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/workouts` | Create workout |
| GET | `/api/workouts/user/{userId}` | Get user's workouts |
| GET | `/api/workouts/{id}` | Get single workout |
| PUT | `/api/workouts/{id}` | Update workout |
| DELETE | `/api/workouts/{id}` | Delete workout |

### Points (requires JWT, except leaderboard)

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/points/user/{userId}` | Get user's points |
| GET | `/api/points/leaderboard` | Public leaderboard |
| POST | `/api/points/workout-complete?workoutId=X` | Award +10 points |

---

## Example: Sign Up + Login

```bash
# Sign up
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"johndoe","email":"john@example.com","password":"secret123","fullName":"John Doe"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"johndoe","password":"secret123"}'
# Returns: { "accessToken": "eyJ...", "userId": 1, ... }

# Create workout (use token from login)
curl -X POST http://localhost:8080/api/workouts \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{"name":"Morning Run","type":"CARDIO","durationMinutes":30,"completed":true}'
```

---

## Architecture Overview

```
Flutter App
     │
     ▼ HTTP (JWT in Authorization header)
┌─────────────────────────────────────────┐
│           API Gateway (:8080)           │
│  • Validates JWT                        │
│  • Injects X-User-Id, X-Username headers│
│  • Routes to microservices              │
└──────┬──────────┬──────────┬────────────┘
       │          │          │
       ▼          ▼          ▼
  User Svc   Workout Svc  Points Svc
  (:8081)     (:8082)      (:8083)
    │            │            │
  Neon PG     Neon PG      Neon PG
  user_db    workout_db   points_db
```

---

## Service Ports

| Service | Local Port | Container Name |
|---|---|---|
| API Gateway | 8080 | gymtracker-api-gateway |
| User Service | 8081 | gymtracker-user-service |
| Workout Service | 8082 | gymtracker-workout-service |
| Points Service | 8083 | gymtracker-points-service |
