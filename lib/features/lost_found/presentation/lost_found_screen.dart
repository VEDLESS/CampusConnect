import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/lost_found_item.dart';
import '../../profile/presentation/profile_providers.dart';
import 'lost_found_providers.dart';

class LostFoundScreen extends ConsumerStatefulWidget {
  const LostFoundScreen({super.key});

  @override
  ConsumerState<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends ConsumerState<LostFoundScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'All'; // All, Lost, Found

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ReportItemForm(),
    );
  }

  Future<void> _contactReporter(String scheme, String value) async {
    final Uri uri = Uri(scheme: scheme, path: value);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not contact reporter: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(lostFoundListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Hub'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportBottomSheet(context),
        icon: const Icon(Icons.report_gmailerrorred_outlined),
        label: const Text('Report Item'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
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

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Items'),
                  selected: _filterType == 'All',
                  onSelected: (val) => setState(() => _filterType = 'All'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Lost'),
                  selected: _filterType == 'Lost',
                  onSelected: (val) => setState(() => _filterType = 'Lost'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Found'),
                  selected: _filterType == 'Found',
                  onSelected: (val) => setState(() => _filterType = 'Found'),
                ),
              ],
            ),
          ),

          // List of Items
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filteredItems = items.where((item) {
                  final matchesSearch = item.title.toLowerCase().contains(_searchQuery) ||
                      item.description.toLowerCase().contains(_searchQuery) ||
                      item.location.toLowerCase().contains(_searchQuery);

                  if (_filterType == 'Lost') {
                    return matchesSearch && item.isLost;
                  } else if (_filterType == 'Found') {
                    return matchesSearch && !item.isLost;
                  }
                  return matchesSearch;
                }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.find_in_page_outlined, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No lost & found logs reported.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final formattedDate = DateFormat('MMM d, y • h:mm a').format(item.dateTime);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left image container
                            Container(
                              width: 110,
                              color: theme.colorScheme.surfaceVariant,
                              child: item.imageUrl != null
                                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                                  : Center(
                                      child: Icon(
                                        item.isLost ? Icons.gavel : Icons.check_circle_outline,
                                        size: 32,
                                        color: item.isLost ? Colors.deepOrange : Colors.green,
                                      ),
                                    ),
                            ),
                            // Right details container
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: item.isLost
                                                ? Colors.deepOrange.withOpacity(0.1)
                                                : Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.isLost ? 'LOST' : 'FOUND',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: item.isLost ? Colors.deepOrange : Colors.green,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.location,
                                            style: theme.textTheme.bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (item.reporterContact.isNotEmpty)
                                          IconButton(
                                            visualDensity: VisualDensity.compact,
                                            icon: const Icon(Icons.phone_outlined, size: 18),
                                            onPressed: () => _contactReporter('tel', item.reporterContact),
                                          ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                          onPressed: () => _contactReporter('mailto', 'contact@campusconnect.app'),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading reports: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportItemForm extends ConsumerStatefulWidget {
  const ReportItemForm({super.key});

  @override
  ConsumerState<ReportItemForm> createState() => _ReportItemFormState();
}

class _ReportItemFormState extends ConsumerState<ReportItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLost = true;
  PlatformFile? _pickedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null || result.files.isEmpty) return;

      setState(() {
        _pickedImage = result.files.first;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    final currentProfile = ref.read(userProfileProvider).value;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final reporterName = currentProfile?.displayName ?? currentUser.displayName ?? 'Anonymous';
    final reporterContact = _phoneController.text.isNotEmpty ? _phoneController.text.trim() : (currentProfile?.phoneNumber ?? '');

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('lost_found/${DateTime.now().millisecondsSinceEpoch}_${_pickedImage!.name}');
        
        if (kIsWeb) {
          final uploadTask = imageRef.putData(_pickedImage!.bytes!);
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          final uploadTask = imageRef.putFile(File(_pickedImage!.path!));
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        }
      }

      final item = LostFoundItem(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        isLost: _isLost,
        location: _locationController.text.trim(),
        dateTime: DateTime.now(),
        reporterId: currentUser.uid,
        reporterName: reporterName,
        reporterContact: reporterContact,
        imageUrl: imageUrl,
      );

      await ref.read(lostFoundRepositoryProvider).reportItem(item);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item reported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to file report: $e')),
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
                'Report Lost or Found Item',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('LOST')),
                      selected: _isLost,
                      selectedColor: Colors.deepOrange.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _isLost ? Colors.deepOrange : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => _isLost = true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('FOUND')),
                      selected: !_isLost,
                      selectedColor: Colors.green.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: !_isLost ? Colors.green : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => _isLost = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Item Title / Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter item name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description (Appearance, details)', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Where was it lost/found?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter location description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone Number (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),

              // Image Picker Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickImage,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Add Picture'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedImage != null ? _pickedImage!.name : 'No picture selected',
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
                onPressed: _isUploading ? null : _submit,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('File Report'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
