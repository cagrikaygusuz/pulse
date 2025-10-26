import 'package:isar/isar.dart';
import '../../domain/entities/project.dart';

part 'project_model.g.dart';

@collection
class ProjectModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String projectId;
  
  late String name;
  
  String? description;
  
  @Index()
  late String userId;
  
  late int sortOrder;
  
  late DateTime createdAt;
  
  late DateTime updatedAt;
  
  late bool isArchived;

  ProjectModel();

  /// Create ProjectModel from Project entity
  factory ProjectModel.fromEntity(Project project) {
    final model = ProjectModel();
    model.projectId = project.id;
    model.name = project.name;
    model.description = project.description;
    model.userId = project.userId;
    model.sortOrder = project.sortOrder;
    model.createdAt = project.createdAt;
    model.updatedAt = project.updatedAt;
    model.isArchived = project.isArchived;
    return model;
  }

  /// Convert ProjectModel to Project entity
  Project toEntity() {
    return Project(
      id: projectId,
      name: name,
      description: description,
      userId: userId,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived,
    );
  }

  /// Update model with entity data
  void updateFromEntity(Project project) {
    projectId = project.id;
    name = project.name;
    description = project.description;
    userId = project.userId;
    sortOrder = project.sortOrder;
    createdAt = project.createdAt;
    updatedAt = project.updatedAt;
    isArchived = project.isArchived;
  }
}
