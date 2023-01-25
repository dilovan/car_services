import 'package:car_services/home.dart';
import 'package:car_services/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/admin.dart';

// import 'authentication.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  //is password visible
  bool passHidden = true;
  String message = "";
  bool isError = false;
  bool isSinging = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: "logo",
                child: Container(
                  width: 415, //MediaQuery.of(context).size.width / 2,
                  height: 150, //MediaQuery.of(context).size.height * 0.80,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                        image: AssetImage('assets/images/logo4.png'),
                        fit: BoxFit.fitWidth),
                  ),
                ),
              ),
              isError
                  ? SizedBox(
                      height: 20,
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    )
                  : Container(),
              const SizedBox(
                height: 20,
              ),
              //email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
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
                    hintText: "EMAIL",
                    labelStyle: TextStyle(fontSize: 50),
                    helperStyle: TextStyle(color: Colors.white),
                    contentPadding: EdgeInsets.all(20)),
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
                    helperStyle: const TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.all(20)),
              ),
              const SizedBox(
                height: 20,
              ),
              isSinging
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isSinging = true;
                        });
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          await SharedPreferences.getInstance().then((auth) {
                            auth.setBool('auth', true);
                            //navigate to home page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          });

                          // }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            setState(() {
                              message = 'No user found for that email.';
                            });
                          } else if (e.code == 'wrong-password') {
                            setState(() {
                              message = 'Wrong password provided.';
                            });
                          } else {
                            message = "Kunown Error";
                          }
                          setState(() {
                            isSinging = false;
                            isError = true;
                            message = "Email or password is not correct!";
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: const Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Need an account? ",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()));
                    },
                    child: const Text(
                      "Signup",
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
