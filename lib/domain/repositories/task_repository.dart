import '../entities/project.dart';
import '../entities/task.dart';

/// Abstract repository for task and project operations
abstract class TaskRepository {
  // Projects

  /// Create a new project
  Future<void> createProject(Project project);

  /// Get projects for a user
  Future<List<Project>> getProjects(String userId);

  /// Get project by ID
  Future<Project?> getProject(String projectId);

  /// Update a project
  Future<void> updateProject(Project project);

  /// Delete a project
  Future<void> deleteProject(String projectId);

  /// Reorder projects
  Future<void> reorderProjects(List<Project> projects);

  /// Archive a project
  Future<void> archiveProject(String projectId);

  /// Unarchive a project
  Future<void> unarchiveProject(String projectId);

  /// Get projects stream for real-time updates
  Stream<List<Project>> getProjectsStream(String userId);

  // Tasks

  /// Create a new task
  Future<void> createTask(Task task);

  /// Get tasks for a project
  Future<List<Task>> getTasks(String projectId);

  /// Get task by ID
  Future<Task?> getTask(String taskId);

  /// Update a task
  Future<void> updateTask(Task task);

  /// Delete a task
  Future<void> deleteTask(String taskId);

  /// Reorder tasks
  Future<void> reorderTasks(List<Task> tasks);

  /// Archive a task
  Future<void> archiveTask(String taskId);

  /// Unarchive a task
  Future<void> unarchiveTask(String taskId);

  /// Mark task as in progress
  Future<void> markTaskInProgress(String taskId);

  /// Mark task as completed
  Future<void> markTaskCompleted(String taskId, {Duration? actualDuration});

  /// Mark task as cancelled
  Future<void> markTaskCancelled(String taskId);

  /// Reset task to pending
  Future<void> resetTaskToPending(String taskId);

  /// Get tasks stream for real-time updates
  Stream<List<Task>> getTasksStream(String projectId);

  /// Search tasks by name
  Future<List<Task>> searchTasks(String query, String userId);

  /// Get tasks by status
  Future<List<Task>> getTasksByStatus(TaskStatus status, String userId);

  /// Get completed tasks in date range
  Future<List<Task>> getCompletedTasksInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
