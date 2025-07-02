import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as flutter_provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewmodels/note_viewmodel.dart';
import 'views/home_view.dart';
import 'views/auth_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ukwhxuqmdblcstwyqoqk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVrd2h4dXFtZGJsY3N0d3lxb3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NDMyMDIsImV4cCI6MjA2NzAxOTIwMn0.l6ixI68KbSFslzg4DcieuPRzfL3QoUXlSc3NT29nOLI',
  );

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return flutter_provider.ChangeNotifierProvider(
      create: (_) => NoteViewModel(),
      child: MaterialApp(
        title: 'Notes App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: session != null ? const HomeView() : const AuthView(),
      ),
    );
  }
}
