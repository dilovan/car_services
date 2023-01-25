import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AdminPackages extends StatefulWidget {
  const AdminPackages({super.key});

  @override
  State<AdminPackages> createState() => _AdminPackagesState();
}

class _AdminPackagesState extends State<AdminPackages> {
  //is Adding to firebase
  bool isAdding = false;
  var vehicle;
  var servicesList = {
    "services": {},
  };
  //get vehicles
  final CollectionReference _vehicles =
      FirebaseFirestore.instance.collection("vehicles");
  TextEditingController packageController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController takesController = TextEditingController();
  TextEditingController warrantyController = TextEditingController();

  @override
  void dispose() {
    packageController.dispose();
    periodController.dispose();
    takesController.dispose();
    warrantyController.dispose();
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
        title: const Text("Add Packages"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "Select Vehicle",
                textScaleFactor: 1.4,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              color: Colors.black12,
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder(
                stream: _vehicles.snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children:
                          List.generate(streamSnapshot.data!.size, (index) {
                        var documentSnapshot =
                            streamSnapshot.data!.docs[index]['features'];
                        var id = streamSnapshot.data!.docs[index].id;
                        return RadioListTile(
                          title: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.network(
                                  documentSnapshot['image'],
                                  width: 50,
                                  height: 50,
                                ),
                                Text(documentSnapshot['made']),
                              ],
                            ),
                          ),
                          value: id,
                          groupValue: vehicle,
                          onChanged: (value) {
                            setState(() {
                              vehicle = value;
                            });
                          },
                        );
                      }).toList(),
                    );
                  }
                  return const Text("no data");
                },
              ),
            ),
            //package features
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Package",
                    textScaleFactor: 1.4,
                  ),
                  //spacer
                  const SizedBox(
                    height: 10,
                  ),
                  //package name
                  TextField(
                    controller: packageController,
                    readOnly: isAdding,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.playlist_add_check,
                          size: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 228, 227, 227)),
                        ),
                        hintText: "Package Name",
                        errorBorder: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 20),
                        contentPadding: EdgeInsets.all(5)),
                  ),
                  //spacer
                  const SizedBox(
                    height: 10,
                  ),
                  //Period
                  TextField(
                    controller: periodController,
                    readOnly: isAdding,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 228, 227, 227)),
                        ),
                        hintText: "Period",
                        errorBorder: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 20),
                        contentPadding: EdgeInsets.all(5)),
                  ),
                  //spacer
                  const SizedBox(
                    height: 10,
                  ),
                  //Takes
                  TextField(
                    controller: takesController,
                    readOnly: isAdding,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.watch_later_rounded,
                          size: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 228, 227, 227)),
                        ),
                        hintText: "Takes",
                        errorBorder: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 20),
                        contentPadding: EdgeInsets.all(5)),
                  ),
                  //spacer
                  const SizedBox(
                    height: 10,
                  ),
                  //Warranty
                  TextField(
                    controller: warrantyController,
                    readOnly: isAdding,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.shield_moon,
                          size: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 228, 227, 227)),
                        ),
                        hintText: "Warranty",
                        errorBorder: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 20),
                        contentPadding: EdgeInsets.all(5)),
                  ),
                  //spacer
                  const SizedBox(
                    height: 10,
                  ),
                  //add services
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Package Services",
                        textScaleFactor: 1.4,
                      ),
                      ElevatedButton.icon(
                        onPressed: isAdding
                            ? () {}
                            : () {
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    "Choose Services",
                                                    textScaleFactor: 1.5,
                                                  ),
                                                  //close button
                                                  InkWell(
                                                    onTap: () =>
                                                        Navigator.pop(context),
                                                    child:
                                                        const Icon(Icons.close),
                                                  )
                                                ],
                                              ),
                                              //spacer
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              vehicle != null
                                                  ?
                                                  //list of services
                                                  StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "services")
                                                          .where('id',
                                                              isEqualTo: vehicle
                                                                  .toString())
                                                          .snapshots(),
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              streamSnapshot) {
                                                        if (streamSnapshot
                                                            .hasData) {
                                                          return Column(
                                                            children:
                                                                List.generate(
                                                                    streamSnapshot
                                                                        .data!
                                                                        .size,
                                                                    (index) {
                                                              final DocumentSnapshot
                                                                  documentSnapshot =
                                                                  streamSnapshot
                                                                          .data!
                                                                          .docs[
                                                                      index];

                                                              return ListTile(
                                                                title: Text(
                                                                    documentSnapshot[
                                                                        "name"]),
                                                                leading: Image
                                                                    .network(
                                                                  documentSnapshot[
                                                                      "icon"],
                                                                  width: 32,
                                                                  height: 32,
                                                                ),
                                                                trailing:
                                                                    InkWell(
                                                                  onTap: () {
                                                                    //add sevices to list
                                                                    servicesList['services']?.putIfAbsent(
                                                                        documentSnapshot[
                                                                            "name"],
                                                                        () => int.parse(
                                                                            documentSnapshot["price"]));
                                                                    setState(
                                                                        () {
                                                                      print(
                                                                          "servies added");
                                                                    });
                                                                  },
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .add_box_rounded,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: 40,
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          );
                                                        }
                                                        return const Text(
                                                            "no Data");
                                                      },
                                                    )
                                                  : const Text(
                                                      "Select Vehicle"),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                        icon: const Icon(Icons.add_task_outlined),
                        label: const Text("Add Service"),
                      ),
                    ],
                  ),
                  //services list
                  servicesList['services'] != null
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                servicesList['services']!.entries.map((e) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      e.key,
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text("${e.value}\$"),
                                      InkWell(
                                        onTap: () {
                                          //remove from list
                                          servicesList['services']!
                                              .remove(e.key);
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          Icons.delete_forever,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(30),
                          child: const Text(
                            "No Services Added",
                            textScaleFactor: 1.1,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          setState(() {
            isAdding = true;
          });
          //add package to firebase

          FirebaseFirestore.instance.collection("packages").doc().set({
            "id": vehicle,
            "title": packageController.text.trim(),
            "features": {
              "period": periodController.text.trim(),
              "takes": takesController.text.trim(),
              "warranty": warrantyController.text.trim(),
            },
            "services": servicesList['services'],
          }).whenComplete(() {
            setState(() {
              isAdding = false;
              packageController.clear();
              takesController.clear();
              periodController.clear();
              warrantyController.clear();
              // servicesList.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Service Package has been added"),
                ),
              );
            });
          }).onError((error, stackTrace) {
            setState(() {
              isAdding = false;
            });
          });
          //
        },
        child: isAdding
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Icon(Icons.add),
      ),
    );
  }
}
