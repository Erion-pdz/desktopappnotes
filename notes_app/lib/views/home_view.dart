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
  String? selectedTag;
  String sortMode = 'date';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = flutter_provider.Provider.of<NoteViewModel>(context, listen: false);
      viewModel.loadNotes();
    });
  }

  List<Note> _getSortedNotes(NoteViewModel viewModel) {
    List<Note> filtered = selectedTag == null || selectedTag == 'Tous'
        ? viewModel.notes
        : viewModel.getNotesByTag(selectedTag!);
    if (sortMode == 'alpha') {
      filtered = [...filtered]
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = flutter_provider.Provider.of<NoteViewModel>(context);
    final allTags = <String>{'Tous'};
    for (final note in viewModel.notes) {
      allTags.addAll(note.tags.where((t) => t.isNotEmpty));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          DropdownButton<String>(
            value: selectedTag ?? 'Tous',
            items: allTags.map((tag) => DropdownMenuItem(value: tag, child: Text(tag))).toList(),
            onChanged: (val) => setState(() => selectedTag = val),
            underline: Container(),
            icon: const Icon(Icons.label),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: sortMode,
            items: const [
              DropdownMenuItem(value: 'date', child: Text('Date')),
              DropdownMenuItem(value: 'alpha', child: Text('A-Z')),
            ],
            onChanged: (val) => setState(() => sortMode = val!),
            underline: Container(),
            icon: const Icon(Icons.sort_by_alpha),
          ),
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
      body: _getSortedNotes(viewModel).isEmpty
          ? const Center(child: Text("Aucune note pour l'instant."))
          : ListView.builder(
              itemCount: _getSortedNotes(viewModel).length,
              itemBuilder: (context, index) {
                Note note = _getSortedNotes(viewModel)[index];
                return NoteCard(note: note);
              },
            ),
    );
  }
}
