import 'package:isar/isar.dart';
import '../../domain/entities/pomodoro_session.dart';

part 'pomodoro_session_model.g.dart';

@collection
class PomodoroSessionModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String sessionId;
  
  @Index()
  late String taskId;
  
  late int sessionTypeValue;
  
  late DateTime startTime;
  
  DateTime? completedAt;
  
  late int durationMinutes;
  
  late bool isCompleted;
  
  int? skipReasonValue;
  
  String? notes;
  
  late DateTime createdAt;
  
  @Index()
  late bool needsSync;

  PomodoroSessionModel();

  /// Create PomodoroSessionModel from PomodoroSession entity
  factory PomodoroSessionModel.fromEntity(PomodoroSession session) {
    final model = PomodoroSessionModel();
    model.sessionId = session.id;
    model.taskId = session.taskId;
    model.sessionTypeValue = session.sessionType.index;
    model.startTime = session.startTime;
    model.completedAt = session.completedAt;
    model.durationMinutes = session.duration.inMinutes;
    model.isCompleted = session.isCompleted;
    model.skipReasonValue = session.skipReason?.index;
    model.notes = session.notes;
    model.createdAt = session.createdAt;
    model.needsSync = true; // New sessions need sync
    return model;
  }

  /// Convert PomodoroSessionModel to PomodoroSession entity
  PomodoroSession toEntity() {
    return PomodoroSession(
      id: sessionId,
      taskId: taskId,
      sessionType: SessionType.values[sessionTypeValue],
      startTime: startTime,
      completedAt: completedAt,
      duration: Duration(minutes: durationMinutes),
      isCompleted: isCompleted,
      skipReason: skipReasonValue != null 
          ? SkipReason.values[skipReasonValue!]
          : null,
      notes: notes,
      createdAt: createdAt,
    );
  }

  /// Update model with entity data
  void updateFromEntity(PomodoroSession session) {
    sessionId = session.id;
    taskId = session.taskId;
    sessionTypeValue = session.sessionType.index;
    startTime = session.startTime;
    completedAt = session.completedAt;
    durationMinutes = session.duration.inMinutes;
    isCompleted = session.isCompleted;
    skipReasonValue = session.skipReason?.index;
    notes = session.notes;
    createdAt = session.createdAt;
    needsSync = true; // Updated sessions need sync
  }

  /// Mark as synced
  void markSynced() {
    needsSync = false;
  }

  /// Mark as needing sync
  void markNeedsSync() {
    needsSync = true;
  }
}
