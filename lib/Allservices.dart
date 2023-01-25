import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllservicesScreen extends StatefulWidget {
  const AllservicesScreen({super.key});

  @override
  State<AllservicesScreen> createState() => _AllservicesScreenState();
}

class _AllservicesScreenState extends State<AllservicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Services"),
      ),
      body: //list of services
          SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              // all services
              StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection("services").snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      List.generate(streamSnapshot.data!.docs.length, (index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    return InkWell(
                      onTap: () {
                        var c =
                            streamSnapshot.data!.docs[index]['id']; //vehicle id
                        showBottomSheet(
                          enableDrag: false,
                          shape: BeveledRectangleBorder(),
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.85,
                              child: Column(
                                children: [
                                  //title
                                  Container(
                                    padding: const EdgeInsets.all(20.0),
                                    color: Colors.blue,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Service information",
                                          style: TextStyle(color: Colors.white),
                                          textScaleFactor: 1.4,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //service detail
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("vehicles")
                                        .doc(c)
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      if (snapshot.hasData) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Image.network(
                                                  snapshot.data['features']
                                                      ['image'],
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                ),
                                              ),
                                              //made
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  //made
                                                  Column(
                                                    children: [
                                                      Text("made"),
                                                      Text(
                                                        snapshot.data[
                                                            'features']['made'],
                                                        textScaleFactor: 1.4,
                                                      ),
                                                    ],
                                                  ),
                                                  //model
                                                  Column(
                                                    children: [
                                                      Text("Model"),
                                                      Text(
                                                        snapshot.data[
                                                                'features']
                                                            ['model'],
                                                        textScaleFactor: 1.4,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                  //service details
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      "${documentSnapshot['name']}",
                                      textScaleFactor: 1.4,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Image.network(
                                          documentSnapshot['icon'],
                                          width: 32,
                                          height: 32,
                                        ),
                                        Text(
                                          "${documentSnapshot['price']}\$",
                                          textScaleFactor: 1.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Card(
                        elevation: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.network(
                                    documentSnapshot['icon'],
                                    width: 32,
                                    height: 32,
                                  ),
                                  Text("${documentSnapshot['price']}\$"),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  "${documentSnapshot['name']}",
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
