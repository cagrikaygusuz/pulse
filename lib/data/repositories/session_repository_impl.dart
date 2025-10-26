import 'package:isar/isar.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/local/isar_service.dart';
import '../datasources/remote/firestore_service.dart';
import '../models/pomodoro_session_model.dart';

/// Implementation of SessionRepository with offline-first approach
class SessionRepositoryImpl implements SessionRepository {
  final Isar _isar;
  final FirestoreService _firestoreService;

  SessionRepositoryImpl({
    Isar? isar,
    FirestoreService? firestoreService,
  }) : _isar = isar ?? IsarService.isar as Isar,
       _firestoreService = firestoreService ?? FirestoreService.instance;

  @override
  Future<void> createSession(PomodoroSession session) async {
    try {
      // Save to local database first
      final sessionModel = PomodoroSessionModel.fromEntity(session);
      await _isar.writeTxn(() async {
        await _isar.pomodoroSessionModels.put(sessionModel);
      });

      // Try to sync to remote if online
      try {
        await _firestoreService.createPomodoroSession(session);
        // Mark as synced
        sessionModel.markSynced();
        await _isar.writeTxn(() async {
          await _isar.pomodoroSessionModels.put(sessionModel);
        });
      } catch (e) {
        // Mark as pending sync
        sessionModel.markNeedsSync();
        await _isar.writeTxn(() async {
          await _isar.pomodoroSessionModels.put(sessionModel);
        });
      }
    } catch (e) {
      throw Exception('Failed to create session: ${e.toString()}');
    }
  }

  @override
  Future<List<PomodoroSession>> getSessions(String userId) async {
    try {
      // Get from local database first
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .sortByCreatedAtDesc()
          .findAll();

      if (sessionModels.isNotEmpty) {
        return sessionModels.map((model) => model.toEntity()).toList();
      }

      // If no local data, try to get from remote
      try {
        final sessions = await _firestoreService.getPomodoroSessions(userId);
        
        // Save to local database
        final sessionModels = sessions.map((session) => PomodoroSessionModel.fromEntity(session)).toList();
        await _isar.writeTxn(() async {
          await _isar.pomodoroSessionModels.putAll(sessionModels);
        });
        
        return sessions;
      } catch (e) {
        // Return empty list if remote fails
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get sessions: ${e.toString()}');
    }
  }

  @override
  Future<PomodoroSession?> getSession(String sessionId) async {
    try {
      final sessionModel = await _isar.pomodoroSessionModels
          .where()
          .sessionIdEqualTo(sessionId)
          .findFirst();

      if (sessionModel != null) {
        return sessionModel.toEntity();
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get session: ${e.toString()}');
    }
  }

  @override
  Future<List<PomodoroSession>> getSessionsForTask(String taskId) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .taskIdEqualTo(taskId)
          .sortByCreatedAtDesc()
          .findAll();

      return sessionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get sessions for task: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSession(PomodoroSession session) async {
    try {
      // Update local database first
      final sessionModel = await _isar.pomodoroSessionModels
          .where()
          .sessionIdEqualTo(session.id)
          .findFirst();

      if (sessionModel != null) {
        sessionModel.updateFromEntity(session);
        await _isar.writeTxn(() async {
          await _isar.pomodoroSessionModels.put(sessionModel);
        });
      }

      // Try to sync to remote
      try {
        await _firestoreService.updatePomodoroSession(session);
        // Mark as synced
        if (sessionModel != null) {
          sessionModel.markSynced();
          await _isar.writeTxn(() async {
            await _isar.pomodoroSessionModels.put(sessionModel);
          });
        }
      } catch (e) {
        // Mark as pending sync
        if (sessionModel != null) {
          sessionModel.markNeedsSync();
          await _isar.writeTxn(() async {
            await _isar.pomodoroSessionModels.put(sessionModel);
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update session: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      // Delete from local database first
      await _isar.writeTxn(() async {
        await _isar.pomodoroSessionModels
            .where()
            .sessionIdEqualTo(sessionId)
            .deleteAll();
      });

      // Try to delete from remote
      try {
        await _firestoreService.deletePomodoroSession(sessionId);
      } catch (e) {
        // Remote deletion failed, but local deletion succeeded
      }
    } catch (e) {
      throw Exception('Failed to delete session: ${e.toString()}');
    }
  }

  @override
  Future<void> markSessionCompleted(String sessionId) async {
    final session = await getSession(sessionId);
    if (session != null) {
      await updateSession(session.markCompleted());
    }
  }

  @override
  Future<void> markSessionSkipped(
    String sessionId,
    SkipReason reason,
    {String? notes}
  ) async {
    final session = await getSession(sessionId);
    if (session != null) {
      await updateSession(session.markSkipped(reason: reason, notes: notes));
    }
  }

  @override
  Future<List<PomodoroSession>> getSessionsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .startTimeBetween(startDate, endDate)
          .sortByStartTimeDesc()
          .findAll();

      return sessionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get sessions in date range: ${e.toString()}');
    }
  }

  @override
  Future<List<PomodoroSession>> getCompletedSessions(String userId) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .isCompletedEqualTo(true)
          .sortByCreatedAtDesc()
          .findAll();

      return sessionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get completed sessions: ${e.toString()}');
    }
  }

  @override
  Future<List<PomodoroSession>> getSkippedSessions(String userId) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .skipReasonValueIsNotNull()
          .sortByCreatedAtDesc()
          .findAll();

      return sessionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get skipped sessions: ${e.toString()}');
    }
  }

  @override
  Future<List<PomodoroSession>> getSessionsByType(
    SessionType sessionType,
    String userId,
  ) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .sessionTypeValueEqualTo(sessionType.index)
          .sortByCreatedAtDesc()
          .findAll();

      return sessionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get sessions by type: ${e.toString()}');
    }
  }

  @override
  Future<PomodoroSession?> getActiveSession(String userId) async {
    try {
      final sessionModel = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .isCompletedEqualTo(false)
          .where()
          .skipReasonValueIsNull()
          .sortByCreatedAtDesc()
          .findFirst();

      if (sessionModel != null) {
        return sessionModel.toEntity();
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get active session: ${e.toString()}');
    }
  }

  @override
  Future<List<PomodoroSession>> getTodaySessions(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getSessionsInDateRange(userId, startOfDay, endOfDay);
  }

  @override
  Future<List<PomodoroSession>> getThisWeekSessions(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return getSessionsInDateRange(userId, startOfWeek, endOfWeek);
  }

  @override
  Future<List<PomodoroSession>> getThisMonthSessions(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return getSessionsInDateRange(userId, startOfMonth, endOfMonth);
  }

  @override
  Future<void> batchCreateSessions(List<PomodoroSession> sessions) async {
    try {
      // Save to local database first
      final sessionModels = sessions.map((session) => PomodoroSessionModel.fromEntity(session)).toList();
      await _isar.writeTxn(() async {
        await _isar.pomodoroSessionModels.putAll(sessionModels);
      });

      // Try to sync to remote
      try {
        await _firestoreService.batchCreatePomodoroSessions(sessions);
        // Mark as synced
        for (final sessionModel in sessionModels) {
          sessionModel.markSynced();
        }
        await _isar.writeTxn(() async {
          await _isar.pomodoroSessionModels.putAll(sessionModels);
        });
      } catch (e) {
        // Mark as pending sync
        for (final sessionModel in sessionModels) {
          sessionModel.markNeedsSync();
        }
        await _isar.writeTxn(() async {
          await _isar.pomodoroSessionModels.putAll(sessionModels);
        });
      }
    } catch (e) {
      throw Exception('Failed to batch create sessions: ${e.toString()}');
    }
  }

  @override
  Future<Duration> getTotalFocusTime(String userId) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .sessionTypeValueEqualTo(SessionType.pomodoro.index)
          .where()
          .isCompletedEqualTo(true)
          .findAll();

      final totalMinutes = sessionModels.fold<int>(
        0,
        (sum, model) => sum + model.durationMinutes,
      );

      return Duration(minutes: totalMinutes);
    } catch (e) {
      throw Exception('Failed to get total focus time: ${e.toString()}');
    }
  }

  @override
  Future<Duration> getTotalFocusTimeInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .sessionTypeValueEqualTo(SessionType.pomodoro.index)
          .where()
          .isCompletedEqualTo(true)
          .where()
          .startTimeBetween(startDate, endDate)
          .findAll();

      final totalMinutes = sessionModels.fold<int>(
        0,
        (sum, model) => sum + model.durationMinutes,
      );

      return Duration(minutes: totalMinutes);
    } catch (e) {
      throw Exception('Failed to get total focus time in range: ${e.toString()}');
    }
  }

  @override
  Future<double> getCompletionRate(String userId) async {
    try {
      final totalSessions = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .count();

      if (totalSessions == 0) return 0.0;

      final completedSessions = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .isCompletedEqualTo(true)
          .count();

      return completedSessions / totalSessions;
    } catch (e) {
      throw Exception('Failed to get completion rate: ${e.toString()}');
    }
  }

  @override
  Future<double> getCompletionRateInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final totalSessions = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .startTimeBetween(startDate, endDate)
          .count();

      if (totalSessions == 0) return 0.0;

      final completedSessions = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .isCompletedEqualTo(true)
          .where()
          .startTimeBetween(startDate, endDate)
          .count();

      return completedSessions / totalSessions;
    } catch (e) {
      throw Exception('Failed to get completion rate in range: ${e.toString()}');
    }
  }

  @override
  Future<Duration> getAverageSessionLength(String userId) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .isCompletedEqualTo(true)
          .findAll();

      if (sessionModels.isEmpty) return Duration.zero;

      final totalMinutes = sessionModels.fold<int>(
        0,
        (sum, model) => sum + model.durationMinutes,
      );

      return Duration(minutes: totalMinutes ~/ sessionModels.length);
    } catch (e) {
      throw Exception('Failed to get average session length: ${e.toString()}');
    }
  }

  @override
  Future<List<int>> getPeakHours(String userId) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .isCompletedEqualTo(true)
          .findAll();

      final hourCounts = <int, int>{};
      for (final model in sessionModels) {
        final hour = model.startTime.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }

      final sortedHours = hourCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedHours.take(3).map((e) => e.key).toList();
    } catch (e) {
      throw Exception('Failed to get peak hours: ${e.toString()}');
    }
  }

  @override
  Stream<List<PomodoroSession>> getSessionsStream(String userId) {
    return _isar.pomodoroSessionModels
        .where()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> syncPendingSessions(String userId) async {
    try {
      final pendingSessions = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .needsSyncEqualTo(true)
          .findAll();

      if (pendingSessions.isEmpty) return;

      // Try to sync to remote
      try {
        await _firestoreService.batchCreatePomodoroSessions(
          pendingSessions.map((model) => model.toEntity()).toList(),
        );
        
        // Mark as synced
        for (final sessionModel in pendingSessions) {
          sessionModel.markSynced();
        }
        await _isar.writeTxn(() async {
          await _isar.pomodoroSessionModels.putAll(pendingSessions);
        });
      } catch (e) {
        // Sync failed, sessions remain marked as needing sync
      }
    } catch (e) {
      throw Exception('Failed to sync pending sessions: ${e.toString()}');
    }
  }

  @override
  Future<List<PomodoroSession>> getPendingSyncSessions(String userId) async {
    try {
      final sessionModels = await _isar.pomodoroSessionModels
          .where()
          .userIdEqualTo(userId)
          .where()
          .needsSyncEqualTo(true)
          .findAll();

      return sessionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pending sync sessions: ${e.toString()}');
    }
  }
}
