import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feed_repository.dart';
import '../../../models/feed_post.dart';
import '../../../models/feed_comment.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(FirebaseFirestore.instance);
});

final feedPostsProvider = StreamProvider<List<FeedPost>>((ref) {
  return ref.watch(feedRepositoryProvider).watchFeedPosts();
});

final feedCommentsProvider = StreamProvider.family<List<FeedComment>, String>((ref, postId) {
  return ref.watch(feedRepositoryProvider).watchComments(postId);
});

final userPostsProvider = StreamProvider.family<List<FeedPost>, String>((ref, userId) {
  return ref.watch(feedRepositoryProvider).watchUserPosts(userId);
});
