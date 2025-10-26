import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/pomodoro_session.dart';
import 'firebase_service.dart';

/// Firestore service for CRUD operations
class FirestoreService {
  static FirestoreService? _instance;

  FirestoreService._();

  /// Get singleton instance
  static FirestoreService get instance {
    _instance ??= FirestoreService._();
    return _instance!;
  }

  // Projects

  /// Create a new project
  Future<void> createProject(Project project) async {
    try {
      await FirebaseService.projectsCollection.doc(project.id).set({
        'id': project.id,
        'name': project.name,
        'description': project.description,
        'userId': project.userId,
        'sortOrder': project.sortOrder,
        'createdAt': FirebaseService.serverTimestamp,
        'updatedAt': FirebaseService.serverTimestamp,
        'isArchived': project.isArchived,
      });
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Get projects for a user
  Future<List<Project>> getProjects(String userId) async {
    try {
      final snapshot = await FirebaseService.projectsCollection
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .orderBy('sortOrder')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Project(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          description: data['description'],
          userId: data['userId'] ?? userId,
          sortOrder: data['sortOrder'] ?? 0,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isArchived: data['isArchived'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Update a project
  Future<void> updateProject(Project project) async {
    try {
      await FirebaseService.projectsCollection.doc(project.id).update({
        'name': project.name,
        'description': project.description,
        'sortOrder': project.sortOrder,
        'updatedAt': FirebaseService.serverTimestamp,
        'isArchived': project.isArchived,
      });
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      await FirebaseService.projectsCollection.doc(projectId).delete();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Reorder projects
  Future<void> reorderProjects(List<Project> projects) async {
    try {
      final batch = FirebaseService.batch();
      
      for (final project in projects) {
        batch.update(
          FirebaseService.projectsCollection.doc(project.id),
          {
            'sortOrder': project.sortOrder,
            'updatedAt': FirebaseService.serverTimestamp,
          },
        );
      }
      
      await batch.commit();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  // Tasks

  /// Create a new task
  Future<void> createTask(Task task) async {
    try {
      await FirebaseService.tasksCollection.doc(task.id).set({
        'id': task.id,
        'projectId': task.projectId,
        'name': task.name,
        'description': task.description,
        'estimatedDurationMinutes': task.estimatedDuration.inMinutes,
        'actualDurationMinutes': task.actualDuration?.inMinutes,
        'sortOrder': task.sortOrder,
        'status': task.status.index,
        'createdAt': FirebaseService.serverTimestamp,
        'updatedAt': FirebaseService.serverTimestamp,
        'isArchived': task.isArchived,
      });
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Get tasks for a project
  Future<List<Task>> getTasks(String projectId) async {
    try {
      final snapshot = await FirebaseService.tasksCollection
          .where('projectId', isEqualTo: projectId)
          .where('isArchived', isEqualTo: false)
          .orderBy('sortOrder')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: data['id'] ?? doc.id,
          projectId: data['projectId'] ?? projectId,
          name: data['name'] ?? '',
          description: data['description'],
          estimatedDuration: Duration(minutes: data['estimatedDurationMinutes'] ?? 25),
          actualDuration: data['actualDurationMinutes'] != null 
              ? Duration(minutes: data['actualDurationMinutes'])
              : null,
          sortOrder: data['sortOrder'] ?? 0,
          status: TaskStatus.values[data['status'] ?? 0],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isArchived: data['isArchived'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Update a task
  Future<void> updateTask(Task task) async {
    try {
      await FirebaseService.tasksCollection.doc(task.id).update({
        'name': task.name,
        'description': task.description,
        'estimatedDurationMinutes': task.estimatedDuration.inMinutes,
        'actualDurationMinutes': task.actualDuration?.inMinutes,
        'sortOrder': task.sortOrder,
        'status': task.status.index,
        'updatedAt': FirebaseService.serverTimestamp,
        'isArchived': task.isArchived,
      });
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await FirebaseService.tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Reorder tasks
  Future<void> reorderTasks(List<Task> tasks) async {
    try {
      final batch = FirebaseService.batch();
      
      for (final task in tasks) {
        batch.update(
          FirebaseService.tasksCollection.doc(task.id),
          {
            'sortOrder': task.sortOrder,
            'updatedAt': FirebaseService.serverTimestamp,
          },
        );
      }
      
      await batch.commit();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  // Pomodoro Sessions

  /// Create a new Pomodoro session
  Future<void> createSession(PomodoroSession session) async {
    try {
      await FirebaseService.pomodoroSessionsCollection.doc(session.id).set({
        'id': session.id,
        'taskId': session.taskId,
        'sessionType': session.sessionType.index,
        'startTime': session.startTime,
        'completedAt': session.completedAt,
        'durationMinutes': session.duration.inMinutes,
        'isCompleted': session.isCompleted,
        'skipReason': session.skipReason?.index,
        'notes': session.notes,
        'createdAt': FirebaseService.serverTimestamp,
      });
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Get sessions for a user
  Future<List<PomodoroSession>> getSessions(String userId) async {
    try {
      final snapshot = await FirebaseService.pomodoroSessionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PomodoroSession(
          id: data['id'] ?? doc.id,
          taskId: data['taskId'] ?? '',
          sessionType: SessionType.values[data['sessionType'] ?? 0],
          startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
          duration: Duration(minutes: data['durationMinutes'] ?? 25),
          isCompleted: data['isCompleted'] ?? false,
          skipReason: data['skipReason'] != null 
              ? SkipReason.values[data['skipReason']]
              : null,
          notes: data['notes'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Get sessions for a specific task
  Future<List<PomodoroSession>> getSessionsForTask(String taskId) async {
    try {
      final snapshot = await FirebaseService.pomodoroSessionsCollection
          .where('taskId', isEqualTo: taskId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PomodoroSession(
          id: data['id'] ?? doc.id,
          taskId: data['taskId'] ?? taskId,
          sessionType: SessionType.values[data['sessionType'] ?? 0],
          startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
          duration: Duration(minutes: data['durationMinutes'] ?? 25),
          isCompleted: data['isCompleted'] ?? false,
          skipReason: data['skipReason'] != null 
              ? SkipReason.values[data['skipReason']]
              : null,
          notes: data['notes'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Update a session
  Future<void> updateSession(PomodoroSession session) async {
    try {
      await FirebaseService.pomodoroSessionsCollection.doc(session.id).update({
        'completedAt': session.completedAt,
        'durationMinutes': session.duration.inMinutes,
        'isCompleted': session.isCompleted,
        'skipReason': session.skipReason?.index,
        'notes': session.notes,
      });
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    try {
      await FirebaseService.pomodoroSessionsCollection.doc(sessionId).delete();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Get sessions in date range
  Future<List<PomodoroSession>> getSessionsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await FirebaseService.pomodoroSessionsCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PomodoroSession(
          id: data['id'] ?? doc.id,
          taskId: data['taskId'] ?? '',
          sessionType: SessionType.values[data['sessionType'] ?? 0],
          startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
          duration: Duration(minutes: data['durationMinutes'] ?? 25),
          isCompleted: data['isCompleted'] ?? false,
          skipReason: data['skipReason'] != null 
              ? SkipReason.values[data['skipReason']]
              : null,
          notes: data['notes'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Batch create sessions
  Future<void> batchCreateSessions(List<PomodoroSession> sessions) async {
    try {
      final batch = FirebaseService.batch();
      
      for (final session in sessions) {
        final docRef = FirebaseService.pomodoroSessionsCollection.doc(session.id);
        batch.set(docRef, {
          'id': session.id,
          'taskId': session.taskId,
          'sessionType': session.sessionType.index,
          'startTime': session.startTime,
          'completedAt': session.completedAt,
          'durationMinutes': session.duration.inMinutes,
          'isCompleted': session.isCompleted,
          'skipReason': session.skipReason?.index,
          'notes': session.notes,
          'createdAt': FirebaseService.serverTimestamp,
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw FirebaseService.handleFirestoreException(e);
    }
  }

  /// Get real-time updates for projects
  Stream<List<Project>> getProjectsStream(String userId) {
    return FirebaseService.projectsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return Project(
            id: data['id'] ?? doc.id,
            name: data['name'] ?? '',
            description: data['description'],
            userId: data['userId'] ?? userId,
            sortOrder: data['sortOrder'] ?? 0,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isArchived: data['isArchived'] ?? false,
          );
        }).toList());
  }

  /// Get real-time updates for tasks
  Stream<List<Task>> getTasksStream(String projectId) {
    return FirebaseService.tasksCollection
        .where('projectId', isEqualTo: projectId)
        .where('isArchived', isEqualTo: false)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return Task(
            id: data['id'] ?? doc.id,
            projectId: data['projectId'] ?? projectId,
            name: data['name'] ?? '',
            description: data['description'],
            estimatedDuration: Duration(minutes: data['estimatedDurationMinutes'] ?? 25),
            actualDuration: data['actualDurationMinutes'] != null 
                ? Duration(minutes: data['actualDurationMinutes'])
                : null,
            sortOrder: data['sortOrder'] ?? 0,
            status: TaskStatus.values[data['status'] ?? 0],
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isArchived: data['isArchived'] ?? false,
          );
        }).toList());
  }
}
