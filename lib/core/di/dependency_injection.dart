import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import '../data/datasources/local/isar_service.dart';
import '../data/datasources/remote/firebase_service.dart';
import '../data/datasources/remote/firestore_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/session_usecases.dart';
import '../domain/usecases/task_usecases.dart';

/// Service locator for dependency injection
final GetIt getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Initialize Isar
  final isar = await IsarService().openIsar();
  getIt.registerSingleton<Isar>(isar);

  // Initialize Firebase
  await FirebaseService.initializeFirebase();

  // Register services
  getIt.registerSingleton<FirebaseService>(FirebaseService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<IsarService>(IsarService());

  // Register repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(auth: getIt<FirebaseService>().auth),
  );
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(
      isar: getIt<Isar>(),
      firestoreService: getIt<FirestoreService>(),
    ),
  );
  getIt.registerSingleton<SessionRepository>(
    SessionRepositoryImpl(
      isar: getIt<Isar>(),
      firestoreService: getIt<FirestoreService>(),
    ),
  );

  // Register auth use cases
  getIt.registerSingleton<SignInWithEmailUseCase>(
    SignInWithEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<CreateUserWithEmailUseCase>(
    CreateUserWithEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<SignOutUseCase>(
    SignOutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<SendPasswordResetEmailUseCase>(
    SendPasswordResetEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateUserProfileUseCase>(
    UpdateUserProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateUserEmailUseCase>(
    UpdateUserEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateUserPasswordUseCase>(
    UpdateUserPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<DeleteUserUseCase>(
    DeleteUserUseCase(getIt<AuthRepository>()),
  );

  // Register task use cases
  getIt.registerSingleton<CreateProjectUseCase>(
    CreateProjectUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<GetProjectsUseCase>(
    GetProjectsUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<UpdateProjectUseCase>(
    UpdateProjectUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<DeleteProjectUseCase>(
    DeleteProjectUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<ReorderProjectsUseCase>(
    ReorderProjectsUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<ArchiveProjectUseCase>(
    ArchiveProjectUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<UnarchiveProjectUseCase>(
    UnarchiveProjectUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<CreateTaskUseCase>(
    CreateTaskUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<GetTasksUseCase>(
    GetTasksUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<UpdateTaskUseCase>(
    UpdateTaskUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<DeleteTaskUseCase>(
    DeleteTaskUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<ReorderTasksUseCase>(
    ReorderTasksUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<MarkTaskInProgressUseCase>(
    MarkTaskInProgressUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<MarkTaskCompletedUseCase>(
    MarkTaskCompletedUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<MarkTaskCancelledUseCase>(
    MarkTaskCancelledUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<ResetTaskToPendingUseCase>(
    ResetTaskToPendingUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<SearchTasksUseCase>(
    SearchTasksUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<GetTasksByStatusUseCase>(
    GetTasksByStatusUseCase(getIt<TaskRepository>()),
  );
  getIt.registerSingleton<GetCompletedTasksInDateRangeUseCase>(
    GetCompletedTasksInDateRangeUseCase(getIt<TaskRepository>()),
  );

  // Register session use cases
  getIt.registerSingleton<CreatePomodoroSessionUseCase>(
    CreatePomodoroSessionUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetSessionsUseCase>(
    GetSessionsUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetSessionsForTaskUseCase>(
    GetSessionsForTaskUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<UpdateSessionUseCase>(
    UpdateSessionUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<DeleteSessionUseCase>(
    DeleteSessionUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<MarkSessionCompletedUseCase>(
    MarkSessionCompletedUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<MarkSessionSkippedUseCase>(
    MarkSessionSkippedUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetSessionsInDateRangeUseCase>(
    GetSessionsInDateRangeUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetCompletedSessionsUseCase>(
    GetCompletedSessionsUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetSkippedSessionsUseCase>(
    GetSkippedSessionsUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetSessionsByTypeUseCase>(
    GetSessionsByTypeUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetActiveSessionUseCase>(
    GetActiveSessionUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetTodaySessionsUseCase>(
    GetTodaySessionsUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetThisWeekSessionsUseCase>(
    GetThisWeekSessionsUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetThisMonthSessionsUseCase>(
    GetThisMonthSessionsUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<BatchCreateSessionsUseCase>(
    BatchCreateSessionsUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetTotalFocusTimeUseCase>(
    GetTotalFocusTimeUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetTotalFocusTimeInRangeUseCase>(
    GetTotalFocusTimeInRangeUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetCompletionRateUseCase>(
    GetCompletionRateUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetCompletionRateInRangeUseCase>(
    GetCompletionRateInRangeUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetAverageSessionLengthUseCase>(
    GetAverageSessionLengthUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetPeakHoursUseCase>(
    GetPeakHoursUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<SyncPendingSessionsUseCase>(
    SyncPendingSessionsUseCase(getIt<SessionRepository>()),
  );
  getIt.registerSingleton<GetPendingSyncSessionsUseCase>(
    GetPendingSyncSessionsUseCase(getIt<SessionRepository>()),
  );
}

/// Dispose all dependencies
Future<void> disposeDependencies() async {
  await getIt.reset();
}
