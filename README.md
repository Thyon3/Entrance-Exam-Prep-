# Entrance Exam Prep (Flutter)

A Flutter mobile application designed for Grade 12 students to prepare for entrance exams. It features a structured curriculum, performance tracking, and an integrated AI study assistant.

## Features

- **Student Portal**: Curriculum access (Subjects → Chapters → Topics), progress tracking, and bookmarking.
- **Learning Modules**: Includes Objectives, Notes, Videos, Exercises, Quizzes, and Exams for every topic.
- **AI Support**: Integrated study assistant for concept clarification.
- **Engagement**: Q&A discussion boards and real-time notifications.
- **Teacher Tools**: Managing curriculum content and answering student questions.
- **Admin Panel**: User management and course configuration.

## Technical Details

- **Framework**: Flutter (Stable)
- **State Management**: Riverpod
- **Architecture**: Module-based Clean Architecture (Domain, Data, Application, Presentation layers)
- **Local Settings**: Edit `lib/core/constants/util.dart` to change the API endpoint (e.g., for local backend testing).

## Project Layout

```text
lib/
├── core/           # API client, styles, and utilities
├── shared/         # Common providers and UI components
└── features/
    ├── auth/       # Authentication flow
    ├── student/    # Dashboard and student-specific views
    ├── curriculum/ # Subject/Chapter/Topic navigation
    ├── content/    # Topic module implementations
    ├── engagement/ # Progress, QA, and notifications
    ├── teacher/    # Content management for teachers
    ├── admin/      # Administrative controls
    └── ai/         # AI assistant integration
```

## Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure API**:
   Update `apiUrl` in `lib/core/constants/util.dart`. By default, it points to the production backend.

3. **Run App**:
   ```bash
   flutter run
   ```

## Group Contributors

| Name | ID |
| :--- | :--- |
| Aman Atalay | UGR/4364/15 |
| Asnake Mengesha | UGR/9465/15 |
| Daniel Shitaye | NSR/9066/14 |
| Fraol Dereje | UGR/6955/15 |
