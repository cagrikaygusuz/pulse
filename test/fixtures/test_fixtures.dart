import 'package:pulse/domain/entities/project.dart';
import 'package:pulse/domain/entities/task.dart';
import 'package:pulse/domain/entities/pomodoro_session.dart';

class ProjectFixture {
  static Project createProject({
    String? id,
    String? name,
    String? description,
    String? userId,
    int? sortOrder,
    bool? isArchived,
  }) {
    return Project(
      id: id ?? 'test-project-id',
      name: name ?? 'Test Project',
      description: description ?? 'Test project description',
      userId: userId ?? 'test-user-id',
      sortOrder: sortOrder ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isArchived: isArchived ?? false,
    );
  }

  static List<Project> createProjectList(int count) {
    return List.generate(count, (index) => createProject(
      id: 'project-$index',
      name: 'Test Project $index',
    ));
  }
}

class TaskFixture {
  static Task createTask({
    String? id,
    String? name,
    String? description,
    String? projectId,
    Duration? estimatedDuration,
    Duration? actualDuration,
    int? sortOrder,
    TaskStatus? status,
    bool? isArchived,
  }) {
    return Task(
      id: id ?? 'test-task-id',
      projectId: projectId ?? 'test-project-id',
      name: name ?? 'Test Task',
      description: description ?? 'Test task description',
      estimatedDuration: estimatedDuration ?? const Duration(minutes: 25),
      actualDuration: actualDuration,
      sortOrder: sortOrder ?? 0,
      status: status ?? TaskStatus.todo,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isArchived: isArchived ?? false,
    );
  }

  static List<Task> createTaskList(int count) {
    return List.generate(count, (index) => createTask(
      id: 'task-$index',
      name: 'Test Task $index',
    ));
  }
}

class PomodoroSessionFixture {
  static PomodoroSession createSession({
    String? id,
    String? taskId,
    SessionType? sessionType,
    DateTime? startTime,
    DateTime? completedAt,
    Duration? duration,
    bool? isCompleted,
    SkipReason? skipReason,
    String? notes,
  }) {
    return PomodoroSession(
      id: id ?? 'test-session-id',
      taskId: taskId ?? 'test-task-id',
      sessionType: sessionType ?? SessionType.pomodoro,
      startTime: startTime ?? DateTime.now().subtract(const Duration(minutes: 10)),
      completedAt: completedAt ?? DateTime.now(),
      duration: duration ?? const Duration(minutes: 25),
      isCompleted: isCompleted ?? true,
      skipReason: skipReason,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  static List<PomodoroSession> createSessionList(int count) {
    return List.generate(count, (index) => createSession(
      id: 'session-$index',
      taskId: 'task-$index',
    ));
  }
}
