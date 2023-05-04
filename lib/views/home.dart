import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/services/hive_service.dart';
import 'tasks.dart';
import 'categories.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(initialPage: 0);
  late int _selectedIndex = 0;

  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        Fluttertoast.showToast(
          msg: "You are offline now!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      } else {
        // resend any pending requests now
        try {
          // get all pending calls
          Box box = HiveService().getBox();
          List writeCalls = box.get('writeCalls');
          List patchCalls = box.get('patchCalls');
          List delCalls = box.get('delCalls');

          // resend pending calls now
          writeCalls.forEach((element) {
            if (element['url'] != null && element['data'] != null) {
              Api.post(element['url'], data: element['data']);
            }
          });
          patchCalls.forEach((element) {
            if (element['url'] != null && element['data'] != null) {
              Api.patch(element['url'], data: element['data']);
            }
          });
          delCalls.forEach((url) {
            Api.delete(url);
          });

          // clear all box data now
          box.clear();
          print(box.values.toString());
        } catch (_) {
          // on error
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("To-Do List"),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(CupertinoIcons.calendar),
        //   ),
        // ],
      ),
      extendBody: true,
      // bottomNavigationBar: BottomAppBar(
      //   shape: const CircularNotchedRectangle(),
      //   notchMargin: 6.0,
      //   clipBehavior: Clip.antiAlias,
      //   child: SizedBox(
      //     height: kBottomNavigationBarHeight,
      //     child: BottomNavigationBar(
      //       currentIndex: _selectedIndex,
      //       selectedItemColor: Colors.brown,
      //       unselectedItemColor: Colors.black,
      //       onTap: (index) {
      //         setState(() {
      //           _selectedIndex = index;
      //           pageController.jumpToPage(index);
      //         });
      //       },
      //       items: const [
      //         BottomNavigationBarItem(
      //           icon: Icon(CupertinoIcons.square_list),
      //           label: '',
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Icon(CupertinoIcons.tag),
      //           label: '',
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: PageView(
        controller: pageController,
        children: const <Widget>[
          Center(
            child: Tasks(),
          ),
          Center(
            child: Categories(),
          ),
        ],
      ),
    );
  }
}
