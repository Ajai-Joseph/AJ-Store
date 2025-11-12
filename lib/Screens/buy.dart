import 'package:aj_store/Pages/buyChats.dart';
import 'package:aj_store/Pages/buyProducts.dart';
import 'package:flutter/material.dart';

class Buy extends StatefulWidget {
  const Buy({Key? key}) : super(key: key);

  @override
  State<Buy> createState() => _BuyState();
}

class _BuyState extends State<Buy> with SingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                text: "ITEMS",
              ),
              Tab(
                text: "CHATS",
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                BuyProducts(),
                BuyChats(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
