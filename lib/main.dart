import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yourfitnessguide/utils/constants.dart';
import 'package:yourfitnessguide/utils/router.dart' as router;
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  final appTheme = const Color(0xff4CC47C);
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => AuthRepository.instance(),
        child: MaterialApp(
          title: 'YourFitnessGuide',
          onGenerateRoute: router.generateRoute,
          initialRoute: mealPlanRoute,
          theme: ThemeData(
            /*colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.grey,
              accentColor: Colors.lightGreen, //this is temporary!
            ),*/
            iconTheme: IconThemeData(color: appTheme), ///might be better if 0xff84C59E
            appBarTheme: AppBarTheme(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: appTheme,
            ),

          )
        ));
  }
}