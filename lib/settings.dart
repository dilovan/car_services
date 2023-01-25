import 'package:car_services/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  //get user info and store in variables
  bool isLoaded = false;
  String? uid, name, phone, address;

  //get user info
  void getUserInfo() {
    if (_auth.currentUser != null) {
      //get user info
      FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .get()
          .then((user) {
        if (user.exists) {
          setState(() {
            uid = user["id"];
            name = user["name"];
            phone = user["phone"] ?? "";
            address = user["address"];
            isLoaded = true;
          });
        } else {
          isLoaded = false;
        }
      });
    } else {
      isLoaded = false;
    }
  }

  Future<String> signOut() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);
    return 'signOut';
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
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
      appBar: AppBar(
        title: const Text("Settings & Information"),
      ),
      body: isLoaded
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //profile image
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.amber,
                        // backgroundImage: NetworkImage(),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  //name and email
                  Padding(
                    padding: const EdgeInsets.all(1),
                    child: Column(
                      children: [
                        Text(
                          name.toString().toUpperCase(),
                          textScaleFactor: 1.4,
                        ),
                        Text(_auth.currentUser!.email.toString()),
                      ],
                    ),
                  ),
                  //divider
                  const Divider(
                    indent: 30,
                    endIndent: 30,
                    color: Colors.black12,
                    height: 30,
                  ),
                  //account and address
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //account
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                      barrierColor: Colors.black87,
                                      elevation: 8,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30)),
                                      ),
                                      builder: (BuildContext context) {
                                        return SingleChildScrollView(
                                            child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            children: [
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    // name
                                                    TextField(
                                                      controller:
                                                          nameController,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      decoration:
                                                          const InputDecoration(
                                                              prefixIcon: Icon(
                                                                Icons.person,
                                                                size: 20,
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            228,
                                                                            227,
                                                                            227)),
                                                              ),
                                                              hintText:
                                                                  "Your name",
                                                              errorBorder:
                                                                  InputBorder
                                                                      .none,
                                                              labelStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          20),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(5)),
                                                    ),
                                                    //spacer
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  ]),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    //update name
                                                    FirebaseFirestore.instance
                                                        .collection("users")
                                                        .doc(uid)
                                                        .update({
                                                      "name": nameController
                                                          .text
                                                          .trim()
                                                    }).whenComplete(() {
                                                      nameController.clear();
                                                      getUserInfo();
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      Icons.edit_note),
                                                  label: const Text("Update"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ));
                                      },
                                      context: context);
                                },
                                child: const Icon(Icons.edit_note)),
                            const Text("Account"),
                            Text(
                              name.toString().toUpperCase(),
                              textScaleFactor: 1.4,
                            ),
                          ],
                        ),
                        //address
                        Column(
                          children: [
                            InkWell(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                      barrierColor: Colors.black87,
                                      elevation: 8,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30)),
                                      ),
                                      builder: (BuildContext context) {
                                        return SingleChildScrollView(
                                            child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            children: [
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    // address
                                                    TextField(
                                                      controller:
                                                          addressController,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      decoration:
                                                          const InputDecoration(
                                                              prefixIcon: Icon(
                                                                Icons
                                                                    .edit_location_alt_rounded,
                                                                size: 20,
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            228,
                                                                            227,
                                                                            227)),
                                                                // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                              ),
                                                              // hintStyle: const TextStyle(),
                                                              hintText:
                                                                  "Your Address",
                                                              errorBorder:
                                                                  InputBorder
                                                                      .none,
                                                              labelStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          20),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(5)),
                                                    ),
                                                    //spacer
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  ]),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    //update address
                                                    FirebaseFirestore.instance
                                                        .collection("users")
                                                        .doc(uid)
                                                        .update({
                                                      "address":
                                                          addressController.text
                                                    }).whenComplete(() {
                                                      addressController.clear();
                                                      getUserInfo();
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      Icons.edit_location_alt),
                                                  label: const Text("Update"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ));
                                      },
                                      context: context);
                                },
                                child:
                                    const Icon(Icons.edit_location_outlined)),
                            const Text("Address"),
                            Text(
                              address.toString().toUpperCase(),
                              textScaleFactor: 1.4,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //phone
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet<void>(
                              barrierColor: Colors.black87,
                              elevation: 8,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                              ),
                              builder: (BuildContext context) {
                                return SingleChildScrollView(
                                    child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            // phone
                                            TextField(
                                              controller: phoneController,
                                              keyboardType:
                                                  TextInputType.number,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              decoration: const InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.sim_card,
                                                    size: 20,
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 1,
                                                        color: Color.fromARGB(
                                                            255,
                                                            228,
                                                            227,
                                                            227)),
                                                    // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  ),
                                                  // hintStyle: const TextStyle(),
                                                  hintText: "Your Phone Number",
                                                  errorBorder: InputBorder.none,
                                                  labelStyle:
                                                      TextStyle(fontSize: 20),
                                                  contentPadding:
                                                      EdgeInsets.all(5)),
                                            ),
                                            //spacer
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ]),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            //update name
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(uid)
                                                .update({
                                              "phone":
                                                  phoneController.text.trim()
                                            }).whenComplete(() {
                                              phoneController.clear();
                                              getUserInfo();
                                              Navigator.pop(context);
                                            });
                                          },
                                          icon: const Icon(Icons.sim_card),
                                          label: const Text("Update"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                              },
                              context: context);
                        },
                        child: const Icon(Icons.sim_card),
                      ),
                      const Text("Phone Number"),
                      Text(
                        phone.toString().toUpperCase(),
                        textScaleFactor: 1.4,
                      ),
                    ],
                  ),
                  //divider
                  const Divider(
                    indent: 30,
                    endIndent: 30,
                    color: Colors.black12,
                    height: 20,
                  ),
                  //orders
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Icon(
                              Icons.trolley,
                            ),
                            Text("Orders"),
                          ],
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("orders")
                              .where("email",
                                  isEqualTo: _auth.currentUser!.email)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data!.size.toString(),
                                textScaleFactor: 1.5,
                              );
                            }
                            return const Text("0");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.small(
        tooltip: "Signout",
        backgroundColor: Colors.red,
        onPressed: () async {
          //logout
          await signOut().then((results) {
            if (results == "signOut") {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SigninScreen()));
            }
          });
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
