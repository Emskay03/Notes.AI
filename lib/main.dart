import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'firebase_options.dart';
import 'package:notes_ai/auth_screen.dart'; // Import your AuthScreen
import 'package:notes_ai/home_screen.dart'; // Import your HomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes AI',
      theme: ThemeData(
        primarySwatch: Colors.blue, // You can customize your theme here
        useMaterial3: true, 
      ),
      home: StreamBuilder<User?>( // This widget listens for auth state changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while Firebase checks the auth state
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            // User is logged in, show the HomeScreen
            return const HomeScreen();
          }
          // User is not logged in, show the AuthScreen
          return const AuthScreen();
        },
      ),
    );
  }
  
}
