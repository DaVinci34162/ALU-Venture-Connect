import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/application.dart';
import '../models/application_model.dart';

class ApplicationFirestoreDatasource {
  final FirebaseFirestore firestore;
  const ApplicationFirestoreDatasource(this.firestore);

  Future<void> applyToOpportunity(Application application) async {
    // Derive the startup owner's uid so it is denormalized onto the
    // application document. The security rules validate this value
    // server-side against the same chain, so it cannot be forged.
    final oppDoc = await firestore
        .collection('opportunities')
        .doc(application.opportunityId)
        .get();
    final startupId = oppDoc.data()!['startupId'] as String;

    final startupDoc =
    await firestore.collection('startups').doc(startupId).get();
    final startupOwnerUid = startupDoc.data()!['createdBy'] as String;

    // Wrap the incoming application (which already carries the applicant's
    // name, role, cover message, and link) so nothing collected on the
    // form is lost. Status and timestamp are set server-side rather than
    // trusting whatever the client sent.
    final model = ApplicationModel(
      id: '',
      opportunityId: application.opportunityId,
      opportunityTitle: application.opportunityTitle,
      startupName: application.startupName,
      studentId: application.studentId,
      applicantName: application.applicantName,
      applicantRole: application.applicantRole,
      coverMessage: application.coverMessage,
      portfolioLink: application.portfolioLink,
      status: ApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );
    final map = model.toMap()..['startupOwnerUid'] = startupOwnerUid;
    await firestore.collection('applications').add(map);
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

  /// All applications submitted to the signed-in admin's startup, newest
  /// first. Queries by the denormalized owner uid, which the security
  /// rules can verify directly against the query.
  Stream<List<Application>> watchApplicationsForStartup(String ownerUid) {
    return firestore
        .collection('applications')
        .where('startupOwnerUid', isEqualTo: ownerUid)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ApplicationModel.fromDoc(doc))
        .toList());
  }
}