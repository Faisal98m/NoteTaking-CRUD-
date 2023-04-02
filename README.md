# Note Taking CRUD App

This is a Flutter app that demonstrates various features including authentication, navigation, and state management using the BLoC pattern. The app is designed to showcase a simple note-taking functionality, where users can create, read, update, and delete notes.

## Features

The app includes the following features:

Authentication: Users can sign up, sign in, sign out, and reset their password if forgotten.
Authorization: Only authenticated users can view and manage their notes.
Notes: Users can create, read, update, and delete notes.
Loading screen: A loading screen is displayed when the app is loading or performing an action that requires user input.

## Structure
The app is structured with a main.dart file that sets up the MaterialApp and initializes the AuthBloc. The AuthBloc handles all authentication and authorization related functionality. The UI is divided into several views, including:

LoginView: The initial view where users can sign in.
RegisterView: The view where users can sign up.
NotesView: The view where users can see their notes.
CreateUpdateNoteView: The view where users can create or update notes.
VerifyEmailView: The view where users can verify their email address.
ForgotPasswordView: The view where users can reset their password.

## Getting Started
To get started with this project, you will need to have Flutter installed on your machine. You can install it by following the instructions in the official Flutter documentation here.

Once you have installed Flutter, you can clone this repository and run the app on your local machine using the following steps:

Clone the repository: git clone https://github.com/Faisal98m/flutterApp.git
Change into the project directory: cd flutterApp
Install the app dependencies: flutter pub get
Run the app: flutter run

## Contributing
Contributions to this project are welcome! If you have any suggestions, bug reports, or feature requests, please open an issue on this repository.

If you would like to contribute to the project, please fork the repository and create a pull request with your changes.
