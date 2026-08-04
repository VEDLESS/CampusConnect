class LostFoundItem {
  const LostFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isLost, // true if lost, false if found
    required this.location,
    required this.dateTime,
    required this.reporterId,
    required this.reporterName,
    required this.reporterContact,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final bool isLost;
  final String location;
  final DateTime dateTime;
  final String reporterId;
  final String reporterName;
  final String reporterContact;
  final String? imageUrl;

  factory LostFoundItem.fromMap(String id, Map<String, dynamic> map) {
    return LostFoundItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isLost: map['isLost'] ?? true,
      location: map['location'] ?? '',
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'] as String)
          : DateTime.now(),
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? 'Anonymous',
      reporterContact: map['reporterContact'] ?? '',
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isLost': isLost,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterContact': reporterContact,
      'imageUrl': imageUrl,
    };
  }
}
