import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfuckyourlife/components/homePage/HomePage.dart';
import 'package:unfuckyourlife/components/initialPage/InitialPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isItFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool? firstTime = prefs.getBool("firstTime");

    if (firstTime == null) {
      prefs.setBool("firstTime", false);
      return true;
    } else {
      return false;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unfuck your life',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: isItFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            if (snapshot.data == false){
              return const HomePage();
            }else{
              return const InitialPage(title: 'Unfuck your life');
            }
          }
          return Container();
        },
      ),
    );
  }
}
