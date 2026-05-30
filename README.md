# Entrance Exam Prep (Flutter Mobile)

Mobile version of the Grade 12 entrance exam preparation platform. Built with Flutter, it shares the **same backend API** as the React web platform and utilizes a **modular clean architecture** for maximum scalability and speed.

---

## 📱 App Screenshots & Pages

Below are screenshots and descriptions of the core screens in the application, highlighting the polished UI and features:

| **Home Dashboard** | **Chapters List** | **Topic Hub** |
| :---: | :---: | :---: |
| <img src="screenshots/home_page.png" width="220" /> | <img src="screenshots/chapters_page.png" width="220" /> | <img src="screenshots/topic_detail_page.png" width="220" /> |
| Weekly progress charts, stats, and quick-access subjects (Physics, Maths, Biology). | Interactive chapter list showing topic counts and progress completion rings. | The centralized hub for all topic learning modules (notes, videos, quizzes, etc.). |

| **Concept Notes** | **Lecture Video Player** | **Exam Hub** |
| :---: | :---: | :---: |
| <img src="screenshots/notes_page.png" width="220" /> | <img src="screenshots/lecture_video_page.png" width="220" /> | <img src="screenshots/exam_page.png" width="220" /> |
| Clean textbook concepts and explanations rendered in native markdown. | In-app native YouTube player with custom playlist navigation and inline video swap. | Interactive mock exams and tests with detailed feedback and timing tracking. |

| **AI Study Partner** | **Saved Bookmarks** | **Search Center** |
| :---: | :---: | :---: |
| <img src="screenshots/Ai_chatbot_page.png" width="220" /> | <img src="screenshots/bookmarks_page.png" width="220" /> | <img src="screenshots/search_contents_page.png" width="220" /> |
| Interactive AI tutor chat for asking complex questions and getting step-by-step guidance. | Saved formulas, questions, and topics kept for quick offline-ready reference. | Global search interface to quickly find content, chapters, or questions. |

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (3.9.x or newer)
* Android SDK / iOS Xcode

### Run in Development

```bash
# Navigate to project directory
cd finalyearproject

# Fetch package dependencies
flutter pub get

# Launch the app on connected emulator or device
flutter run
```

---

## 🌐 API Configuration

By default, the app points to the production API (matching the React web frontend):

`https://final-year-project-2-entrance-exam.onrender.com/api`

To override the endpoint for local development (e.g. running the backend locally), edit [util.dart](file:///D:/Mobile%20App%20Final%20Year%20Project/finalyearproject/lib/core/constants/util.dart):

```dart
// Android emulator → localhost:5000
const String apiUrl = 'http://10.0.2.2:5000/api'; 
```

---

## 📁 Project Architecture

The codebase follows the **Feature-First Clean Architecture** structure:

```
lib/
├── core/           # API clients, colors, premium theme, shared widgets
├── shared/         # Auth gate, routing, state providers
└── features/
    ├── auth/       # Login, registration, password recovery (glowing neon gradients)
    ├── student/    # Student dashboard, custom navigation docks, drawers
    ├── curriculum/ # Subjects → chapters → topics curriculum tree
    ├── content/    # Content modules (objectives, concepts, videos, practice)
    ├── engagement/ # Progress tracking, bookmarks, notifications, Q&A boards
    ├── teacher/    # Course/content CRUD, Q&A moderation tools
    ├── admin/      # User management, course approvals
    ├── profile/    # Student/Teacher profile pages
    └── ai/         # AI Study Partner chatbot interface
```

* **Domain layer**: Defines models and business logic.
* **Data layer**: Implements remote/local data sources (`*_remote_data_source.dart`).
* **Application layer**: Manages state using Riverpod providers.
* **Presentation layer**: UI layouts, custom widgets, and pages.

---

## 👥 Role Privileges

* **Student**: Access to dashboards, learning pathways, AI Tutor chatbot, practice tests, and performance bookmarks.
* **Teacher**: Management portal for subjects, chapters, and topics; Q&A thread management.
* **Admin**: Subject CRUD and global user moderation dashboards.

---

## 👥 Group Contributors

| 🧑‍💻 Name | 🆔 Student ID |
| :--- | :--- |
| **Aman Atalay** | `UGR/4364/15` |
| **Asnake Mengesha** | `UGR/9465/15` |
| **Daniel Shitaye** | `NSR/9066/14` |
| **Fraol Dereje** | `UGR/6955/15` |

