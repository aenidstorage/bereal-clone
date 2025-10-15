import 'dart:io' as d;
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rebeal/common/locator.dart';
import 'package:rebeal/common/splash.dart';
import 'package:rebeal/state/app.state.dart';
import 'package:rebeal/state/auth.state.dart';
import 'package:provider/provider.dart';
import 'package:rebeal/state/post.state.dart';
import 'package:rebeal/state/search.state.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to get cameras, but don't crash if it fails (e.g., on web)
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Camera initialization failed: $e');
    cameras = [];
  }
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  setupDependencies();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(
    sharedPreferences: sharedPreferences,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);
  final SharedPreferences sharedPreferences;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStates>(create: (_) => AppStates()),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<PostState>(create: (_) => PostState()),
        ChangeNotifierProvider<SearchState>(create: (_) => SearchState()),
      ],
      child: MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFFB65B86), // Fallback color
          ),
          title: 'ReBeal.',
          debugShowCheckedModeBanner: false,
          home: SplashPage()),
    );
  }
}
