import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddFeatures extends StatefulWidget {
  const AddFeatures({super.key});

  @override
  State<AddFeatures> createState() => _AddFeaturesState();
}

class _AddFeaturesState extends State<AddFeatures> {
  //list of vehicles
  var vehicle;
  int selectedService = 0;
  TextEditingController serviceController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String icon = "";
  List<Map<String, dynamic>> icons = [];
  bool isIconsLoaded = false;
  void getServiceIcons() {
    FirebaseStorage.instance.ref().child("services").listAll().then((result) {
      for (var element in result.items) {
        element.getDownloadURL().then((image) {
          var name = element.name;
          var icon = image;
          var map = {
            "name": name,
            "icon": icon,
          };
          icons.add(map);
          setState(() {
            isIconsLoaded = true;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    serviceController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getServiceIcons();
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
    //get vehicles
    final CollectionReference _vehicles =
        FirebaseFirestore.instance.collection("vehicles");
    final CollectionReference _services =
        FirebaseFirestore.instance.collection("services");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adding Services"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  //service name
                  TextField(
                    controller: serviceController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.design_services_outlined,
                          size: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 228, 227, 227)),
                          // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        // hintStyle: const TextStyle(),
                        hintText: "Service Name",
                        // errorText: _errorEmail,
                        errorBorder: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 20),
                        contentPadding: EdgeInsets.all(5)),
                  ),
                  //spacer
                  const SizedBox(
                    height: 10,
                  ),
                  //service price
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.currency_exchange,
                          size: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 228, 227, 227)),
                          // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        // hintStyle: const TextStyle(),
                        hintText: "Service Price",
                        // errorText: _errorEmail,
                        errorBorder: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 20),
                        contentPadding: EdgeInsets.all(5)),
                  ),
                  //spacer
                  const SizedBox(
                    height: 20,
                  ),
                  //icons title
                  const Text(
                    "Select Service Icon",
                    style: TextStyle(fontSize: 16),
                  ),
                  //List of image of services
                  isIconsLoaded
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20,
                          child: ListView(
                            children: List.generate(icons.length, (index) {
                              var fileName = icons[index]['name'].split('.');
                              return ListTile(
                                selected:
                                    selectedService == index ? true : false,
                                selectedColor: Colors.blue,
                                leading: Image.network(
                                  icons[index]['icon'].toString(),
                                  width: 32,
                                  height: 32,
                                ),
                                title: Text(fileName[0]),
                                onTap: () {
                                  icon = icons[index]['icon'];
                                  setState(() {
                                    selectedService = index;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20,
                          child: Center(
                            child: Container(
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                        ),
                  //spacer
                  const SizedBox(
                    height: 20,
                  ),
                  //vehicles title
                  const Text(
                    "Select Vehicle",
                    style: TextStyle(fontSize: 16),
                  ),
                  //spacer
                  const SizedBox(
                    height: 20,
                  ),
                  //List of vehicles
                  StreamBuilder(
                      stream: _vehicles.snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: List.generate(streamSnapshot.data!.size,
                                (index) {
                              var documentSnapshot =
                                  streamSnapshot.data!.docs[index]['features'];
                              var id = streamSnapshot.data!.docs[index].id;
                              return RadioListTile(
                                title: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        documentSnapshot['image'],
                                        width: 50,
                                        height: 50,
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          width: 20,
                                        ),
                                      ),
                                      Text(documentSnapshot['made']),
                                    ],
                                  ),
                                ),
                                value: id,
                                groupValue: vehicle,
                                onChanged: (value) {
                                  setState(() {
                                    vehicle = id;
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }
                        return const Text("no data");
                      }),
                  //spacer
                  const SizedBox(
                    height: 100,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (serviceController.text.isEmpty ||
              priceController.text.isEmpty ||
              vehicle.toString() == "") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.blue,
                content: const Text(
                  'Please,Fill required fiels',
                  textScaleFactor: 1.4,
                  style: TextStyle(color: Colors.white),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else {
            var newService = {
              "id": vehicle,
              "name": serviceController.text.trim(),
              "price": priceController.text.trim(),
              "icon": icon,
            };
            _services.doc().set(newService).then((value) {
              serviceController.clear();
              priceController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.blue,
                  content: const Text(
                    'Service has been added',
                    textScaleFactor: 1.4,
                    style: TextStyle(color: Colors.white),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            });
          }
        },
        child: const Icon(
          Icons.post_add_rounded,
        ),
      ),
    );
  }
}
