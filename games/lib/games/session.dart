import 'package:flutter/material.dart';

import 'arrow.dart';
import 'blocks.dart';
import 'bus.dart';
import 'munch.dart';
import 'queens.dart';

/// What the shell gives a game: the level, a seed, and callbacks.
class GameSession {
  GameSession({
    required this.level,
    required this.seed,
    required this.onWin,
    required this.onFail,
    this.onScore,
    this.demo = false,
  });

  /// Store-screenshot mode: games may pre-fill a nicer mid-game state.
  final bool demo;

  final int level;
  final int seed;
  final VoidCallback onWin;
  final VoidCallback onFail;

  /// Endless games report score changes here.
  final ValueChanged<int>? onScore;

  /// Bumped by the shell when the player spends a hint.
  final hint = ValueNotifier<int>(0);

  /// Bumped by the shell when the player revives (endless games).
  final revive = ValueNotifier<int>(0);
}

Widget buildGame(String game, GameSession session) => switch (game) {
  'arrow' => ArrowGame(session: session),
  'queens' => QueensGame(session: session),
  'blocks' => BlocksGame(session: session),
  'munch' => MunchGame(session: session),
  'bus' => BusGame(session: session),
  _ => throw ArgumentError('Unknown game $game'),
};

/// Small row of hearts for in-level mistakes.
class Hearts extends StatelessWidget {
  const Hearts({super.key, required this.left, this.total = 3});
  final int left;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              i < left ? Icons.favorite : Icons.favorite_border,
              color: Colors.red.shade600,
              size: 26,
            ),
          ),
      ],
    );
  }
}
