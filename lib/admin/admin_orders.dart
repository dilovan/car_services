import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            if (streamSnapshot.data!.size > 0) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.separated(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    // print(streamSnapshot.data!.docs[index].id);
                    return _OrderTile(documentSnapshot);
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    thickness: 1,
                    color: Colors.blue,
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.trolley,
                      size: 50,
                    ),
                    Text("No Orders"),
                  ],
                ),
              );
            }
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
    Timestamp time = item['timestamp'];
    DateTime date = DateTime.parse(time.toDate().toString());
    var d = DateFormat.yMMMd().add_jm().format(date);
    var isAccepted = item['accepted'] == "yes" ? true : false;
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer name",
                    textScaleFactor: 1,
                  ),
                  Text(
                    item['customer'],
                    textScaleFactor: 1.4,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Vehicle",
                    textScaleFactor: 1,
                  ),
                  Text(
                    item['vehicle'],
                    textScaleFactor: 1.4,
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Order Date",
                textScaleFactor: 1.1,
              ),
              Text(
                d.toString(),
                textScaleFactor: 1.1,
              ),
            ],
          ),
        ],
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
              ),
              Expanded(
                child: Text(
                  item['package'],
                  textAlign: TextAlign.end,
                  textScaleFactor: 1.4,
                  softWrap: true,
                ),
              ),
            ],
          ),
          //service info
          subtitle: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Accepted",
                    style: TextStyle(
                      color:
                          item['accepted'] == "no" ? Colors.red : Colors.blue,
                    ),
                    textScaleFactor: 1.8,
                  ),
                  InkWell(
                    onTap: () {
                      //toggle acception
                      var accept = item['accepted'] == "no" ? "yes" : "no";
                      FirebaseFirestore.instance
                          .collection("orders")
                          .doc(item.id)
                          .update({"accepted": accept});
                    },
                    child: Icon(
                      item['accepted'] == "no"
                          ? Icons.check_box_outline_blank
                          : Icons.check_box,
                      color:
                          item['accepted'] == "no" ? Colors.red : Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
      ],
    );
  }
}
