import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mdg_fixasset/Const/colors.dart';
import 'package:mdg_fixasset/Utils/ApiService.dart';
import 'package:file_saver/file_saver.dart';
import 'package:mdg_fixasset/Utils/UtilService.dart';
import 'package:mdg_fixasset/WIdgets/CustomAlertDialog.dart';
import 'package:mdg_fixasset/constant.dart';
import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
import 'package:pluto_grid/pluto_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.sheetList});
  final List<String> sheetList;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  ApiService apiService = ApiService();
  UtilService utilService = UtilService();
  late PlutoGridStateManager stateManager;

  String processInfo = "";
  String selectedLocation = "";
  String selectedDepartment = "";
  String selectedPosition = "";

  bool isLoading = false;

  List<Map<String, dynamic>> cellsList = [];
  List<Map<String, dynamic>> showHideHeaderList = [];

  List<String> headerList = [];
  List<String> sheetList = [];

  Map<String, dynamic> _controllers = {};

  TextEditingController sheetDropdownSearchController = TextEditingController();
  TextEditingController departmentDropdownSearchController =
      TextEditingController();

  List<String> departmentList = [];
  List<String> positionList = [];
  List<String> locationList = [];
  List<String> branchList = [];
  List<String> typeList = ["Desktop", "Laptop"];
  int sheetRowCount = 0;

  List<String> setList(String listType) {
    switch (listType) {
      case "Position":
        return positionList;
        break;
      case "Location":
        return locationList;
        break;
      case "Department":
        return departmentList;
        break;
      case "Branch":
        return branchList;
        break;
      case "Type":
        return typeList;
        break;
      default:
        return [];
    }
  }

  List<PlutoColumn> setColum() {
    return List<PlutoColumn>.generate(headerList.length, (index) {
      _controllers[headerList[index]] = TextEditingController();
      if (headerList[index] == "No.") {
        return PlutoColumn(
            width: 50,
            minWidth: 45,
            backgroundColor: Colors.black12,
            textAlign: PlutoColumnTextAlign.center,
            title: headerList[index],
            field: headerList[index],
            hide: !showHideHeaderList[index][headerList[index]],
            type: PlutoColumnType.text());
      } else {
        return PlutoColumn(
            backgroundColor: Colors.black12,
            textAlign: PlutoColumnTextAlign.center,
            title: headerList[index],
            field: headerList[index],
            hide: !showHideHeaderList[index][headerList[index]],
            type: PlutoColumnType.text());
      }
    });
  }

  //INITIALIZE BUILD
  Future<void> initBuildTable() async {
    getOptionalValue("Branch").then((branch) {
      setState(() {
        branchList = branch;
      });
    });
    getOptionalValue("Location").then((location) {
      setState(() {
        locationList = location;
      });
    });
    getOptionalValue("Department").then((department) {
      setState(() {
        departmentList = department;
      });
    });
    getOptionalValue("Position").then((position) {
      setState(() {
        positionList = position;
      });
    });
    processInfo = "Initialize processing...";
    // await apiService
    //     .fetchData(
    //         "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?request_type=1&sheet=Tamwe Office  PC List")
    //     .then((cells) {
    //   print("CELL ${cells.length}");
    //   cells.forEach((cell) {
    //     var cellData = cell;
    //     setState(() {
    //       cellsList.add(cell);
    //     });
    //   });
    // });
    // await apiService
    //     .getHeader(
    //         "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?request_type=2&sheet=Tamwe Office  PC List")
    //     .then((headers) {
    //   headers.forEach((header) {
    //     setState(() {
    //       headerList.add(header);
    //     });
    //   });
    // });
  }

  Future<List<String>> getOptionalValue(String selector) async {
    List<String> optionaList = [];
    await apiService
        .getHeader(
            "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?request_type=1&sheet=optional")
        .then((optionalItems) {
      // if (selector != "Location") {
      //   optionaList.add('Select All');
      // }
      optionalItems.forEach((item) {
        if (item["$selector"].isNotEmpty) {
          setState(() {
            optionaList.add('${item["$selector"]}');
          });
        }
      });
    });
    print(optionaList);
    return optionaList;
  }

  Future<List<String>> getHeaderValues(String sheetName) async {
    headerList.clear();
    await apiService
        .getHeader(
            "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?request_type=2&sheet=$sheetName")
        .then((headers) {
      headers.forEach((header) {
        setState(() {
          headerList.add('$header');
        });
      });
    });
    return headerList;
  }

  Future<List<Map<String, dynamic>>> getCellValues(String sheetName,
      {String filterColumn = "", String filterValue = ""}) async {
    await apiService
        .fetchData(requestType: "1", sheet: sheetName)
        .then((cells) {
      sheetRowCount = cells.length;
      cellsList.clear();
      if (filterColumn.isNotEmpty && filterValue != 'Select All') {
        cells.forEach((cells) {
          var cellData = cells;
          if (cells[filterColumn] == filterValue) {
            print("${cells[filterColumn] == filterValue}");
            setState(() {
              cellsList.add(cellData);
            });
          }
        });
      } else {
        cells.forEach((cells) {
          var cellData = cells;
          setState(() {
            cellsList.add(cellData);
          });
        });
      }
    });

    return cellsList;
  }

  Future<List<Map<String, dynamic>>> getFilterCells(String filterColum,
      String filterValue, List<Map<String, dynamic>> dataList) async {
    List<Map<String, dynamic>> responseDataList = [];
    dataList.forEach((data) {
      Map<String, dynamic> cellData = {};

      cellData = dataList.firstWhere((cells) {
        if (cells[filterColum] == filterValue) {
          return true;
        } else {
          return false;
        }
      });
      responseDataList.add(cellData);
    });
    return responseDataList;
  }

  List<String> getFilterValue(String headerName, String responseValue) {
    List<String> filterList = [];
    List<Map<String, dynamic>> filterData =
        utilService.removeDuplicates(cellsList, "$headerName");
    filterData.forEach((filterValue) {
      filterList.add(filterValue[responseValue]);
    });

    return filterList;
  }

  List<dynamic> getItemList(
    List<Map> dataList,
  ) {
    List<dynamic> itemList = [];
    dataList.forEach((data) {
      setState(() {
        itemList.add(data);
      });
    });
    return itemList;
  }

  //Update Row
  Future<void> updateRow(PlutoRow? row) async {
    Map<String, dynamic> value = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          List<dynamic> _dataController = [];
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: LayoutBuilder(
              builder: (ctx, size) {
                return Container(
                  padding: const EdgeInsets.all(15),
                  width: 400,
                  height: MediaQuery.of(context).size.height / 1.1,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(0)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        ...row!.cells.entries.map((e) {
                          _controllers[e.key]!.text = e.value.value.toString();
                          print(_controllers[headerList[0]]!.text);
                          if (e.key.isNotEmpty && e.key != "No.") {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(e.key),
                                subtitle: e.key == "Position" ||
                                        e.key == "Location" ||
                                        e.key == "Department" ||
                                        e.key == "Position" ||
                                        e.key == "Type"
                                    ? CustomDropdownSearch(
                                        itemList: setList(e.key),
                                        lable: e.value.value.toString(),
                                        onChange: (selectedItem) {
                                          _controllers[e.key].text =
                                              selectedItem;
                                          print(_controllers[e.key].text);
                                        },
                                      )
                                    : TextFormField(
                                        controller: _controllers[e.key],
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            borderSide: BorderSide(width: 0.5),
                                          ),
                                          hintText: e.key,
                                        ),
                                      ),
                              ),
                            );
                          } else {
                            return Text(
                                'Row နံပါတ် (${e.value.value}) ကို Edit ပြုလုပ်ရန်အတွက် Password လိုအပ်ပါသည်။.');
                          }
                        }).toList(),
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            spacing: 10,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx, null);
                                },
                                child: const Text('Cancel.'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx, _controllers);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.blue,
                                  ),
                                ),
                                child: const Text(
                                  'Update.',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
    stateManager.setShowLoading(true);

    if (value == null || value.isEmpty) {
      stateManager.setShowLoading(false);
      return;
    } else {
      await apiService
          .fetchData(
              sheet: selectedLocation,
              requestType: "3",
              row: value[headerList[0]]!.text.toString(),
              data: "A,B,C,D")
          .then((response) {
        row!.cells.forEach((key, val) {
          stateManager.changeCellValue(
            stateManager.currentRow!.cells[key]!,
            value[key]!.text,
            force: true,
          );
        });
      });
      stateManager.setShowLoading(false);
    }
  }

  //Update Cell
  Future<void> updateCell(PlutoCell? cell) async {
    String? value = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          final _dataController = TextEditingController();
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: LayoutBuilder(
              builder: (ctx, size) {
                return Container(
                  padding: const EdgeInsets.all(15),
                  width: 400,
                  height: MediaQuery.of(context).size.height / 1.1,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(0)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(cell!.value.toString()),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _dataController,
                            decoration: InputDecoration(
                              hintText: cell.column.title,
                            ),
                          ),
                        ),

                        // ...row!.cells.entries.map((e) {
                        //   if (e.value.column != "" &&
                        //       e.value.column.title != "No.") {
                        //     return Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: TextFormField(
                        //         controller: TextEditingController(),
                        //         decoration: InputDecoration(
                        //           hintText: e.value.column.title,
                        //         ),
                        //       ),
                        //     );
                        //   } else {
                        //     return Text(
                        //         'ID : ${e.value.value} Edit ပြုလုပ်ရန်အတွက် Password လိုအပ်ပါသည်။.');
                        //   }
                        // }).toList(),
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            spacing: 10,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx, null);
                                },
                                child: const Text('Cancel.'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx, _dataController.text);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.blue,
                                  ),
                                ),
                                child: const Text(
                                  'Update.',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });

    if (value == null || value.isEmpty) {
      return;
    }

    stateManager.changeCellValue(
      stateManager.currentRow!.cells['No.']!,
      value,
      force: true,
    );
  }

  //Export PDF
  void exportToPdf() async {
    var plutoGridPdfExport = pluto_grid_export.PlutoGridDefaultPdfExport(
      title: "$selectedLocation",
      creator: "MDG-!T",
      format: pluto_grid_export.PdfPageFormat.a4.landscape,
    );

    await pluto_grid_export.Printing.sharePdf(
      bytes: await plutoGridPdfExport.export(stateManager),
      filename: plutoGridPdfExport.getFilename(),
    );
  }

  //Export CSV
  void exportToCsv() async {
    String title = "pluto_grid_export";

    var exported = const Utf8Encoder()
        .convert(pluto_grid_export.PlutoGridExport.exportCSV(stateManager));
    DateTime now = DateTime.now();
    String dateTimeFormat = DateFormat('dd-MM-yyyy_hh:mm').format(now);
    // use file_saver from pub.dev
    await FileSaver.instance.saveFile(
        name: "${title}_$dateTimeFormat", ext: "csv", bytes: exported);
  }

  @override
  void initState() {
    initBuildTable().then((value) {
      setState(() {
        selectedLocation = "HO";
        sheetList = widget.sheetList;
        getCellValues(selectedLocation!).then(
          (cells) {
            getHeaderValues(selectedLocation!).then((headers) {
              headerList.forEach((header) {
                showHideHeaderList.add({header: true});
              });
              setState(() {});
            });
          },
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        headerList.length > 0
            ? Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: MediaQuery.of(context).size.height / 1.2,
                        child: PlutoGrid(
                          onLoaded: (event) {
                            event.stateManager.setShowColumnFilter(true);
                            stateManager = event.stateManager;
                            stateManager
                                .setSelectingMode(PlutoGridSelectingMode.row);
                          },
                          onChanged: (PlutoGridOnChangedEvent event) {
                            print(event);
                          },
                          onSelected: (PlutoGridOnSelectedEvent event) async {
                            if (event.row != null) {
                              if (event.cell!.column.field == "No.") {
                                await updateRow(event.row);
                              } else {
                                await updateCell(event.cell);
                              }
                            }
                          },
                          createHeader: (stateManager) {
                            stateManager.setFilter((element) => true);
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text("Total Rows : $sheetRowCount"),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        //Choose Location
                                        CustomDropdownSearch(
                                          width: 6,
                                          lable: selectedLocation,
                                          itemList: branchList,
                                          onChange: (selectedItem) {
                                            print("Branch : $selectedItem");
                                            setState(() {
                                              if (selectedLocation.isNotEmpty) {
                                                stateManager
                                                    .setShowLoading(true);
                                              }
                                              selectedLocation = selectedItem!;
                                              processInfo = "Processing...";
                                            });
                                            getCellValues(selectedLocation!)
                                                .then(
                                              (cells) {
                                                getHeaderValues(
                                                        selectedLocation!)
                                                    .then((headers) {
                                                  headerList.forEach((header) {
                                                    showHideHeaderList
                                                        .add({header: true});
                                                  });
                                                  setState(() {
                                                    if (selectedLocation
                                                        .isNotEmpty) {
                                                      stateManager
                                                          .setShowLoading(
                                                              false);
                                                    }

                                                    print(
                                                        showHideHeaderList[0]);
                                                    print(
                                                        "SHEET : ${selectedLocation}, FILTER : ${headers[3]}, Cells Count : ${cells.length}, Department Count : ${departmentList.length}");
                                                  });
                                                });
                                              },
                                            );
                                          },
                                        ),

                                        // //Choose Department
                                        // CustomDropdownSearch(
                                        //   width: 6,
                                        //   lable: "Choose Department",
                                        //   itemList: departmentList,
                                        //   onChange: (selectedItem) {
                                        //     print(
                                        //         "Department Item : $selectedItem");

                                        //     setState(() {
                                        //       stateManager.setShowLoading(true);
                                        //       processInfo = "Processing...";
                                        //       selectedDepartment =
                                        //           selectedItem!;
                                        //     });
                                        //     getCellValues(selectedLocation,
                                        //             filterColumn: "Department",
                                        //             filterValue:
                                        //                 selectedDepartment)
                                        //         .then(
                                        //       (updateCell) {
                                        //         getHeaderValues(
                                        //                 selectedLocation!)
                                        //             .then((headers) {
                                        //           setState(() {
                                        //             stateManager
                                        //                 .setShowLoading(false);

                                        //             if (updateCell.length ==
                                        //                 0) {
                                        //               processInfo = "Not Found";
                                        //             }
                                        //           });
                                        //         });
                                        //       },
                                        //     );
                                        //   },
                                        // ),
                                        IconButton(
                                          icon: Icon(Icons.filter_list_alt),
                                          onPressed: () {
                                            showModal(context, Builder(
                                              builder: (context) {
                                                return Expanded(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3,
                                                    child: StatefulBuilder(
                                                        builder:
                                                            (context, onState) {
                                                      bool checkState = false;
                                                      return ListView.builder(
                                                        itemCount:
                                                            headerList.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return ListTile(
                                                            title: Text(
                                                                headerList[
                                                                    index]),
                                                            leading: Checkbox(
                                                                value: showHideHeaderList[
                                                                        index][
                                                                    headerList[
                                                                        index]],
                                                                onChanged:
                                                                    (status) {
                                                                  onState(() {
                                                                    showHideHeaderList[
                                                                            index]
                                                                        [
                                                                        headerList[
                                                                            index]] = status!;

                                                                    print(
                                                                        "${headerList[index]} : ${showHideHeaderList[index][headerList[index]]}");
                                                                  });
                                                                }),
                                                          );
                                                        },
                                                      );
                                                    }),
                                                  ),
                                                );
                                              },
                                            ),
                                                title: "Filter Columns",
                                                actions: [
                                                  IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          getCellValues(
                                                                  selectedLocation!)
                                                              .then(
                                                            (cells) {
                                                              getHeaderValues(
                                                                      selectedLocation!)
                                                                  .then(
                                                                      (headers) {
                                                                headerList
                                                                    .forEach(
                                                                        (header) {
                                                                  showHideHeaderList
                                                                      .add({
                                                                    header: true
                                                                  });
                                                                });
                                                                setState(() {
                                                                  print(
                                                                      showHideHeaderList[
                                                                          0]);
                                                                  print(
                                                                      "SHEET : ${selectedLocation}, FILTER : ${headers[3]}, Cells Count : ${cells.length}, Department Count : ${departmentList.length}");
                                                                });
                                                              });
                                                            },
                                                          );
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: Icon(Icons.done))
                                                ]);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {},
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: MaterialButton(
                                              color: Colour.blue,
                                              onPressed: exportToCsv,
                                              child: const Text(
                                                "Add",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: MaterialButton(
                                              color: Colour.blue,
                                              onPressed: exportToCsv,
                                              child: const Text(
                                                "Export Excel",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          createFooter: ((stateManager) {
                            stateManager.setPageSize(50, notify: false);
                            return PlutoPagination(stateManager);
                          }),
                          mode: PlutoGridMode.select,
                          configuration: const PlutoGridConfiguration(
                            scrollbar: PlutoGridScrollbarConfig(
                              dragDevices: // In case of Mobile
                                  // {
                                  //   PointerDeviceKind.touch,
                                  //   PointerDeviceKind.stylus,
                                  //   PointerDeviceKind.invertedStylus,
                                  //   PointerDeviceKind.unknown,
                                  // }

                                  // In case of desktop
                                  {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.trackpad,
                                PointerDeviceKind.unknown,
                              },
                            ),
                          ),
                          columns: setColum(),
                          rows: List<PlutoRow>.generate(cellsList.length,
                              (index) {
                            Map<String, PlutoCell> cells = {};
                            headerList.forEach((header) {
                              if (header == "No.") {
                                cells[header] = PlutoCell(value: index + 1);
                              } else {
                                cells[header] =
                                    PlutoCell(value: cellsList[index][header]);
                              }
                            });
                            PlutoRow row = PlutoRow(cells: cells);
                            return row;
                          }),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: LoadingWidget(
                            title: "$processInfo",
                            color: processInfo == "Processing..."
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        processInfo == "Processing..."
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    color: Colors.black45,
                                    strokeWidth: 1,
                                  ),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              )
      ],
    );
  }
}

//LOADING WIDGET
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.title = "LOADING...",
    this.color,
  });

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text("$title"),
          Container(
              height: 1,
              width: MediaQuery.of(context).size.width / 6,
              child: LinearProgressIndicator(
                color: color,
              )),
        ],
      ),
    );
  }
}

//CustomDropdownSearch Widget
class CustomDropdownSearch extends StatefulWidget {
  const CustomDropdownSearch({
    super.key,
    required this.itemList,
    this.onChange,
    required this.lable,
    this.width = 8,
    this.margin = 4,
  });

  final String lable;
  final List<String> itemList;
  final Function(String?)? onChange;
  final double width;
  final double margin;

  @override
  State<CustomDropdownSearch> createState() => _CustomDropdownSearchState();
}

class _CustomDropdownSearchState extends State<CustomDropdownSearch> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(widget.margin),
      padding: EdgeInsets.symmetric(horizontal: 4),
      width: MediaQuery.of(context).size.width / widget.width,
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          borderRadius: BorderRadius.circular(6)),
      child: DropdownSearch<String>(
        popupProps: PopupProps.menu(
          itemBuilder: (context, item, isSelected) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              padding: EdgeInsets.all(0),
              decoration: !isSelected
                  ? null
                  : BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      color: Colors.white,
                    ),
              child: ListTile(
                selected: isSelected,
                title: Text(
                  item,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            );
          },
          menuProps: MenuProps(
            backgroundColor: Colors.white,
            elevation: 4,
          ),
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(2),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  )),
              autocorrect: true,
              padding: EdgeInsets.all(2),
              scrollPadding: EdgeInsets.all(2)),
          showSelectedItems: true,
          disabledItemFn: (String s) => s.isEmpty,
        ),
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            border: InputBorder.none,
            hintText: "",
          ),
        ),
        items: widget.itemList,
        onChanged: widget.onChange,
        selectedItem: "${widget.lable}",
      ),
    );
  }
}
