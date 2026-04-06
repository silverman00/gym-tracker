import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/points_provider.dart';
import '../models/points.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pointsProvider = context.watch<PointsProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Points & Leaderboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final userId = auth.currentUser?.id;
              if (userId != null) {
                pointsProvider.refresh(userId);
              }
            },
          ),
        ],
      ),
      body: pointsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final userId = context.read<AuthProvider>().currentUser?.id;
                if (userId != null) {
                  await context.read<PointsProvider>().refresh(userId);
                }
              },
              child: CustomScrollView(
                slivers: [
                  // ── My Points Card ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _MyPointsCard(
                      points: pointsProvider.userPoints,
                      currentUserId: auth.currentUser?.id,
                    ),
                  ),

                  // ── Leaderboard header ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Leaderboard',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // ── Leaderboard list ─────────────────────────────────────
                  pointsProvider.leaderboard.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(child: Text('No leaderboard data yet')),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _LeaderboardTile(
                              entry: pointsProvider.leaderboard[i],
                              currentUserId: auth.currentUser?.id,
                            ),
                            childCount: pointsProvider.leaderboard.length,
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}

class _MyPointsCard extends StatelessWidget {
  final UserPoints? points;
  final int? currentUserId;
  const _MyPointsCard({this.points, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Points',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 14)),
                Text('${points?.totalPoints ?? 0}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold)),
                Text(
                  '${points?.workoutsCompleted ?? 0} workouts completed',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int? currentUserId;
  const _LeaderboardTile({required this.entry, this.currentUserId});

  Widget _rankWidget() {
    if (entry.rank == 1) return const Text('🥇', style: TextStyle(fontSize: 24));
    if (entry.rank == 2) return const Text('🥈', style: TextStyle(fontSize: 24));
    if (entry.rank == 3) return const Text('🥉', style: TextStyle(fontSize: 24));
    return CircleAvatar(
      radius: 16,
      child: Text('${entry.rank}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = entry.userId == currentUserId;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isMe
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: ListTile(
        leading: _rankWidget(),
        title: Row(
          children: [
            Text(entry.username ?? 'User ${entry.userId}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isMe)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('You',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
          ],
        ),
        subtitle: Text('${entry.workoutsCompleted} workouts completed'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${entry.totalPoints}',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary)),
            const Text('pts', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
