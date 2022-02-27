import 'package:aj_store/customerProductDetails.dart';
import 'package:aj_store/sellerProductDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryWiseProducts extends StatelessWidget {
  String categoryName;
  CategoryWiseProducts({required this.categoryName});
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
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
          title: Text(categoryName),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("Products")
              .where('Category', isEqualTo: categoryName)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot x = snapshot.data!.docs[index];
                  List li = x['Images'];
                  String sellerId = x['Seller ID'];

                  return GestureDetector(
                    onTap: () {
                      if (sellerId == auth.currentUser!.uid) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SellerProductDetails(
                                productId: x['Product ID'])));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CustomerProductDetails(
                                productId: x['Product ID'])));
                      }
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Image(
                              image: NetworkImage(li.first),
                              width: 90,
                              height: 90,
                            ),
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "₹ ${x['Price']}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                )),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                x['Title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                ),
                                Text(
                                  x['Place'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data!.docs.length,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
