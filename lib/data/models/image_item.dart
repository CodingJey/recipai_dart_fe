import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'subtype_detail.dart';

class ImageItem extends Equatable {
  final String name;
  final String imageUrl;
  final int id;
  final String categoryId;
  final List<SubtypeDetail> subtypes;
  final List<String> selectedSubtypeNames;

  ImageItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.categoryId,
    required this.subtypes,
    List<String>? selectedSubtypeNames,
  }) : selectedSubtypeNames = selectedSubtypeNames ?? [];

  ImageItem copyWith({
    String? name,
    String? imageUrl,
    int? id,
    String? categoryId,
    List<SubtypeDetail>? subtypes,
    List<String>? selectedSubtypeNames,
  }) {
    return ImageItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      subtypes: subtypes ?? this.subtypes,
      selectedSubtypeNames: selectedSubtypeNames != null
          ? List<String>.from(selectedSubtypeNames)
          : List<String>.from(this.selectedSubtypeNames),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    categoryId,
    subtypes,
    selectedSubtypeNames,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'selectedSubtypeNames': selectedSubtypeNames,
    };
  }

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      categoryId: json['categoryId'] as String? ?? '',
      subtypes: [],
      selectedSubtypeNames: List<String>.from(
        json['selectedSubtypeNames'] as List,
      ),
    );
  }
}
