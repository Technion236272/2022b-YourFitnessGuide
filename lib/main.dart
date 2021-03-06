import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/router.dart' as router;
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AuthRepository.instance(),
        child: MaterialApp(
            title: 'YourFitnessGuide',
            //initialRoute: viewMealPlanRoute,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: router.generateRoute,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.grey[200],
              bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
              iconTheme: const IconThemeData(color: appTheme),

              ///might be better if 0xff84C59E
              appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(color: Colors.white),
                backgroundColor: appTheme,
              ),
            )));
  }
}
