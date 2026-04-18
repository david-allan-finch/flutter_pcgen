// Singleton marker for user-input selections.
final class UserSelection {
  UserSelection._();
  static final UserSelection _instance = UserSelection._();
  static UserSelection getInstance() => _instance;
}
