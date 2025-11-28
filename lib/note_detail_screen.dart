import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:notes_ai/secrets.dart'; // Your llamaApiKey here

class NoteDetailScreen extends StatefulWidget {
  final String noteId;
  final String currentTitle;
  final String currentContent;
  final String currentSummary;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    required this.currentTitle,
    required this.currentContent,
    this.currentSummary = '',
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _summaryController;

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSummarizing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _contentController = TextEditingController(text: widget.currentContent);
    _summaryController = TextEditingController(text: widget.currentSummary);
  }

  // ------------------------------
  // UPDATE NOTE
  // ------------------------------
  Future<void> _updateNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.noteId)
            .update({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
        });

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update note: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // ------------------------------
  // DELETE NOTE
  // ------------------------------
  Future<void> _deleteNote() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.noteId)
            .delete();

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete note: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // ------------------------------
  // SUMMARIZE NOTE (Groq LLaMA 3.1)
  // ------------------------------
  Future<void> _summarizeNote() async {
    setState(() {
      _isSummarizing = true;
      _summaryController.text = 'Generating summary...';
    });

    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $llamaApiKey",
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {
              "role": "system",
              "content": "Your job is to summarize the note. Output only the summary text. No greetings, no explanations, no formatting, no quotes, no prefixes."
            },
            {
              "role": "user",
              "content": _contentController.text.trim()
            }
          ],
          "temperature": 0.2,
          "max_tokens": 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String generatedSummary =
            data['choices'][0]['message']['content']?.trim() ??
                "No summary generated.";

        await FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.noteId)
            .update({
          'summary': generatedSummary,
          'lastSummarizedAt': Timestamp.now(),
        });

        setState(() => _summaryController.text = generatedSummary);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note summarized successfully!')),
        );
      } else {
        throw Exception(
            "Groq API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      setState(() => _summaryController.text = 'Error generating summary.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to summarize note: $e')),
      );

      print("Groq API error: $e");
    } finally {
      setState(() => _isSummarizing = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  // ------------------------------
  // UI
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading || _isSummarizing ? null : _deleteNote,
            tooltip: 'Delete Note',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading || _isSummarizing ? null : _updateNote,
            tooltip: 'Save Changes',
          ),
          IconButton(
            icon: _isSummarizing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            onPressed: _isLoading || _isSummarizing ? null : _summarizeNote,
            tooltip: 'Summarize Note with AI',
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),

              const SizedBox(height: 16),

              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Note Content',
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  expands: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter content' : null,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'AI Summary',
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                readOnly: true,
              ),

              if (_isLoading) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
