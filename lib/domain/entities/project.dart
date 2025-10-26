import 'package:equatable/equatable.dart';

/// Project entity representing a collection of related tasks
class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final String? description;
  final String userId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  /// Create a copy of this project with updated fields
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// Create a project with updated timestamp
  Project updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Create a project with new sort order
  Project updateSortOrder(int newSortOrder) {
    return copyWith(
      sortOrder: newSortOrder,
      updatedAt: DateTime.now(),
    );
  }

  /// Archive this project
  Project archive() {
    return copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Unarchive this project
  Project unarchive() {
    return copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        userId,
        sortOrder,
        createdAt,
        updatedAt,
        isArchived,
      ];

  @override
  String toString() {
    return 'Project(id: $id, name: $name, userId: $userId, sortOrder: $sortOrder, isArchived: $isArchived)';
  }
}
