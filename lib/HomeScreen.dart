import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mdg_fixasset/Screens/DashboardScreen.dart';
import 'package:mdg_fixasset/Utils/ApiService.dart';

class HomeScree extends StatefulWidget {
  const HomeScree({super.key});

  @override
  State<HomeScree> createState() => _HomeScreeState();
}

class _HomeScreeState extends State<HomeScree> {
  bool isMenuOpen = false;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  Map<String, dynamic> headers = {};
  List<dynamic> sheets = [];

  void drawerToggle() {
    _key.currentState?.openDrawer();
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();
  String googleSheetActiveUrl =
      "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec";
  String param = "?sheet=Tamwe Office  PC List&request_type=2";
  ApiService apiService = ApiService();

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    apiService.getSheet("${googleSheetActiveUrl}").then((value) {
      //print(value['sheetNames']);
      sheets = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<SideMenuItem> items = [
      SideMenuItem(
        title: 'Dashboard',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.home),
        badgeContent: Text(
          '3',
          style: TextStyle(color: Colors.white),
        ),
      ),
      SideMenuItem(
        title: 'Ground Assets',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.inbox),
      ),
      SideMenuItem(
        title: 'PC Name & IP',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.computer),
      ),
      SideMenuItem(
        title: 'Demaged',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.delete),
      ),
      SideMenuItem(
        title: 'Repire Stock',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.rebase_edit),
      ),
      SideMenuItem(
        title: 'Settings',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.settings),
      ),
      SideMenuItem(
        title: 'Exit',
        onTap: (_, __) {},
        icon: Icon(Icons.exit_to_app),
      ),
    ];
    return Scaffold(
        key: _key,
        // appBar: AppBar(
        //   leading: IconButton(
        //       icon: Icon(Icons.menu),
        //       onPressed: () {
        //         drawerToggle();
        //       }),
        //   actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.info))],
        // ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SideMenu(
              style: SideMenuStyle(
                  displayMode: SideMenuDisplayMode.auto,
                  decoration: BoxDecoration(),
                  openSideMenuWidth: 200,
                  compactSideMenuWidth: 40,
                  hoverColor: Colors.black26,
                  selectedColor: Colors.black87,
                  selectedIconColor: Colors.white,
                  unselectedIconColor: Colors.black54,
                  backgroundColor: Colors.white,
                  selectedTitleTextStyle: TextStyle(color: Colors.white),
                  unselectedTitleTextStyle: TextStyle(color: Colors.black54),
                  iconSize: 20,
                  itemBorderRadius: const BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  showTooltip: true,
                  itemHeight: 50.0,
                  itemInnerSpacing: 8.0,
                  itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                  toggleColor: Colors.black54),
              // Page controller to manage a PageView
              controller: sideMenu,
              // Will shows on top of all items, it can be a logo or a Title text
              title: Container(),
              // Will show on bottom of SideMenu when displayMode was SideMenuDisplayMode.open
              footer: Text('Info!'),
              // Notify when display mode changed
              onDisplayModeChanged: (mode) {
                print(mode);
              },
              // List of SideMenuItem to show them on SideMenu
              items: items,
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                children: [
                  FutureBuilder<List<String>>(
                    future: apiService.getSheet(googleSheetActiveUrl),
                    builder: (context, AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.hasData) {
                        return DashboardScreen(
                          sheetList: snapshot.data!,
                        );
                      } else {
                        return Center(
                          child: Container(
                              height: 50,
                              width: 50,
                              child: const CupertinoActivityIndicator()),
                        );
                      }
                    },
                  ),
                  Container(
                    child: Center(
                      child: Text('Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
