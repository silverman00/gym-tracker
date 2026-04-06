import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import 'add_workout_screen.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>().workouts;
    final isLoading = context.watch<WorkoutProvider>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final userId = context.read<AuthProvider>().currentUser?.id;
              if (userId != null) {
                context.read<WorkoutProvider>().loadWorkouts(userId);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Workout'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : workouts.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    final userId =
                        context.read<AuthProvider>().currentUser?.id;
                    if (userId != null) {
                      await context.read<WorkoutProvider>().loadWorkouts(userId);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: workouts.length,
                    itemBuilder: (ctx, i) =>
                        _WorkoutCard(workout: workouts[i]),
                  ),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No workouts yet',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Tap + to add your first workout',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  const _WorkoutCard({required this.workout});

  Color _typeColor(BuildContext ctx) {
    final primary = Theme.of(ctx).colorScheme.primary;
    return switch (workout.type ?? '') {
      'CARDIO'      => Colors.orange,
      'HIIT'        => Colors.red,
      'YOGA'        => Colors.purple,
      'FLEXIBILITY' => Colors.green,
      _             => primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _typeColor(context).withOpacity(0.15),
          child: Icon(Icons.fitness_center, color: _typeColor(context)),
        ),
        title: Text(workout.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (workout.type != null)
              Text(workout.type!,
                  style: TextStyle(
                      color: _typeColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            if (workout.durationMinutes != null)
              Text('${workout.durationMinutes} min',
                  style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (workout.completed)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              _CompleteButton(workoutId: workout.id!),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Delete "${workout.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<WorkoutProvider>().deleteWorkout(workout.id!);
    }
  }
}

class _CompleteButton extends StatelessWidget {
  final int workoutId;
  const _CompleteButton({required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.check_circle_outline),
      tooltip: 'Mark complete (+10 pts)',
      onPressed: () async {
        final success =
            await context.read<WorkoutProvider>().markComplete(workoutId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(success
                ? '✓ Workout complete! +10 points'
                : 'Failed to update'),
            backgroundColor: success ? Colors.green : Colors.red,
          ));
        }
      },
    );
  }
}
