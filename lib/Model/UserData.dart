class UserData {
  final String uid;
  final String name;
  final String email;
  final String account_created;
  final String last_app_opened;
  final bool isPurchased;
  final int countdownCount;

  UserData({
    required this.uid,
    required this.name,
    required this.email,
    required this.account_created,
    required this.last_app_opened,
    required this.isPurchased,
    required this.countdownCount,
  });
}
