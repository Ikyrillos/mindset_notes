import 'dart:developer';

// Repeating yourself

// DRY dont' repeat yourself

// Dart thre is no multiple inhertince
// but you can user multiple mixin. seprated with , comma

class UserController with LogManager {
  Future<void> fetchUsers() async {}
}

class ProjectController {
  Future<void> fetchProjects() async {}
}

class UiController {
  Future<void> drawUI() async {}
}

// some tool
mixin LogManager {
  final int logTimes = 5;

  void logAction(String msg) {
    log(msg);
  }
}
