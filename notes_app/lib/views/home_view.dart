import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as flutter_provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';
import '../viewmodels/note_viewmodel.dart';
import '../widgets/note_card.dart';
import 'editor_view.dart';
import 'auth_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = flutter_provider.Provider.of<NoteViewModel>(context, listen: false);
      viewModel.loadNotes(); // ← on charge les notes au démarrage
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = flutter_provider.Provider.of<NoteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthView()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadNotes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditorView()),
        ),
        child: const Icon(Icons.add),
      ),
      body: viewModel.notes.isEmpty
          ? const Center(child: Text("Aucune note pour l'instant."))
          : ListView.builder(
              itemCount: viewModel.notes.length,
              itemBuilder: (context, index) {
                Note note = viewModel.notes[index];
                return NoteCard(note: note);
              },
            ),
    );
  }
}
