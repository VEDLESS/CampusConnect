import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/campus_user.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../feed/presentation/feed_providers.dart';
import 'connections_providers.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _initialized = false;

  late TextEditingController _nameController;
  late TextEditingController _rollController;
  late TextEditingController _phoneController;
  late TextEditingController _usernameController;
  String? _selectedBranch;
  int? _selectedSemester;

  final List<String> _branches = [
    'Computer Science & Engineering',
    'Electronics & Communication Engineering',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Information Technology',
    'Chemical Engineering',
  ];

  final List<int> _semesters = List.generate(8, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _rollController = TextEditingController();
    _phoneController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _initializeFields(CampusUser? user) {
    if (user == null) return;
    _nameController.text = user.displayName ?? '';
    _rollController.text = user.rollNumber ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _usernameController.text = user.username ?? '';
    _selectedBranch = user.branch;
    _selectedSemester = user.semester;
  }

  Future<void> _uploadProfilePicture(CampusUser currentUser) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.first;

      setState(() {
        _initialized = false;
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profiles/${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}_${picked.name}');

      String downloadUrl;
      if (kIsWeb) {
        final uploadTask = storageRef.putData(picked.bytes!);
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        final uploadTask = storageRef.putFile(File(picked.path!));
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      final updatedUser = CampusUser(
        id: currentUser.id,
        email: currentUser.email,
        displayName: _nameController.text.trim(),
        photoUrl: downloadUrl,
        rollNumber: _rollController.text.trim(),
        branch: _selectedBranch,
        semester: _selectedSemester,
        phoneNumber: _phoneController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
      );

      await ref.read(profileRepositoryProvider).updateProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading profile picture: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile(CampusUser currentUser) async {
    if (!_formKey.currentState!.validate()) return;

    final usernameVal = _usernameController.text.trim().toLowerCase();
    if (usernameVal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a unique username.')),
      );
      return;
    }

    // Verify username is unique
    final isUnique = await ref.read(profileRepositoryProvider).isUsernameUnique(usernameVal, currentUser.id);
    if (!mounted) return;
    if (!isUnique) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This username is already taken. Please choose another one.')),
      );
      return;
    }

    final updatedUser = CampusUser(
      id: currentUser.id,
      email: currentUser.email,
      displayName: _nameController.text.trim(),
      photoUrl: currentUser.photoUrl,
      rollNumber: _rollController.text.trim(),
      branch: _selectedBranch,
      semester: _selectedSemester,
      phoneNumber: _phoneController.text.trim(),
      username: usernameVal,
    );

    try {
      await ref.read(profileRepositoryProvider).updateProfile(updatedUser);
      setState(() {
        _isEditing = false;
        _initialized = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Widget _buildStatsSection(CampusUser user) {
    final connectionsAsync = ref.watch(myConnectionsProvider);
    final userPostsAsync = ref.watch(userPostsProvider(user.id));

    int friendCount = 0;
    int pendingRequestsCount = 0;
    int postsCount = 0;

    connectionsAsync.whenData((connections) {
      for (var conn in connections) {
        final status = conn['status'] as String;
        if (status == 'accepted') {
          friendCount++;
        } else if (status.startsWith('pending_') && status.endsWith('_to_${user.id}')) {
          pendingRequestsCount++;
        }
      }
    });

    userPostsAsync.whenData((posts) {
      postsCount = posts.length;
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('Posts', '$postsCount'),
          _buildDivider(),
          _buildStatColumn('Friends', '$friendCount'),
          _buildDivider(),
          _buildStatColumn('Requests', '$pendingRequestsCount'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsyncValue = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          profileAsyncValue.when(
            data: (firebaseUserDoc) {
              if (firebaseUserDoc == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                    _initialized = false;
                  });
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: profileAsyncValue.when(
        data: (firebaseUserDoc) {
          final authUser = FirebaseAuth.instance.currentUser;
          final user = firebaseUserDoc ?? (authUser != null ? CampusUser(
            id: authUser.uid,
            email: authUser.email ?? '',
            displayName: authUser.displayName,
          ) : null);

          if (user == null) {
            return const Center(
              child: Text('User session not found. Please log in again.'),
            );
          }

          final bool isProfileMissing = firebaseUserDoc == null;
          final bool activeEditMode = _isEditing || isProfileMissing;

          if (!_initialized) {
            _initializeFields(user);
            _initialized = true;
            if (isProfileMissing) {
              _isEditing = true;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  (user.displayName ?? 'C').substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : null,
                        ),
                        if (activeEditMode)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                onPressed: () => _uploadProfilePicture(user),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? 'Campus Member',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.username != null && user.username!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Display Stats counters
                  _buildStatsSection(user),
                  const SizedBox(height: 24),

                  // Profile Details Form / Views
                  if (activeEditMode) ...[
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Unique Username',
                        prefixText: '@ ',
                        prefixIcon: Icon(Icons.alternate_email),
                        border: OutlineInputBorder(),
                        hintText: 'e.g. john_doe',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a username';
                        }
                        if (value.trim().contains(' ')) {
                          return 'Username cannot contain spaces';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rollController,
                      decoration: const InputDecoration(
                        labelText: 'Roll Number / ID',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your roll number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      decoration: const InputDecoration(
                        labelText: 'Department / Branch',
                        prefixIcon: Icon(Icons.school_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _branches
                          .map((branch) => DropdownMenuItem(
                                value: branch,
                                child: Text(
                                  branch,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedBranch = val),
                      validator: (value) =>
                          value == null ? 'Please select your branch' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedSemester,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        prefixIcon: Icon(Icons.class_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _semesters
                          .map((sem) => DropdownMenuItem(
                                value: sem,
                                child: Text('Semester $sem'),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedSemester = val),
                      validator: (value) =>
                          value == null ? 'Please select your semester' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _saveProfile(user),
                        child: const Text('Save Profile'),
                      ),
                    ),
                  ] else ...[
                    // View Mode Cards
                    _buildInfoCard(
                      theme,
                      icon: Icons.alternate_email,
                      label: 'Unique Username',
                      value: user.username != null ? '@${user.username}' : 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: Icons.badge_outlined,
                      label: 'Roll Number / ID',
                      value: user.rollNumber ?? 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: Icons.school_outlined,
                      label: 'Branch / Department',
                      value: user.branch ?? 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: Icons.class_outlined,
                      label: 'Semester',
                      value: user.semester != null
                          ? 'Semester ${user.semester}'
                          : 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: user.phoneNumber?.isNotEmpty == true
                          ? user.phoneNumber!
                          : 'Not set',
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ref.read(authRepositoryProvider).signOut();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading profile: $err')),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
