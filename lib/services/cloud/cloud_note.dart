//implement cloud note to represent a note on cloud firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUSerIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
// IMMUTABLE CLASS WITH A CONSTQNT CONSTRUCTOR AND SNAPSHOT FROM FIRESTORE AND CREATE INSTANCES OF OUR CLOUD NOTE