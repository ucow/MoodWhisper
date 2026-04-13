import 'package:uuid/uuid.dart';

class IdGenerator {
  IdGenerator._();

  static const Uuid _uuid = Uuid();

  /// Generates a new UUID v4
  static String generate() {
    return _uuid.v4();
  }

  /// Validates if a string is a valid UUID
  static bool isValid(String id) {
    try {
      Uuid.parse(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
