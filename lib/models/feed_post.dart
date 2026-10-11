import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPost {
  const FeedPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.likedBy,
    required this.commentsCount,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final List<String> likedBy;
  final int commentsCount;
  final DateTime createdAt;

  factory FeedPost.fromMap(String id, Map<String, dynamic> map) {
    return FeedPost(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      authorPhotoUrl: map['authorPhotoUrl'] as String?,
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] as String?,
      likesCount: map['likesCount'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'likedBy': likedBy,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
