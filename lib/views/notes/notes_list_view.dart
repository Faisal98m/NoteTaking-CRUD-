import 'package:flutter/material.dart';
import '../../services/crud/notes_service.dart';
import '../../utilities/dialog/delete_dialog.dart';

//callback definition
typedef DeleteNoteCallBack = void Function(DatabaseNote note); //

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes; //Notes wants a list of notes to display
  final DeleteNoteCallBack onDeleteNote;
  //call a function thats going to call a delete dialog

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              // create a delete icon
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete),
            ),
          );
        });
  }
}
