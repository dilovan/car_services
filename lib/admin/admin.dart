import 'dart:ffi';

import 'package:car_services/admin/add_services.dart';
import 'package:car_services/admin/add_vehicles.dart';
import 'package:car_services/admin/admin_orders.dart';
import 'package:car_services/admin/admin_packages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../home.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  //numbers
  int orderNumber = 0;
  int vehicleNumber = 0;
  int serviceNumber = 0;
  bool isNumbersLoaded = false;
  Map lastOrder = {};

  Future<void> getInfo() async {
    await FirebaseFirestore.instance
        .collection("orders")
        .snapshots()
        .length
        .then((value) {
      setState(() {
        orderNumber = value;
        isNumbersLoaded = true;
      });
    });
  }

  //get last order function
  Future<QuerySnapshot<Map<String, dynamic>>> getLastOrder() async {
    return await FirebaseFirestore.instance
        .collection("orders")
        .snapshots()
        .last;
  }

  //get counters function
  Future<int> getCount(String collection) async {
    int count = await FirebaseFirestore.instance
        .collection(collection)
        .get()
        .then((value) => value.size);
    return count;
  }

  @override
  void initState() {
    //get orders
    getCount("orders").then((value) {
      setState(() {
        orderNumber = value;
      });
    });
    //get vehicles
    getCount("vehicles").then((value) {
      setState(() {
        vehicleNumber = value;
      });
    });
    //get services
    getCount("services").then((value) {
      setState(() {
        serviceNumber = value;
        isNumbersLoaded = true;
      });
    });

    //get last order
    getLastOrder().then((value) {
      print(value.docs.asMap());
      setState(() {
        lastOrder = value.docs.asMap();
        print(lastOrder);
      });
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
    //admin pages
    List<Map<String, dynamic>> sections = [
      {
        "icon": Icons.playlist_add_check_outlined,
        "name": "Packages",
      },
      {
        "icon": Icons.car_repair,
        "name": "Vehicles",
      },
      {
        "icon": Icons.add_task_outlined,
        "name": "Services",
      },
      {
        "icon": Icons.file_present_outlined,
        "name": "Orders",
      },
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text("Admin Page"),
          // backgroundColor: Colors.blue[200],
          leading: InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen())),
              child: const Icon(Icons.home)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //sections
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(sections.length, (index) {
                    //border radius for tabs bevel
                    BorderRadius br;

                    if (index == 0) {
                      br = const BorderRadius.only()
                          .copyWith(bottomRight: const Radius.circular(20));
                    } else if (index == 1) {
                      br = const BorderRadius.only()
                          .copyWith(bottomLeft: const Radius.circular(20));
                    } else if (index == 2) {
                      br = const BorderRadius.only()
                          .copyWith(topRight: const Radius.circular(20));
                    } else {
                      br = const BorderRadius.only()
                          .copyWith(topLeft: const Radius.circular(20));
                    }

                    return InkWell(
                      onTap: () {
                        if (sections[index]['name'] == "Services") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (contex) => const AddFeatures()),
                          );
                        } else if (sections[index]['name'] == "Vehicles") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (contex) => const AddVehicles()),
                          );
                        } else if (sections[index]['name'] == "Orders") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (contex) => const AdminOrders()),
                          );
                        } else if (sections[index]['name'] == "Packages") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (contex) => const AdminPackages()),
                          );
                        }
                      },
                      child: Card(
                        elevation: 1,
                        shape: const BeveledRectangleBorder().copyWith(
                          borderRadius: br,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              sections[index]['icon'],
                              size: 55,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              sections[index]['name'],
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              //numbers
              !isNumbersLoaded
                  ? Center()
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "Orders",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                orderNumber.toString(),
                                style:
                                    TextStyle(fontSize: 30, color: Colors.blue),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "Vehicles",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                vehicleNumber.toString(),
                                style:
                                    TextStyle(fontSize: 30, color: Colors.blue),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "Services",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                serviceNumber.toString(),
                                style:
                                    TextStyle(fontSize: 30, color: Colors.blue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              //last order
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.hasData) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[0];
                    // print(documentSnapshot['services']);
                    Timestamp time = documentSnapshot['timestamp'];
                    DateTime date = DateTime.parse(time.toDate().toString());
                    var d = DateFormat.yMMMd().add_jm().format(date);

                    Map<String, dynamic> services =
                        documentSnapshot['services'];
                    var total = 0.0;
                    Iterable v = services.values;
                    v.forEach(
                      (element) {
                        total += element;
                      },
                    );

                    Map s = documentSnapshot['services'] as Map;
                    int serviceCount = s.length;
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Card(
                        shape: const BeveledRectangleBorder().copyWith(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20)),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //card title
                              Container(
                                color: Colors.blue,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Last Order",
                                      style: TextStyle(color: Colors.white),
                                      textScaleFactor: 1.4,
                                      // style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      d.toString(),
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),

                              //from
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "From",
                                      textScaleFactor: 1.1,
                                    ),
                                    Text(
                                      documentSnapshot['customer'],
                                      textScaleFactor: 1.1,
                                    ),
                                  ],
                                ),
                              ),
                              //items
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Services"),
                                    Text(serviceCount.toString()),
                                  ],
                                ),
                              ),
                              //date for service
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Service Date"),
                                    Text(documentSnapshot['date']),
                                  ],
                                ),
                              ),
                              //service slote
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Time Slote"),
                                    Text(documentSnapshot['time']),
                                  ],
                                ),
                              ),
                              //service location
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Customer Location"),
                                    Text(documentSnapshot['address']),
                                  ],
                                ),
                              ),
                              //customer phone
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Customer Phone"),
                                    Text(documentSnapshot['phone']),
                                  ],
                                ),
                              ),
                              //accepting
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Accepted",
                                      style: TextStyle(
                                        color:
                                            documentSnapshot['accepted'] == "no"
                                                ? Colors.red
                                                : Colors.blue,
                                      ),
                                      textScaleFactor: 1.8,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        //toggle acception
                                        var accept =
                                            documentSnapshot['accepted'] == "no"
                                                ? "yes"
                                                : "no";
                                        FirebaseFirestore.instance
                                            .collection("orders")
                                            .doc(documentSnapshot.id)
                                            .update({"accepted": accept});
                                      },
                                      child: Icon(
                                        documentSnapshot['accepted'] == "no"
                                            ? Icons.check_box_outline_blank
                                            : Icons.check_box,
                                        color:
                                            documentSnapshot['accepted'] == "no"
                                                ? Colors.red
                                                : Colors.blue,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //breke line
                              Container(
                                margin: const EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width,
                                height: 1,
                                color: Colors.black12,
                              ),
                              //total price
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Price",
                                      textScaleFactor: 1.4,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                    Text(
                                      "${total.toString()}\$",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                      textScaleFactor: 1.4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              )
                            ]),
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ));
  }
}
