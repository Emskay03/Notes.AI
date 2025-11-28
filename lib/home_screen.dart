import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_ai/add_note_screen.dart';
import 'package:notes_ai/Widgets/note_card.dart'; // Import your new NoteCard widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        backgroundColor: Theme.of(context).colorScheme.primary, // Make AppBar consistent
        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text/Icon color
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No notes yet! Add one using the + button.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final note = snapshot.data!.docs[index];
              final noteData = note.data() as Map<String, dynamic>;
              return NoteCard(
                noteId: note.id,
                title: noteData['title'] ?? '',
                content: noteData['content'] ?? '',
                summary: noteData['summary'] ?? '', // Pass the summary
                onDelete: () {
                  // This is a placeholder for potential swipe-to-delete action
                  // For now, deletion happens in NoteDetailScreen
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Note',
        backgroundColor: Theme.of(context).colorScheme.secondary, // Modern FAB color
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}
