import 'package:car_services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    //get vehicles
    final CollectionReference _vehicles =
        FirebaseFirestore.instance.collection("vehicles");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Vehicle"),
      ),
      body:
          //list of vehicles
          //     ListView(
          //   children: List.generate(_vehicles.length, (index) {
          //     return InkWell(
          //       onTap: () {
          //         // print("Car:${streamSnapshot.data!.docs[index].id}");
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => ServicesScreen(
          //               carId: _vehicles[index]['id'],
          //               carImage: _vehicles[index]['image'],
          //               carName: _vehicles[index]['made'],
          //             ),
          //           ),
          //         );
          //       },
          //       child: Card(
          //         margin: const EdgeInsets.all(10),
          //         elevation: 1,
          //         child: Padding(
          //           padding: const EdgeInsets.all(10.0),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               Text(
          //                 _vehicles[index]['made'],
          //                 style: const TextStyle(fontSize: 30),
          //               ),
          //               Image.asset(
          //                 _vehicles[index]['image'],
          //                 width: 100,
          //                 height: 100,
          //                 fit: BoxFit.contain,
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     );
          //   }).toList(),
          // ),
          //list of vehicles
          StreamBuilder(
        stream: _vehicles.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData && streamSnapshot.data!.size > 0) {
            return ListView(
              children: List.generate(streamSnapshot.data!.size, (index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServicesScreen(
                          package: streamSnapshot.data!.docs[index],
                          carId: streamSnapshot.data!.docs[index].id,
                          carImage: documentSnapshot['features']['image'],
                          carName: documentSnapshot['features']['made'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            documentSnapshot['features']['made'],
                            style: const TextStyle(fontSize: 30),
                          ),
                          documentSnapshot['features']['image'] != null
                              ? Image.network(
                                  documentSnapshot['features']['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  "assets/images/logo4.png",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          } else {
            return const Center(
              child: Text("No data"),
            );
          }
        },
      ),
    );
  }
}
