import 'package:car_services/home.dart';
import 'package:car_services/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //is password visible
  bool passHidden = true;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  String? uid;
  String? userEmail;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  //nameController
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String _errorPassword = "";
  String _errorEmail = "";

  Future<User?> registerWithEmailPassword(String email, String password) async {
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    // if (kDebugMode) {
    //   try {
    //     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 9090);
    //     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    //   } catch (e) {
    //     // ignore: avoid_print
    //     print(e);
    //   }
    // }

    User? user;
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      if (user != null) {
        uid = user.uid;
        userEmail = user.email;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else if (e.code == 'No user found for that email') {
        print('No user found for that email.');
      }
    } catch (e) {
      print("error $e");
    }
    return user;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 415, //MediaQuery.of(context).size.width / 2,
                height: 150, //MediaQuery.of(context).size.height * 0.80,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      image: AssetImage('assets/images/logo4.png'),
                      fit: BoxFit.fitWidth),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //Username
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: const InputDecoration(
                    prefixIconColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.person,
                      size: 30,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: "USER NAME",
                    labelStyle: TextStyle(fontSize: 50),
                    helperStyle: TextStyle(color: Colors.white),
                    contentPadding: EdgeInsets.all(20)),
              ),
              const SizedBox(
                height: 20,
              ),
              //phone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: const InputDecoration(
                    prefixIconColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.phone,
                      size: 30,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: "PHONE NUMBER",
                    labelStyle: TextStyle(fontSize: 50),
                    helperStyle: TextStyle(color: Colors.white),
                    contentPadding: EdgeInsets.all(20)),
              ),
              const SizedBox(
                height: 20,
              ),
              //email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: InputDecoration(
                    prefixIconColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.email,
                      size: 30,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintStyle: const TextStyle(color: Colors.white),
                    hintText: "EMAIL",
                    errorText: _errorEmail,
                    errorBorder: InputBorder.none,
                    labelStyle: const TextStyle(fontSize: 50),
                    helperStyle: const TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.all(20)),
              ),
              const SizedBox(
                height: 20,
              ),
              //password
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                keyboardType: TextInputType.visiblePassword,
                obscureText: passHidden,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                    suffixIconColor: Colors.white,
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          passHidden = !passHidden;
                        });
                      },
                      child: Text(
                        passHidden ? "show" : "hide",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    prefixIconColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.lock,
                      size: 30,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintStyle: const TextStyle(color: Colors.white),
                    hintText: "PASSWORD",
                    labelStyle: const TextStyle(fontSize: 50),
                    errorText: _errorPassword,
                    errorBorder: InputBorder.none,
                    helperStyle: const TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.all(20)),
              ),
              const SizedBox(
                height: 20,
              ),
              //button submit
              ElevatedButton(
                onPressed: () async {
                  registerWithEmailPassword(
                          emailController.text, passwordController.text)
                      .then((user) async {
                    // update user display name
                    await user
                        ?.updateDisplayName(nameController.text)
                        .then((value) {
                      // print("display user updated");
                    });

                    //save user in firestore
                    var userInfo = {
                      "id": user?.uid,
                      "name": nameController.text,
                      "phone": phoneController.text,
                      "address": "",
                      "image": "",
                      "rule": "customer",
                    };
                    //add user info to users collection in firestore
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(user?.uid)
                        .set(userInfo)
                        .then((value) {
                      if (user != null) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()));
                      } else {
                        setState(() {
                          _errorPassword = "Password is too weak!";
                          _errorEmail = "Email already registered!";
                        });
                      }
                    });
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: const Center(
                    child: Text(
                      "SIGNUP",
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //have an account button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Have an account? ",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SigninScreen()));
                    },
                    child: const Text(
                      "Signin",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
