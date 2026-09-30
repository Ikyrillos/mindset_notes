import 'package:flutter/material.dart';
import 'package:mindset_notes/core/routes/route_constants.dart';
import 'package:mindset_notes/features/auth/presentation/auth_screen.dart';
import 'package:mindset_notes/features/profile/presnetation/user_screen.dart';

import '../../features/notes/presentation/pages/note_editor_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.notes:
        return MaterialPageRoute(
          builder: (_) => const NotesPage(),
          settings: settings,
        );

      case RouteConstants.noteEditor:
        return MaterialPageRoute(
          builder: (_) => NoteEditorPage(),
          settings: settings,
        );

      case RouteConstants.userScreen:
        return MaterialPageRoute(
          builder: (_) => UserScreen(),
          settings: settings,
        );

      case RouteConstants.auth:
        return MaterialPageRoute(
          builder: (_) => AuthScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _UnknownRoutePage(),
          settings: settings,
        );
    }
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Route not found')));
  }
}
