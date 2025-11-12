import 'package:aj_store/customerProductDetails.dart';
import 'package:aj_store/sellerProductDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuyProducts extends StatefulWidget {
  BuyProducts({Key? key}) : super(key: key);

  @override
  State<BuyProducts> createState() => _BuyProductsState();
}

class _BuyProductsState extends State<BuyProducts> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseAuth auth = FirebaseAuth.instance;
  late bool search;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    search = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    search = true;
                  });
                },
                icon: Icon(
                  Icons.search,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection("Products").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot x = snapshot.data!.docs[index];
                        List li = x['Images'];
                        String sellerId = x['Seller ID'];
                        if (search == false) {
                          return GestureDetector(
                            onTap: () {
                              if (sellerId == auth.currentUser!.uid) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SellerProductDetails(
                                        productId: x['Product ID'])));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerProductDetails(
                                            productId: x['Product ID'])));
                              }
                            },
                            child: Card(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
                                              color: Colors.blue,
                                              fontSize: 15),
                                        )),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        x['Title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                        } else {
                          if (searchController.text.length <=
                              x['Title'].toString().length) {
                            if (x['Title'].toString().substring(
                                    0, searchController.text.length) ==
                                searchController.text) {
                              return GestureDetector(
                                onTap: () {
                                  if (sellerId == auth.currentUser!.uid) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SellerProductDetails(
                                                    productId:
                                                        x['Product ID'])));
                                  } else {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerProductDetails(
                                                    productId:
                                                        x['Product ID'])));
                                  }
                                },
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                            } else {
                              return SizedBox();
                            }
                          } else {
                            return SizedBox();
                          }
                        }
                      },
                      itemCount: snapshot.data!.docs.length,
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
