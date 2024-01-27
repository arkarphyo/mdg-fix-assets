import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mdg_fixasset/Const/colors.dart';
import 'package:mdg_fixasset/Utils/ApiService.dart';
import 'package:file_saver/file_saver.dart';
import 'package:mdg_fixasset/Utils/UtilService.dart';
import 'package:mdg_fixasset/WIdgets/CustomDropDownSearch.dart';
import 'package:mdg_fixasset/constant.dart';
import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
import 'package:pluto_grid/pluto_grid.dart';

import '../WIdgets/LoadingWidget.dart';

class CctvReportScreen extends StatefulWidget {
  const CctvReportScreen({super.key, required this.sheetList});
  final List<String> sheetList;

  @override
  State<CctvReportScreen> createState() => _CctvReportScreenState();
}

//Default Sheet
//SET SetHeader
//SET SetCell
//

class _CctvReportScreenState extends State<CctvReportScreen> with AutomaticKeepAliveClientMixin {
  @override
  // Implement wantKeepAlive
  bool get wantKeepAlive => true;

  ApiService apiService = ApiService();
  UtilService utilService = UtilService();
  late PlutoGridStateManager stateManager;

  bool processInfo = false;
  String selectedYear = "";
  String selectedDepartment = "";
  String selectedPosition = "";

  bool isLoading = false;

  List<PlutoColumn> plutoColumns = [];

  List<Map<String, dynamic>> cellsList = [];
  List<Map<String, dynamic>> showHideHeaderList = [];

  List<String> headerList = [];
  List<String> sheetList = [];

  final Map<String, dynamic> _controllers = {};

  TextEditingController sheetDropdownSearchController = TextEditingController();
  TextEditingController departmentDropdownSearchController = TextEditingController();

  List<String> departmentList = [];
  List<String> positionList = [];
  List<String> locationList = [];
  List<String> yearList = [];
  List<String> branchList = [];
  List<String> typeList = ["Desktop", "Laptop"];
  int sheetRowCount = 0;

  //Set Optional List Type
  List<String> setList(String listType) {
    switch (listType) {
      case "Position":
        return positionList;
      case "Location":
        return locationList;
      case "Department":
        return departmentList;
      case "Branch":
        return branchList;
      case "Type":
        return typeList;
      default:
        return [];
    }
  }

  //Set Columns
  List<PlutoColumn> setColum() {
    plutoColumns = List<PlutoColumn>.generate(headerList.length, (index) {
      _controllers[headerList[index]] = TextEditingController();
      if (headerList[index] == "No." || headerList[index] == "ID") {
        return PlutoColumn(width: 50, minWidth: 45, backgroundColor: Colors.black12, textAlign: PlutoColumnTextAlign.center, title: headerList[index], field: headerList[index], hide: headerList[index] == "ID" ? showHideHeaderList[index][headerList[index]] : !showHideHeaderList[index][headerList[index]], type: PlutoColumnType.text());
      } else {
        return PlutoColumn(backgroundColor: Colors.black12, textAlign: PlutoColumnTextAlign.center, title: headerList[index], field: headerList[index], hide: !showHideHeaderList[index][headerList[index]], type: PlutoColumnType.text());
      }
    });
    return plutoColumns;
  }

  //INITIALIZE BUILD
  Future<void> initBuildTable() async {
    setState(() {
      yearList = widget.sheetList;
    });
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
    processInfo = true;
  }

  //Get OptionalValue
  Future<List<String>> getOptionalValue(String selector) async {
    List<String> optionaList = [];
    await apiService.getHeader("https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?request_type=1&sheet=optional").then((optionalItems) {
      // if (selector != "Location") {
      //   optionaList.add('Select All');
      // }
      for (var item in optionalItems) {
        if (item[selector].isNotEmpty) {
          setState(() {
            optionaList.add('${item[selector]}');
          });
        }
      }
    });
    return optionaList;
  }

  //Get HeadeValues ---<URL>
  Future<List<String>> getHeaderValues(String sheetName) async {
    headerList.clear();
    await apiService.getHeader("${ApiService.cctvUrl}request_type=2&sheet=$sheetName").then((headers) {
      for (var header in headers) {
        setState(() {
          headerList.add('$header');
        });
      }
    });
    return headerList;
  }

  //Get CellValues ---<URL>
  Future<List<Map<String, dynamic>>> getCellValues(String sheetName, {String filterColumn = "", String filterValue = ""}) async {
    await apiService.fetchData(hostUrl: ApiService.cctvUrl, requestType: "1", sheet: sheetName).then((cells) {
      sheetRowCount = cells.length;
      cellsList.clear();
      if (filterColumn.isNotEmpty && filterValue != 'Select All') {
        for (var cell in cells) {
          var cellData = cell;
          if (cell[filterColumn] == filterValue) {
            setState(() {
              cellsList.add(cellData);
            });
          }
        }
      } else {
        for (var cell in cells) {
          var cellData = cell;
          setState(() {
            cellsList.add(cellData);
          });
        }
      }
    });

    return cellsList;
  }

  //Get FilterCells
  Future<List<Map<String, dynamic>>> getFilterCells(String filterColum, String filterValue, List<Map<String, dynamic>> dataList) async {
    List<Map<String, dynamic>> responseDataList = [];
    for (var datas in dataList) {
      Map<String, dynamic> cellData = {};

      cellData = dataList.firstWhere((cells) {
        if (cells[filterColum] == filterValue) {
          return true;
        } else {
          return false;
        }
      });
      responseDataList.add(cellData);
    }
    return responseDataList;
  }

  //Get FilterValue
  List<String> getFilterValue(String headerName, String responseValue) {
    List<String> filterList = [];
    // List<Map<String, dynamic>> filterData =
    //     utilService.removeDuplicates(cellsList, "$headerName");
    // filterData.forEach((filterValue) {
    //   filterList.add(filterValue[responseValue]);
    // });

    return filterList;
  }

  //Get ItemList
  List<dynamic> getItemList(
    List<Map> dataList,
  ) {
    List<dynamic> itemList = [];
    for (var data in dataList) {
      setState(() {
        itemList.add(data);
      });
    }
    return itemList;
  }

  //Add Row
  Future<void> addRow() async {
    List<PlutoRow> rowList = [];
    List<String> dataList = [];
    //List<String>
    var data = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: LayoutBuilder(builder: (ctx, size) {
              return Container(
                padding: const EdgeInsets.all(15),
                width: 400,
                height: MediaQuery.of(context).size.height / 1.1,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Center(
                        child: Text(
                      "Add new purchased item",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                    Column(
                      children: List.generate(headerList.length, (index) {
                        if (headerList[index] == "No.") {
                          _controllers[headerList[index]]!.text = "${sheetRowCount + 1}";
                          return ListTile(
                            title: const Text("ROW ID"),
                            subtitle: TextFormField(
                              enabled: false,
                              controller: _controllers[headerList[index]],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(width: 0.5),
                                ),
                                hintText: headerList[index],
                              ),
                            ),
                          );
                        } else if (headerList[index] == "ID") {
                          return ListTile(
                            title: const Text("UUID"),
                            subtitle: TextFormField(
                              enabled: false,
                              controller: _controllers[headerList[index]],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(width: 0.5),
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
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            subtitle: headerList[index] == "Position" || headerList[index] == "Location" || headerList[index] == "Department" || headerList[index] == "Position" || headerList[index] == "Type"
                                ? CustomDropdownSearch(
                                    itemList: setList(headerList[index]),
                                    lable: headerList[index],
                                    onChange: (selectedItem) {
                                      _controllers[headerList[index]].text = selectedItem;
                                    },
                                  )
                                : TextFormField(
                                    controller: _controllers[headerList[index]],
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(width: 0.5),
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
                              _controllers.forEach((editKey, editController) {
                                dataList.add(editController.value!.text);
                                rowList.add(PlutoRow(cells: {}));
                              });
                              Navigator.pop(ctx, dataList);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
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

    stateManager.setShowLoading(true);
    Map<String, PlutoCell> plutoCellObject = {};

    _controllers.forEach((key, val) {
      plutoCellObject[key] = PlutoCell(
        value: val.value!.text.toString(),
      );
    });
    rowList.add(PlutoRow(cells: plutoCellObject));

    if (data == null || data.isEmpty) {
      stateManager.setShowLoading(false);
      return;
    } else {
      //SET ---<URL>
      await apiService.fetchData(hostUrl: ApiService.cctvUrl, sheet: selectedYear, requestType: "3", row: (int.parse(data[0]) + 1).toString(), data: "${data.join(',')}").then((response) {
        stateManager.appendRows(rowList);
        stateManager.setShowLoading(false);
      });
    }
  }

  //Update Row
  Future<void> updateRow(PlutoRow? row) async {
    List<String> data = [];
    //Map<String, dynamic>
    var value = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: LayoutBuilder(
              builder: (ctx, size) {
                return Container(
                  padding: const EdgeInsets.all(15),
                  width: 400,
                  height: MediaQuery.of(context).size.height / 1.1,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              child: ListTile(
                                title: Text(e.key),
                                subtitle: e.key == "Position" || e.key == "Location" || e.key == "Department" || e.key == "Position" || e.key == "Type"
                                    ? CustomDropdownSearch(
                                        itemList: setList(e.key),
                                        lable: e.value.value.toString(),
                                        onChange: (selectedItem) {
                                          _controllers[e.key].text = "$selectedItem";
                                        },
                                      )
                                    : TextFormField(
                                        controller: _controllers[e.key],
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4),
                                            borderSide: const BorderSide(width: 0.5),
                                          ),
                                          hintText: e.key,
                                        ),
                                      ),
                              ),
                            );
                          } else {
                            return Text('Row နံပါတ် (${e.value.value}) ကို Edit ပြုလုပ်ရန်အတွက် Password လိုအပ်ပါသည်။.');
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
                                  _controllers.forEach((editKey, editController) {
                                    data.add(editController.value!.text);
                                  });
                                  Navigator.pop(ctx, _controllers);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
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
      //SET ---<URL>
      await apiService.fetchData(hostUrl: ApiService.cctvUrl, sheet: selectedYear, requestType: "3", row: (int.parse(value[headerList[0]]!.text) + 1).toString(), data: data.join(',')).then((response) {
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
          final dataController = TextEditingController();

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: LayoutBuilder(
              builder: (ctx, size) {
                dataController.text = cell!.value.toString();

                return Container(
                  padding: const EdgeInsets.all(15),
                  width: 300,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: ListTile(
                            title: Text(cell.column.title),
                            subtitle: cell.column.title == "Location" || cell.column.title == "Position" || cell.column.title == "Department" || cell.column.title == "Type"
                                ? CustomDropdownSearch(
                                    itemList: setList(cell.column.title),
                                    lable: cell.value.toString(),
                                    onChange: (selectedItem) {
                                      dataController.text = selectedItem!;
                                    },
                                  )
                                : TextFormField(
                                    controller: dataController,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(width: 0.5),
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
                                    if (cell.column.title == headerList[i]) {
                                      data['column'] = i + 1;
                                    }
                                  }
                                  data['row'] = (cell.row.cells[headerList[0]]!.value) + 1;
                                  data['value'] = dataController.text;
                                  Navigator.pop(ctx, data);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
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
      //SET ---<URL>
      await apiService
          .fetchData(
        sheet: selectedYear,
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Update Successfully",
            style: TextStyle(color: Colors.green),
          )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Update failed",
            style: TextStyle(color: Colors.red),
          )));
        }
        stateManager.setShowLoading(false);
      });
    }
  }

  //Export PDF
  void exportToPdf() async {
    var plutoGridPdfExport = pluto_grid_export.PlutoGridDefaultPdfExport(
      title: selectedYear,
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

    var exported = const Utf8Encoder().convert(pluto_grid_export.PlutoGridExport.exportCSV(stateManager));
    DateTime now = DateTime.now();
    String dateTimeFormat = DateFormat('dd-MM-yyyy_hh:mm').format(now);
    // use file_saver from pub.dev
    await FileSaver.instance.saveFile(name: "${title}_$dateTimeFormat", ext: "csv", bytes: exported);
  }

  //INITIALIZE
  @override
  void initState() {
    initBuildTable().then((value) {
      setState(() {
        DateTime now = DateTime.now();
        String year = DateFormat('yyyy').format(now);
        selectedYear = year;
        sheetList = widget.sheetList;
        getCellValues(selectedYear).then(
          (cells) {
            getHeaderValues(selectedYear).then((headers) {
              for (var header in headerList) {
                setState(() {
                  showHideHeaderList.add({header: true});
                });
              }
            });
          },
        );
      });
    });
    super.initState();
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        headerList.isNotEmpty
            ? Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: MediaQuery.of(context).size.height / 1.2,
                        child: PlutoGrid(
                          onLoaded: (event) {
                            event.stateManager.setShowColumnFilter(true);
                            stateManager = event.stateManager;
                            stateManager.setSelectingMode(PlutoGridSelectingMode.row);
                            stateManager.setFilter((element) => true);
                            // for (PlutoColumn col in plutoColumns) {
                            //   stateManager.autoFitColumn(context, col);
                            // }
                          },
                          onChanged: (PlutoGridOnChangedEvent event) {},
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
                            print(yearList.length);
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  //Choose Location
                                  CustomDropdownSearch(
                                    width: 6,
                                    lable: selectedYear,
                                    itemList: yearList,
                                    onChange: (selectedItem) {
                                      setState(() {
                                        if (selectedYear.isNotEmpty) {
                                          stateManager.setShowLoading(true);
                                        }
                                        selectedYear = selectedItem!;
                                        processInfo = true;
                                      });
                                      getCellValues(selectedYear).then(
                                        (cells) {
                                          getHeaderValues(selectedYear).then((headers) {
                                            for (var header in headerList) {
                                              showHideHeaderList.add({header: true});
                                            }
                                            setState(() {
                                              if (selectedYear.isNotEmpty) {
                                                stateManager.setShowLoading(false);
                                              }
                                            });
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      //Set Filter Columns
                                      IconButton(
                                        icon: const Icon(Icons.filter_list_alt),
                                        onPressed: () {
                                          showModal(context, Builder(
                                            builder: (context) {
                                              return Expanded(
                                                child: SizedBox(
                                                  width: MediaQuery.of(context).size.width / 3,
                                                  child: StatefulBuilder(builder: (context, onState) {
                                                    return ListView.builder(
                                                      itemCount: headerList.length,
                                                      itemBuilder: (context, index) {
                                                        return ListTile(
                                                          title: Text(headerList[index]),
                                                          leading: Checkbox(
                                                              value: showHideHeaderList[index][headerList[index]],
                                                              onChanged: (status) {
                                                                onState(() {
                                                                  showHideHeaderList[index][headerList[index]] = status!;
                                                                  stateManager.hideColumn(plutoColumns[index], status == true ? false : true, notify: true);
                                                                });
                                                              }),
                                                        );
                                                      },
                                                    );
                                                  }),
                                                ),
                                              );
                                            },
                                          ), title: "Filter Columns", topActions: [
                                            SizedBox(
                                              width: 200,
                                              child: SizedBox(
                                                child: ListTile(
                                                  trailing: Checkbox(onChanged: (status) {}, value: true),
                                                  title: const Text("Select All"),
                                                ),
                                              ),
                                            ),
                                          ], bottomActions: []);
                                        },
                                      ),
                                      //Add Row
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          addRow();
                                        },
                                      ),
                                      //ExportCSV
                                      IconButton(
                                        onPressed: () {
                                          exportToCsv();
                                        },
                                        icon: const Icon(Icons.download),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          createFooter: ((stateManager) {
                            stateManager.setPageSize(50, notify: false);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(width: MediaQuery.of(context).size.width / 2, child: PlutoPagination(stateManager)),
                                Text("Total Rows : $sheetRowCount"),
                              ],
                            );
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
                          rows: List<PlutoRow>.generate(cellsList.length, (index) {
                            Map<String, PlutoCell> cells = {};
                            for (var header in headerList) {
                              if (header == "No.") {
                                cells[header] = PlutoCell(value: index + 1);
                              } else if (header == "ID") {
                                cells[header] = PlutoCell(
                                  value: "*****",
                                );
                              } else {
                                cells[header] = PlutoCell(value: cellsList[index][header]);
                              }
                            }
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
                            title: "Loading...",
                            color: processInfo ? Colour.blue : Colors.red,
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
