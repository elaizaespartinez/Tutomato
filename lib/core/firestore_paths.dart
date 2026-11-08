/// Collection names in one place so a typo can't create a second collection.
class FirestorePaths {
  FirestorePaths._();

  static const users = 'users';
  static const publicProfiles = 'publicProfiles';
  static const friendships = 'friendships';

  // sub-collections of users/{uid}
  static const tasks = 'tasks';
  static const sessions = 'sessions';
  static const cheers = 'cheers';

  /// Both friends always compute the same id, so a friendship can only exist
  /// once: the two uids sorted and joined.
  static String pairId(String a, String b) {
    final sorted = [a, b]..sort();
    return sorted.join('_');
  }
}
