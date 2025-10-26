import 'package:isar/isar.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@collection
class TaskModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String taskId;
  
  @Index()
  late String projectId;
  
  late String name;
  
  String? description;
  
  late int estimatedDurationMinutes;
  
  int? actualDurationMinutes;
  
  late int sortOrder;
  
  late int statusValue;
  
  late DateTime createdAt;
  
  late DateTime updatedAt;
  
  late bool isArchived;

  TaskModel();

  /// Create TaskModel from Task entity
  factory TaskModel.fromEntity(Task task) {
    final model = TaskModel();
    model.taskId = task.id;
    model.projectId = task.projectId;
    model.name = task.name;
    model.description = task.description;
    model.estimatedDurationMinutes = task.estimatedDuration.inMinutes;
    model.actualDurationMinutes = task.actualDuration?.inMinutes;
    model.sortOrder = task.sortOrder;
    model.statusValue = task.status.index;
    model.createdAt = task.createdAt;
    model.updatedAt = task.updatedAt;
    model.isArchived = task.isArchived;
    return model;
  }

  /// Convert TaskModel to Task entity
  Task toEntity() {
    return Task(
      id: taskId,
      projectId: projectId,
      name: name,
      description: description,
      estimatedDuration: Duration(minutes: estimatedDurationMinutes),
      actualDuration: actualDurationMinutes != null 
          ? Duration(minutes: actualDurationMinutes!)
          : null,
      sortOrder: sortOrder,
      status: TaskStatus.values[statusValue],
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived,
    );
  }

  /// Update model with entity data
  void updateFromEntity(Task task) {
    taskId = task.id;
    projectId = task.projectId;
    name = task.name;
    description = task.description;
    estimatedDurationMinutes = task.estimatedDuration.inMinutes;
    actualDurationMinutes = task.actualDuration?.inMinutes;
    sortOrder = task.sortOrder;
    statusValue = task.status.index;
    createdAt = task.createdAt;
    updatedAt = task.updatedAt;
    isArchived = task.isArchived;
  }
}
