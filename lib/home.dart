import 'package:car_services/Allservices.dart';
import 'package:car_services/admin/admin.dart';
import 'package:car_services/services.dart';
import 'package:car_services/signin.dart';
import 'package:car_services/vhicles.dart';
import 'package:car_services/orders.dart';
import 'package:car_services/settings.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //firebase firesore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  //firestore firebase database handler
  CollectionReference vehicle =
      FirebaseFirestore.instance.collection('vehicles');

  //get user info and store in variables
  bool isLoaded = false;
  String? name, uid, phone, address, image, rule;
  bool searching = false;
  //list of vehicles
  // final List<Map<String, dynamic>> _vehicles = [
  //   {
  //     "id": "098974043232",
  //     "made": "BMW",
  //     "image": "assets/images/bmw.png",
  //   },
  //   {
  //     "id": "453353534534",
  //     "made": "TOYOTA",
  //     "image": "assets/images/TY.jpg",
  //   },
  //   {
  //     "id": "095747897989",
  //     "made": "HAVAL",
  //     "image": "assets/images/haval.png",
  //   },
  //   {
  //     "id": "096656876980",
  //     "made": "VW",
  //     "image": "assets/images/vw.png",
  //   },
  // ];

  // //services
  // final List<Map<String, dynamic>> _services = [
  //   {
  //     "id": "098974043232",
  //     "icon":
  //         "https://firebasestorage.googleapis.com/v0/b/carservices-fd6b2.appspot.com/o/services%2Foil.png?alt=media&token=88303685-eb85-4181-91c7-9c8a89ad402f",
  //     "name": "Engine oil",
  //     "price": 50,
  //   },
  //   {
  //     "id": "098974043232",
  //     "icon":
  //         "https://firebasestorage.googleapis.com/v0/b/carservices-fd6b2.appspot.com/o/services%2Ftire.png?alt=media&token=38d3d190-12e1-4b57-9cc9-879aca199600",
  //     "name": "Tire Air check",
  //     "price": 10,
  //   },
  //   {
  //     "id": "098974043232",
  //     "icon":
  //         "https://firebasestorage.googleapis.com/v0/b/carservices-fd6b2.appspot.com/o/services%2Fbattery.png?alt=media&token=1185fd6e-ff09-4b43-bb76-5816b1443d2a",
  //     "name": "Battry",
  //     "price": 50,
  //   },
  //   {
  //     "id": "453353534534",
  //     "icon":
  //         "https://firebasestorage.googleapis.com/v0/b/carservices-fd6b2.appspot.com/o/services%2Fpainting.png?alt=media&token=9f783c10-ec00-4d60-a30a-a0b496dd0cea",
  //     "name": "Painting",
  //     "price": 110,
  //   },
  //   {
  //     "id": "453353534534",
  //     "icon":
  //         "https://firebasestorage.googleapis.com/v0/b/carservices-fd6b2.appspot.com/o/services%2Ftire(2).png?alt=media&token=4dbbef24-fb0c-4d4e-be79-fe189b6487ef",
  //     "name": "4 tire",
  //     "price": 160,
  //   },
  //   {
  //     "id": "453353534534",
  //     "icon":
  //         "https://firebasestorage.googleapis.com/v0/b/carservices-fd6b2.appspot.com/o/services%2Fcar-wash.png?alt=media&token=a8d13805-1736-43d9-9490-04958b40f5dd",
  //     "name": "Vehicle Wash",
  //     "price": 10,
  //   },
  //   {
  //     "id": "098974043232",
  //     "icon":
  //         "https://firebasestorage.googleapis.com/v0/b/carservices-fd6b2.appspot.com/o/services%2Foil.png?alt=media&token=88303685-eb85-4181-91c7-9c8a89ad402f",
  //     "name": "Inspect clutch",
  //     "price": 20,
  //   },
  //   {
  //     "id": "098974043232",
  //     "icon":
  //         "https://firebasestorage.googleapis.com/v0/b/carservices-fd6b2.appspot.com/o/services%2Fpiston.png?alt=media&token=a7b55dc7-d23f-49bc-a9ca-5b7703fc97c8",
  //     "name": "Piston",
  //     "price": 120,
  //   },
  // ];

  //search text controller
  TextEditingController searchControl = TextEditingController();

  //list of images for banner
  final List _images2 = [
    "https://stimg.cardekho.com/images/carexteriorimages/630x420/Lamborghini/Lamborghini-Huracan-EVO/6731/1546932239757/front-left-side-47.jpg",
    "https://www.lamborghini.com/sites/it-en/files/DAM/lamborghini/gateway-family/few-off/sian/car_sian.png",
    "https://blog.dupontregistry.com/wp-content/uploads/2013/05/lamborghini-egoista.jpg",
  ];

  //firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user info
  void getUserInfo() {
    if (_auth.currentUser != null) {
      //get user info
      var userinfo = FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .get();

      userinfo.then((user) {
        if (user.exists) {
          setState(() {
            uid = user["id"];
            name = user["name"];
            phone = user["phone"];
            address = user["address"];
            rule = user['rule'];
            isLoaded = true;
          });
        } else {
          isLoaded = false;
        }
      });
    } else {
      isLoaded = false;
    }
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  var searchList = [];

  @override
  Widget build(BuildContext context) {
    //get services
    final CollectionReference _services =
        FirebaseFirestore.instance.collection("services");
    // getUserInfo();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //user name, logo and user avatar
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //name nad address column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          name != null
                              ? Row(
                                  children: [
                                    const Text(
                                      "HI",
                                      textScaleFactor: 1.4,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 6,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "$name",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: const [
                                    Text(
                                      "HI",
                                      textScaleFactor: 1.4,
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "GUEST",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                          address != null
                              ? Text(
                                  "$address",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                )
                              : const Text(
                                  " ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                        ],
                      ),
                    ),
                    //Logo
                    Expanded(
                      child: InkWell(
                        onTap: rule == "admin"
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminScreen()),
                                )
                            : () {},
                        child: Image.asset(
                          "assets/images/logo4.png",
                          width: MediaQuery.of(context).size.width * 0.40,
                          height: 50,
                        ),
                      ),
                    ),
                    //avatar
                    Expanded(
                      child: !isLoaded
                          ? Stack(
                              alignment: Alignment.center,
                              children: const [
                                Center(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.amber,
                                  ),
                                ),
                                Icon(Icons.settings)
                              ],
                            )
                          : image != null
                              ? Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.amber,
                                        backgroundImage: NetworkImage(image!),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: InkWell(
                                          onTap: _auth.currentUser != null
                                              ? () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SettingsScreen(),
                                                    ),
                                                  );
                                                }
                                              : () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SigninScreen(),
                                                    ),
                                                  );
                                                },
                                          child: Icon(Icons.settings)),
                                    ),
                                  ],
                                )
                              : Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: const CircleAvatar(
                                          backgroundColor: Colors.amber,
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        child: InkWell(
                                          onTap: _auth.currentUser != null
                                              ? () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SettingsScreen(),
                                                    ),
                                                  );
                                                }
                                              : () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SigninScreen(),
                                                    ),
                                                  );
                                                },
                                          child: Icon(
                                            Icons.settings,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ]),
                    ),
                  ],
                ),
              ),
              //search box
              searching
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 30,
                        right: 30,
                        bottom: 20,
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: searchControl,
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 20),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              suffixIconColor: Colors.blue,
                              suffixIcon: InkWell(
                                onTap: () {
                                  searchList.clear();
                                  FirebaseFirestore.instance
                                      .collection("services")
                                      .where("name",
                                          isEqualTo: searchControl.text.trim())
                                      .get()
                                      .then((value) {
                                    value.docs.forEach((element) {
                                      var item = element.data();
                                      searchList.add(item);
                                    });
                                    setState(() {});
                                  });
                                },
                                child: const Icon(
                                  Icons.search_sharp,
                                  size: 25,
                                  color: Colors.blue,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.blue),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.blue),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              hintStyle: const TextStyle(color: Colors.blue),
                              hintText: "Search for vehicle services",
                              labelStyle: const TextStyle(
                                  fontSize: 15, color: Colors.blue),
                              // helperStyle: TextStyle(color: Colors.black),
                              contentPadding:
                                  const EdgeInsets.only(left: 10, right: 10),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: searchList.map((e) {
                                String v = "";
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(),
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: (() {
                                      var s = FirebaseFirestore.instance
                                          .collection("vehicles")
                                          .doc(e['id'])
                                          .get()
                                          .then((value) {
                                        return value.data();
                                      });
                                      //get vehicle service
                                      s.then((vehicle) {
                                        vehicle != null
                                            ? Text(vehicle['features']['made'])
                                            : v = "Known";
                                        setState(() {});
                                        vehicle != null
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ServicesScreen(
                                                    package: vehicle,
                                                    carId: e['id'],
                                                    carImage:
                                                        vehicle['features']
                                                            ['image'],
                                                    carName: vehicle['features']
                                                        ['made'],
                                                  ),
                                                ),
                                              )
                                            : () {};
                                      });
                                    }),
                                    // subtitle: Text(v),
                                    leading: Image.network(
                                      e['icon'],
                                      width: 32,
                                      height: 32,
                                    ),
                                    title: Text(
                                      e['name'],
                                      style: TextStyle(
                                          textBaseline:
                                              TextBaseline.alphabetic),
                                      textAlign: TextAlign.start,
                                    ),
                                    trailing: Text("${e['price']}\$"),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
              //title of banners
              const Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: Text(
                  "Special Service",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              //banner content
              CarouselSlider(
                items: _images2
                    .map(
                      (x) => Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(x, scale: 1),
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 70,
                            left: 10,
                            child: Text(
                              'Oil change',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black,
                                        offset: Offset(1, 0),
                                        blurRadius: 4)
                                  ]),
                            ),
                          ),
                          const Positioned(
                            bottom: 50,
                            left: 10,
                            child: Text(
                              'Service price 20 USD',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black,
                                        offset: Offset(1, 0),
                                        blurRadius: 4)
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      // currentIndex = index;
                      // _product = _products[index];
                    });
                  },
                ),
              ),
              //title of service
              const Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: Text(
                  "Our Service",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              //list of services
              Padding(
                padding: const EdgeInsets.all(20.0),
                child:
                    // all services
                    StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("services")
                      .limit(11)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      return GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                            streamSnapshot.data!.docs.length + 1, (index) {
                          if (index == 11) {
                            return InkWell(
                              onTap: () {
                                // all services

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AllservicesScreen(),
                                  ),
                                );
                              },
                              child: const Card(
                                  child: Center(child: Text("More"))),
                            );
                          } else {
                            final DocumentSnapshot documentSnapshot =
                                streamSnapshot.data!.docs[index];
                            return InkWell(
                              onTap: () {
                                var c = streamSnapshot.data!.docs[index]
                                    ['id']; //vehicle id
                                showBottomSheet(
                                  enableDrag: false,
                                  shape: BeveledRectangleBorder(),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.85,
                                      child: Column(
                                        children: [
                                          //title
                                          Container(
                                            padding: const EdgeInsets.all(20.0),
                                            color: Colors.blue,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Service information",
                                                  style: TextStyle(
                                                      color: Colors.white),
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
                                                AsyncSnapshot<dynamic>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Center(
                                                        child: Image.network(
                                                          snapshot.data[
                                                                  'features']
                                                              ['image'],
                                                          width: MediaQuery.of(
                                                                      context)
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
                                                                        'features']
                                                                    ['made'],
                                                                textScaleFactor:
                                                                    1.4,
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
                                                                textScaleFactor:
                                                                    1.4,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Image.network(
                                            documentSnapshot['icon'].toString(),
                                            width: 32,
                                            height: 32,
                                          ),
                                          Text(
                                              "${documentSnapshot['price']}\$"),
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
                          }
                        }).toList(),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              //support title
              const Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: Text(
                  "Support Vehicles",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              //supporting vehicles
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("vehicles")
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      return GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                            streamSnapshot.data!.docs.length, (index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];
                          return InkWell(
                            onTap: () {
                              //
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServicesScreen(
                                    package: streamSnapshot.data!.docs[index],
                                    carId: streamSnapshot.data!.docs[index].id,
                                    carImage: documentSnapshot['features']
                                        ['image'],
                                    carName: documentSnapshot['features']
                                        ['made'],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 1,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Image.network(
                                          documentSnapshot['features']['image'],
                                          width: 32,
                                          height: 32,
                                        ),
                                        Text(
                                            "${documentSnapshot['features']['model']}"),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        "${documentSnapshot['features']['made']}",
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
              //break line
              Container(
                margin: const EdgeInsets.all(20),
                height: 1,
                color: Colors.grey[200],
              ),
              //copyrights
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Copyrights 2023",
                      textScaleFactor: 1.4,
                    ),
                    Text(
                      "V 1.0",
                      textScaleFactor: 1.4,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        //navigation bar
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.car_repair_sharp,
              ),
              label: 'Vehicles',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.file_copy_outlined,
              ),
              label: 'Orders',
            ),
          ],
          //on icon taped
          onTap: (index) {
            //home page
            if (index == 0) {
              setState(() {
                //home tab
              });
            }
            //vehicles
            else if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CarsScreen()));
            }
            // orders
            else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Orders()));
            }
            //home
            else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            }
          },
        ),
      ),
    );
  }
}
