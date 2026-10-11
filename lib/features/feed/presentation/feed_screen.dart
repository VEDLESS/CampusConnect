import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feed_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../../models/feed_post.dart';
import '../../../models/feed_comment.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _postController = TextEditingController();
  PlatformFile? _pickedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
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

  Future<void> _submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty && _pickedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    final currentProfile = ref.read(userProfileProvider).value;
    final currentUid = ref.read(currentUserIdProvider);
    if (currentUid == null) return;

    final authorName = currentProfile?.displayName ?? 'Anonymous';
    final authorPhoto = currentProfile?.photoUrl;

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('feed/${DateTime.now().millisecondsSinceEpoch}_${_pickedImage!.name}');

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

      await ref.read(feedRepositoryProvider).createPost(
            authorId: currentUid,
            authorName: authorName,
            authorPhotoUrl: authorPhoto,
            content: text,
            imageUrl: imageUrl,
          );

      _postController.clear();
      setState(() {
        _pickedImage = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish post: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedPostsAsync = ref.watch(feedPostsProvider);
    final currentUid = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Buzz'),
      ),
      body: currentUid == null
          ? const Center(child: Text('Please sign in to view and share campus updates.'))
          : Column(
              children: [
                // Create Post Card
                Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_note, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _postController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: "What's going on around campus?",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_pickedImage != null) ...[
                          const SizedBox(height: 12),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: kIsWeb
                                        ? MemoryImage(_pickedImage!.bytes!) as ImageProvider
                                        : FileImage(File(_pickedImage!.path!)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => setState(() => _pickedImage = null),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.image_outlined),
                              tooltip: 'Add Photo',
                              onPressed: _pickImage,
                            ),
                            _isUploading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: _submitPost,
                                    icon: const Icon(Icons.send_rounded, size: 16),
                                    label: const Text('Post'),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Feed list
                Expanded(
                  child: feedPostsAsync.when(
                    data: (posts) {
                      if (posts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.feed_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              Text('No news or posts yet', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              const Text('Be the first to post something exciting!'),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final isLiked = post.likedBy.contains(currentUid);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: post.authorPhotoUrl != null ? NetworkImage(post.authorPhotoUrl!) : null,
                                    child: post.authorPhotoUrl == null ? Text(post.authorName[0]) : null,
                                  ),
                                  title: Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(_formatTimestamp(post.createdAt)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(post.content, style: const TextStyle(fontSize: 15)),
                                ),
                                if (post.imageUrl != null)
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(post.imageUrl!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isLiked ? Icons.favorite : Icons.favorite_border,
                                          color: isLiked ? Colors.red : null,
                                        ),
                                        onPressed: () {
                                          ref.read(feedRepositoryProvider).toggleLikePost(post.id, currentUid);
                                        },
                                      ),
                                      Text('${post.likesCount}'),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.comment_outlined),
                                        onPressed: () => _showCommentsSheet(context, post.id),
                                      ),
                                      Text('${post.commentsCount}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error loading feed: $e')),
                  ),
                ),
              ],
            ),
    );
  }

  void _showCommentsSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return CommentsDrawer(postId: postId, scrollController: scrollController);
          },
        );
      },
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class CommentsDrawer extends ConsumerStatefulWidget {
  const CommentsDrawer({
    super.key,
    required this.postId,
    required this.scrollController,
  });

  final String postId;
  final ScrollController scrollController;

  @override
  ConsumerState<CommentsDrawer> createState() => _CommentsDrawerState();
}

class _CommentsDrawerState extends ConsumerState<CommentsDrawer> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    final currentProfile = ref.read(userProfileProvider).value;
    final currentUid = ref.read(currentUserIdProvider);
    if (currentUid == null) return;

    final authorName = currentProfile?.displayName ?? 'Anonymous';
    final authorPhoto = currentProfile?.photoUrl;

    await ref.read(feedRepositoryProvider).addComment(
          postId: widget.postId,
          authorId: currentUid,
          authorName: authorName,
          authorPhotoUrl: authorPhoto,
          content: text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsAsync = ref.watch(feedCommentsProvider(widget.postId));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Comments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet. Write one below!'));
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        backgroundImage: comment.authorPhotoUrl != null
                            ? NetworkImage(comment.authorPhotoUrl!)
                            : null,
                        child: comment.authorPhotoUrl == null ? Text(comment.authorName[0]) : null,
                      ),
                      title: Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(comment.content),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
