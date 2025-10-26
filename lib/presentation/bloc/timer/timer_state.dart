import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/pomodoro_session.dart';

abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object?> get props => [];
}

class TimerInitialState extends TimerState {
  const TimerInitialState();
}

class TimerRunningState extends TimerState {
  final Duration remainingTime;
  final String taskId;
  final String taskName;
  final DateTime startTime;
  final SessionType sessionType;
  final int completedPomodoros;

  const TimerRunningState({
    required this.remainingTime,
    required this.taskId,
    required this.taskName,
    required this.startTime,
    required this.sessionType,
    this.completedPomodoros = 0,
  });

  @override
  List<Object?> get props => [
        remainingTime,
        taskId,
        taskName,
        startTime,
        sessionType,
        completedPomodoros,
      ];

  TimerRunningState copyWith({
    Duration? remainingTime,
    String? taskId,
    String? taskName,
    DateTime? startTime,
    SessionType? sessionType,
    int? completedPomodoros,
  }) {
    return TimerRunningState(
      remainingTime: remainingTime ?? this.remainingTime,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      startTime: startTime ?? this.startTime,
      sessionType: sessionType ?? this.sessionType,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    );
  }
}

class TimerPausedState extends TimerState {
  final Duration remainingTime;
  final String taskId;
  final String taskName;
  final DateTime startTime;
  final SessionType sessionType;
  final int completedPomodoros;

  const TimerPausedState({
    required this.remainingTime,
    required this.taskId,
    required this.taskName,
    required this.startTime,
    required this.sessionType,
    this.completedPomodoros = 0,
  });

  @override
  List<Object?> get props => [
        remainingTime,
        taskId,
        taskName,
        startTime,
        sessionType,
        completedPomodoros,
      ];
}

class TimerCompletedState extends TimerState {
  final String taskId;
  final String taskName;
  final Duration completedDuration;
  final SessionType sessionType;
  final int completedPomodoros;
  final SessionType? nextSessionType;

  const TimerCompletedState({
    required this.taskId,
    required this.taskName,
    required this.completedDuration,
    required this.sessionType,
    required this.completedPomodoros,
    this.nextSessionType,
  });

  @override
  List<Object?> get props => [
        taskId,
        taskName,
        completedDuration,
        sessionType,
        completedPomodoros,
        nextSessionType,
      ];
}

class TimerSkippedState extends TimerState {
  final String taskId;
  final String taskName;
  final DateTime interruptedAt;
  final Duration completedDuration;
  final SessionType sessionType;
  final SkipReason skipReason;
  final String? notes;

  const TimerSkippedState({
    required this.taskId,
    required this.taskName,
    required this.interruptedAt,
    required this.completedDuration,
    required this.sessionType,
    required this.skipReason,
    this.notes,
  });

  @override
  List<Object?> get props => [
        taskId,
        taskName,
        interruptedAt,
        completedDuration,
        sessionType,
        skipReason,
        notes,
      ];
}

class TimerErrorState extends TimerState {
  final String message;
  final String? taskId;

  const TimerErrorState({
    required this.message,
    this.taskId,
  });

  @override
  List<Object?> get props => [message, taskId];
}
