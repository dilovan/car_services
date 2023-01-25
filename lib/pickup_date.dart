import 'dart:async';
import 'package:car_services/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//payment metods enum for selected method
enum Payment { None, PayPall, GooglePay, Creadit, PayAffter }

class PickUpDateTime extends StatefulWidget {
  const PickUpDateTime({
    super.key,
    required this.id,
    required this.services,
    required this.vehicle,
    required this.title,
  });
  final String vehicle;
  final String title;
  final String id;
  final Map<String, dynamic> services;

  @override
  State<PickUpDateTime> createState() => _PickUpDateTimeState();
}

class _PickUpDateTimeState extends State<PickUpDateTime> {
  //get user info and store in variables
  bool isLoaded = false;
  String? uid, name, phone, address;
  //firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _firestore =
      FirebaseFirestore.instance.collection("users");
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

  //slotes of date to book
  Map<String, dynamic> slotes = {
    "08:00-08:30": true, //false = not available for booking
    "08:30-09:00": true,
    "09:00-09:30": true,
    "09:30-10:00": true,
    "10:00-10:30": true,
    "10:30-11:00": true,
    "11:00-11:30": true,
    "11:30-12:00": true,
    "12:00-12:30": true,
    "12:30-01:00": true,
    "13:00-13:30": true,
    "13:30-14:00": true,
  };
  //payment proccess
  bool isPaying = false;
  bool isCompleted = false;
  double total = 0.0;
  var payment;
  //selected date
  String selectedDate = "";
  int selectedDateDay = 0;
  //last selected
  String lasteSelected = "";
  //selected slote
  String selectedSlote = "";
  //date and time for date and time selection
  var today = DateTime.now();
//google map
  TextEditingController addressController = TextEditingController();
  //review form
  int starsSelected = 0;
  TextEditingController commentCOntroller = TextEditingController();
  bool isReviewd = false;
  @override
  void initState() {
    //get user info
    getUserInfo();
    payment = Payment.None;
    Iterable v = widget.services.values;
    v.forEach((element) {
      total += element!!;
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
    const Map<int, String> weekdayName = {
      1: "Mon",
      2: "Tue",
      3: "Wed",
      4: "Thu",
      5: "Fri",
      6: "Sat",
      7: "Sun"
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isCompleted
          ? AppBar(
              title: const Text("Order paced"),
              leading: InkWell(
                  onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen())),
                  child: const Icon(Icons.arrow_back_ios_new)),
            )
          : AppBar(
              title: const Text("Pick Up date and time slote"),
            ),
      body: isPaying
          ? isCompleted
              ? SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/orderd.png",
                        ),
                        const Text(
                          "Order was placed successfully",
                          // textScaleFactor: 1.4,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "We've recived your order and our team working to get it to you as quick and soon as possible",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        isReviewd //if review completed submit
                            ? Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //stars
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          Icons.star,
                                          // size: 30,
                                          color: starsSelected >= i
                                              ? Colors.yellow
                                              : Colors.grey,
                                        );
                                      }),
                                    ),
                                    //comment
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.comment,
                                        ),
                                        Expanded(
                                            child:
                                                Text(commentCOntroller.text)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Thank you for your review!",
                                      textScaleFactor: 1.6,
                                    )
                                  ],
                                ),
                              )
                            //add review
                            : Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    //stars
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Rate",
                                          textScaleFactor: 1.4,
                                        ),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  starsSelected = index;
                                                });
                                              },
                                              child: Icon(
                                                Icons.star,
                                                color: starsSelected >= index
                                                    ? Colors.yellow
                                                    : Colors.grey,
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextField(
                                      controller: commentCOntroller,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                      decoration: const InputDecoration(
                                          prefixIconColor: Colors.grey,
                                          prefixIcon: Icon(
                                            Icons.comment,
                                            size: 30,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0)),
                                          ),
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          hintText: "Enter your comment here",
                                          contentPadding: EdgeInsets.all(20)),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    //submit button
                                    ElevatedButton(
                                      onPressed: () {
                                        if (commentCOntroller.text.isNotEmpty) {
                                          //submit
                                          var revObj = {
                                            "id": widget.id,
                                            "name": name,
                                            "package": widget.title,
                                            "message":
                                                commentCOntroller.text.trim(),
                                            "rate": starsSelected,
                                          };
                                          FirebaseFirestore.instance
                                              .collection("reviews")
                                              .doc()
                                              .set(revObj)
                                              .whenComplete(() {
                                            setState(() {
                                              isReviewd = true;
                                            });
                                          });
                                        }
                                      },
                                      child: const Text("Submit"),
                                    ),
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Proccessing",
                        textScaleFactor: 1.4,
                      ),
                    ],
                  ),
                )
          : SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //address title
                    const Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        "Pick-up Address",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textScaleFactor: 1.4,
                      ),
                    ),
                    //address
                    Container(
                      color: Colors.black12,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          isLoaded
                              ? Container(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        child: const Card(
                                          shape: BeveledRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                          child: Icon(
                                            Icons.location_on,
                                            size: 50,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      address != null
                                          ? Text(
                                              address!,
                                              textScaleFactor: 1.4,
                                            )
                                          : const Text(
                                              "No address",
                                              textScaleFactor: 1.4,
                                            ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    isDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            //close button sheet
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  icon: const Icon(Icons.close),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Colors.white),
                                              child: TextField(
                                                controller: addressController,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter Address',
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 15.0,
                                                          top: 15.0),
                                                  suffixIcon: IconButton(
                                                    icon: const Icon(Icons
                                                        .location_history_rounded),
                                                    onPressed: () async {
                                                      _firestore
                                                          .doc(_auth
                                                              .currentUser!.uid)
                                                          .update({
                                                        "address":
                                                            addressController
                                                                .text
                                                                .trim()
                                                                .toString()
                                                      }).whenComplete(() {
                                                        Navigator.pop(context);
                                                        //address
                                                        setState(() {
                                                          address =
                                                              addressController
                                                                  .text;
                                                        });
                                                      });
                                                    },
                                                    iconSize: 30.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  child: const Card(
                                    shape: BeveledRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Icon(
                                      Icons.edit_location_alt,
                                      size: 50,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                "Edit Location",
                                textScaleFactor: 1.4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //title
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "When do you want the service?",
                        textScaleFactor: 1.4,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    //date title
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Select Date",
                        textScaleFactor: 1.2,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    //pick-up date
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 120,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                                List.generate(weekdayName.length, (index) {
                              return Container(
                                height: 120,
                                width: 100,
                                margin: const EdgeInsets.all(5),
                                child: InkWell(
                                  onTap: () {
                                    selectedSlote = "";
                                    selectedDate = (DateTime.now()
                                            .add(Duration(days: index)))
                                        .toString();
                                    selectedDateDay = (DateTime.now()
                                        .add(Duration(days: index))
                                        .day);
                                    var nDate =
                                        selectedDate.split(' ')[0].trim();
                                    FirebaseFirestore.instance
                                        .collection("slotes")
                                        .doc(nDate)
                                        .snapshots()
                                        .forEach((element) {
                                      if (element.exists) {
                                        var s = element.data();
                                        //check if slote date exist in within document date
                                        var isNull =
                                            s!['slotes'] == null ? true : false;
                                        if (s.isNotEmpty) {
                                          if (!isNull) {
                                            //get list of available slotes
                                            var slo = s['slotes'] as List;
                                            //update local map set all available first
                                            slotes.updateAll(
                                                (key, value) => value = true);
                                            //then set slotes available to false for local map
                                            slo.forEach((sl) {
                                              slotes.update(
                                                  sl, (value) => value = false);
                                            });
                                          } else {
                                            //if not exist set all slotes available
                                            slotes.updateAll(
                                                (key, value) => value = false);
                                          }
                                          setState(() {});
                                        } else {
                                          //set date an update all slotes to available true=available
                                          slotes.updateAll(
                                              (key, value) => value = true);
                                          setState(() {});
                                        }
                                      } else {
                                        //update all slotes to available = true
                                        var s = {"slotes": []};
                                        FirebaseFirestore.instance
                                            .collection("slotes")
                                            .doc(nDate)
                                            .set(s);
                                        slotes.entries.map(
                                          (e) {
                                            slotes.updateAll(
                                                (key, value) => value = true);
                                          },
                                        );
                                        setState(() {});
                                      }
                                    });
                                    // setState(() {});
                                  },
                                  child: Card(
                                    color: selectedDateDay ==
                                            DateTime.now()
                                                .add(Duration(days: index))
                                                .day
                                        ? Colors.blue
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          weekdayName[DateTime.now()
                                                  .add(Duration(days: index))
                                                  .weekday]
                                              .toString(),
                                          style: TextStyle(
                                              color: selectedDateDay ==
                                                      DateTime.now()
                                                          .add(Duration(
                                                              days: index))
                                                          .day
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 18),
                                          textScaleFactor: 1.4,
                                        ),
                                        Text(
                                          (DateTime.now()
                                                  .add(Duration(days: index))
                                                  .day)
                                              .toString(),
                                          textScaleFactor: 1.4,
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: selectedDateDay ==
                                                    DateTime.now()
                                                        .add(Duration(
                                                            days: index))
                                                        .day
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })),
                      ),
                    ),
                    //time slote
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Select Pick-Up time slote",
                        textScaleFactor: 1.2,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    //slotes
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 80,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: slotes.entries.map((element) {
                            return element.value
                                ? InkWell(
                                    onTap: element.value
                                        ? () {
                                            // if (lasteSelected.isNotEmpty) {
                                            lasteSelected = element.key;
                                            selectedSlote = element.key;
                                            slotes.update(lasteSelected,
                                                (value) => value = true);
                                            // } else {
                                            //   selectedSlote = element.key;
                                            //   lasteSelected = element.key;
                                            //   slotes.update(selectedSlote,
                                            //       (value) => value = false);
                                            // }
                                            setState(() {});
                                          }
                                        : () {},
                                    child: Card(
                                      color: lasteSelected != element.key
                                          ? Colors.white
                                          : Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Colors.blue,
                                          width: 1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      margin: const EdgeInsets.all(10),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            element.key.toString(),
                                            style: TextStyle(
                                              color:
                                                  lasteSelected != element.key
                                                      ? Colors.black
                                                      : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      border: Border.all(color: Colors.blue),
                                    ),
                                    child: Text(element.key));
                          }).toList(),
                        ),
                      ),
                    ),
                    //Payment title
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Pay using:",
                        textScaleFactor: 1.2,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    //Payment mwthods
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          RadioListTile(
                            value: Payment.GooglePay,
                            groupValue: payment,
                            title: const Text("Google Pay"),
                            subtitle: const Text("Pay via google ply"),
                            secondary: const Icon(
                              Icons.payment_outlined,
                              color: Colors.blue,
                            ),
                            onChanged: (value) {
                              setState(() {
                                payment = value;
                              });
                            },
                          ),
                          RadioListTile(
                            value: Payment.PayPall,
                            groupValue: payment,
                            title: const Text("Pay pal"),
                            subtitle: const Text("Pay via Paypal"),
                            secondary: const Icon(
                              Icons.paypal,
                              color: Colors.blue,
                            ),
                            onChanged: (value) {
                              setState(() {
                                payment = value;
                              });
                            },
                          ),
                          RadioListTile(
                            value: Payment.Creadit,
                            groupValue: payment,
                            title: const Text("Debit/Credit Cards"),
                            subtitle:
                                const Text("Pay via Debit / Creadit cards"),
                            secondary: const Icon(
                              Icons.credit_score,
                              color: Colors.blue,
                            ),
                            onChanged: (value) {
                              setState(() {
                                payment = value;
                              });
                            },
                          ),
                          RadioListTile(
                            value: Payment.PayAffter,
                            groupValue: payment,
                            title: const Text("Pay Affter"),
                            subtitle:
                                const Text("Pay Affrer Services completed"),
                            secondary: const Icon(
                              Icons.wallet_rounded,
                              color: Colors.blue,
                            ),
                            onChanged: (value) {
                              setState(() {
                                payment = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    //Payment action
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //total price
                          Container(
                            color: Colors.green,
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "$total\$",
                              textScaleFactor: 1.2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                          //pay button
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.all(20),
                              ),
                              onPressed: () {
                                var msg = "";
                                if (Payment.None == payment) {
                                  msg = "Please,Select payment";
                                } else if (address!.isEmpty) {
                                  msg = "Address is not picked up!";
                                } else if (selectedSlote.isEmpty) {
                                  msg = "Please,Select slote";
                                } else {
                                  var nDate = selectedDate.split(' ')[0];
                                  //create order object
                                  var order = {
                                    "id": uid,
                                    "customer": name,
                                    "address": address,
                                    "phone": phone!,
                                    "date": nDate,
                                    "time": selectedSlote,
                                    "accepted": "no",
                                    "email": _auth.currentUser!.email,
                                    "payment": payment.toString(),
                                    "vehicle": widget.vehicle,
                                    "package": widget.title,
                                    'timestamp': Timestamp.now(),
                                    "services": widget.services,
                                  };
                                  //make order to firebase
                                  FirebaseFirestore.instance
                                      .collection("orders")
                                      .doc()
                                      .set(order)
                                      .whenComplete(() {
                                    FirebaseFirestore.instance
                                        .collection("slotes")
                                        .doc(nDate)
                                        .update(
                                      {
                                        'slotes': FieldValue.arrayUnion(
                                            [selectedSlote])
                                      },
                                    );
                                  }).then((value) {
                                    setState(() {
                                      isPaying = true;
                                    });
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      setState(() {
                                        isCompleted = true;
                                      });
                                    });
                                  });

                                  //end add
                                }
                              },
                              icon: const Icon(Icons.payment),
                              label: const Text(
                                "Pay",
                                textScaleFactor: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //spacer
                    const SizedBox(
                      height: 50,
                    ),
                  ]),
            ),
    );
  }
}
