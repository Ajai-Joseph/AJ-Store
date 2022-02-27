import 'package:aj_store/Screens/buy.dart';
import 'package:aj_store/Screens/sell.dart';
import 'package:aj_store/login.dart';
import 'package:aj_store/profile.dart';
import 'package:aj_store/selectCategory.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  final screens = [
    Buy(),
    Sell(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("AJ Store"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue,
                  Colors.purple,
                ],
              ),
            ),
          ),
        ),
        drawer: drawer(context),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              label: "BUY",
              icon: Icon(
                Icons.shopping_cart,
              ),
            ),
            BottomNavigationBarItem(
              label: "SELL",
              icon: Icon(Icons.sell),
            ),
          ],
        ),
        body: screens[currentIndex],
      ),
    );
  }
}

Widget drawer(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.6,
    child: Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                height: 80,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.blue,
                  Colors.purple,
                ])),
              ),
              Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SelectCategory(
                                fromWhichPage: "home",
                              )));
                    },
                    horizontalTitleGap: 0,
                    leading: Icon(Icons.category),
                    title: Text("All Categories"),
                  ),
                  ListTile(
                    horizontalTitleGap: 0,
                    leading: Icon(Icons.folder),
                    title: Text("My Orders"),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Profile()));
                    },
                    horizontalTitleGap: 0,
                    leading: Icon(Icons.person),
                    title: Text("My Account"),
                  ),
                  ListTile(
                    onTap: () async {
                      final sharedPreference =
                          await SharedPreferences.getInstance();
                      await sharedPreference.clear();
                      auth.signOut().then((value) => {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                                (route) => false)
                          });
                    },
                    horizontalTitleGap: 0,
                    leading: Icon(Icons.logout),
                    title: Text("Logout"),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "Developer Contact:",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade900,
                ),
              ),
              ListTile(
                horizontalTitleGap: 0,
                dense: true,
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                leading: Icon(
                  Icons.email,
                  size: 17,
                ),
                title: Text(
                  "ajaijoseph363@gmail.com",
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
              ListTile(
                horizontalTitleGap: 0,
                dense: true,
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                leading: Icon(
                  Icons.phone,
                  size: 17,
                ),
                title: Text(
                  "+91 9497308477",
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
