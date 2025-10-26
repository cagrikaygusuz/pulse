# Pulse Pomodoro Timer - Complete Development Plan

## Phase 1: Setup & Foundation

### 1.1 Project Structure & Dependencies

- Create layered architecture folders: `lib/core/`, `lib/data/`, `lib/domain/`, `lib/presentation/`
- Update `pubspec.yaml` with core dependencies:
- `flutter_bloc: ^8.1.3` and `equatable: ^2.0.5` for state management
- `firebase_core: ^2.24.2`, `firebase_auth: ^4.16.0`, `cloud_firestore: ^4.14.0`
- `isar: ^3.1.0`, `isar_flutter_libs: ^3.1.0` for local database
- `flutter_localizations` for i18n support
- `intl: ^0.19.0` for date/time formatting
- Add dev dependencies: `build_runner: ^2.4.7`, `isar_generator: ^3.1.0`, `mockito: ^5.4.4`, `bloc_test: ^9.1.5`

### 1.2 Localization Setup

- Create `lib/core/l10n/` directory
- Add `l10n.yaml` configuration file
- Create `lib/core/l10n/app_en.arb` with English strings
- Create `lib/core/l10n/app_tr.arb` with Turkish translations
- Key strings: timer controls, task management, analytics labels, achievement names

### 1.3 Theme & Color System

- Create `lib/core/theme/app_colors.dart` with brand colors:
- `primaryAccent: Color(0xFFED6B06)` - Focus/Energy
- `secondaryAccent: Color(0xFF9D1348)` - Long Break/Intensity
- `success: Color(0xFF008B5D)` - Completion/Achievement
- `primaryBackground: Color(0xFF364395)` - Discipline/Trust
- Create `lib/core/theme/app_theme.dart` with light/dark `ThemeData`
- Configure Inter font family in `pubspec.yaml` and `assets/fonts/`

### 1.4 Constants & Utilities

- Create `lib/core/constants/app_constants.dart`:
- Default Pomodoro duration (25 min), short break (5 min), long break (15 min)
- Pomodoros before long break (4)
- Maximum task name length, validation rules
- Create `lib/core/utils/` for helper functions (date formatters, validators)

---

## Phase 2: Data Layer & Domain Models

### 2.1 Domain Entities

- Create `lib/domain/entities/project.dart`:
- Fields: `id`, `name`, `description`, `userId`, `sortOrder`, `createdAt`, `updatedAt`, `isArchived`
- Include `copyWith()` and `Equatable` props
- Create `lib/domain/entities/task.dart`:
- Fields: `id`, `projectId`, `name`, `description`, `estimatedDuration`, `actualDuration`, `sortOrder`, `status`, `createdAt`, `updatedAt`, `isArchived`
- Enum `TaskStatus`: pending, inProgress, completed, cancelled
- Create `lib/domain/entities/pomodoro_session.dart`:
- Fields: `id`, `taskId`, `sessionType`, `startTime`, `completedAt`, `duration`, `isCompleted`, `skipReason`, `createdAt`
- Enum `SessionType`: work, shortBreak, longBreak

### 2.2 Isar Database Setup

- Create `lib/data/datasources/local/isar_service.dart`:
- Initialize Isar instance with schemas
- Implement singleton pattern
- Create Isar collection models in `lib/data/models/`:
- `project_model.dart` with `@collection` annotation
- `task_model.dart` with `@collection` annotation
- `pomodoro_session_model.dart` with `@collection` annotation
- Each model includes `toEntity()` and `fromEntity()` methods
- Run `flutter pub run build_runner build` to generate Isar code

### 2.3 Firebase Setup

- Create `lib/data/datasources/remote/firebase_service.dart`
- Initialize Firebase in `lib/main.dart` with `Firebase.initializeApp()`
- Create `lib/data/datasources/remote/firestore_service.dart`:
- Collection references: `users`, `projects`, `tasks`, `pomodoro_sessions`, `achievements`
- CRUD methods with error handling

### 2.4 Repository Interfaces & Implementation

- Create `lib/domain/repositories/auth_repository.dart` (abstract)
- Create `lib/data/repositories/auth_repository_impl.dart`:
- `signInWithEmail()`, `signUpWithEmail()`, `signOut()`, `getCurrentUser()`
- Create `lib/domain/repositories/task_repository.dart` (abstract)
- Create `lib/data/repositories/task_repository_impl.dart`:
- Offline-first: write to Isar first, sync to Firestore when online
- `getTasks()`, `createTask()`, `updateTask()`, `deleteTask()`, `reorderTasks()`
- Create `lib/domain/repositories/session_repository.dart` (abstract)
- Create `lib/data/repositories/session_repository_impl.dart`:
- `createSession()`, `completeSession()`, `getSessions()`, `syncPendingSessions()`

### 2.5 Use Cases

- Create `lib/domain/usecases/auth/`:
- `sign_in_usecase.dart`, `sign_up_usecase.dart`, `sign_out_usecase.dart`
- Create `lib/domain/usecases/tasks/`:
- `get_tasks_usecase.dart`, `create_task_usecase.dart`, `update_task_usecase.dart`, `delete_task_usecase.dart`
- Create `lib/domain/usecases/timer/`:
- `start_pomodoro_usecase.dart`, `complete_session_usecase.dart`, `skip_session_usecase.dart`

### 2.6 CI/CD Pipeline Setup

- Create `.github/workflows/ci.yml`:
- Run on push/PR to main branch
- Jobs: analyze (flutter analyze), test (flutter test), build (Android APK, Windows executable)
- Cache Flutter SDK and dependencies
- Create `.github/workflows/release.yml` for tagged releases

---

## Phase 3: Core Timer Logic & BLoC

### 3.1 Timer State Management

- Create `lib/presentation/bloc/timer/timer_state.dart`:
- `TimerInitialState`, `TimerRunningState`, `TimerPausedState`, `TimerCompletedState`, `TimerSkippedState`, `TimerErrorState`
- `TimerRunningState` includes: `remainingTime`, `taskId`, `taskName`, `startTime`, `sessionType`, `completedPomodoros`
- Create `lib/presentation/bloc/timer/timer_cubit.dart`:
- Use `Stream<int>` with `Timer.periodic()` for countdown
- Methods: `startTimer()`, `pauseTimer()`, `resumeTimer()`, `skipSession()`, `completeSession()`
- Implement timer lock: prevent state changes when `isTimerLocked` is true
- Auto-transition logic: work → short break → work → ... → long break (after 4 work sessions)

### 3.2 Timer Lock Implementation

- Add `bool get isTimerLocked => state is TimerRunningState` in `TimerCubit`
- Throw `TimerLockedException` when attempting locked operations
- UI layer will disable controls based on lock state

### 3.3 Graceful Skip Logic

- Create `skip_session_usecase.dart` to log interrupted sessions
- Add `skipReason` field to `PomodoroSession` entity
- Store incomplete sessions in Isar with `isCompleted: false` flag
- Sync skipped sessions to Firestore for analytics

### 3.4 Background Timer Service

- Create `lib/core/services/timer_service.dart`:
- Handle timer continuation when app is backgrounded
- Platform-specific implementations for Android (Foreground Service) and Windows (Background Task)
- Integrate with `TimerCubit` to persist timer state

### 3.5 Local Notifications

- Add `flutter_local_notifications: ^16.3.0` to `pubspec.yaml`
- Create `lib/core/services/notification_service.dart`:
- Initialize platform-specific notification channels
- `showTimerCompletedNotification()`, `showBreakStartedNotification()`
- Trigger notifications from `TimerCubit` on state transitions

---

## Phase 4: Task Management UI & Persistence

### 4.1 Authentication UI

- Create `lib/presentation/pages/auth/login_page.dart`:
- Email/password input fields with validation
- Sign in and sign up buttons
- Error message display
- Create `lib/presentation/bloc/auth/auth_bloc.dart`:
- Events: `AuthCheckRequested`, `SignInRequested`, `SignUpRequested`, `SignOutRequested`
- States: `AuthInitialState`, `AuthLoadingState`, `AuthAuthenticatedState`, `AuthUnauthenticatedState`, `AuthErrorState`
- Implement route guards in `lib/core/router/app_router.dart`

### 4.2 Project Management UI

- Create `lib/presentation/pages/projects/projects_page.dart`:
- List of projects with `ReorderableListView`
- Add/Edit/Delete project actions
- Navigate to task list on project tap
- Create `lib/presentation/bloc/project/project_bloc.dart`:
- Events: `LoadProjectsEvent`, `CreateProjectEvent`, `UpdateProjectEvent`, `DeleteProjectEvent`, `ReorderProjectsEvent`
- States: `ProjectInitialState`, `ProjectLoadingState`, `ProjectLoadedState`, `ProjectErrorState`
- Create `lib/presentation/widgets/project/project_tile.dart` with drag handle

### 4.3 Task Management UI

- Create `lib/presentation/pages/tasks/tasks_page.dart`:
- Filtered task list by project
- `ReorderableListView` for drag-and-drop sorting
- Task status indicators (pending, in progress, completed)
- Create `lib/presentation/pages/tasks/task_detail_page.dart`:
- Task name, description, estimated duration inputs
- Duration picker (Pomodoros or minutes)
- Save/Cancel actions with validation
- Create `lib/presentation/bloc/task/task_bloc.dart`:
- Events: `LoadTasksEvent`, `CreateTaskEvent`, `UpdateTaskEvent`, `DeleteTaskEvent`, `ReorderTasksEvent`
- States: `TaskInitialState`, `TaskLoadingState`, `TaskLoadedState`, `TaskErrorState`

### 4.4 Drag-and-Drop Persistence

- Implement `onReorder` callback in `ReorderableListView`
- Update `sortOrder` field for affected items
- Save to Isar immediately for responsive UI
- Queue Firestore sync in background

### 4.5 Mandatory Task Link Validation

- Create `lib/presentation/pages/timer/task_selection_widget.dart`:
- Dropdown or searchable list of active tasks
- Required field validation before timer start
- Integrate with `TimerCubit.startTimer(taskId)` method
- Display selected task info during active session

### 4.6 Input Validation

- Create `lib/core/utils/validators.dart`:
- `validateTaskName()`, `validateProjectName()`, `validateDuration()`, `validateEmail()`, `validatePassword()`
- Implement in form fields with real-time feedback

---

## Phase 5: Advanced Features & Analytics

### 5.1 Visual Countdown with CustomPainter

- Create `lib/presentation/widgets/timer/visual_countdown_widget.dart`:
- Use `CustomPainter` for animated arc
- Gradient fill from `primaryAccent` to `secondaryAccent`
- Particle effects on completion (using `Canvas.drawCircle()` for particles)
- Smooth animation with `AnimationController` and `CurvedAnimation`
- Wrap in `RepaintBoundary` for performance
- Display remaining time in center with large, bold typography

### 5.2 Heatmap View

- Create `lib/presentation/pages/analytics/heatmap_page.dart`:
- Grid layout showing 365 days (current year)
- Color intensity based on completed Pomodoros per day
- Tooltip on hover/tap showing exact count and date
- Create `lib/domain/usecases/analytics/get_heatmap_data_usecase.dart`:
- Query Firestore for sessions grouped by date
- Calculate intensity levels (0-4 scale)
- Create `lib/presentation/widgets/analytics/heatmap_grid.dart`:
- Custom painter for grid cells
- Color mapping: no sessions → gray, 1-2 → light accent, 3-5 → medium, 6+ → full intensity

### 5.3 Achievement System

- Create `lib/domain/entities/achievement.dart`:
- Fields: `id`, `name`, `description`, `category`, `iconName`, `unlockedAt`, `progress`
- Enum `AchievementCategory`: consistency, volume, discipline
- Define achievements in `lib/core/constants/achievements.dart`:
- Consistency: "Week Warrior" (7-day streak), "Monthly Master" (30-day streak)
- Volume: "Century Club" (100 sessions), "Thousand Hours" (1000 hours focused)
- Discipline: "Focused Mind" (<5% skip rate), "Unbreakable" (0 skips in 30 days)
- Create `lib/domain/usecases/achievements/check_achievements_usecase.dart`:
- Run after each session completion
- Query session history from Firestore
- Calculate streak, total count, skip rate
- Unlock achievements and save to Firestore
- Create `lib/presentation/pages/achievements/achievements_page.dart`:
- Grid of achievement cards (locked/unlocked states)
- Progress bars for in-progress achievements
- Celebration animation on unlock

### 5.4 Basic Statistics Dashboard

- Create `lib/presentation/pages/analytics/statistics_page.dart`:
- Cards displaying: total sessions, total focus time, average session length, completion rate
- Bar chart: sessions per day of week
- Pie chart: time distribution by project
- Create `lib/domain/usecases/analytics/get_statistics_usecase.dart`:
- Aggregate session data from Firestore
- Calculate metrics with date range filters
- Add `fl_chart: ^0.66.0` to `pubspec.yaml` for charts

### 5.5 Offline-First Sync Strategy

- Create `lib/core/services/sync_service.dart`:
- Listen to connectivity changes
- Queue pending operations in Isar
- Sync on connectivity restore with retry logic
- Handle conflict resolution (last-write-wins)
- Integrate with all repository implementations
- Display sync status indicator in UI

---

## Phase 6: Polish, Testing & Deployment

### 6.1 Comprehensive Testing

- Create unit tests in `test/unit/`:
- `domain/usecases/` tests with mocked repositories
- `data/repositories/` tests with mocked data sources
- `presentation/bloc/` tests using `bloc_test` package
- Create widget tests in `test/widget/`:
- `timer_page_test.dart`, `tasks_page_test.dart`, `heatmap_page_test.dart`
- Test user interactions, state changes, accessibility
- Create integration tests in `test/integration/`:
- `timer_flow_test.dart`: complete Pomodoro session workflow
- `task_management_test.dart`: CRUD operations and sync
- Target 80%+ code coverage

### 6.2 Responsive Design

- Implement responsive layouts using `LayoutBuilder`:
- Mobile: single column, bottom navigation
- Tablet: two-column layout for timer + task list
- Desktop: three-column layout with sidebar navigation
- Test on Android (phone/tablet) and Windows (various window sizes)
- Ensure touch targets are 44x44 logical pixels minimum

### 6.3 Accessibility

- Add semantic labels to all interactive widgets
- Implement keyboard navigation for Windows (Tab, Enter, Escape)
- Test with screen readers (TalkBack on Android)
- Ensure color contrast ratios meet WCAG AA standards
- Support high contrast mode and large text

### 6.4 Performance Optimization

- Profile app with Flutter DevTools
- Optimize CustomPainter repaints with `shouldRepaint()`
- Implement pagination for large task/session lists
- Use `const` constructors throughout
- Minimize Firestore reads with local caching

### 6.5 App Icon & Branding

- Design app icon featuring Pulse logo/concept
- Create adaptive icons for Android (foreground + background)
- Generate all required icon sizes for Windows
- Update `android/app/src/main/res/` and `windows/runner/resources/`
- Update app name and description in platform manifests

### 6.6 Documentation

- Update `README.md` with:
- Project description and features
- Setup instructions (Flutter SDK, Firebase config)
- Build commands for Android and Windows
- Architecture overview diagram
- Create `CONTRIBUTING.md` with development guidelines
- Document API endpoints and data models in `documentation/api/`

### 6.7 Release Preparation

- Configure Android release signing in `android/app/build.gradle.kts`
- Set up Windows code signing certificate
- Create release build scripts: `scripts/build_android.sh`, `scripts/build_windows.bat`
- Test release builds on physical devices
- Prepare store listings (screenshots, descriptions) for Google Play

### 6.8 Deployment

- Tag release version: `git tag v1.0.0`
- Trigger GitHub Actions release workflow
- Upload Android APK/AAB to Google Play Console (internal testing track)
- Distribute Windows installer via GitHub Releases
- Monitor crash reports and user feedback
- Plan hotfix process for critical bugs

---

## Key Technical Decisions Summary

- **Database**: Isar for local storage (fast, type-safe, offline-first)
- **State Management**: BLoC/Cubit (testable, scalable, clear separation)
- **Authentication**: Firebase Auth with email/password only initially
- **Platforms**: Android and Windows prioritized for development/testing
- **Visual Effects**: Advanced CustomPainter with particle effects and gradients
- **CI/CD**: Set up in Phase 2 for early issue detection
- **Font**: Inter for modern, professional aesthetic
- **Architecture**: Clean layered architecture (Presentation → Domain → Data)
