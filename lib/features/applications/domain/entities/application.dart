import 'package:equatable/equatable.dart';

enum ApplicationStatus { pending, interview, accepted, rejected }

class Application extends Equatable {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;
  final String studentId;
  final ApplicationStatus status;
  final DateTime submittedAt;

  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
    required this.studentId,
    required this.status,
    required this.submittedAt,
  });

  @override
  List<Object?> get props => [
    id,
    opportunityId,
    opportunityTitle,
    startupName,
    studentId,
    status,
    submittedAt,
  ];
}