import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/application.dart';
import '../models/application_model.dart';

class ApplicationFirestoreDatasource {
  final FirebaseFirestore firestore;
  const ApplicationFirestoreDatasource(this.firestore);

  Future<void> applyToOpportunity(Application application) async {
    final model = ApplicationModel(
      id: '',
      opportunityId: application.opportunityId,
      opportunityTitle: application.opportunityTitle,
      startupName: application.startupName,
      studentId: application.studentId,
      status: ApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );
    await firestore.collection('applications').add(model.toMap());
  }

  Stream<List<Application>> watchMyApplications(String studentId) {
    return firestore
        .collection('applications')
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ApplicationModel.fromDoc(doc))
        .toList());
  }
}