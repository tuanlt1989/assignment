import 'package:flutter/material.dart';

import 'culprit.dart';
import 'patches.dart';
import 'putt.dart';
import 'pips.dart';
import 'weave.dart';
import 'queens.dart';
import 'tango.dart';

/// What the shell gives a game: difficulty, puzzle number, a seed, callbacks.
///
/// Contract for every game widget:
/// * Build a puzzle from ([difficulty], [level], [seed]) deterministically
///   (same inputs → same puzzle; the daily challenge relies on this).
/// * Call [onWin] once when solved. Call [onFail] only for a real loss
///   (e.g. out of hearts / strokes); the shell offers a free retry.
/// * Call [addMistake] for each mistake (wrong move, extra stroke...). The
///   shell turns mistakes + hints into 1–3 stars.
/// * Listen to [hint]: each bump = reveal one helpful step.
class GameSession {
  GameSession({
    required this.level,
    required this.seed,
    required this.onWin,
    required this.onFail,
    this.difficulty = 0,
    this.onScore,
    this.demo = false,
  });

  /// 0 easy, 1 medium, 2 hard, 3 expert.
  final int difficulty;

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

  /// Mistakes so far in this attempt (drives the star rating).
  final mistakes = ValueNotifier<int>(0);

  void addMistake() => mistakes.value++;
}

/// [lang] is the UI language (Word Weave picks its dictionary from it).
Widget buildGame(String game, GameSession session, {String lang = 'en'}) =>
    switch (game) {
      'queens' => QueensGame(session: session),
      'weave' => WeaveGame(session: session, lang: lang),
      'pips' => PipsGame(session: session),
      'putt' => PuttGame(session: session),
      'patches' => PatchGame(session: session),
      'tango' => TangoGame(session: session),
      'culprit' => CulpritGame(session: session, lang: lang),
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
