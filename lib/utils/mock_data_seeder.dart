import 'package:cloud_firestore/cloud_firestore.dart';

class MockDataSeeder {
  static Future<void> seedIfEmpty() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Check users
      final usersSnap = await firestore.collection('users').limit(1).get();
      if (usersSnap.docs.isEmpty) {
        await _seedUsers(firestore);
      }

      // Check events
      final eventsSnap = await firestore.collection('events').limit(1).get();
      if (eventsSnap.docs.isEmpty) {
        await _seedEvents(firestore);
      }

      // Check notes
      final notesSnap = await firestore.collection('notes').limit(1).get();
      if (notesSnap.docs.isEmpty) {
        await _seedNotes(firestore);
      }

      // Check marketplace
      final marketSnap = await firestore.collection('marketplace').limit(1).get();
      if (marketSnap.docs.isEmpty) {
        await _seedMarketplace(firestore);
      }

      // Check lostAndFound
      final lfSnap = await firestore.collection('lostAndFound').limit(1).get();
      if (lfSnap.docs.isEmpty) {
        await _seedLostFound(firestore);
      }
    } catch (e) {
      // Quietly log error if any database restriction occurs
      print('MockDataSeeder error: $e');
    }
  }

  static Future<void> _seedEvents(FirebaseFirestore firestore) async {
    final batch = firestore.batch();
    final col = firestore.collection('events');

    final items = [
      {
        'title': 'GDSC Flutter Bootcamp',
        'description': 'A comprehensive 3-day bootcamp covering state management, animations, and Firebase integration in Flutter.',
        'organizer': 'Google Developer Student Club',
        'dateTime': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'location': 'CS Seminar Hall (Block 3)',
        'attendees': [],
        'bannerUrl': null,
      },
      {
        'title': 'Annual Sports Meet 2026',
        'description': 'Inter-department sports championship featuring cricket, football, basketball, and athletics events.',
        'organizer': 'Campus Sports Committee',
        'dateTime': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'location': 'University Main Ground',
        'attendees': [],
        'bannerUrl': null,
      },
      {
        'title': 'Hacktoberfest Campus Hackathon',
        'description': 'Showcase your skills in open source contributions and win exclusive swags and cash prizes!',
        'organizer': 'Coding Club CC',
        'dateTime': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        'location': 'Main Seminar Hall (Block 1)',
        'attendees': [],
        'bannerUrl': null,
      }
    ];

    for (var item in items) {
      batch.set(col.doc(), item);
    }
    await batch.commit();
  }

  static Future<void> _seedNotes(FirebaseFirestore firestore) async {
    final batch = firestore.batch();
    final col = firestore.collection('notes');

    final items = [
      {
        'title': 'Data Structures Lecture Notes',
        'description': 'Handwritten notes covering Trees, Graphs, Sorting algorithms, and Space Complexity analyses.',
        'subject': 'Data Structures & Algorithms',
        'semester': 3,
        'fileUrl': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        'fileName': 'dsa_full_notes.pdf',
        'uploaderId': 'system',
        'uploaderName': 'Prof. Sharma',
        'uploadedAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Engineering Physics Cheat Sheet',
        'description': 'Quick formulas and theorems for Quantum Physics and Fiber Optics exam revision.',
        'subject': 'Engineering Physics',
        'semester': 1,
        'fileUrl': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        'fileName': 'physics_revision.pdf',
        'uploaderId': 'system',
        'uploaderName': 'Senior Club',
        'uploadedAt': DateTime.now().toIso8601String(),
      }
    ];

    for (var item in items) {
      batch.set(col.doc(), item);
    }
    await batch.commit();
  }

  static Future<void> _seedMarketplace(FirebaseFirestore firestore) async {
    final batch = firestore.batch();
    final col = firestore.collection('marketplace');

    final items = [
      {
        'title': 'Casio Scientific Calculator fx-991EX',
        'description': 'Mint condition scientific calculator, perfect for calculus and engineering courses. Includes protective cover.',
        'category': 'Electronics',
        'price': 800.0,
        'sellerId': 'system',
        'sellerName': 'Aman Gupta',
        'sellerPhone': '+91 9876543211',
        'sellerEmail': 'aman.gupta@univ.edu',
        'createdAt': DateTime.now().toIso8601String(),
        'imageUrl': null,
      },
      {
        'title': 'Introduction to Algorithms (CLRS)',
        'description': '4th edition textbook, slightly highlighted but in great shape. Must-have for CSE majors.',
        'category': 'Books',
        'price': 450.0,
        'sellerId': 'system',
        'sellerName': 'Rohan Shah',
        'sellerPhone': '+91 9988776655',
        'sellerEmail': 'rohan.shah@univ.edu',
        'createdAt': DateTime.now().toIso8601String(),
        'imageUrl': null,
      },
      {
        'title': 'Engineering Drawing Board (A2 size)',
        'description': 'A2 size drawing board with parallel ruler and clips. Perfect for first-year lab classes.',
        'category': 'Essentials',
        'price': 300.0,
        'sellerId': 'system',
        'sellerName': 'Karan Malhotra',
        'sellerPhone': '+91 9123456789',
        'sellerEmail': 'karan.m@univ.edu',
        'createdAt': DateTime.now().toIso8601String(),
        'imageUrl': null,
      }
    ];

    for (var item in items) {
      batch.set(col.doc(), item);
    }
    await batch.commit();
  }

  static Future<void> _seedLostFound(FirebaseFirestore firestore) async {
    final batch = firestore.batch();
    final col = firestore.collection('lostAndFound');

    final items = [
      {
        'title': 'Black Leather Wallet',
        'description': 'Found a black leather wallet containing a student ID card belonging to Vedant Patel. Please claim it.',
        'isLost': false,
        'location': 'Main Cafeteria Counter 3',
        'dateTime': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'reporterId': 'system',
        'reporterName': 'Cafeteria Manager',
        'reporterContact': '+91 9876543212',
        'imageUrl': null,
      },
      {
        'title': 'Apple AirPods Pro Case',
        'description': 'Lost my AirPods Pro charging case (empty, no earphones inside). Had a green silicone cover.',
        'isLost': true,
        'location': 'Library Silent Study Zone (Floor 2)',
        'dateTime': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'reporterId': 'system',
        'reporterName': 'Sanya Sen',
        'reporterContact': '+91 9900112233',
        'imageUrl': null,
      }
    ];

    for (var item in items) {
      batch.set(col.doc(), item);
    }
    await batch.commit();
  }

  static Future<void> _seedUsers(FirebaseFirestore firestore) async {
    final batch = firestore.batch();
    final col = firestore.collection('users');

    final users = [
      {
        'id': 'dummy_alice',
        'email': 'alice.vance@univ.edu',
        'displayName': 'Alice Vance',
        'photoUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Alice',
        'rollNumber': 'CS23B1002',
        'branch': 'Computer Science',
        'semester': 6,
        'phoneNumber': '+91 9999888801',
        'username': 'alice_v',
      },
      {
        'id': 'dummy_bob',
        'email': 'bob.miller@univ.edu',
        'displayName': 'Bob Miller',
        'photoUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Bob',
        'rollNumber': 'EE22B2005',
        'branch': 'Electrical Engineering',
        'semester': 8,
        'phoneNumber': '+91 9999888802',
        'username': 'bob_m',
      },
      {
        'id': 'dummy_charlie',
        'email': 'charlie.day@univ.edu',
        'displayName': 'Charlie Day',
        'photoUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Charlie',
        'rollNumber': 'ME24B3012',
        'branch': 'Mechanical Engineering',
        'semester': 4,
        'phoneNumber': '+91 9999888803',
        'username': 'charlie_d',
      },
      {
        'id': 'dummy_diana',
        'email': 'diana.prince@univ.edu',
        'displayName': 'Diana Prince',
        'photoUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Diana',
        'rollNumber': 'CE25B4021',
        'branch': 'Civil Engineering',
        'semester': 2,
        'phoneNumber': '+91 9999888804',
        'username': 'diana_p',
      },
      {
        'id': 'dummy_evan',
        'email': 'evan.wright@univ.edu',
        'displayName': 'Evan Wright',
        'photoUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Evan',
        'rollNumber': 'BT22B5001',
        'branch': 'Biotechnology',
        'semester': 8,
        'phoneNumber': '+91 9999888805',
        'username': 'evan_w',
      }
    ];

    for (var u in users) {
      final docId = u['id'] as String;
      final map = Map<String, dynamic>.from(u)..remove('id');
      batch.set(col.doc(docId), map);
    }
    await batch.commit();
  }
}
