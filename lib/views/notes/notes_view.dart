import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/auth/bloc/auth_event.dart';
import 'package:flutter_application_1/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_application_1/views/notes/notes_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/cloud/cloud_note.dart';
import '../../utilities/dialog/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId =>
      AuthService.firebase().currentUser!.id; // gets the user from Auth User

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Notes'),
          backgroundColor: Colors.lightGreen,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createUpdateNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text(
                        'Log out',
                      )),
                ];
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (CloudNote note) {
                      Navigator.of(context).pushNamed(
                        createUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
