import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/app_constants.dart';
import 'package:pulse/domain/entities/pomodoro_session.dart';
import 'package:pulse/domain/repositories/session_repository.dart';
import 'package:pulse/domain/repositories/task_repository.dart';
import 'package:pulse/presentation/bloc/timer/timer_event.dart';
import 'package:pulse/presentation/bloc/timer/timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final SessionRepository _sessionRepository;
  final TaskRepository _taskRepository;
  Timer? _timer;
  Timer? _tickTimer;

  TimerCubit({
    required SessionRepository sessionRepository,
    required TaskRepository taskRepository,
  })  : _sessionRepository = sessionRepository,
        _taskRepository = taskRepository,
        super(const TimerInitialState());

  /// Check if timer is currently locked (running)
  bool get isTimerLocked => state is TimerRunningState;

  /// Start a new timer session
  Future<void> startTimer({
    required String taskId,
    required String taskName,
    Duration? customDuration,
    SessionType sessionType = SessionType.work,
  }) async {
    if (isTimerLocked) {
      emit(TimerErrorState(
        message: 'Cannot start timer while another session is active. '
            'Complete or skip the current session first.',
        taskId: taskId,
      ));
      return;
    }

    try {
      // Determine session duration
      Duration duration;
      switch (sessionType) {
        case SessionType.work:
          duration = customDuration ?? 
              Duration(minutes: AppConstants.defaultPomodoroDurationMinutes);
          break;
        case SessionType.shortBreak:
          duration = Duration(minutes: AppConstants.defaultShortBreakDurationMinutes);
          break;
        case SessionType.longBreak:
          duration = Duration(minutes: AppConstants.defaultLongBreakDurationMinutes);
          break;
      }

      // Create session record
      final session = PomodoroSession(
        id: '', // Will be set by repository
        taskId: taskId,
        sessionType: sessionType,
        startTime: DateTime.now(),
        duration: duration,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await _sessionRepository.createSession(session);

      // Start the timer
      emit(TimerRunningState(
        remainingTime: duration,
        taskId: taskId,
        taskName: taskName,
        startTime: DateTime.now(),
        sessionType: sessionType,
        completedPomodoros: _getCompletedPomodoros(),
      ));

      _startTickTimer();
    } catch (e) {
      emit(TimerErrorState(
        message: 'Failed to start timer: ${e.toString()}',
        taskId: taskId,
      ));
    }
  }

  /// Pause the current timer
  void pauseTimer() {
    if (state is TimerRunningState) {
      final currentState = state as TimerRunningState;
      _stopTickTimer();
      
      emit(TimerPausedState(
        remainingTime: currentState.remainingTime,
        taskId: currentState.taskId,
        taskName: currentState.taskName,
        startTime: currentState.startTime,
        sessionType: currentState.sessionType,
        completedPomodoros: currentState.completedPomodoros,
      ));
    }
  }

  /// Resume the paused timer
  void resumeTimer() {
    if (state is TimerPausedState) {
      final currentState = state as TimerPausedState;
      
      emit(TimerRunningState(
        remainingTime: currentState.remainingTime,
        taskId: currentState.taskId,
        taskName: currentState.taskName,
        startTime: currentState.startTime,
        sessionType: currentState.sessionType,
        completedPomodoros: currentState.completedPomodoros,
      ));

      _startTickTimer();
    }
  }

  /// Complete the current session
  Future<void> completeSession() async {
    if (state is! TimerRunningState) return;

    final currentState = state as TimerRunningState;
    _stopTickTimer();

    try {
      // Update session as completed
      final sessions = await _sessionRepository.getSessionsForTask(currentState.taskId);
      if (sessions.isNotEmpty) {
        final latestSession = sessions.first;
        final completedSession = latestSession.copyWith(
          completedAt: DateTime.now(),
          isCompleted: true,
        );
        await _sessionRepository.updateSession(completedSession);
      }

      // Determine next session type
      final nextSessionType = _getNextSessionType(currentState.sessionType);

      emit(TimerCompletedState(
        taskId: currentState.taskId,
        taskName: currentState.taskName,
        completedDuration: DateTime.now().difference(currentState.startTime),
        sessionType: currentState.sessionType,
        completedPomodoros: currentState.completedPomodoros + 
            (currentState.sessionType == SessionType.work ? 1 : 0),
        nextSessionType: nextSessionType,
      ));
    } catch (e) {
      emit(TimerErrorState(
        message: 'Failed to complete session: ${e.toString()}',
        taskId: currentState.taskId,
      ));
    }
  }

  /// Skip the current session
  Future<void> skipSession({
    required SkipReason skipReason,
    String? notes,
  }) async {
    if (state is! TimerRunningState) return;

    final currentState = state as TimerRunningState;
    _stopTickTimer();

    try {
      // Update session as skipped
      final sessions = await _sessionRepository.getSessionsForTask(currentState.taskId);
      if (sessions.isNotEmpty) {
        final latestSession = sessions.first;
        final skippedSession = latestSession.copyWith(
          completedAt: DateTime.now(),
          isCompleted: false,
          skipReason: skipReason,
          notes: notes,
        );
        await _sessionRepository.updateSession(skippedSession);
      }

      emit(TimerSkippedState(
        taskId: currentState.taskId,
        taskName: currentState.taskName,
        interruptedAt: DateTime.now(),
        completedDuration: DateTime.now().difference(currentState.startTime),
        sessionType: currentState.sessionType,
        skipReason: skipReason,
        notes: notes,
      ));
    } catch (e) {
      emit(TimerErrorState(
        message: 'Failed to skip session: ${e.toString()}',
        taskId: currentState.taskId,
      ));
    }
  }

  /// Reset timer to initial state
  void resetTimer() {
    if (isTimerLocked) {
      emit(TimerErrorState(
        message: 'Cannot reset timer during active session',
      ));
      return;
    }

    _stopTickTimer();
    emit(const TimerInitialState());
  }

  /// Start the tick timer for countdown
  void _startTickTimer() {
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTimerTick();
    });
  }

  /// Stop the tick timer
  void _stopTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  /// Handle timer tick
  void _onTimerTick() {
    if (state is TimerRunningState) {
      final currentState = state as TimerRunningState;
      final newTime = currentState.remainingTime - const Duration(seconds: 1);

      if (newTime.inSeconds <= 0) {
        // Timer completed
        completeSession();
      } else {
        emit(currentState.copyWith(remainingTime: newTime));
      }
    }
  }

  /// Get the number of completed Pomodoros
  int _getCompletedPomodoros() {
    // This would typically query the session repository
    // For now, return 0 as a placeholder
    return 0;
  }

  /// Determine the next session type based on Pomodoro cycle
  SessionType _getNextSessionType(SessionType currentType) {
    switch (currentType) {
      case SessionType.work:
        // After work, take a break
        // Check if we need a long break (after 4 work sessions)
        final completedPomodoros = _getCompletedPomodoros();
        return (completedPomodoros + 1) % AppConstants.defaultPomodorosBeforeLongBreak == 0
            ? SessionType.longBreak
            : SessionType.shortBreak;
      case SessionType.shortBreak:
      case SessionType.longBreak:
        // After break, return to work
        return SessionType.work;
    }
  }

  @override
  Future<void> close() {
    _stopTickTimer();
    return super.close();
  }
}
