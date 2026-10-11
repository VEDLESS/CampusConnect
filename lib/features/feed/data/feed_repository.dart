import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/feed_post.dart';
import '../../../models/feed_comment.dart';

class FeedRepository {
  const FeedRepository(this._firestore);

  final FirebaseFirestore _firestore;

  // Stream all feed posts ordered by createdAt descending
  Stream<List<FeedPost>> watchFeedPosts() {
    return _firestore
        .collection('feed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FeedPost.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Stream posts for a specific user
  Stream<List<FeedPost>> watchUserPosts(String userId) {
    return _firestore
        .collection('feed')
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FeedPost.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Create a new post
  Future<void> createPost({
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    String? imageUrl,
  }) async {
    await _firestore.collection('feed').add({
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': 0,
      'likedBy': [],
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle like on a post
  Future<void> toggleLikePost(String postId, String userId) async {
    final docRef = _firestore.collection('feed').doc(postId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final likedBy = List<String>.from(snapshot.data()?['likedBy'] ?? []);
      int likesCount = snapshot.data()?['likesCount'] ?? 0;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        likesCount = (likesCount - 1).clamp(0, 999999);
      } else {
        likedBy.add(userId);
        likesCount++;
      }

      transaction.update(docRef, {
        'likedBy': likedBy,
        'likesCount': likesCount,
      });
    });
  }

  // Add comment to a post
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    final batch = _firestore.batch();
    
    final commentRef = _firestore.collection('feed').doc(postId).collection('comments').doc();
    batch.set(commentRef, {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final postRef = _firestore.collection('feed').doc(postId);
    batch.update(postRef, {
      'commentsCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Stream comments for a specific post
  Stream<List<FeedComment>> watchComments(String postId) {
    return _firestore
        .collection('feed')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FeedComment.fromMap(doc.id, doc.data())).toList();
    });
  }
}
