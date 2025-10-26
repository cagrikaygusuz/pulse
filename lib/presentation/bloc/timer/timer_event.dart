import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/pomodoro_session.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

class StartTimerEvent extends TimerEvent {
  final String taskId;
  final String taskName;
  final Duration? customDuration;
  final SessionType sessionType;

  const StartTimerEvent({
    required this.taskId,
    required this.taskName,
    this.customDuration,
    this.sessionType = SessionType.work,
  });

  @override
  List<Object?> get props => [taskId, taskName, customDuration, sessionType];
}

class PauseTimerEvent extends TimerEvent {
  const PauseTimerEvent();
}

class ResumeTimerEvent extends TimerEvent {
  const ResumeTimerEvent();
}

class CompleteSessionEvent extends TimerEvent {
  const CompleteSessionEvent();
}

class SkipSessionEvent extends TimerEvent {
  final SkipReason skipReason;
  final String? notes;

  const SkipSessionEvent({
    required this.skipReason,
    this.notes,
  });

  @override
  List<Object?> get props => [skipReason, notes];
}

class ResetTimerEvent extends TimerEvent {
  const ResetTimerEvent();
}

class TimerTickEvent extends TimerEvent {
  const TimerTickEvent();
}
