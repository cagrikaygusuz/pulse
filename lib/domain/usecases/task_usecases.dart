import '../entities/project.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for creating a new project
class CreateProjectUseCase {
  final TaskRepository _taskRepository;

  CreateProjectUseCase(this._taskRepository);

  Future<void> call({
    required String name,
    String? description,
    required String userId,
  }) async {
    try {
      final project = Project(
        id: const Uuid().v4(),
        name: name,
        description: description,
        userId: userId,
        sortOrder: 0, // Will be updated when reordering
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _taskRepository.createProject(project);
    } catch (e) {
      throw Exception('Failed to create project: ${e.toString()}');
    }
  }
}

/// Use case for getting all projects for a user
class GetProjectsUseCase {
  final TaskRepository _taskRepository;

  GetProjectsUseCase(this._taskRepository);

  Future<List<Project>> call(String userId) async {
    try {
      return await _taskRepository.getProjects(userId);
    } catch (e) {
      throw Exception('Failed to get projects: ${e.toString()}');
    }
  }
}

/// Use case for updating a project
class UpdateProjectUseCase {
  final TaskRepository _taskRepository;

  UpdateProjectUseCase(this._taskRepository);

  Future<void> call(Project project) async {
    try {
      await _taskRepository.updateProject(project);
    } catch (e) {
      throw Exception('Failed to update project: ${e.toString()}');
    }
  }
}

/// Use case for deleting a project
class DeleteProjectUseCase {
  final TaskRepository _taskRepository;

  DeleteProjectUseCase(this._taskRepository);

  Future<void> call(String projectId) async {
    try {
      await _taskRepository.deleteProject(projectId);
    } catch (e) {
      throw Exception('Failed to delete project: ${e.toString()}');
    }
  }
}

/// Use case for reordering projects
class ReorderProjectsUseCase {
  final TaskRepository _taskRepository;

  ReorderProjectsUseCase(this._taskRepository);

  Future<void> call(List<Project> projects) async {
    try {
      await _taskRepository.reorderProjects(projects);
    } catch (e) {
      throw Exception('Failed to reorder projects: ${e.toString()}');
    }
  }
}

/// Use case for archiving a project
class ArchiveProjectUseCase {
  final TaskRepository _taskRepository;

  ArchiveProjectUseCase(this._taskRepository);

  Future<void> call(String projectId) async {
    try {
      await _taskRepository.archiveProject(projectId);
    } catch (e) {
      throw Exception('Failed to archive project: ${e.toString()}');
    }
  }
}

/// Use case for unarchiving a project
class UnarchiveProjectUseCase {
  final TaskRepository _taskRepository;

  UnarchiveProjectUseCase(this._taskRepository);

  Future<void> call(String projectId) async {
    try {
      await _taskRepository.unarchiveProject(projectId);
    } catch (e) {
      throw Exception('Failed to unarchive project: ${e.toString()}');
    }
  }
}

/// Use case for creating a new task
class CreateTaskUseCase {
  final TaskRepository _taskRepository;

  CreateTaskUseCase(this._taskRepository);

  Future<void> call({
    required String name,
    String? description,
    required Duration estimatedDuration,
    required String projectId,
  }) async {
    try {
      final task = Task(
        id: const Uuid().v4(),
        projectId: projectId,
        name: name,
        description: description,
        estimatedDuration: estimatedDuration,
        sortOrder: 0, // Will be updated when reordering
        status: TaskStatus.todo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _taskRepository.createTask(task);
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }
}

/// Use case for getting all tasks for a project
class GetTasksUseCase {
  final TaskRepository _taskRepository;

  GetTasksUseCase(this._taskRepository);

  Future<List<Task>> call(String projectId) async {
    try {
      return await _taskRepository.getTasks(projectId);
    } catch (e) {
      throw Exception('Failed to get tasks: ${e.toString()}');
    }
  }
}

/// Use case for updating a task
class UpdateTaskUseCase {
  final TaskRepository _taskRepository;

  UpdateTaskUseCase(this._taskRepository);

  Future<void> call(Task task) async {
    try {
      await _taskRepository.updateTask(task);
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }
}

/// Use case for deleting a task
class DeleteTaskUseCase {
  final TaskRepository _taskRepository;

  DeleteTaskUseCase(this._taskRepository);

  Future<void> call(String taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }
}

/// Use case for reordering tasks
class ReorderTasksUseCase {
  final TaskRepository _taskRepository;

  ReorderTasksUseCase(this._taskRepository);

  Future<void> call(List<Task> tasks) async {
    try {
      await _taskRepository.reorderTasks(tasks);
    } catch (e) {
      throw Exception('Failed to reorder tasks: ${e.toString()}');
    }
  }
}

/// Use case for marking a task as in progress
class MarkTaskInProgressUseCase {
  final TaskRepository _taskRepository;

  MarkTaskInProgressUseCase(this._taskRepository);

  Future<void> call(String taskId) async {
    try {
      await _taskRepository.markTaskInProgress(taskId);
    } catch (e) {
      throw Exception('Failed to mark task as in progress: ${e.toString()}');
    }
  }
}

/// Use case for marking a task as completed
class MarkTaskCompletedUseCase {
  final TaskRepository _taskRepository;

  MarkTaskCompletedUseCase(this._taskRepository);

  Future<void> call(String taskId, {Duration? actualDuration}) async {
    try {
      await _taskRepository.markTaskCompleted(taskId, actualDuration: actualDuration);
    } catch (e) {
      throw Exception('Failed to mark task as completed: ${e.toString()}');
    }
  }
}

/// Use case for marking a task as cancelled
class MarkTaskCancelledUseCase {
  final TaskRepository _taskRepository;

  MarkTaskCancelledUseCase(this._taskRepository);

  Future<void> call(String taskId) async {
    try {
      await _taskRepository.markTaskCancelled(taskId);
    } catch (e) {
      throw Exception('Failed to mark task as cancelled: ${e.toString()}');
    }
  }
}

/// Use case for resetting a task to pending
class ResetTaskToPendingUseCase {
  final TaskRepository _taskRepository;

  ResetTaskToPendingUseCase(this._taskRepository);

  Future<void> call(String taskId) async {
    try {
      await _taskRepository.resetTaskToPending(taskId);
    } catch (e) {
      throw Exception('Failed to reset task to pending: ${e.toString()}');
    }
  }
}

/// Use case for searching tasks
class SearchTasksUseCase {
  final TaskRepository _taskRepository;

  SearchTasksUseCase(this._taskRepository);

  Future<List<Task>> call(String query, String userId) async {
    try {
      return await _taskRepository.searchTasks(query, userId);
    } catch (e) {
      throw Exception('Failed to search tasks: ${e.toString()}');
    }
  }
}

/// Use case for getting tasks by status
class GetTasksByStatusUseCase {
  final TaskRepository _taskRepository;

  GetTasksByStatusUseCase(this._taskRepository);

  Future<List<Task>> call(TaskStatus status, String userId) async {
    try {
      return await _taskRepository.getTasksByStatus(status, userId);
    } catch (e) {
      throw Exception('Failed to get tasks by status: ${e.toString()}');
    }
  }
}

/// Use case for getting completed tasks in date range
class GetCompletedTasksInDateRangeUseCase {
  final TaskRepository _taskRepository;

  GetCompletedTasksInDateRangeUseCase(this._taskRepository);

  Future<List<Task>> call(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _taskRepository.getCompletedTasksInDateRange(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      throw Exception('Failed to get completed tasks in date range: ${e.toString()}');
    }
  }
}
