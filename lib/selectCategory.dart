import 'package:aj_store/addProduct.dart';
import 'package:aj_store/categoryWiseProducts.dart';
import 'package:flutter/material.dart';

class SelectCategory extends StatelessWidget {
  String fromWhichPage;
  SelectCategory({required this.fromWhichPage});
  List categoryIcons = [
    Icons.directions_car,
    Icons.two_wheeler,
    Icons.apartment,
    Icons.phone_android_rounded,
    Icons.electrical_services_rounded,
    Icons.chair,
    Icons.book,
    Icons.pets,
    Icons.face_retouching_natural_sharp,
    Icons.settings,
    Icons.sports_cricket,
    Icons.category,
  ];
  List categoryNames = [
    "Cars",
    "Bikes",
    "Properties",
    "Mobiles",
    "Electronics",
    "Furniture",
    "Books",
    "Pets",
    "Fashion",
    "Services",
    "Sports",
    "Other",
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
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
        title: Text(
          "Select Category",
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (fromWhichPage == "home") {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CategoryWiseProducts(
                      categoryName: categoryNames[index],
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AddProduct(
                      categoryName: categoryNames[index],
                    ),
                  ),
                );
              }
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categoryIcons[index],
                  ),
                  Text(
                    categoryNames[index],
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: categoryNames.length,
      ),
    ));
  }
}
