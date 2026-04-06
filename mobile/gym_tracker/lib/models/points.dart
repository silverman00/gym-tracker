class UserPoints {
  final int? id;
  final int userId;
  final String? username;
  final int totalPoints;
  final int workoutsCompleted;
  final String? lastUpdated;

  const UserPoints({
    this.id,
    required this.userId,
    this.username,
    required this.totalPoints,
    required this.workoutsCompleted,
    this.lastUpdated,
  });

  factory UserPoints.fromJson(Map<String, dynamic> json) => UserPoints(
        id:                 json['id'] as int?,
        userId:             json['userId'] as int,
        username:           json['username'] as String?,
        totalPoints:        json['totalPoints'] as int? ?? 0,
        workoutsCompleted:  json['workoutsCompleted'] as int? ?? 0,
        lastUpdated:        json['lastUpdated'] as String?,
      );
}

class LeaderboardEntry {
  final int rank;
  final int userId;
  final String? username;
  final int totalPoints;
  final int workoutsCompleted;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    this.username,
    required this.totalPoints,
    required this.workoutsCompleted,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank:              json['rank'] as int,
        userId:            json['userId'] as int,
        username:          json['username'] as String?,
        totalPoints:       json['totalPoints'] as int? ?? 0,
        workoutsCompleted: json['workoutsCompleted'] as int? ?? 0,
      );
}
