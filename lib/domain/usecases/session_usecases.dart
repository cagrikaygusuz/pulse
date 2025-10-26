import '../entities/pomodoro_session.dart';
import '../repositories/session_repository.dart';

/// Use case for creating a new Pomodoro session
class CreatePomodoroSessionUseCase {
  final SessionRepository _sessionRepository;

  CreatePomodoroSessionUseCase(this._sessionRepository);

  Future<void> call({
    required String taskId,
    required SessionType sessionType,
    required Duration duration,
  }) async {
    try {
      final session = PomodoroSession(
        id: const Uuid().v4(),
        taskId: taskId,
        sessionType: sessionType,
        startTime: DateTime.now(),
        duration: duration,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await _sessionRepository.createSession(session);
    } catch (e) {
      throw Exception('Failed to create Pomodoro session: ${e.toString()}');
    }
  }
}

/// Use case for getting all sessions for a user
class GetSessionsUseCase {
  final SessionRepository _sessionRepository;

  GetSessionsUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(String userId) async {
    try {
      return await _sessionRepository.getSessions(userId);
    } catch (e) {
      throw Exception('Failed to get sessions: ${e.toString()}');
    }
  }
}

/// Use case for getting sessions for a specific task
class GetSessionsForTaskUseCase {
  final SessionRepository _sessionRepository;

  GetSessionsForTaskUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(String taskId) async {
    try {
      return await _sessionRepository.getSessionsForTask(taskId);
    } catch (e) {
      throw Exception('Failed to get sessions for task: ${e.toString()}');
    }
  }
}

/// Use case for updating a session
class UpdateSessionUseCase {
  final SessionRepository _sessionRepository;

  UpdateSessionUseCase(this._sessionRepository);

  Future<void> call(PomodoroSession session) async {
    try {
      await _sessionRepository.updateSession(session);
    } catch (e) {
      throw Exception('Failed to update session: ${e.toString()}');
    }
  }
}

/// Use case for deleting a session
class DeleteSessionUseCase {
  final SessionRepository _sessionRepository;

  DeleteSessionUseCase(this._sessionRepository);

  Future<void> call(String sessionId) async {
    try {
      await _sessionRepository.deleteSession(sessionId);
    } catch (e) {
      throw Exception('Failed to delete session: ${e.toString()}');
    }
  }
}

/// Use case for marking a session as completed
class MarkSessionCompletedUseCase {
  final SessionRepository _sessionRepository;

  MarkSessionCompletedUseCase(this._sessionRepository);

  Future<void> call(String sessionId) async {
    try {
      await _sessionRepository.markSessionCompleted(sessionId);
    } catch (e) {
      throw Exception('Failed to mark session as completed: ${e.toString()}');
    }
  }
}

/// Use case for marking a session as skipped
class MarkSessionSkippedUseCase {
  final SessionRepository _sessionRepository;

  MarkSessionSkippedUseCase(this._sessionRepository);

  Future<void> call(
    String sessionId,
    SkipReason reason,
    {String? notes}
  ) async {
    try {
      await _sessionRepository.markSessionSkipped(sessionId, reason, notes: notes);
    } catch (e) {
      throw Exception('Failed to mark session as skipped: ${e.toString()}');
    }
  }
}

/// Use case for getting sessions in date range
class GetSessionsInDateRangeUseCase {
  final SessionRepository _sessionRepository;

  GetSessionsInDateRangeUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _sessionRepository.getSessionsInDateRange(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      throw Exception('Failed to get sessions in date range: ${e.toString()}');
    }
  }
}

/// Use case for getting completed sessions
class GetCompletedSessionsUseCase {
  final SessionRepository _sessionRepository;

  GetCompletedSessionsUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(String userId) async {
    try {
      return await _sessionRepository.getCompletedSessions(userId);
    } catch (e) {
      throw Exception('Failed to get completed sessions: ${e.toString()}');
    }
  }
}

/// Use case for getting skipped sessions
class GetSkippedSessionsUseCase {
  final SessionRepository _sessionRepository;

  GetSkippedSessionsUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(String userId) async {
    try {
      return await _sessionRepository.getSkippedSessions(userId);
    } catch (e) {
      throw Exception('Failed to get skipped sessions: ${e.toString()}');
    }
  }
}

/// Use case for getting sessions by type
class GetSessionsByTypeUseCase {
  final SessionRepository _sessionRepository;

  GetSessionsByTypeUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(
    SessionType sessionType,
    String userId,
  ) async {
    try {
      return await _sessionRepository.getSessionsByType(sessionType, userId);
    } catch (e) {
      throw Exception('Failed to get sessions by type: ${e.toString()}');
    }
  }
}

/// Use case for getting active session
class GetActiveSessionUseCase {
  final SessionRepository _sessionRepository;

  GetActiveSessionUseCase(this._sessionRepository);

  Future<PomodoroSession?> call(String userId) async {
    try {
      return await _sessionRepository.getActiveSession(userId);
    } catch (e) {
      throw Exception('Failed to get active session: ${e.toString()}');
    }
  }
}

/// Use case for getting today's sessions
class GetTodaySessionsUseCase {
  final SessionRepository _sessionRepository;

  GetTodaySessionsUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(String userId) async {
    try {
      return await _sessionRepository.getTodaySessions(userId);
    } catch (e) {
      throw Exception('Failed to get today\'s sessions: ${e.toString()}');
    }
  }
}

/// Use case for getting this week's sessions
class GetThisWeekSessionsUseCase {
  final SessionRepository _sessionRepository;

  GetThisWeekSessionsUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(String userId) async {
    try {
      return await _sessionRepository.getThisWeekSessions(userId);
    } catch (e) {
      throw Exception('Failed to get this week\'s sessions: ${e.toString()}');
    }
  }
}

/// Use case for getting this month's sessions
class GetThisMonthSessionsUseCase {
  final SessionRepository _sessionRepository;

  GetThisMonthSessionsUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(String userId) async {
    try {
      return await _sessionRepository.getThisMonthSessions(userId);
    } catch (e) {
      throw Exception('Failed to get this month\'s sessions: ${e.toString()}');
    }
  }
}

/// Use case for batch creating sessions
class BatchCreateSessionsUseCase {
  final SessionRepository _sessionRepository;

  BatchCreateSessionsUseCase(this._sessionRepository);

  Future<void> call(List<PomodoroSession> sessions) async {
    try {
      await _sessionRepository.batchCreateSessions(sessions);
    } catch (e) {
      throw Exception('Failed to batch create sessions: ${e.toString()}');
    }
  }
}

/// Use case for getting total focus time
class GetTotalFocusTimeUseCase {
  final SessionRepository _sessionRepository;

  GetTotalFocusTimeUseCase(this._sessionRepository);

  Future<Duration> call(String userId) async {
    try {
      return await _sessionRepository.getTotalFocusTime(userId);
    } catch (e) {
      throw Exception('Failed to get total focus time: ${e.toString()}');
    }
  }
}

/// Use case for getting total focus time in date range
class GetTotalFocusTimeInRangeUseCase {
  final SessionRepository _sessionRepository;

  GetTotalFocusTimeInRangeUseCase(this._sessionRepository);

  Future<Duration> call(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _sessionRepository.getTotalFocusTimeInRange(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      throw Exception('Failed to get total focus time in range: ${e.toString()}');
    }
  }
}

/// Use case for getting completion rate
class GetCompletionRateUseCase {
  final SessionRepository _sessionRepository;

  GetCompletionRateUseCase(this._sessionRepository);

  Future<double> call(String userId) async {
    try {
      return await _sessionRepository.getCompletionRate(userId);
    } catch (e) {
      throw Exception('Failed to get completion rate: ${e.toString()}');
    }
  }
}

/// Use case for getting completion rate in date range
class GetCompletionRateInRangeUseCase {
  final SessionRepository _sessionRepository;

  GetCompletionRateInRangeUseCase(this._sessionRepository);

  Future<double> call(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _sessionRepository.getCompletionRateInRange(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      throw Exception('Failed to get completion rate in range: ${e.toString()}');
    }
  }
}

/// Use case for getting average session length
class GetAverageSessionLengthUseCase {
  final SessionRepository _sessionRepository;

  GetAverageSessionLengthUseCase(this._sessionRepository);

  Future<Duration> call(String userId) async {
    try {
      return await _sessionRepository.getAverageSessionLength(userId);
    } catch (e) {
      throw Exception('Failed to get average session length: ${e.toString()}');
    }
  }
}

/// Use case for getting peak hours
class GetPeakHoursUseCase {
  final SessionRepository _sessionRepository;

  GetPeakHoursUseCase(this._sessionRepository);

  Future<List<int>> call(String userId) async {
    try {
      return await _sessionRepository.getPeakHours(userId);
    } catch (e) {
      throw Exception('Failed to get peak hours: ${e.toString()}');
    }
  }
}

/// Use case for syncing pending sessions
class SyncPendingSessionsUseCase {
  final SessionRepository _sessionRepository;

  SyncPendingSessionsUseCase(this._sessionRepository);

  Future<void> call(String userId) async {
    try {
      await _sessionRepository.syncPendingSessions(userId);
    } catch (e) {
      throw Exception('Failed to sync pending sessions: ${e.toString()}');
    }
  }
}

/// Use case for getting pending sync sessions
class GetPendingSyncSessionsUseCase {
  final SessionRepository _sessionRepository;

  GetPendingSyncSessionsUseCase(this._sessionRepository);

  Future<List<PomodoroSession>> call(String userId) async {
    try {
      return await _sessionRepository.getPendingSyncSessions(userId);
    } catch (e) {
      throw Exception('Failed to get pending sync sessions: ${e.toString()}');
    }
  }
}
