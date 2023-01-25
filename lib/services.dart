import 'package:car_services/services_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen(
      {super.key,
      required this.carId,
      required this.carImage,
      required this.carName,
      required this.package});
  final String carId, carImage, carName;
  final dynamic package;
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
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
    var packages = FirebaseFirestore.instance
        .collection("packages")
        .where("id", isEqualTo: widget.carId)
        // .orderBy("title", descending: false)
        .snapshots();
    var total = 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.carName),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: packages,
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData && streamSnapshot.data!.size > 0) {
              //make list of packages
              return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: List.generate(streamSnapshot.data!.size, (index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    //list of features
                    Map<String, dynamic> _features =
                        streamSnapshot.data!.docs[index]['features'];
                    //list of services
                    Map<String, dynamic> _services =
                        streamSnapshot.data!.docs[index]['services'];
                    //count total price
                    total = 0.0;
                    _services.values.forEach(
                      (element) {
                        total += element;
                      },
                    );
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Service title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "${documentSnapshot['title']}".toUpperCase(),
                                  textScaleFactor: 1.4,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Hero(
                                tag: "Hero_${widget.carId}_$index",
                                child: Image.network(
                                  widget.carImage,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                          //spacer
                          const SizedBox(
                            height: 5,
                          ),
                          //features
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _features.entries.map((e) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_box,
                                      color: Colors.blue,
                                    ),
                                    Text(
                                      e.value.toString(),
                                      textScaleFactor: 1.4,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          //services included
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_box,
                                  color: Colors.blue,
                                ),
                                Text(
                                  "Include ${_services.length} Services",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textScaleFactor: 1.4,
                                ),
                              ],
                            ),
                          ),
                          //prices
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Price",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textScaleFactor: 1.4,
                                ),
                                Text(
                                  "$total\$",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textScaleFactor: 1.4,
                                ),
                              ],
                            ),
                          ),

                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ElevatedButton.icon(
                                  onPressed: () {
                                    //
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ServicesDetailsScreen(
                                                  serviceID: widget.carId,
                                                  carId: documentSnapshot.id,
                                                  carImage: widget.carImage,
                                                  carName: widget.carName,
                                                  index: index,
                                                  service: documentSnapshot,
                                                )));
                                  },
                                  icon: const Icon(Icons.details),
                                  label: const Text("Service Details")),
                            ),
                          ),
                          const Divider()
                        ],
                      ),
                    );
                  }).toList());
            }
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.list_alt),
                  Text(
                    "No Service package ",
                    textScaleFactor: 1.4,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
