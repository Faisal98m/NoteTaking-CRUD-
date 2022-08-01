import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/utilities/generics/get_argument.dart';
import 'package:flutter_application_1/services/cloud/cloud_note.dart';
import 'package:flutter_application_1/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

import '../../utilities/dialog/cannot_share_empty_note.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note; // keep hold of our current note so we dont recreate it
  late final FirebaseCloudStorage _notesService; //keep hold of our noteService
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    //listens to the text controller
    final note = _note; //get note from _note
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      text: text,
      documentId: note.documentId,
    );
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote; // Textfield should be prepopulated with original note
      _textController.text = widgetNote.text; // set the text
      return widgetNote;
    }

    // creating our note
    final existingNote = _note; // Have we created this note before
    if (existingNote != null) {
      // if we have
      return existingNote; // return the existing note
    } // if we dont then we create a new note
    final currentUser =
        AuthService.firebase().currentUser!; //retrieve the user from firebase
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(
        ownerUserId: userId); //create note with that owner
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note; // get the note
    if (_textController.text.isEmpty && note != null) {
      //if the text is empty and the note is not null
      _notesService.deleteNote(
          documentId: note.documentId); // we go to note service and delete note
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        text: text,
        documentId: note.documentId,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Notes'),
        actions: [
          IconButton(
              onPressed: () async {
                final text = _textController.text;
                if (_note == null || text.isEmpty) {
                  await showCannotShareEmptyNotesDialog(context);
                } else {
                  Share.share(text);
                }
              },
              icon: const Icon(Icons.share))
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener(); // get notes from snapshot
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Start typing your note...'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
