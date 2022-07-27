import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/utilities/generics/get_argument.dart';
import '../../services/crud/notes_service.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note; // keep hold of our current note so we dont recreate it
  late final NotesService _notesService; //keep hold of our noteService
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
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
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();
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
    final email =
        currentUser.email!; // extract the email from current user + unwrap
    final owner =
        await _notesService.getUser(email: email); // get owner from databse.
    final newNote = await _notesService.createNote(
        owner: owner); //create note with that owner
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note; // get the note
    if (_textController.text.isEmpty && note != null) {
      //if the text is empty and the note is not null
      _notesService.deleteNote(
          id: note.id); // we go to note service and delete note
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
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
