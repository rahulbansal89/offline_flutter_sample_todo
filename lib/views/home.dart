import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/add_task_dialog.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddTaskAlertDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
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
