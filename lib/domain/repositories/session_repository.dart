import '../entities/pomodoro_session.dart';

/// Abstract repository for Pomodoro session operations
abstract class SessionRepository {
  /// Create a new Pomodoro session
  Future<void> createSession(PomodoroSession session);

  /// Get sessions for a user
  Future<List<PomodoroSession>> getSessions(String userId);

  /// Get session by ID
  Future<PomodoroSession?> getSession(String sessionId);

  /// Get sessions for a specific task
  Future<List<PomodoroSession>> getSessionsForTask(String taskId);

  /// Update a session
  Future<void> updateSession(PomodoroSession session);

  /// Delete a session
  Future<void> deleteSession(String sessionId);

  /// Mark session as completed
  Future<void> markSessionCompleted(String sessionId);

  /// Mark session as skipped
  Future<void> markSessionSkipped(
    String sessionId,
    SkipReason reason,
    {String? notes}
  );

  /// Get sessions in date range
  Future<List<PomodoroSession>> getSessionsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get completed sessions for a user
  Future<List<PomodoroSession>> getCompletedSessions(String userId);

  /// Get skipped sessions for a user
  Future<List<PomodoroSession>> getSkippedSessions(String userId);

  /// Get sessions by type
  Future<List<PomodoroSession>> getSessionsByType(
    SessionType sessionType,
    String userId,
  );

  /// Get active session for a user
  Future<PomodoroSession?> getActiveSession(String userId);

  /// Get today's sessions for a user
  Future<List<PomodoroSession>> getTodaySessions(String userId);

  /// Get this week's sessions for a user
  Future<List<PomodoroSession>> getThisWeekSessions(String userId);

  /// Get this month's sessions for a user
  Future<List<PomodoroSession>> getThisMonthSessions(String userId);

  /// Batch create sessions
  Future<void> batchCreateSessions(List<PomodoroSession> sessions);

  /// Get total focus time for a user
  Future<Duration> getTotalFocusTime(String userId);

  /// Get total focus time in date range
  Future<Duration> getTotalFocusTimeInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get completion rate for a user
  Future<double> getCompletionRate(String userId);

  /// Get completion rate in date range
  Future<double> getCompletionRateInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get average session length for a user
  Future<Duration> getAverageSessionLength(String userId);

  /// Get peak hours for a user
  Future<List<int>> getPeakHours(String userId);

  /// Get sessions stream for real-time updates
  Stream<List<PomodoroSession>> getSessionsStream(String userId);

  /// Sync pending sessions to remote
  Future<void> syncPendingSessions(String userId);

  /// Get pending sync sessions
  Future<List<PomodoroSession>> getPendingSyncSessions(String userId);
}
