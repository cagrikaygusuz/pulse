# Pulse Project Blueprint

## 1. Project Overview
**Application Name:** Pulse
**Slogan/Motto:** Master your flow. Measure your focus.
**Goal:** To create a cross-platform Pomodoro timer that integrates deeply with advanced task management and provides insightful productivity analytics to help users maintain focus and analyze their work patterns.
**GitHub Repository:** [https://github.com/cagrikaygusuz/pulse.git](https://github.com/cagrikaygusuz/pulse.git)
**Localization (i18n):** English (EN) and Turkish (TR)

### 1.1 Problem Statement & Target Audience
* Standard Pomodoro applications often function as isolated timers, failing to link focused time to meaningful productivity metrics.
* They lack hierarchical task context (Project > Task > Subtask).

Pulse solves this by forcing a link between time and a defined goal.

**Target Audience:** Remote knowledge workers, software developers, students, and creative professionals who require deep, uninterrupted focus sessions and need quantifiable data to prove their efficiency and identify peak performance times.
The application is designed for the user who seeks discipline and verifiable data, transitioning the user from mere time logging to integrated, verifiable productivity intelligence.

**Unique Selling Proposition (USP):** Pulse is not just a timer; it is a seamless, distraction-free environment that merges disciplined time management with advanced, syncable task hierarchy and rich gamified analytics.

## 2. Technology Stack & Architecture

| Component | Technology / Framework | Reason for Choice |
| :--- | :--- | :--- |
| Frontend/App | Flutter (Dart) | "Single codebase for iOS, Android, Windows, and macOS, offering high performance and excellent UI customizability (for visual countdowns, heatmaps, etc.). Flutter allows precise control over the animation and feel necessary for a premium focus tool." |
| State Management | BLoC / Cubit | "Structured, testable, and scalable state management. `Cubit` will be used for simple, eventless state transitions (e.g., the countdown ticker). `BLoC` will handle complex business flows (e.g., Task completion, Achievement processing, cross-platform data synchronization)." |
| Backend & Auth | Google Firebase (Authentication & Firestore) | "Provides essential real-time synchronization across all devices. Firebase Auth simplifies user sign-up/login, and Firestore's flexible NoSQL structure is ideal for storing dynamic task lists and time-series data (session logs)." |
| Local Database | Isar (or Hive) | "Highly efficient local storage for offline operation. `Isar` will store the active Pomodoro session details, unsynced session logs, and user settings, ensuring the timer functions perfectly even without internet connectivity (Offline-First Strategy)." |
| Architecture | "Layered Architecture (Presentation, Domain, Data)" | "`Presentation:` Widgets and UI. `Domain:` Core models, Use Cases (e.g., StartNewPomodoroUseCase), and entity rules. `Data:` Repositories handling data sources (Isar and Firestore). This separation ensures that the core business logic (Domain) is testable and independent of the Flutter framework." |
| Preferred Font | Inter / Roboto | "A modern, clean, and highly legible sans-serif font to maintain a disciplined and professional aesthetic across all platforms." |

### 2.1 Data Synchronization Strategy
Pulse will adopt an *Offline-First* approach:
* All active Pomodoro sessions and basic task interactions (creation/completion) are written *first to Isar*.
* Upon session completion or when connectivity is restored, the data is pushed to *Firestore* for long-term storage and cross-device synchronization.
* Firestore will serve as the single source of truth for all complex analytics (Heatmap data, Achievements).

## 3. Visual Identity (Branding)
**Core Colors (Based on User Selection):** These colors will be used strategically to influence the user's psychological state and clearly delineate between work and rest.

| Hex Code | Use Case | Description | Color Psychology in UI |
| :--- | :--- | :--- | :--- |
| `#ed6b06` | Primary Accent / Focus Timer / Start Button | "Energy, Focus, Action (Turuncu/Kırmızı)" | "Used for the active fill of the Visual Countdown arc, primary CTAs during work periods, and urgency alerts." |
| `#9d1348` | Secondary Accent / Long Break Indicator | "Passion, Intensity (Bordo/Koyu Pempe)" | "Used sparingly, often for Long Break screens or to highlight high-priority tasks, indicating a deeper intensity or reward." |
| `#008b5d` | Success / Completion / Achievement | "Efficiency, Growth (Koyu Yeşil/Zümrüt)" | "Dominant color for task completion markers, achievement notifications, and overall statistics graphs that show progress." |
| `#364395` | Primary Background / Discipline / Trust | "Reliability, Stability (Koyu Mavi/Çivit)" | "Used as the primary background color in Dark Mode or as a header background in Light Mode, promoting a calm, disciplined workspace." |

## 4. Finalized Feature List

### A. Core Pomodoro Mechanics
* **Customizable Cycles:** Durations are stored locally (Isar) and synced (Firestore) to ensure consistency across devices.
* **Loop Management:** The BLoC must handle the automatic transition Pomodoro -> Short Break -> Pomodoro -> ... -> Long Break, tracking the session index.
* **Visual Countdown:** *(Feature)* Implemented using Flutter's `CustomPainter` to create a high-performance, smooth animated arc that visually represents the passing time, significantly enhancing focus immersion.

### B. Advanced Task & Project Management
* **Project/Task Hierarchy:** Data models must support one-to-many relationships (Project -> Tasks, Task -> Subtasks).
* **Estimated Duration (Tahmini Süre):** *(Feature)* This estimate (in Pomodoros) is a core piece of data used for comparison against the actual time spent, feeding into advanced analytics for planning accuracy.
* **Drag-and-Drop Sorting:** *(Feature)* Implemented using Flutter's `ReorderableListView` or custom drag logic, ensuring the sort order is persisted in both Isar (for local UI) and Firestore (for sync).
* **Mandatory Task Link:** A front-end validation rule ensures the user selects a task ID before the timer BLoC accepts the start event.

### C. Focus & Discipline Controls
* **Timer Lock (Zamanlama Ayarlama Kiliti):** *(Feature)* The Presentation Layer will disable or visually gray-out all cycle-modifying controls (skip, reset, duration change) when the timer is in the Running state.
* **Graceful Skip (Seans Atlama):** *(Feature)* This triggers a specific BLoC event (`GracefulSkipRequested`) which logs the session as "Interrupted" or "Incomplete" rather than simply deleting it.
    * This incomplete data is vital for accurate analysis of distraction patterns.

### D. Analytics, Reporting & Motivation
* **Heatmap View (Isı Haritası):** *(Feature)* Requires processing time-series data from Firestore to generate a grid visualizing the volume of completed Pomodoros per day and time block throughout the year.
    * Data points must include `completionTimestamp` and `sessionType`.
* **Achievement System (Başarımlar):** *(Feature)* Achievement rules (e.g., check for a 7-day streak, cumulative session count) will be stored in the Domain Layer and checked asynchronously against the Firestore data.
* **Achievement Categories:**
    * Consistency: (Daily/Weekly Streaks)
    * Volume: (Total hours/sessions completed)
    * Discipline: (Low rate of Graceful Skips)
* **Basic Statistics:** Tracking metrics like average Pomodoro length, most focused project, and time spent on breaks vs. work.

## 5. Development Roadmap (Phase 1 - Expanded Detail)
The development will proceed in a structured, mentor-guided manner, ensuring stability and testability at every stage.

| Phase | Focus Area | Deliverables | Key Technology | Specific Tasks/Milestones |
| :--- | :--- | :--- | :--- | :--- |
| **Phase 1** | Setup & Foundation | "Project structure, Core Dependencies, L10N files, Theming" | "Flutter, BLoC, i18n" | "- Initialize Flutter Project. - Add `flutter_bloc`, `equatable`, `firebase_core` to pubspec.yaml. - Define Layered Architecture folder structure (data, domain, presentation). - Implement basic EN/TR localization boilerplate. - Setup core `ThemeData` using selected color codes." |
| **Phase 2** | Data & Domain | "Core Models, Data Repositories, Use Cases, DB Init" | "Firebase Auth, Firestore, Isar" | "- Define Task, Project, PomodoroSession models (with toJson/fromJson for data mapping). - Initialize Isar database and define schemas. - Implement `AuthRepository` for Firebase sign-in/out. - Define initial `GetTasksUseCase` and `SaveSessionUseCase`." |
| **Phase 3** | Core Timer Logic | "Timer Cubit, UI, Background Services, Timer Lock" | "BLoC/Cubit, Dart Stream Controllers" | "- Create `TimerCubit` to handle the countdown using Dart Timer and StreamController. - Implement logic for cycle transitions (work -> break). - Integrate platform-specific local notifications for timer end. - Implement the `Timer Lock` logic by restricting state transitions in the Cubit." |
| **Phase 4** | Task UI & Persistence | "Task List Screen, CRUD Operations, D&D" | "Flutter Widgets, Firestore Service" | "- Implement the Task/Project screens (Presentation). - Implement CRUD operations via `TaskRepository` to Firestore (Data). - Implement `Drag-and-Drop Sorting` persistence logic. - Enforce `Mandatory Task Link` UI validation upon timer start." |
| **Phase 5** | Advanced Features | "Visuals, Logging, Analytics Engine" | "CustomPaint, Data Layer Logic" | "- Implement the `Visual Countdown` UI using `CustomPainter`. - Implement `Graceful Skip` logging and analysis logic. - Create the `AnalyticsRepository` to process Firestore session logs for the `Heatmap` view. - Define and implement the logic for the first three `Achievements`." |
| **Phase 6** | Polish & Deployment | "Final UI/UX, Testing, Documentation" | All | "- Comprehensive unit and widget testing. - Ensure full responsiveness across mobile/desktop platforms. - Final application icon and store assets creation. - Setup CI/CD for GitHub deployment." |