class CloudStorageException implements Exception {
  const CloudStorageException(); // parent exception
}

//C in Crud
class CouldNotCreateNoteException extends CloudStorageException {}

//R in Crud
class CouldNotGetAllNotes extends CloudStorageException {}

//U in Crud
class CouldNotUpdateNote extends CloudStorageException {}

//D in Crud
class CouldNotDeleteNote extends CloudStorageException {}
