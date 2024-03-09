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
import 'package:pluto_grid/pluto_grid.dart';

import '../WIdgets/CustomDropDownSearch.dart';
import '../WIdgets/LoadingWidget.dart';

class DesktopAssetScreen extends StatefulWidget {
  const DesktopAssetScreen({super.key, required this.sheetList});
  final List<String> sheetList;

  @override
  State<DesktopAssetScreen> createState() => _DesktopAssetScreenState();
}

class _DesktopAssetScreenState extends State<DesktopAssetScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  ApiService apiService = ApiService();
  UtilService utilService = UtilService();
  late PlutoGridStateManager stateManager;

  String processInfo = "";
  String selectedBranch = "";
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
      if (headerList[index] == "No." || headerList[index] == "ID") {
        return PlutoColumn(
            width: 50,
            minWidth: 45,
            backgroundColor: Colors.black12,
            textAlign: PlutoColumnTextAlign.center,
            title: headerList[index],
            field: headerList[index],
            hide: headerList[index] == "ID"
                ? showHideHeaderList[index][headerList[index]]
                : !showHideHeaderList[index][headerList[index]],
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

  Future<void> addRow() async {
    List<PlutoRow> _rowList = [];
    List<String> dataList = [];
    //List<String>
    var _data = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: LayoutBuilder(builder: (ctx, size) {
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
                        Center(
                            child: Text(
                          "Add new purchased item",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                        Column(
                          children: List.generate(headerList.length, (index) {
                            if (headerList[index] == "No.") {
                              _controllers[headerList[index]]!.text =
                                  "${sheetRowCount + 1}";
                              return ListTile(
                                title: Text("ROW ID"),
                                subtitle: TextFormField(
                                  enabled: false,
                                  controller: _controllers[headerList[index]],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(width: 0.5),
                                    ),
                                    hintText: headerList[index],
                                  ),
                                ),
                              );
                            } else if (headerList[index] == "ID") {
                              return ListTile(
                                title: Text("UUID"),
                                subtitle: TextFormField(
                                  enabled: false,
                                  controller: _controllers[headerList[index]],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(width: 0.5),
                                    ),
                                    hintText: headerList[index],
                                  ),
                                ),
                              );
                            } else {
                              _controllers[headerList[index]]!.text = "";
                              return ListTile(
                                title: Text(
                                  headerList[index],
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: headerList[index] == "Position" ||
                                        headerList[index] == "Location" ||
                                        headerList[index] == "Department" ||
                                        headerList[index] == "Position" ||
                                        headerList[index] == "Type"
                                    ? CustomDropdownSearch(
                                        itemList: setList(headerList[index]),
                                        lable: headerList[index],
                                        onChange: (selectedItem) {
                                          _controllers[headerList[index]].text =
                                              selectedItem;
                                          print(_controllers[headerList[index]]
                                              .text);
                                        },
                                      )
                                    : TextFormField(
                                        controller:
                                            _controllers[headerList[index]],
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            borderSide: BorderSide(width: 0.5),
                                          ),
                                          hintText: headerList[index],
                                        ),
                                      ),
                              );
                            }
                          }),
                        ),
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
                                  _controllers
                                      .forEach((editKey, editController) {
                                    dataList.add(editController.value!.text);
                                    _rowList.add(PlutoRow(cells: {}));
                                    print(editController.value!.text);
                                  });
                                  print("Data : ${dataList.join(",")}");
                                  Navigator.pop(ctx, dataList);
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
                      ]),
                ),
              );
            }),
          );
        });

    // PlutoRow(cells: PlutoCell(key: ""))
    // stateManager.appendRows(rows)

    stateManager.setShowLoading(true);
    Map<String, PlutoCell> plutoCellObject = {};

    _controllers.forEach((key, val) {
      plutoCellObject[key] = PlutoCell(
        value: val.value!.text.toString(),
      );
    });
    _rowList.add(PlutoRow(cells: plutoCellObject));

    if (_data == null || _data.isEmpty) {
      stateManager.setShowLoading(false);
      return;
    } else {
      await apiService
          .fetchData(
              sheet: selectedBranch,
              requestType: "3",
              row: (int.parse(_data[0]) + 1).toString(),
              data: "${_data.join(',')}")
          .then((response) {
        stateManager.appendRows(_rowList);
        stateManager.setShowLoading(false);
      });
    }
  }

  //Update Row
  Future<void> updateRow(PlutoRow? row) async {
    List<String> _data = [];
    //Map<String, dynamic>
    var value = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
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
                          if (e.key.isNotEmpty && e.key != "No.") {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 0),
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
                                              "$selectedItem";
                                          print(_controllers[e.key].text);
                                        },
                                      )
                                    : TextFormField(
                                        controller: _controllers[e.key],
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 0),
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
                                  Navigator.pop(ctx, {});
                                },
                                child: const Text('Cancel.'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _controllers
                                      .forEach((editKey, editController) {
                                    _data.add(editController.value!.text);
                                    print(editController.value!.text);
                                  });
                                  print("Data : ${_data.join(",")}");
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
              sheet: selectedBranch,
              requestType: "3",
              row: (int.parse(value[headerList[0]]!.text) + 1).toString(),
              data: "${_data.join(',')}")
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
    //Map<String, dynamic>?
    var value = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          final _dataController = TextEditingController();

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: LayoutBuilder(
              builder: (ctx, size) {
                _dataController.text = cell!.value.toString();

                return Container(
                  padding: const EdgeInsets.all(15),
                  width: 300,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(0)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: ListTile(
                            title: Text(cell!.column.title),
                            subtitle: cell!.column.title == "Location" ||
                                    cell!.column.title == "Position" ||
                                    cell!.column.title == "Department" ||
                                    cell!.column.title == "Type"
                                ? CustomDropdownSearch(
                                    itemList: setList(cell!.column.title),
                                    lable: cell.value.toString(),
                                    onChange: (selectedItem) {
                                      _dataController.text = selectedItem!;
                                    },
                                  )
                                : TextFormField(
                                    controller: _dataController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(width: 0.5),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
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
                                  Map<String, dynamic> data = {};
                                  for (int i = 0; i < headerList.length; i++) {
                                    if (cell!.column.title == headerList[i]) {
                                      data['column'] = i + 1;
                                    }
                                  }
                                  data['row'] =
                                      (cell!.row.cells[headerList[0]]!.value) +
                                          1;
                                  data['value'] = _dataController.text;
                                  Navigator.pop(ctx, data);
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
    } else {
      stateManager.setShowLoading(true);
      await apiService
          .fetchData(
        sheet: selectedBranch,
        requestType: "5",
        data: value['value'],
        row: "${value['row']}",
        column: "${value['column']}",
      )
          .then((result) {
        if (result[0]['status']) {
          stateManager.changeCellValue(
            stateManager.currentCell!,
            value['value'],
            force: true,
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            "Update Successfully",
            style: TextStyle(color: Colors.green),
          )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            "Update failed",
            style: TextStyle(color: Colors.red),
          )));
        }
        stateManager.setShowLoading(false);
      });
    }
  }

  // //Export PDF
  // void exportToPdf() async {
  //   var plutoGridPdfExport = pluto_grid_export.PlutoGridDefaultPdfExport(
  //     title: "$selectedBranch",
  //     creator: "MDG-!T",
  //     format: pluto_grid_export.PdfPageFormat.a4.landscape,
  //   );

  //   await pluto_grid_export.Printing.sharePdf(
  //     bytes: await plutoGridPdfExport.export(stateManager),
  //     filename: plutoGridPdfExport.getFilename(),
  //   );
  // }

  // //Export CSV
  // void exportToCsv() async {
  //   String title = "LAPTOP-Report-";

  //   var exported = const Utf8Encoder()
  //       .convert(pluto_grid_export.PlutoGridExport.exportCSV(stateManager));
  //   DateTime now = DateTime.now();
  //   String dateTimeFormat = DateFormat('dd-MM-yyyy_hh:mm').format(now);
  //   // use file_saver from pub.dev
  //   await FileSaver.instance.saveFile(
  //       name: "${title}_$dateTimeFormat", ext: "csv", bytes: exported);
  // }

  @override
  void initState() {
    initBuildTable().then((value) {
      setState(() {
        selectedBranch = widget.sheetList[0];
        sheetList = [selectedBranch]; // widget.sheetList;
        getCellValues(selectedBranch!).then(
          (cells) {
            getHeaderValues(selectedBranch!).then((headers) {
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
                                        // CustomDropdownSearch(
                                        //   width: 6,
                                        //   lable: selectedBranch,
                                        //   itemList: branchList,
                                        //   onChange: (selectedItem) {
                                        //     print("Branch : $selectedItem");
                                        //     setState(() {
                                        //       if (selectedBranch.isNotEmpty) {
                                        //         stateManager.setShowLoading(true);
                                        //       }
                                        //       selectedBranch = selectedItem!;
                                        //       processInfo = "Processing...";
                                        //     });
                                        //     getCellValues(selectedBranch!).then(
                                        //       (cells) {
                                        //         getHeaderValues(selectedBranch!).then((headers) {
                                        //           headerList.forEach((header) {
                                        //             showHideHeaderList.add({header: true});
                                        //           });
                                        //           setState(() {
                                        //             if (selectedBranch.isNotEmpty) {
                                        //               stateManager.setShowLoading(false);
                                        //             }

                                        //             print(showHideHeaderList[0]);
                                        //             print("SHEET : ${selectedBranch}, FILTER : ${headers[3]}, Cells Count : ${cells.length}, Department Count : ${departmentList.length}");
                                        //           });
                                        //         });
                                        //       },
                                        //     );
                                        //   },
                                        // ),
                                        //Set Filter
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
                                                topActions: [],
                                                bottomActions: []);
                                          },
                                        ),
                                        //Add ROW
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            addRow();
                                          },
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            //exportToCsv();
                                          },
                                          icon: Icon(Icons.download),
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
                              } else if (header == "ID") {
                                cells[header] = PlutoCell(
                                  value: "*****",
                                );
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
