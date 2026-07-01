import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/application.dart';

class ApplicationModel extends Application {
  const ApplicationModel({
    required super.id,
    required super.opportunityId,
    required super.opportunityTitle,
    required super.startupName,
    required super.studentId,
    required super.status,
    required super.submittedAt,
  });

  factory ApplicationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      opportunityId: data['opportunityId'] as String,
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      studentId: data['studentId'] as String,
      status: ApplicationStatus.values.firstWhere(
            (e) => e.name == data['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'opportunityId': opportunityId,
    'opportunityTitle': opportunityTitle,
    'startupName': startupName,
    'studentId': studentId,
    'status': status.name,
    'submittedAt': Timestamp.fromDate(submittedAt),
  };
}