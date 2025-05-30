import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'subtype_detail.dart';

class ImageItem extends Equatable {
  final String name;
  final String imageUrl;
  final int id;
  final String categoryName;
  final List<SubtypeDetail> subtypes;
  final List<String> selectedSubtypeNames;

  ImageItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.categoryName,
    required this.subtypes,
    List<String>? selectedSubtypeNames,
  }) : selectedSubtypeNames = selectedSubtypeNames ?? [];

  ImageItem copyWith({
    String? name,
    String? imageUrl,
    int? id,
    String? categoryName,
    List<SubtypeDetail>? subtypes,
    List<String>? selectedSubtypeNames,
  }) {
    return ImageItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryName: categoryName ?? this.categoryName,
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
    categoryName,
    subtypes,
    selectedSubtypeNames,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'categoryName': categoryName,
      'selectedSubtypeNames': selectedSubtypeNames,
    };
  }

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      categoryName: json['categoryName'] as String? ?? '',
      subtypes: [],
      selectedSubtypeNames: List<String>.from(
        json['selectedSubtypeNames'] as List,
      ),
    );
  }
}
