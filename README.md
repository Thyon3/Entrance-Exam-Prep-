# Entrance Exam Prep (Flutter Mobile)

Mobile version of the Grade 12 entrance exam preparation web app. Uses the **same backend API** as `Final_year_project_2-Entrance-Exam-Preparation-Platform` and follows the **module + clean architecture** layout from `nexatrackerprod`.

## Run

```bash
cd finalyearproject
flutter pub get
flutter run
```

## API URL

Default production API (same as the React app):

`https://final-year-project-2-entrance-exam.onrender.com/api`

To use a local backend, edit `lib/core/constants/util.dart`:

```dart
const String apiUrl = 'http://10.0.2.2:5000/api'; // Android emulator → localhost:5000
```

## Project structure

```
lib/
├── core/           # API client, theme, shared widgets
├── shared/         # Auth gate, grade provider
└── features/
    ├── auth/       # Login, register, forgot/reset password
    ├── student/    # Dashboard, drawer
    ├── curriculum/ # Subjects → chapters → topics
    ├── content/    # Topic tabs (objectives, concept, video, …)
    ├── engagement/ # Progress, bookmarks, notifications, Q&A
    ├── teacher/    # Course management, Q&A/issues
    ├── admin/      # Users, courses
    ├── profile/
    └── ai/         # AI study assistant
```

Each feature uses: `domain/`, `data/` (`*_remote_data_source.dart`), `application/` (Riverpod), `presentation/pages/`.

## Roles

- **Student**: dashboard, curriculum, all topic tabs, AI tutor, bookmarks, reports
- **Teacher**: subjects/chapters/topics CRUD, Q&A and issue review
- **Admin**: user status, subject CRUD
