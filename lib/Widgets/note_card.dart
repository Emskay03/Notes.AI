// lib/widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:notes_ai/note_detail_screen.dart';

class NoteCard extends StatefulWidget {
  final String noteId;
  final String title;
  final String content;
  final String summary; // Ensure summary is passed
  final VoidCallback onDelete; // If we wanted a delete action here directly

  const NoteCard({
    super.key,
    required this.noteId,
    required this.title,
    required this.content,
    required this.summary,
    required this.onDelete, // Not used yet, but good to have for future swipe actions
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _isHovered = false;

  void _onEnter(PointerEvent details) {
    setState(() {
      _isHovered = true;
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme for consistent styling

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0, // Scale up slightly on hover
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NoteDetailScreen(
                  noteId: widget.noteId,
                  currentTitle: widget.title,
                  currentContent: widget.content,
                  currentSummary: widget.summary,
                ),
              ),
            );
          },
          child: Card(
            elevation: _isHovered ? 8.0 : 2.0, // "Levitate" effect
            shadowColor: _isHovered ? theme.colorScheme.primary.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Rounded corners for modern look
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title.isNotEmpty ? widget.title : 'Untitled Note',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.content.isNotEmpty ? widget.content : 'No content available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Optional: Display a summary indicator if available
                  if (widget.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text('Summarized', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
