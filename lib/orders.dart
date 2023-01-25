import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  String uid = "";
  getOrders() {
    uid = FirebaseAuth.instance.currentUser!.uid.toString();
  }

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
    getOrders();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where('id', isEqualTo: uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.separated(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  // return _OrderTile(orders[index]);
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return _OrderTile(documentSnapshot);
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _OrderTile(item) {
    Map<String, dynamic> services = item['services'];
    var total = 0.0;
    Iterable v = services.values;
    v.forEach(
      (element) {
        total += element;
      },
    );
    return ExpansionTile(
      title: Text(
        item['vehicle'],
        textScaleFactor: 1.4,
      ),
      children: [
        ListTile(
          //package type
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "package",
                textScaleFactor: 1.4,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  item['package'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                  textScaleFactor: 1.4,
                  softWrap: true,
                ),
              ),
            ],
          ),
          //service info
          subtitle: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['date'],
                      textScaleFactor: 1.4,
                    ),
                    Text(
                      item['time'],
                      textScaleFactor: 1.4,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "package",
                      textScaleFactor: 1.4,
                    ),
                    Text(
                      item['package'],
                      textScaleFactor: 1.4,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Accepted",
                      textScaleFactor: 1.4,
                    ),
                    Text(
                      item['accepted'].toString().toUpperCase(),
                      textScaleFactor: 1.4,
                      style: TextStyle(
                          color: item['accepted'] == "no"
                              ? Colors.red
                              : Colors.blue),
                    ),
                  ],
                ),
                //service title
                const SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Services",
                        textScaleFactor: 1.4,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        services.length.toString(),
                        textScaleFactor: 1.4,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      )
                    ],
                  ),
                ),
                //services
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: services.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                              e.key,
                              textScaleFactor: 1.4,
                              softWrap: true,
                              textAlign: TextAlign.justify,
                            )),
                            Text(
                              "${e.value.toString()}\$",
                              textScaleFactor: 1.4,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList()),

                const SizedBox(
                  height: 10,
                ),
                //total
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        textScaleFactor: 1.4,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        "${total.toString()}\$",
                        textScaleFactor: 1.4,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
