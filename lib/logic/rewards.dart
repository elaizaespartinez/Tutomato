import 'package:tutomato/core/constants.dart';

/// Study Points for one completed focus session.
///
/// The design shows "+25 Study Points" for a 25-minute session, so points
/// equal the focus minutes. Tying points to minutes also stops anyone farming
/// points with 1-minute sessions.
/// TODO(team): if you prefer a flat 25 per session, change this one line.
int pointsForFocusMinutes(int minutes) => minutes < 0 ? 0 : minutes;

class RipenessResult {
  const RipenessResult(this.level, this.ripeness, {required this.leveledUp});

  final int level;
  final int ripeness;
  final bool leveledUp;
}

/// "Pomodori ripeness +8%". Ripeness fills 0..99, then rolls into the next
/// level (e.g. level 3 at 96% + 8 -> level 4 at 4%).
RipenessResult applyRipeness({
  required int level,
  required int ripeness,
  int gain = AppConstants.ripenessPerSession,
}) {
  var total = ripeness + gain;
  var newLevel = level;
  while (total >= AppConstants.ripenessPerLevel) {
    total -= AppConstants.ripenessPerLevel;
    newLevel++;
  }
  return RipenessResult(newLevel, total, leveledUp: newLevel > level);
}
