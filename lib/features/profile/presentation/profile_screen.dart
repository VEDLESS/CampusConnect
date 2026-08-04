import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/campus_user.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _rollController;
  late TextEditingController _phoneController;
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeFields(CampusUser? user) {
    if (user == null) return;
    _nameController.text = user.displayName ?? '';
    _rollController.text = user.rollNumber ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _selectedBranch = user.branch;
    _selectedSemester = user.semester;
  }

  Future<void> _saveProfile(CampusUser currentUser) async {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = CampusUser(
      id: currentUser.id,
      email: currentUser.email,
      displayName: _nameController.text.trim(),
      photoUrl: currentUser.photoUrl,
      rollNumber: _rollController.text.trim(),
      branch: _selectedBranch,
      semester: _selectedSemester,
      phoneNumber: _phoneController.text.trim(),
    );

    try {
      await ref.read(profileRepositoryProvider).updateProfile(updatedUser);
      setState(() {
        _isEditing = false;
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

  @override
  Widget build(BuildContext context) {
    final profileAsyncValue = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          profileAsyncValue.when(
            data: (user) {
              if (user == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
                onPressed: () {
                  if (!_isEditing) {
                    _initializeFields(user);
                  }
                  setState(() {
                    _isEditing = !_isEditing;
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
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User profile not found.'));
          }

          // Initialize fields only once when transitioning to edit mode
          if (!_isEditing) {
            _initializeFields(user);
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
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Details Form / Views
                  if (_isEditing) ...[
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
                  ]
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
