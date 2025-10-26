import 'package:equatable/equatable.dart';

/// Session type enum
enum SessionType {
  work('Work'),
  shortBreak('Short Break'),
  longBreak('Long Break');

  const SessionType(this.displayName);
  final String displayName;

  /// Check if this is a work session
  bool get isWork => this == SessionType.work;

  /// Check if this is a break session
  bool get isBreak => this != SessionType.work;

  /// Get default duration for this session type
  Duration get defaultDuration {
    switch (this) {
      case SessionType.work:
        return const Duration(minutes: 25);
      case SessionType.shortBreak:
        return const Duration(minutes: 5);
      case SessionType.longBreak:
        return const Duration(minutes: 15);
    }
  }
}

/// Skip reason enum for interrupted sessions
enum SkipReason {
  interruption('Interruption', 'External interruption occurred'),
  distraction('Distraction', 'Lost focus due to distraction'),
  emergency('Emergency', 'Urgent matter requiring attention'),
  taskComplete('Task Complete', 'Task finished before timer'),
  technical('Technical Issue', 'App or device technical problem');

  const SkipReason(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Pomodoro session entity representing a focused work or break period
class PomodoroSession extends Equatable {
  const PomodoroSession({
    required this.id,
    required this.taskId,
    required this.sessionType,
    required this.startTime,
    this.completedAt,
    required this.duration,
    required this.isCompleted,
    this.skipReason,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final SessionType sessionType;
  final DateTime startTime;
  final DateTime? completedAt;
  final Duration duration;
  final bool isCompleted;
  final SkipReason? skipReason;
  final String? notes;
  final DateTime createdAt;

  /// Create a copy of this session with updated fields
  PomodoroSession copyWith({
    String? id,
    String? taskId,
    SessionType? sessionType,
    DateTime? startTime,
    DateTime? completedAt,
    Duration? duration,
    bool? isCompleted,
    SkipReason? skipReason,
    String? notes,
    DateTime? createdAt,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      sessionType: sessionType ?? this.sessionType,
      startTime: startTime ?? this.startTime,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      skipReason: skipReason ?? this.skipReason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Mark session as completed
  PomodoroSession markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// Mark session as skipped with reason
  PomodoroSession markSkipped({
    required SkipReason reason,
    String? notes,
  }) {
    return copyWith(
      isCompleted: false,
      completedAt: DateTime.now(),
      skipReason: reason,
      notes: notes,
    );
  }

  /// Update session duration
  PomodoroSession updateDuration(Duration newDuration) {
    return copyWith(duration: newDuration);
  }

  /// Add notes to session
  PomodoroSession addNotes(String newNotes) {
    final updatedNotes = notes == null ? newNotes : '$notes\n$newNotes';
    return copyWith(notes: updatedNotes);
  }

  /// Get actual session duration (time from start to completion/skip)
  Duration get actualDuration {
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startTime);
  }

  /// Get remaining time if session is still active
  Duration get remainingTime {
    if (isCompleted || completedAt != null) {
      return Duration.zero;
    }
    final elapsed = DateTime.now().difference(startTime);
    final remaining = duration.inSeconds - elapsed.inSeconds;
    return Duration(seconds: remaining.clamp(0, duration.inSeconds));
  }

  /// Check if session is currently active
  bool get isActive {
    return !isCompleted && completedAt == null && remainingTime.inSeconds > 0;
  }

  /// Check if session is expired (time exceeded but not completed)
  bool get isExpired {
    return !isCompleted && completedAt == null && remainingTime.inSeconds <= 0;
  }

  /// Check if session was completed successfully
  bool get wasCompletedSuccessfully {
    return isCompleted && completedAt != null;
  }

  /// Check if session was skipped
  bool get wasSkipped {
    return !isCompleted && skipReason != null;
  }

  /// Get session efficiency (actual vs planned duration)
  double get efficiency {
    if (duration.inMinutes == 0) return 0.0;
    return (actualDuration.inMinutes / duration.inMinutes * 100).clamp(0.0, 200.0);
  }

  /// Get session status description
  String get statusDescription {
    if (isActive) {
      return 'Active';
    } else if (wasCompletedSuccessfully) {
      return 'Completed';
    } else if (wasSkipped) {
      return 'Skipped (${skipReason!.displayName})';
    } else if (isExpired) {
      return 'Expired';
    } else {
      return 'Unknown';
    }
  }

  /// Get session type color (for UI)
  String get typeColor {
    switch (sessionType) {
      case SessionType.work:
        return '#ED6B06'; // Primary accent
      case SessionType.shortBreak:
        return '#008B5D'; // Success
      case SessionType.longBreak:
        return '#9D1348'; // Secondary accent
    }
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        sessionType,
        startTime,
        completedAt,
        duration,
        isCompleted,
        skipReason,
        notes,
        createdAt,
      ];

  @override
  String toString() {
    return 'PomodoroSession(id: $id, taskId: $taskId, sessionType: $sessionType, isCompleted: $isCompleted, duration: $duration)';
  }
}
