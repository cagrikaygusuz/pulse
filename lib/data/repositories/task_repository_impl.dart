import 'package:isar/isar.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/isar_service.dart';
import '../datasources/remote/firestore_service.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository with offline-first approach
class TaskRepositoryImpl implements TaskRepository {
  final Isar _isar;
  final FirestoreService _firestoreService;

  TaskRepositoryImpl({
    Isar? isar,
    FirestoreService? firestoreService,
  }) : _isar = isar ?? IsarService.isar as Isar,
       _firestoreService = firestoreService ?? FirestoreService.instance;

  // Projects

  @override
  Future<void> createProject(Project project) async {
    try {
      // Save to local database first
      final projectModel = ProjectModel.fromEntity(project);
      await _isar.writeTxn(() async {
        await _isar.projectModels.put(projectModel);
      });

      // Try to sync to remote if online
      try {
        await _firestoreService.createProject(project);
        // Mark as synced
        projectModel.markSynced();
        await _isar.writeTxn(() async {
          await _isar.projectModels.put(projectModel);
        });
      } catch (e) {
        // Mark as pending sync
        projectModel.markNeedsSync();
        await _isar.writeTxn(() async {
          await _isar.projectModels.put(projectModel);
        });
      }
    } catch (e) {
      throw Exception('Failed to create project: ${e.toString()}');
    }
  }

  @override
  Future<List<Project>> getProjects(String userId) async {
    try {
      // Get from local database first
      final projectModels = await _isar.projectModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .isArchivedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      if (projectModels.isNotEmpty) {
        return projectModels.map((model) => model.toEntity()).toList();
      }

      // If no local data, try to get from remote
      try {
        final projects = await _firestoreService.getProjects(userId);
        
        // Save to local database
        final projectModels = projects.map((project) => ProjectModel.fromEntity(project)).toList();
        await _isar.writeTxn(() async {
          await _isar.projectModels.putAll(projectModels);
        });
        
        return projects;
      } catch (e) {
        // Return empty list if remote fails
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get projects: ${e.toString()}');
    }
  }

  @override
  Future<Project?> getProject(String projectId) async {
    try {
      final projectModel = await _isar.projectModels
          .where()
          .projectIdEqualTo(projectId)
          .findFirst();

      if (projectModel != null) {
        return projectModel.toEntity();
      }

      // Try to get from remote if not found locally
      try {
        final projects = await _firestoreService.getProjects(projectId);
        if (projects.isNotEmpty) {
          final project = projects.first;
          // Save to local database
          final projectModel = ProjectModel.fromEntity(project);
          await _isar.writeTxn(() async {
            await _isar.projectModels.put(projectModel);
          });
          return project;
        }
      } catch (e) {
        // Return null if remote fails
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get project: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    try {
      // Update local database first
      final projectModel = await _isar.projectModels
          .where()
          .projectIdEqualTo(project.id)
          .findFirst();

      if (projectModel != null) {
        projectModel.updateFromEntity(project);
        await _isar.writeTxn(() async {
          await _isar.projectModels.put(projectModel);
        });
      }

      // Try to sync to remote
      try {
        await _firestoreService.updateProject(project);
        // Mark as synced
        if (projectModel != null) {
          projectModel.markSynced();
          await _isar.writeTxn(() async {
            await _isar.projectModels.put(projectModel);
          });
        }
      } catch (e) {
        // Mark as pending sync
        if (projectModel != null) {
          projectModel.markNeedsSync();
          await _isar.writeTxn(() async {
            await _isar.projectModels.put(projectModel);
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update project: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      // Delete from local database first
      await _isar.writeTxn(() async {
        await _isar.projectModels
            .where()
            .projectIdEqualTo(projectId)
            .deleteAll();
      });

      // Try to delete from remote
      try {
        await _firestoreService.deleteProject(projectId);
      } catch (e) {
        // Remote deletion failed, but local deletion succeeded
        // This is acceptable for offline-first approach
      }
    } catch (e) {
      throw Exception('Failed to delete project: ${e.toString()}');
    }
  }

  @override
  Future<void> reorderProjects(List<Project> projects) async {
    try {
      // Update local database first
      final projectModels = <ProjectModel>[];
      for (final project in projects) {
        final projectModel = await _isar.projectModels
            .where()
            .projectIdEqualTo(project.id)
            .findFirst();
        if (projectModel != null) {
          projectModel.updateFromEntity(project);
          projectModels.add(projectModel);
        }
      }

      await _isar.writeTxn(() async {
        await _isar.projectModels.putAll(projectModels);
      });

      // Try to sync to remote
      try {
        await _firestoreService.reorderProjects(projects);
        // Mark as synced
        for (final projectModel in projectModels) {
          projectModel.markSynced();
        }
        await _isar.writeTxn(() async {
          await _isar.projectModels.putAll(projectModels);
        });
      } catch (e) {
        // Mark as pending sync
        for (final projectModel in projectModels) {
          projectModel.markNeedsSync();
        }
        await _isar.writeTxn(() async {
          await _isar.projectModels.putAll(projectModels);
        });
      }
    } catch (e) {
      throw Exception('Failed to reorder projects: ${e.toString()}');
    }
  }

  @override
  Future<void> archiveProject(String projectId) async {
    final project = await getProject(projectId);
    if (project != null) {
      await updateProject(project.archive());
    }
  }

  @override
  Future<void> unarchiveProject(String projectId) async {
    final project = await getProject(projectId);
    if (project != null) {
      await updateProject(project.unarchive());
    }
  }

  @override
  Stream<List<Project>> getProjectsStream(String userId) {
    return _isar.projectModels
        .where()
        .userIdEqualTo(userId)
        .where()
        .isArchivedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  // Tasks

  @override
  Future<void> createTask(Task task) async {
    try {
      // Save to local database first
      final taskModel = TaskModel.fromEntity(task);
      await _isar.writeTxn(() async {
        await _isar.taskModels.put(taskModel);
      });

      // Try to sync to remote if online
      try {
        await _firestoreService.createTask(task);
        // Mark as synced
        taskModel.markSynced();
        await _isar.writeTxn(() async {
          await _isar.taskModels.put(taskModel);
        });
      } catch (e) {
        // Mark as pending sync
        taskModel.markNeedsSync();
        await _isar.writeTxn(() async {
          await _isar.taskModels.put(taskModel);
        });
      }
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  @override
  Future<List<Task>> getTasks(String projectId) async {
    try {
      // Get from local database first
      final taskModels = await _isar.taskModels
          .where()
          .projectIdEqualTo(projectId)
          .where()
          .isArchivedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      if (taskModels.isNotEmpty) {
        return taskModels.map((model) => model.toEntity()).toList();
      }

      // If no local data, try to get from remote
      try {
        final tasks = await _firestoreService.getTasks(projectId);
        
        // Save to local database
        final taskModels = tasks.map((task) => TaskModel.fromEntity(task)).toList();
        await _isar.writeTxn(() async {
          await _isar.taskModels.putAll(taskModels);
        });
        
        return tasks;
      } catch (e) {
        // Return empty list if remote fails
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get tasks: ${e.toString()}');
    }
  }

  @override
  Future<Task?> getTask(String taskId) async {
    try {
      final taskModel = await _isar.taskModels
          .where()
          .taskIdEqualTo(taskId)
          .findFirst();

      if (taskModel != null) {
        return taskModel.toEntity();
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get task: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      // Update local database first
      final taskModel = await _isar.taskModels
          .where()
          .taskIdEqualTo(task.id)
          .findFirst();

      if (taskModel != null) {
        taskModel.updateFromEntity(task);
        await _isar.writeTxn(() async {
          await _isar.taskModels.put(taskModel);
        });
      }

      // Try to sync to remote
      try {
        await _firestoreService.updateTask(task);
        // Mark as synced
        if (taskModel != null) {
          taskModel.markSynced();
          await _isar.writeTxn(() async {
            await _isar.taskModels.put(taskModel);
          });
        }
      } catch (e) {
        // Mark as pending sync
        if (taskModel != null) {
          taskModel.markNeedsSync();
          await _isar.writeTxn(() async {
            await _isar.taskModels.put(taskModel);
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      // Delete from local database first
      await _isar.writeTxn(() async {
        await _isar.taskModels
            .where()
            .taskIdEqualTo(taskId)
            .deleteAll();
      });

      // Try to delete from remote
      try {
        await _firestoreService.deleteTask(taskId);
      } catch (e) {
        // Remote deletion failed, but local deletion succeeded
      }
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  @override
  Future<void> reorderTasks(List<Task> tasks) async {
    try {
      // Update local database first
      final taskModels = <TaskModel>[];
      for (final task in tasks) {
        final taskModel = await _isar.taskModels
            .where()
            .taskIdEqualTo(task.id)
            .findFirst();
        if (taskModel != null) {
          taskModel.updateFromEntity(task);
          taskModels.add(taskModel);
        }
      }

      await _isar.writeTxn(() async {
        await _isar.taskModels.putAll(taskModels);
      });

      // Try to sync to remote
      try {
        await _firestoreService.reorderTasks(tasks);
        // Mark as synced
        for (final taskModel in taskModels) {
          taskModel.markSynced();
        }
        await _isar.writeTxn(() async {
          await _isar.taskModels.putAll(taskModels);
        });
      } catch (e) {
        // Mark as pending sync
        for (final taskModel in taskModels) {
          taskModel.markNeedsSync();
        }
        await _isar.writeTxn(() async {
          await _isar.taskModels.putAll(taskModels);
        });
      }
    } catch (e) {
      throw Exception('Failed to reorder tasks: ${e.toString()}');
    }
  }

  @override
  Future<void> archiveTask(String taskId) async {
    final task = await getTask(taskId);
    if (task != null) {
      await updateTask(task.archive());
    }
  }

  @override
  Future<void> unarchiveTask(String taskId) async {
    final task = await getTask(taskId);
    if (task != null) {
      await updateTask(task.unarchive());
    }
  }

  @override
  Future<void> markTaskInProgress(String taskId) async {
    final task = await getTask(taskId);
    if (task != null) {
      await updateTask(task.markInProgress());
    }
  }

  @override
  Future<void> markTaskCompleted(String taskId, {Duration? actualDuration}) async {
    final task = await getTask(taskId);
    if (task != null) {
      await updateTask(task.markCompleted(actualDuration: actualDuration));
    }
  }

  @override
  Future<void> markTaskCancelled(String taskId) async {
    final task = await getTask(taskId);
    if (task != null) {
      await updateTask(task.markCancelled());
    }
  }

  @override
  Future<void> resetTaskToPending(String taskId) async {
    final task = await getTask(taskId);
    if (task != null) {
      await updateTask(task.resetToPending());
    }
  }

  @override
  Stream<List<Task>> getTasksStream(String projectId) {
    return _isar.taskModels
        .where()
        .projectIdEqualTo(projectId)
        .where()
        .isArchivedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<List<Task>> searchTasks(String query, String userId) async {
    try {
      final taskModels = await _isar.taskModels
          .where()
          .nameContains(query, caseSensitive: false)
          .where()
          .isArchivedEqualTo(false)
          .findAll();

      return taskModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: ${e.toString()}');
    }
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status, String userId) async {
    try {
      final taskModels = await _isar.taskModels
          .where()
          .statusValueEqualTo(status.index)
          .where()
          .isArchivedEqualTo(false)
          .findAll();

      return taskModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get tasks by status: ${e.toString()}');
    }
  }

  @override
  Future<List<Task>> getCompletedTasksInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final taskModels = await _isar.taskModels
          .where()
          .statusValueEqualTo(TaskStatus.completed.index)
          .where()
          .updatedAtBetween(startDate, endDate)
          .where()
          .isArchivedEqualTo(false)
          .findAll();

      return taskModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get completed tasks in date range: ${e.toString()}');
    }
  }
}
