import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup_model.dart';

class StartupFirestoreDataSource {
  final FirebaseFirestore firestore;
  StartupFirestoreDataSource(this.firestore);

  CollectionReference get _collection => firestore.collection('startups');

  /// Finds the startup created by this uid, if any. Used to check
  /// "does this admin already have a startup profile."
  Stream<StartupModel?> watchMyStartup(String uid) {
    return _collection.where('createdBy', isEqualTo: uid).limit(1).snapshots().map(
          (snapshot) {
        if (snapshot.docs.isEmpty) return null;
        final doc = snapshot.docs.first;
        return StartupModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      },
    );
  }

  Future<void> create(StartupModel model) async {
    final docId = firestore.collection('startups').doc().id;
    await _collection.doc(docId).set(model.toMap());
  }
}