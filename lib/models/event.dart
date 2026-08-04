class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.dateTime,
    required this.location,
    required this.attendees,
    this.bannerUrl,
  });

  final String id;
  final String title;
  final String description;
  final String organizer;
  final DateTime dateTime;
  final String location;
  final List<String> attendees; // list of user UIDs
  final String? bannerUrl;

  factory CampusEvent.fromMap(String id, Map<String, dynamic> map) {
    return CampusEvent(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      organizer: map['organizer'] ?? '',
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'] as String)
          : DateTime.now(),
      location: map['location'] ?? '',
      attendees: List<String>.from(map['attendees'] ?? []),
      bannerUrl: map['bannerUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'organizer': organizer,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'attendees': attendees,
      'bannerUrl': bannerUrl,
    };
  }
}
