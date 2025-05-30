import 'package:equatable/equatable.dart'; // Optional: for equality if needed

class SubtypeDetail extends Equatable {
  // Made it Equatable for good measure
  final String name;

  const SubtypeDetail({required this.name});

  @override
  List<Object?> get props => [name];
}
