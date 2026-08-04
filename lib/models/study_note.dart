class StudyNote {
  const StudyNote({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.semester,
    required this.fileUrl,
    required this.fileName,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploadedAt,
  });

  final String id;
  final String title;
  final String description;
  final String subject;
  final int semester;
  final String fileUrl;
  final String fileName;
  final String uploaderId;
  final String uploaderName;
  final DateTime uploadedAt;

  factory StudyNote.fromMap(String id, Map<String, dynamic> map) {
    return StudyNote(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      semester: map['semester'] ?? 1,
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      uploaderId: map['uploaderId'] ?? '',
      uploaderName: map['uploaderName'] ?? 'Anonymous',
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.parse(map['uploadedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'semester': semester,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
