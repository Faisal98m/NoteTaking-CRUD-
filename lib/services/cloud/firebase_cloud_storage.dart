import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/cloud/cloud_note.dart';
import 'package:flutter_application_1/services/cloud/cloud_storage_constants.dart';
import 'package:flutter_application_1/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance
      .collection('notes'); // how we're going to talk with firestore

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNote();
    }
  }

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      await notes
          .doc(documentId)
          .update({textFieldName: text}); //.doc.documentId is the path
    } catch (e) {
      throw CouldNotUpdateNote();
    }
  }

//grab a stream of data and be able to subscribe to all the changes happening to it with (SNAPSHOT)
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) => notes
      .snapshots()
      .map((event) => event.docs // we wanna see all the changes happening live
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where(
              (note) => note.ownerUserId == ownerUserId)); // (WHERE) is a query

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      // communicating with firestore and reading the documents
      return await notes
          .where(
            ownerUSerIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) {
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUSerIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotCreateNoteException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUSerIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }
}
