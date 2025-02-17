import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a news category with its properties.
class NewsCategory {
  /// Unique identifier for the category
  final String? id;

  /// Display name of the category
  final String? name;

  /// Icon path or identifier for the category
  final String? icon;

  /// Alias or alternative name for the category
  final String? alias;

  /// Description for the category
  final String? description;

  /// Whether to show it as a category or not
  final bool? showAsCategory;

  /// Creates a new [NewsCategory] instance
  NewsCategory({
    this.id,
    this.name,
    this.icon,
    this.alias,
    this.description,
    this.showAsCategory,
  });

  /// Creates a [NewsCategory] from a JSON map
  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      id: json['id'] as String?,
      name: json['name'] as String?,
      icon: json['icon'] as String?,
      alias: json['alias'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Creates a [NewsCategory] from a Firestore document snapshot
  factory NewsCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return NewsCategory();

    return NewsCategory(
      id: data['id'] as String?,
      name: data['name'] as String?,
      icon: data['icon'] as String?,
      alias: data['alias'] as String?,
    );
  }

  /// Converts the [NewsCategory] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'alias': alias,
    };
  }

  /// Creates a copy of this [NewsCategory] with the given fields replaced with new values
  NewsCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? alias,
  }) {
    return NewsCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      alias: alias ?? this.alias,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          alias == other.alias;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ icon.hashCode ^ alias.hashCode;

  @override
  String toString() {
    return 'NewsCategory(id: $id, name: $name, icon: $icon, alias: $alias)';
  }
}