import 'package:equatable/equatable.dart';

/// Task status enum
enum TaskStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  const TaskStatus(this.displayName);
  final String displayName;

  /// Check if task is active (not completed or cancelled)
  bool get isActive => this == TaskStatus.pending || this == TaskStatus.inProgress;

  /// Check if task is completed
  bool get isCompleted => this == TaskStatus.completed;

  /// Check if task is cancelled
  bool get isCancelled => this == TaskStatus.cancelled;
}

/// Task entity representing a work item within a project
class Task extends Equatable {
  const Task({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.estimatedDuration,
    this.actualDuration,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String name;
  final String? description;
  final Duration estimatedDuration;
  final Duration? actualDuration;
  final int sortOrder;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  /// Create a copy of this task with updated fields
  Task copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    Duration? estimatedDuration,
    Duration? actualDuration,
    int? sortOrder,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// Create a task with updated timestamp
  Task updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Create a task with new sort order
  Task updateSortOrder(int newSortOrder) {
    return copyWith(
      sortOrder: newSortOrder,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark task as in progress
  Task markInProgress() {
    return copyWith(
      status: TaskStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark task as completed
  Task markCompleted({Duration? actualDuration}) {
    return copyWith(
      status: TaskStatus.completed,
      actualDuration: actualDuration ?? this.actualDuration,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark task as cancelled
  Task markCancelled() {
    return copyWith(
      status: TaskStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  /// Reset task to pending status
  Task resetToPending() {
    return copyWith(
      status: TaskStatus.pending,
      actualDuration: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Archive this task
  Task archive() {
    return copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Unarchive this task
  Task unarchive() {
    return copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Update estimated duration
  Task updateEstimatedDuration(Duration newDuration) {
    return copyWith(
      estimatedDuration: newDuration,
      updatedAt: DateTime.now(),
    );
  }

  /// Update actual duration
  Task updateActualDuration(Duration newDuration) {
    return copyWith(
      actualDuration: newDuration,
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate completion percentage based on actual vs estimated duration
  double get completionPercentage {
    if (actualDuration == null || estimatedDuration.inMinutes == 0) {
      return 0.0;
    }
    return (actualDuration!.inMinutes / estimatedDuration.inMinutes * 100).clamp(0.0, 100.0);
  }

  /// Check if task is overdue (estimated duration exceeded)
  bool get isOverdue {
    if (actualDuration == null) return false;
    return actualDuration!.inMinutes > estimatedDuration.inMinutes;
  }

  /// Get remaining estimated time
  Duration get remainingEstimatedTime {
    if (actualDuration == null) return estimatedDuration;
    final remaining = estimatedDuration.inMinutes - actualDuration!.inMinutes;
    return Duration(minutes: remaining.clamp(0, estimatedDuration.inMinutes));
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        description,
        estimatedDuration,
        actualDuration,
        sortOrder,
        status,
        createdAt,
        updatedAt,
        isArchived,
      ];

  @override
  String toString() {
    return 'Task(id: $id, projectId: $projectId, name: $name, status: $status, estimatedDuration: $estimatedDuration)';
  }
}
