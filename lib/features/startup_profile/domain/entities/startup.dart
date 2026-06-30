import 'package:equatable/equatable.dart';

class Startup extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool verified;
  final String createdBy; // uid of the startup admin who created it

  const Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.verified,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [id, name, description, verified, createdBy];
}