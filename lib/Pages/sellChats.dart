import 'package:aj_store/sellChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellChats extends StatelessWidget {
  SellChats({Key? key}) : super(key: key);
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late String userId;
  String? productName, productPrice;
  @override
  Widget build(BuildContext context) {
    userId = auth.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseFirestore
          .collection("Sell Last Message")
          .doc(userId)
          .collection("Messages")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemBuilder: (context, index) {
              QueryDocumentSnapshot x = snapshot.data!.docs[index];
              if (snapshot.hasData) {
                if (x['Id'] != userId) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SellChatScreen(
                                  receiverId: x['Id'],
                                  productId: x['Product ID'],
                                  productName: x['Product Name'],
                                  productPrice: x['Product Price'],
                                )));
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          x['Image'],
                        ),
                      ),
                      title: Text(x['Name']),
                      subtitle: Text(x['Last Message']),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(x['Product Name']),
                          Text(
                            x['Product Price'],
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
            itemCount: snapshot.data!.docs.length,
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
