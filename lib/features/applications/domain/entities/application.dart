import 'package:equatable/equatable.dart';

enum ApplicationStatus { pending, interview, accepted, rejected }

class Application extends Equatable {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;
  final String studentId;
  // Applicant-provided details (collected on the apply form).
  final String applicantName;
  final String applicantRole;
  final String coverMessage;
  final String portfolioLink;
  final ApplicationStatus status;
  final DateTime submittedAt;

  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
    required this.studentId,
    required this.applicantName,
    required this.applicantRole,
    required this.coverMessage,
    required this.portfolioLink,
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
    applicantName,
    applicantRole,
    coverMessage,
    portfolioLink,
    status,
    submittedAt,
  ];
}