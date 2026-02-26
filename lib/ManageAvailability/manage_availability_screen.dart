import 'package:flutter/material.dart';

import '../utility/ColorCode.dart';

class ManageAvailabilityScreen extends StatefulWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  State<ManageAvailabilityScreen> createState() => _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [

                /// MENU
                Builder(
                  builder: (context) => InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Image.asset(
                      "assets/home/menu-02.png",
                      width: 26,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                /// TITLE
                const Text(
                  "Manage Availability",
                  style: TextStyle(
                    color: ColorCode.white,
                    fontSize: 16,
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

              ],
            ),
          ),
        ],
      ),

    );
  }
}
