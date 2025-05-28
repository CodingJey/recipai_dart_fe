import '../../core/utils/string_utils.dart';
import 'subtype_detail.dart';

// // Helper class to explicitly update selectedSubtypeNames
// class SelectedSubtypeNamesValue {
//   // Renamed
//   final List<String> value;
//   SelectedSubtypeNamesValue(this.value);
// }

class ImageItem {
  final String name;
  final String imageUrl;
  final int id;
  final String baseAssetFolder;
  final List<String> subtypeFileBasenames;
  final List<SubtypeDetail> subtypes;
  List<String> selectedSubtypeNames; // Changed from String? to List<String>

  ImageItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.subtypeFileBasenames,
    List<String>? selectedSubtypeNames, // Allow initializing with a list
  }) : baseAssetFolder = imageUrl.split('/').last.split('.').first,
       subtypes = _generateSubtypeDetails(
         imageUrl.split('/').last.split('.').first,
         subtypeFileBasenames,
       ),
       selectedSubtypeNames =
           selectedSubtypeNames ?? []; // Initialize to empty list if null

  static List<SubtypeDetail> _generateSubtypeDetails(
    String baseFolder,
    List<String> fileBasenames,
  ) {
    return fileBasenames.map((basename) {
      String displayName = toTitleCase(basename);
      String imageNameWithExt = "$basename.png";
      String assetPath = "assets/images/$baseFolder/$imageNameWithExt";
      return SubtypeDetail(name: displayName, assetPath: assetPath);
    }).toList();
  }

  ImageItem copyWith({
    String? name,
    String? imageUrl,
    int? id,
    List<String>? subtypeFileBasenames,
    List<String>? selectedSubtypeNames, // Direct list parameter
  }) {
    return ImageItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      subtypeFileBasenames: subtypeFileBasenames ?? this.subtypeFileBasenames,
      selectedSubtypeNames: selectedSubtypeNames != null
          ? List<String>.from(selectedSubtypeNames)
          : List<String>.from(this.selectedSubtypeNames),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageItem &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        _listEquals(other.selectedSubtypeNames, selectedSubtypeNames);
  }

  @override
  int get hashCode {
    return Object.hash(id, name, imageUrl, selectedSubtypeNames);
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
