class CampusUser {
  const CampusUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.rollNumber,
    this.branch,
    this.semester,
    this.phoneNumber,
    this.username,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? rollNumber;
  final String? branch;
  final int? semester;
  final String? phoneNumber;
  final String? username;

  factory CampusUser.fromMap(String id, Map<String, dynamic> map) {
    return CampusUser(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      rollNumber: map['rollNumber'] as String?,
      branch: map['branch'] as String?,
      semester: map['semester'] as int?,
      phoneNumber: map['phoneNumber'] as String?,
      username: map['username'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'rollNumber': rollNumber,
      'branch': branch,
      'semester': semester,
      'phoneNumber': phoneNumber,
      'username': username,
    };
  }
}
