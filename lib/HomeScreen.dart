import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mdg_fixasset/Const/colors.dart';
import 'package:mdg_fixasset/Const/images.dart';
import 'package:mdg_fixasset/Screens/CctvReportScreen.dart';
import 'package:mdg_fixasset/Screens/DashboardScreen.dart';
import 'package:mdg_fixasset/Screens/GroundAssetScreen.dart';
import 'package:mdg_fixasset/Utils/ApiService.dart';

class HomeScree extends StatefulWidget {
  const HomeScree({super.key});

  @override
  State<HomeScree> createState() => _HomeScreeState();
}

class _HomeScreeState extends State<HomeScree> {
  bool isMenuOpen = false;
  int selectedMenuItem = 0;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  Map<String, dynamic> headers = {};
  List<dynamic> sheets = [];
  List<dynamic> cctvSheets = [];

  // void drawerToggle() {
  //   _key.currentState?.openDrawer();
  // }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();
  String googleSheetActiveUrl =
      "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?";
  String param = "sheet=Tamwe Office  PC List&request_type=2";
  ApiService apiService = ApiService();

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
      selectedMenuItem = index;
    });
    // apiService.getSheet("${ApiService.gssUrl}").then((value) {
    //   //print(value['sheetNames']);
    //   sheets = value;
    // });
    // apiService.getSheet("${ApiService.cctvUrl}").then((value) {
    //   cctvSheets = value;
    // });
    // Future.delayed(Duration.zero).then((finish) async {
    //   if (Platform.isWindows) {
    //     bool isFullScreen = await DesktopWindow.getFullScreen();
    //     await DesktopWindow.setFullScreen(isFullScreen);
    //   }
    // });
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
        title: 'Damaged',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.delete),
      ),
      SideMenuItem(
        title: 'Repair',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.rebase_edit),
      ),
      SideMenuItem(
        title: 'CCTV Report',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        icon: Icon(Icons.camera_indoor_outlined),
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
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              Images.square_logo,
              fit: BoxFit.fitHeight,
              height: 50,
            ),
          ),
          leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                toggleMenu();
              }),
          actions: [
            IconButton(
                onPressed: () {
                  apiService.getSheet("cctv").then((value) {
                    print(value);
                  });
                },
                icon: const Icon(Icons.info))
          ],
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SideMenu(
              alwaysShowFooter: true,
              style: SideMenuStyle(
                  displayMode: isMenuOpen
                      ? SideMenuDisplayMode.open
                      : SideMenuDisplayMode.compact,
                  decoration: BoxDecoration(),
                  openSideMenuWidth: 200,
                  compactSideMenuWidth: 50,
                  hoverColor: Colour.blue.withOpacity(0.2),
                  selectedColor: Colour.blue,
                  selectedIconColor: Colors.white,
                  unselectedIconColor: Colors.black54,
                  backgroundColor: Colors.transparent,
                  selectedTitleTextStyle: TextStyle(color: Colors.white),
                  unselectedTitleTextStyle: TextStyle(color: Colors.black54),
                  iconSize: 24,
                  selectedHoverColor: Colour.blue.withOpacity(0.9),
                  itemBorderRadius: const BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                  showTooltip: true,
                  itemHeight: 50.0,
                  itemInnerSpacing: 8.0,
                  itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                  toggleColor: Colors.black54),
              // Page controller to manage a PageView
              controller: sideMenu,
              displayModeToggleDuration: Duration(milliseconds: 300),

              //showToggle: isMenuOpen,
              // Will shows on top of all items, it can be a logo or a Title text
              title: Container(
                  margin: isMenuOpen ? EdgeInsets.all(4) : EdgeInsets.all(2),
                  width: isMenuOpen ? 180 : 50,
                  height: 46,
                  child: isMenuOpen
                      ? Image.asset(Images.square_logo)
                      : Image.asset(
                          Images.logo,
                          fit: BoxFit.contain,
                        )),
              // Will show on bottom of SideMenu when displayMode was SideMenuDisplayMode.open
              footer: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Ver:1.0.1',
                  style: TextStyle(fontSize: 10),
                ),
              ),

              // Notify when display mode changed
              onDisplayModeChanged: (mode) {
                print(mode);
              },
              // List of SideMenuItem to show them on SideMenu
              items: items,
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      onPageChanged: (value) {
                        setState(() {
                          selectedMenuItem = value;
                        });
                      },
                      children: [
                        FutureBuilder<List<String>>(
                            future: apiService.getSheet(""),
                            builder: (context,
                                AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.hasData) {
                                return DashboardScreen(
                                  sheetList: snapshot.data!,
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                        FutureBuilder<List<String>>(
                            future: apiService.getSheet(""),
                            builder: (context,
                                AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.hasData) {
                                return GroundAssetScreen(
                                  sheetList: snapshot.data!,
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                        Container(
                          child: Center(
                            child: Text('IP Address & Port'),
                          ),
                        ),
                        Container(
                          child: Center(
                            child: Text('Damage'),
                          ),
                        ),
                        Container(
                          child: Center(
                            child: Text('Repair'),
                          ),
                        ),
                        FutureBuilder<List<String>>(
                            future: apiService.getSheet(ApiService.cctvUrl),
                            builder: (context,
                                AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.hasData) {
                                return CctvReportScreen(
                                  sheetList: snapshot.data!,
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                        Container(
                          child: Center(
                            child: Text('Settings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
