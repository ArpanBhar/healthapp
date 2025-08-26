import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/chat.dart';
import 'package:healthapp/login.dart';
import 'package:healthapp/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  bool pageStatus = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,home: Scaffold(body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, asyncSnapshot) {
        if(asyncSnapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }
        if(asyncSnapshot.hasData){
          return LlmChatScreen();
        }
        return pageStatus ? SignUpPage(onPressed: (){
          setState(() {
            pageStatus = false;
          });
        }) : LoginPage(onPressed: (){
          setState(() {
            pageStatus = true;
          });
        },);
      }
    )));
  }
}
