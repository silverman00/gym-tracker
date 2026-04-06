class Exercise {
  final int? id;
  final String? name;
  final int? sets;
  final int? reps;
  final double? weight;
  final int? durationSeconds;
  final String? notes;

  const Exercise({
    this.id,
    this.name,
    this.sets,
    this.reps,
    this.weight,
    this.durationSeconds,
    this.notes,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id:              json['id'] as int?,
        name:            json['name'] as String?,
        sets:            json['sets'] as int?,
        reps:            json['reps'] as int?,
        weight:          (json['weight'] as num?)?.toDouble(),
        durationSeconds: json['durationSeconds'] as int?,
        notes:           json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (sets != null) 'sets': sets,
        if (reps != null) 'reps': reps,
        if (weight != null) 'weight': weight,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (notes != null) 'notes': notes,
      };
}

class Workout {
  final int? id;
  final int? userId;
  final String name;
  final String? description;
  final String? type;
  final String? difficulty;
  final int? durationMinutes;
  final String? workoutDate;
  final bool completed;
  final int? caloriesBurned;
  final String? notes;
  final List<Exercise> exercises;
  final String? createdAt;

  const Workout({
    this.id,
    this.userId,
    required this.name,
    this.description,
    this.type,
    this.difficulty,
    this.durationMinutes,
    this.workoutDate,
    this.completed = false,
    this.caloriesBurned,
    this.notes,
    this.exercises = const [],
    this.createdAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id:              json['id'] as int?,
        userId:          json['userId'] as int?,
        name:            json['name'] as String,
        description:     json['description'] as String?,
        type:            json['type'] as String?,
        difficulty:      json['difficulty'] as String?,
        durationMinutes: json['durationMinutes'] as int?,
        workoutDate:     json['workoutDate'] as String?,
        completed:       json['completed'] as bool? ?? false,
        caloriesBurned:  json['caloriesBurned'] as int?,
        notes:           json['notes'] as String?,
        exercises:       (json['exercises'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt:       json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name':            name,
        if (description != null) 'description': description,
        if (type != null) 'type': type,
        if (difficulty != null) 'difficulty': difficulty,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (workoutDate != null) 'workoutDate': workoutDate,
        'completed':       completed,
        if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
        if (notes != null) 'notes': notes,
        'exercises':       exercises.map((e) => e.toJson()).toList(),
      };
}
