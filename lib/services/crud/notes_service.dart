import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/extensions/list/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:flutter/foundation.dart';

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  DatabaseUser? _user;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        // anyone who listens to the stream, our caall back will get called and get populated
        _notesStreamController.sink.add(_notes);
      },
    );
  } //singleton
  factory NotesService() => _shared;

  //Be able to control a stream of the list of db notes// in control of the changes in the notes list
  late final StreamController<List<DatabaseNote>>
      _notesStreamController; //everything from the outside will be read by _notesStreamController

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      }); //get all notes in notes service

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes =
        await getAllNotes(); //gets all of our notes from getAllNotes function
    _notes = allNotes.toList(); // convert all the iterable notes to a list
    _notesStreamController.add(_notes); //
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

//make sure note exists
    await getNote(id: note.id);

    //update db
    final updatesCount = await db.update(
      noteTable,
      {
        textColumn: text,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(
          _notes); //everything from the outside will be read by _notesStreamController
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    //render all the notes for the user
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow)); //get db type
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      //query the db
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = []; //local cache updated
    _notesStreamController.add(_notes); // user ui is updated with info

    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    // signature is deleteNote
    final db = _getDatabaseOrThrow(); //get db or throw exception
    final deletedCount = await db.delete(
      //
      noteTable, // from the noteTable
      where: 'id = ?', //delete an object which has column id set to something
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      // if couldnot delete note
      throw CouldNotDeleteNote(); // throw exception
    } else {
      _notes
          .removeWhere((note) => note.id == id); //remove note from local cache
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);

    //make sure owner exists in db with correct id
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    //create the note
    final noteId = await db.insert(noteTable, {
      //reutrns id
      userIdColumn: owner.id,
      textColumn: text,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
    );
    _notes.add(note); // read the notes inside the user
    _notesStreamController.add(
        _notes); //everything from the outside will be read by _notesStreamController

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1, // limits the number of rows returned by the query
      where: 'email = ?', //looking for email
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      // either 0 rows
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results
          .first); //or one row which is the user with the given email address.
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1, // limits the number of rows returned by the query
      where: 'email = ?', //looking for email
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      //check to see if a user with given email exists
      throw UserAlreadyExists(); // if it does throw exception
    }

    final userId = await db.insert(userTable, {
      //insert the user after checking user doesn't already exist
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    //deleting a user function
    final db =
        _getDatabaseOrThrow(); // gets the db or fethces the _getDatabaseOrThrow function
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    // private function that our reading and writing are going to use to get the current database
    final db = _db;
    if (db == null) {
      // if there is no database
      throw DatabaseIsNotOpen(); // throw an exception
    } else {
      return db; //else return the db
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // create user table
      await db.execute(createUserTable);
      //create note table
      await db.execute(createNoteTable);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db; // we have our database
    if (db == null) {
      //if db is not open
      throw DatabaseIsNotOpen(); //throw this exception
    } else {
      await db.close(); //otherwise close the db
      _db = null; //reset databse
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    // constructor
    required this.id, // named parameters
    required this.email, //named parameters
  });

  DatabaseUser.fromRow(
      Map<String, Object?>
          map) //Every user is going to be represented by Map <String, Object?> // A row inside the user table
      : id = map[idColumn] as int, // shorthand for constructing object
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID= $id, email = $email';

  @override // equality behaviour to see if two people are equal to eachother
  bool operator ==(covariant DatabaseUser other) =>
      id ==
      other
          .id; // Covariant allows you to chnage the behaviour of your input parameter so that it does conform to the signature of the parameter in the superclass

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;

  const DatabaseNote({
    //initializer
    required this.id,
    required this.userId,
    required this.text,
  });

  DatabaseNote.fromRow(Map<String, Object?> map) //instantiate from row
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String;

  @override
  String toString() => 'Note, ID= $id, userId= $userId, text = $text';

  @override // equality behaviour to see if two people are equal to eachother
  bool operator ==(covariant DatabaseNote other) =>
      id ==
      other
          .id; // allows you to chnage the behaviour of your input parameter so that it does conform to the signature of the parameter in the superclass

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "User" (
	"id"	INTEGER NOT NULL,
	"email"	INTEGER NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	PRIMARY KEY("id"),
	FOREIGN KEY("user_id") REFERENCES "User"("id")
);
''';
