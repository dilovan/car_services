import 'package:car_services/admin/admin.dart';
import 'package:car_services/firebase_options.dart';
import 'package:car_services/home.dart';
import 'package:car_services/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //user
  Future<bool> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool authSignedIn = prefs.getBool('auth') ?? false;
    return authSignedIn;
  }

  bool isLoaded = false;
  bool authSignedIn = false;
  String? name, uid, phone, address, image, rule;
  var _auth = FirebaseAuth.instance;
  //get user info
  Future<bool> getUserInfo() async {
    if (_auth.currentUser != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      authSignedIn = prefs.getBool('auth') ?? false;
      //get user info
      var userinfo = FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .get();

      userinfo.then((user) {
        if (user.exists) {
          setState(() {
            uid = user["id"];
            name = user["name"];
            phone = user["phone"];
            address = user["address"];
            rule = user["rule"];
            isLoaded = true;
          });
        } else {
          isLoaded = false;
        }
      });
    } else {
      isLoaded = false;
    }
    return authSignedIn;
  }

  @override
  void initState() {
    //waiting for 3 seconds
    Future.delayed(const Duration(seconds: 3)).then((value) => {
          if (_auth.currentUser != null)
            {
              //if user loged in before navigate to home page
              getUserInfo().then((isLogedin) {
                if (isLogedin) {
                  if (rule == "admin") {
                    //navigate to signin page
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminScreen()));
                  } else {
                    //navigate to signin page
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                  }
                } else {
                  //if not loggedin navigate to signin page
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SigninScreen()));
                }
              })
            }
          else
            {
              //if not loggedin navigate to signin page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const SigninScreen()))
            }
        });
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Hero(
            tag: "logo_493480394503",
            child: Container(
              width: 415, //MediaQuery.of(context).size.width / 2,
              height: 150, //MediaQuery.of(context).size.height * 0.80,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                image: DecorationImage(
                    image: AssetImage('assets/images/logo4.png'),
                    fit: BoxFit.fitWidth),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
