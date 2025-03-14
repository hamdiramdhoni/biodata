// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class BiodataService {
  final FirebaseFirestore db;

  BiodataService(this.db);

  Future<String> add(Map<String, dynamic> data) async {
    // add a new document with a generated id
    final document = await db.collection('biodata').add(data);
    return document.id;
  }

  // Fetching data
  Stream<QuerySnapshot<Map<String, dynamic>>> getBiodata() {
    return db.collection('biodata').snapshots();
  }

  // delete a document by id
  Future<void> delete(String documentId) async {
    await db.collection('biodata').doc(documentId).delete();
  }

  // update a document by id
  Future<void> update(String documentId, Map<String, dynamic> data) async {
    await db.collection('biodata').doc(documentId).update(data);
  }
}
