import '../../domain/entities/startup.dart';

class StartupModel extends Startup {
  const StartupModel({
    required super.id,
    required super.name,
    required super.description,
    required super.verified,
    required super.createdBy,
  });

  factory StartupModel.fromMap(String id, Map<String, dynamic> data) {
    return StartupModel(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String,
      verified: data['verified'] as bool? ?? false,
      createdBy: data['createdBy'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'verified': verified,
      'createdBy': createdBy,
    };
  }
}