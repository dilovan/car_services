import 'package:car_services/pickup_date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesDetailsScreen extends StatefulWidget {
  const ServicesDetailsScreen({
    super.key,
    required this.serviceID,
    required this.carId,
    required this.carImage,
    required this.carName,
    required this.index,
    required this.service,
  });
  final String serviceID, carId, carImage, carName;
  final int index;
  final dynamic service;
  @override
  State<ServicesDetailsScreen> createState() => _ServicesDetailsScreenState();
}

class _ServicesDetailsScreenState extends State<ServicesDetailsScreen> {
  Map<String, dynamic> features = {};
  Map<String, dynamic> servicez = {};
  @override
  void initState() {
    features = widget.service['features'] as Map<String, dynamic>;
    servicez = widget.service['services'] as Map<String, dynamic>;
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
    var total = 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.carName),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //image
              Center(
                child: Hero(
                  tag: "Hero_${widget.carId}_${widget.index}",
                  child: Image.network(
                    widget.carImage,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              //title
              Text(
                widget.service['title'],
                textScaleFactor: 1.4,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              //spacer
              const SizedBox(
                height: 5,
              ),
              //service description
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.car_crash_outlined,
                            color: Colors.blue,
                          ),
                          Text(
                            features['period'],
                            textScaleFactor: 1.4,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.gas_meter_rounded,
                            color: Colors.blue,
                          ),
                          Text(
                            features['takes'],
                            textScaleFactor: 1.4,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.blue,
                          ),
                          Text(
                            features['warranty'],
                            textScaleFactor: 1.4,
                          ),
                        ],
                      ),
                    ]),
              ),
              //spacer
              const SizedBox(
                height: 20,
              ),
              //service counter
              Text(
                "Include ${servicez.length.toString()} Services",
                textScaleFactor: 1.4,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              //services included
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: servicez.entries.map((element) {
                    total += element.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  var required = 50 -
                                      double.parse(element.value.toString());
                                  if (total < required) {
                                    print(
                                        "You can't delete ${element.key} service.Because at least total ptice is 50 USD");
                                  } else {
                                    setState(() {
                                      servicez.remove(element.key);
                                    });
                                    // print("${element.key} has been removed");
                                  }
                                },
                                child: const Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.blue,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  element.key,
                                  textScaleFactor: 1.4,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${element.value.toString()} \$",
                          textScaleFactor: 1.4,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              //spacer
              const SizedBox(
                height: 30,
              ),
              //customer reviews title
              const Text(
                "Customer reviews",
                textScaleFactor: 1.4,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              //customer reviews
              SizedBox(
                height: 120,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("reviews")
                      .where("id", isEqualTo: widget.carId)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData &&
                        streamSnapshot.data!.size > 0) {
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                          streamSnapshot.data!.size,
                          (index) {
                            final DocumentSnapshot reviews =
                                streamSnapshot.data!.docs[index];
                            int start = reviews['rate'];

                            return Card(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.50,
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          reviews['name'],
                                          textScaleFactor: 1.4,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children:
                                              List<Widget>.generate(5, (iii) {
                                            return Icon(
                                              Icons.star,
                                              size: 20,
                                              color: start >= iii + 1
                                                  ? Colors.yellow
                                                  : Colors.grey,
                                            );
                                          }, growable: true),
                                        ),
                                      ],
                                    ),
                                    Text(reviews['message'])
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text("No Reviews,Yet"),
                      );
                    }
                  },
                ),
              ),
              //spacer
              const SizedBox(
                height: 10,
              ),
              //total price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    textScaleFactor: 1.4,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("$total \$",
                      textScaleFactor: 1.4,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              //spacer
              const SizedBox(
                height: 10,
              ),
              //add service or next step
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //other service button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        //other service list
                        showModalBottomSheet(
                            isDismissible: false,
                            context: context,
                            builder: (context) {
                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //title
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Choose Services",
                                            textScaleFactor: 1.5,
                                          ),
                                          //close button
                                          InkWell(
                                            onTap: () => Navigator.pop(context),
                                            child: const Icon(Icons.close),
                                          )
                                        ],
                                      ),
                                      //spacer
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      widget.carId != null
                                          ?
                                          //list of services
                                          StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection("services")
                                                  .where('id',
                                                      isEqualTo: widget
                                                          .serviceID
                                                          .toString())
                                                  .snapshots(),
                                              builder: (context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      streamSnapshot) {
                                                if (streamSnapshot.hasData) {
                                                  return Column(
                                                    children: List.generate(
                                                        streamSnapshot.data!
                                                            .size, (index) {
                                                      final DocumentSnapshot
                                                          documentSnapshot =
                                                          streamSnapshot.data!
                                                              .docs[index];

                                                      return ListTile(
                                                        //service name
                                                        subtitle: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                  "${documentSnapshot["name"]}"),
                                                            ),
                                                            Text(
                                                              "${documentSnapshot['price']}\$",
                                                              softWrap: true,
                                                            ),
                                                          ],
                                                        ),
                                                        //service icon
                                                        leading: Image.network(
                                                          documentSnapshot[
                                                              "icon"],
                                                          width: 32,
                                                          height: 32,
                                                        ),
                                                        //add service button
                                                        trailing: InkWell(
                                                          onTap: () {
                                                            //add sevices to list
                                                            servicez.putIfAbsent(
                                                                documentSnapshot[
                                                                    "name"],
                                                                () => int.parse(
                                                                    documentSnapshot[
                                                                        "price"]));
                                                            setState(() {});
                                                          },
                                                          child: const Icon(
                                                            Icons
                                                                .add_box_rounded,
                                                            color: Colors.blue,
                                                            size: 40,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  );
                                                }
                                                return const Text("no Data");
                                              },
                                            )
                                          : const Text("Select Vehicle"),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Add Service",
                        textScaleFactor: 1.4,
                      ),
                    ),
                  ),
                  //pick up date and time slote button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(15),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PickUpDateTime(
                                    id: widget.carId,
                                    vehicle: widget.carName,
                                    services: servicez,
                                    title: widget.service['title'],
                                  )),
                        );
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text(
                        "Pick-up",
                        textScaleFactor: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              //spacer
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
