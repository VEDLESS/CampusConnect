import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/study_note.dart';
import '../../profile/presentation/profile_providers.dart';
import 'notes_providers.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedSemesterFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUploadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const UploadNoteForm(),
    );
  }

  Future<void> _downloadOrOpenUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file URL: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadBottomSheet(context),
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Upload Material'),
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search subjects or notes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<int?>(
                  value: _selectedSemesterFilter,
                  hint: const Text('Sem'),
                  underline: const SizedBox(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSemesterFilter = value;
                    });
                  },
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('All')),
                    ...List.generate(8, (index) {
                      final sem = index + 1;
                      return DropdownMenuItem<int?>(
                        value: sem,
                        child: Text('Sem $sem'),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: notesAsync.when(
              data: (notes) {
                final filteredNotes = notes.where((note) {
                  final matchesSearch = note.title.toLowerCase().contains(_searchQuery) ||
                      note.subject.toLowerCase().contains(_searchQuery) ||
                      note.description.toLowerCase().contains(_searchQuery);
                  final matchesSem = _selectedSemesterFilter == null || note.semester == _selectedSemesterFilter;
                  return matchesSearch && matchesSem;
                }).toList();

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_outlined, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No study materials found.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          child: Icon(Icons.picture_as_pdf_outlined, color: theme.colorScheme.primary),
                        ),
                        title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${note.subject} • Semester ${note.semester}'),
                            const SizedBox(height: 4),
                            Text('Uploaded by: ${note.uploaderName}', style: theme.textTheme.bodySmall),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (note.uploaderId == FirebaseAuth.instance.currentUser?.uid)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: theme.colorScheme.error,
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Material?'),
                                      content: const Text('Are you sure you want to delete this study material?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ref.read(notesRepositoryProvider).deleteNote(note.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Material deleted successfully.')),
                                      );
                                    }
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.download_for_offline_outlined),
                              color: theme.colorScheme.primary,
                              onPressed: () => _downloadOrOpenUrl(note.fileUrl),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading study materials: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class UploadNoteForm extends ConsumerStatefulWidget {
  const UploadNoteForm({super.key});

  @override
  ConsumerState<UploadNoteForm> createState() => _UploadNoteFormState();
}

class _UploadNoteFormState extends ConsumerState<UploadNoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subjectController = TextEditingController();
  int _selectedSemester = 1;

  PlatformFile? _pickedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      setState(() {
        _pickedFile = result.files.first;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate() || _pickedFile == null) {
      if (_pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file to upload.')),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final currentProfile = ref.read(userProfileProvider).value;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final uploaderName = currentProfile?.displayName ?? currentUser.displayName ?? 'Anonymous';

    try {
      // 1. Upload to Firebase Storage
      final fileRef = FirebaseStorage.instance
          .ref()
          .child('notes/${DateTime.now().millisecondsSinceEpoch}_${_pickedFile!.name}');
      
      late String downloadUrl;
      if (kIsWeb) {
        final uploadTask = fileRef.putData(_pickedFile!.bytes!);
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        final uploadTask = fileRef.putFile(File(_pickedFile!.path!));
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      // 2. Save note to Firestore
      final note = StudyNote(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subject: _subjectController.text.trim(),
        semester: _selectedSemester,
        fileUrl: downloadUrl,
        fileName: _pickedFile!.name,
        uploaderId: currentUser.uid,
        uploaderName: uploaderName,
        uploadedAt: DateTime.now(),
      );

      await ref.read(notesRepositoryProvider).uploadNote(note);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semesters = List.generate(8, (index) => index + 1);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload Study Material',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter subject name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description (Topic details)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'Target Semester',
                  border: OutlineInputBorder(),
                ),
                items: semesters
                    .map((sem) => DropdownMenuItem(
                          value: sem,
                          child: Text('Semester $sem'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSemester = val);
                },
              ),
              const SizedBox(height: 20),

              // File Picker Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Select File'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedFile != null ? _pickedFile!.name : 'No file selected (PDF, JPG, etc.)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isUploading ? null : _upload,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Upload & Share'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


