# 📱 CampusConnect (Mark1) - Project Context Document

This document provides complete details about the **CampusConnect (Mark1)** mobile/web application. It acts as an architectural guide and feature index for developers and AI models (like ChatGPT) to understand the codebase.

---

## 🛠️ Tech Stack & Key Dependencies

*   **Framework**: Flutter (cross-platform, tested extensively on Chrome/Web)
*   **State Management**: Riverpod (`flutter_riverpod` v2)
*   **Routing**: GoRouter (`go_router` v17)
*   **Backend & DB**: Firebase (Core, Authentication, Firestore, Cloud Storage)
*   **UI Assets**: Google Fonts (Inter/Outfit), Lottie animations, cached network images
*   **Media Handling**: `file_picker` (Web-compatible file selectors)
*   **Mock Seeder**: Auto-populates mock data in Firestore during startup

---

## 📁 Codebase Directory Structure

```text
lib/
├── config/              # Firebase initial configuration
├── core/                # Core App Runner class
├── models/              # Shared data models/schemas
├── routes/              # GoRouter definitions
├── theme/               # Dark-mode styling tokens and color systems
├── utils/               # Database seeder and mock helpers
├── widgets/             # Reusable UI controls (e.g., AppFeatureCard)
└── features/            # Feature modules (Domain-driven structure)
    ├── auth/            # Auth gates, sign-in, and Dev-Drawer simulator
    ├── calculator/      # Custom GPA / SGPA / CGPA calculator
    ├── chat/            # Real-time peer-to-peer messaging
    ├── events/          # Campus events calendar
    ├── feed/            # "Campus Buzz" Instagram-inspired feed
    ├── home/            # Swipe-container (PageView) holding primary modules
    ├── lost_found/      # Lost & Found sector with item recovery alerts
    ├── marketplace/     # Student classifieds marketplace
    ├── notes/           # Study Notes upload and sharing repository
    ├── notifications/   # Push messages and connection alerts
    └── profile/         # Profile stats, username checks, connection handling
```

---

## 💎 Primary Feature Modules & Business Logic

### 1. 📲 Home Layout & Navigation (`lib/features/home`)
*   **Aesthetics**: Sleek dark mode featuring curated accent colors and glassmorphism cards.
*   **Swipe Gestures**: Employs a horizontal `PageView` allowing users to swipe left/right between:
    *   **Dashboard** (Quick utility entry points & VJTI Mumbai Banner illustration)
    *   **Buzz** (Feed posts and comments)
    *   **Chats** (Direct messages)
    *   **Profile** (Personal details and statistics)
*   **Quick Shortcuts**: The top-right AppBar houses direct links to the **Connections Directory** (Add Friend icon) and **Inbox** (DM icon).

### 2. 🎓 GPA Calculator (`lib/features/calculator`)
*   **Grading System**: Custom grade points mapped directly to college standards:
    *   `AA` (10 pts), `AB` (9 pts), `BB` (8 pts), `BC` (7 pts), `CC` (6 pts), `CD` (5 pts), `DD` (4 pts), `FF` (Fail/0 pts).
*   **Inputs**:
    *   Supports entering the names of individual subjects and their respective credits.
    *   Offers an option to input previous semesters' SGPA (limited to a maximum of 8 semesters).
    *   **Validation Rule**: If calculating the CGPA for semester $N$ (e.g., 6th sem), the app accepts previous SGPAs only up to semester $N-1$ (e.g., 5 semesters).

### 3. 🤝 Social Connections & Profile Stats (`lib/features/profile`)
*   **Personalization**:
    *   **Unique Usernames**: Every user must register a unique `@username` (no spaces). The app performs a database check on save to prevent duplicate handles.
    *   **Avatar Upload**: Users can tap their profile picture to trigger a `FilePicker` and upload a new photo directly to **Firebase Storage**.
*   **Real-time Profile Stats**:
    *   Displays three counters in an Instagram-like row: **Posts Count**, **Friends Count** (accepted mutual connections), and **Incoming Requests Count**.
*   **Connections Directory**:
    *   Divided into three tabs: **My Friends** (remove friend option), **Requests** (accept/decline requests), and **Find Users**.
    *   **Search**: Supports query filtering by display name, username, and department/branch.

### 4. 💬 Peer-to-Peer Chat (`lib/features/chat`)
*   **Capabilities**: Real-time text chat between any two connected users.
*   **Model**:
    *   `ChatMessage` stores message texts, sender IDs, and timestamps.
    *   `ChatSession` logs ongoing conversations, maintaining last-sent message snippets for fast list rendering.

### 5. 📢 Campus Buzz (Social Feed) (`lib/features/feed`)
*   **Social Interactions**:
    *   Students can publish text posts accompanied by optional image attachments.
    *   Features real-time interactive likes (with visual like counters) and comments.

### 6. 🔍 Lost & Found (`lib/features/lost_found`)
*   **Workflows**:
    *   Post details of a lost item including photo, description, contact information, and coordinates.
    *   Other students can click a **"Report Found"** button. This notifies the original poster and automatically marks the item as recovered.

### 7. 📚 Study Notes Hub (`lib/features/notes`)
*   **Sharing**:
    *   Students can upload PDF/doc notes to Firebase Storage and categorize them by subject name.
    *   Search field allows filtering notes by title, topic, or course.

### 8. 🎭 Events Hub (`lib/features/events`)
*   *   Hosts registrations and listings for upcoming college seminars, workshops, and student festivals.

---

## 🗄️ Database Schemas (Firestore)

### `/users/{uid}`
```json
{
  "displayName": "Alice Vance",
  "email": "alice.vance@univ.edu",
  "photoUrl": "https://api.dicebear.com/7.x/adventurer/png?seed=Alice",
  "rollNumber": "CS23B1002",
  "branch": "Computer Science & Engineering",
  "semester": 6,
  "phoneNumber": "+91 9999888801",
  "username": "alice_v"
}
```

### `/connections/{connectionId}`
```json
{
  "connectionId": "unique_doc_id",
  "userUids": ["uid_1", "uid_2"],
  "status": "accepted" // Or "pending_uid1_to_uid2"
}
```

### `/feed/{postId}`
```json
{
  "authorId": "uid_1",
  "authorName": "Alice Vance",
  "authorPhotoUrl": "https://...",
  "content": "Excited for the upcoming VJTI festival!",
  "imageUrl": "https://...",
  "createdAt": "2026-08-16T12:00:00Z",
  "likedBy": ["uid_2", "uid_3"],
  "likeCount": 2,
  "commentCount": 0
}
```
