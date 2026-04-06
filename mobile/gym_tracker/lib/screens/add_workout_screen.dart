import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../utils/constants.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl        = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _durationCtrl    = TextEditingController();
  final _caloriesCtrl    = TextEditingController();
  final _notesCtrl       = TextEditingController();

  String _type       = 'STRENGTH';
  String _difficulty = 'INTERMEDIATE';
  bool   _completed  = false;

  final List<Map<String, dynamic>> _exercises = [];

  static const _types = [
    'STRENGTH', 'CARDIO', 'FLEXIBILITY', 'HIIT',
    'CROSSFIT', 'YOGA', 'SPORTS', 'OTHER',
  ];
  static const _difficulties = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await context.read<WorkoutProvider>().createWorkout(
          name:            _nameCtrl.text.trim(),
          description:     _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          type:            _type,
          difficulty:      _difficulty,
          durationMinutes: _durationCtrl.text.isEmpty
              ? null
              : int.tryParse(_durationCtrl.text),
          completed:       _completed,
          caloriesBurned:  _caloriesCtrl.text.isEmpty
              ? null
              : int.tryParse(_caloriesCtrl.text),
          notes:           _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          exercises:       _exercises,
        );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_completed
              ? 'Workout added! +10 points earned 🎉'
              : 'Workout added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(context.read<WorkoutProvider>().error ?? 'Failed to save'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addExercise() {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final weightCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16, 24, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Exercise',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: setsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sets'),
                )),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: repsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps'),
                )),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                )),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    setState(() {
                      _exercises.add({
                        'name':   nameCtrl.text,
                        if (setsCtrl.text.isNotEmpty)   'sets':   int.tryParse(setsCtrl.text),
                        if (repsCtrl.text.isNotEmpty)   'reps':   int.tryParse(repsCtrl.text),
                        if (weightCtrl.text.isNotEmpty) 'weight': double.tryParse(weightCtrl.text),
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<WorkoutProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _submit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Name ────────────────────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Workout Name *',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────────────
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // ── Type & Difficulty ────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: _types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    items: _difficulties
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() => _difficulty = v!),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Duration & Calories ──────────────────────────────────────
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (min)',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _caloriesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories burned',
                      prefixIcon: Icon(Icons.local_fire_department_outlined),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Notes ────────────────────────────────────────────────────
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 8),

              // ── Mark as completed ────────────────────────────────────────
              SwitchListTile(
                value: _completed,
                onChanged: (v) => setState(() => _completed = v),
                title: const Text('Mark as Completed'),
                subtitle: const Text('Earn +10 points instantly'),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),

              // ── Exercises ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Exercises',
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              ..._exercises.asMap().entries.map((entry) {
                final i = entry.key;
                final ex = entry.value;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(ex['name'] as String),
                  subtitle: Text([
                    if (ex['sets'] != null) '${ex['sets']} sets',
                    if (ex['reps'] != null) '${ex['reps']} reps',
                    if (ex['weight'] != null) '${ex['weight']} kg',
                  ].join(' · ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () =>
                        setState(() => _exercises.removeAt(i)),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // ── Submit button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Workout',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
