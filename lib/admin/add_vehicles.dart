import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class AddVehicles extends StatefulWidget {
  const AddVehicles({super.key});

  @override
  State<AddVehicles> createState() => _AddVehiclesState();
}

class _AddVehiclesState extends State<AddVehicles> {
  //firebase storage instance
  FirebaseStorage storage = FirebaseStorage.instance;
  //firebase firestore instance
  final CollectionReference _vehicles =
      FirebaseFirestore.instance.collection("vehicles");
  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _upload(String inputSource) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        await storage
            .ref('vehicles')
            .child(fileName)
            .putFile(
                imageFile,
                SettableMetadata(customMetadata: {
                  'uploaded_by': made.text.trim(),
                  'description': model.text.trim()
                }))
            .then((snap) {
          //get image url
          snap.ref.getDownloadURL().then((image) {
            //make map to add
            var map = {
              "features": {
                "image": image,
                "made": made.text.trim(),
                "model": model.text.trim(),
              }
            };
            //add car to vehicle collection in firestore
            _vehicles.doc().set(map).then((done) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Vehicle has been added"),
                ),
              );
            });
          });
        });

        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  // Retriev the uploaded images
  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref('vehicles').list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description'
      });
    });
    return files;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  TextEditingController made = TextEditingController();
  TextEditingController model = TextEditingController();

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
        title: const Text("Add Vehicles"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: StreamBuilder(
          stream: _vehicles.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData && streamSnapshot.data!.size > 0) {
              return ListView(
                children: List.generate(streamSnapshot.data!.size, (index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        documentSnapshot['features']['made'],
                        textScaleFactor: 1.4,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    leading: documentSnapshot['features']['image'] != null
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
                    trailing: InkWell(
                      onTap: () {
                        //delete vehicle
                        FirebaseFirestore.instance
                            .collection("vehicles")
                            .doc(documentSnapshot.id)
                            .delete()
                            .whenComplete(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Vehicle has been deleted"),
                            ),
                          );
                        });
                      },
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 30,
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet<void>(
                barrierColor: Colors.black87,
                //background color for modal bottom screen
                // backgroundColor: Colors.white,
                //elevates modal bottom screen
                elevation: 8,
                // gives rounded corner to modal bottom screen
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              // made
                              TextField(
                                controller: made,
                                keyboardType: TextInputType.text,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.car_repair,
                                      size: 20,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 228, 227, 227)),
                                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    // hintStyle: const TextStyle(),
                                    hintText: "Made",
                                    errorBorder: InputBorder.none,
                                    labelStyle: TextStyle(fontSize: 20),
                                    contentPadding: EdgeInsets.all(5)),
                              ),
                              //spacer
                              const SizedBox(
                                height: 10,
                              ),
                              //model
                              TextField(
                                controller: model,
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
                                          color: Color.fromARGB(
                                              255, 228, 227, 227)),
                                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    // hintStyle: const TextStyle(),
                                    hintText: "Model",
                                    // errorText: _errorEmail,
                                    errorBorder: InputBorder.none,
                                    labelStyle: TextStyle(fontSize: 20),
                                    contentPadding: EdgeInsets.all(5)),
                              ),
                            ]),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "Select Image from",
                            textScaleFactor: 1.4,
                          ),
                        ),
                        //upload buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                                onPressed: () => _upload('camera'),
                                icon: const Icon(Icons.camera),
                                label: const Text('camera')),
                            ElevatedButton.icon(
                                onPressed: () => _upload('gallery'),
                                icon: const Icon(Icons.library_add),
                                label: const Text('Gallery')),
                          ],
                        ),
                      ],
                    ),
                  ));
                },
                context: context);
          },
          child: const Icon(
            Icons.playlist_add_circle_sharp,
            size: 40,
          )),
    );
  }
}
