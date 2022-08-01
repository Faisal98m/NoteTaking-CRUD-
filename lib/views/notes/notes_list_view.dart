import 'package:flutter/material.dart';
import '../../services/cloud/cloud_note.dart';
import '../../utilities/dialog/delete_dialog.dart';

//callback definition
typedef NoteCallback = void Function(
    CloudNote note); // we could tell notes view to delete a note

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes; //Notes wants a list of notes to display
  final NoteCallback onDeleteNote;
  //call a function thats going to call a delete dialog
  final NoteCallback onTap;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes.elementAt(index);
          return ListTile(
            onTap: () {
              onTap(note);
            },
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
