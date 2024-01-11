import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mdg_fixasset/Utils/ApiService.dart';
import 'package:dropdown_model_list/dropdown_model_list.dart';
import 'package:mdg_fixasset/Utils/UtilService.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.sheetList});
  final List<String> sheetList;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ApiService apiService = ApiService();
  UtilService utilService = UtilService();

  String processInfo = "";

  List<Map<String, dynamic>> cellsList = [];

  List<String> headerList = [];
  List<String> sheetList = [];

  TextEditingController sheetDropdownSearchController = TextEditingController();
  TextEditingController departmentDropdownSearchController =
      TextEditingController();

  List<String> departmentList = [];
  List<String> positionList = [];
  List<String> locationList = [];

  //INITIALIZE BUILD
  Future<void> initBuildTable() async {
    getOptionalValue("Department").then((department) {
      setState(() {
        departmentList = department;
      });
    });
    getOptionalValue("Location").then((location) {
      setState(() {
        locationList = location;
      });
    });

    getOptionalValue("Position").then((position) {
      setState(() {
        positionList = position;
      });
    });
    processInfo = "First you need to selected a Sheet!";
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

  Future<List<Map<String, dynamic>>> getCellValues(String sheetName) async {
    await apiService
        .fetchData(
            "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?request_type=1&sheet=$sheetName")
        .then((cells) {
      cellsList.clear();
      cells.forEach((cell) {
        var cellData = cell;
        setState(() {
          cellsList.add(cellData);
        });
      });
    });

    return cellsList;
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

  @override
  void initState() {
    initBuildTable().then((value) {
      setState(() {
        sheetList = widget.sheetList;
      });
    });

    print(sheetList.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sheetList.length > 0) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdownSearch(
                  width: 6,
                  lable: "Choose Sheet",
                  itemList: sheetList,
                  onChange: (selectedItem) {
                    print("Selected Item : $selectedItem");
                    setState(() {
                      processInfo = "Processing...";
                    });
                    getCellValues(selectedItem!).then(
                      (cells) {
                        getHeaderValues(selectedItem!).then((headers) {
                          setState(() {
                            print(
                                "SHEET : ${selectedItem}, FILTER : ${headers[3]}, Cells Count : ${cells.length}, Department Count : ${departmentList.length}");
                          });
                        });
                      },
                    );
                  },
                ),

                CustomDropdownSearch(
                  width: 6,
                  lable: "Choose Location",
                  itemList: locationList,
                  onChange: (selectedItem) {
                    print("Location Item : $selectedItem");
                  },
                ),
                CustomDropdownSearch(
                  width: 6,
                  lable: "Choose Department",
                  itemList: departmentList,
                  onChange: (selectedItem) {
                    print("Department Item : $selectedItem");
                  },
                ),
                CustomDropdownSearch(
                  width: 6,
                  lable: "Choose Position",
                  itemList: positionList,
                  onChange: (selectedItem) {
                    print("Postion Item : $selectedItem");
                  },
                ),

                ///Search DropDown
                // Container(
                //   width: MediaQuery.of(context).size.width / 4,
                //   child: SearchDropList(
                //     itemSelected: selectedSheet,
                //     dropListModel: sheetListModel,
                //     showIcon: true,
                //     showArrowIcon: true,
                //     showBorder: true,
                //     textEditingController: sheetDropdownSearchController,
                //     paddingTop: 0,
                //     suffixIcon: Icons.arrow_drop_down,
                //     containerPadding: const EdgeInsets.all(10),
                //     icon: const Icon(Icons.groups_2_rounded, color: Colors.black),
                //     onOptionSelected: (optionItem) {
                //       selectedSheet = optionItem;
                //       getHeaderValues(selectedSheet.title).then((headers) {
                //         setState(() {
                //           departmentList = getFilterValue(headers[2], headers[2]);
                //           setOptionItem(departmentList, departmentOptionItemList);
                //           showDepartmentDropDown = true;
                //           departmentListModel =
                //               DropListModel(departmentOptionItemList);

                //           print(
                //               "SHEET : ${selectedSheet.title}, FILTER : ${headers[2]}, Department Count : ${departmentListModel.listOptionItems.length}");
                //         });
                //       });
                //     },
                //   ),
                // ),

                // Visibility(
                //   visible: showDepartmentDropDown,
                //   child: Container(
                //     width: MediaQuery.of(context).size.width / 4,
                //     child: SearchDropList(
                //       itemSelected: selectedDepartment,
                //       dropListModel: departmentListModel,
                //       showIcon: true,
                //       showArrowIcon: true,
                //       showBorder: true,
                //       textEditingController: departmentDropdownSearchController,
                //       paddingTop: 0,
                //       suffixIcon: Icons.arrow_drop_down,
                //       containerPadding: const EdgeInsets.all(10),
                //       icon:
                //           const Icon(Icons.groups_2_rounded, color: Colors.black),
                //       onOptionSelected: (optionItem) {},
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          cellsList.length > 0 && headerList.length > 0
              ? Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                          //     List.generate(headerList.length, (index) {
                          //   return Text(headerList[index]);
                          // })
                          [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: MediaQuery.of(context).size.height / 1.2,
                          child: PlutoGrid(
                              columns: List<PlutoColumn>.generate(
                                  headerList.length, (index) {
                                if (headerList[index] == "No.") {
                                  return PlutoColumn(
                                      width: 50,
                                      minWidth: 45,
                                      backgroundColor: Colors.black54,
                                      textAlign: PlutoColumnTextAlign.center,
                                      title: headerList[index],
                                      field: headerList[index],
                                      type: PlutoColumnType.text());
                                } else {
                                  return PlutoColumn(
                                      backgroundColor: Colors.black54,
                                      textAlign: PlutoColumnTextAlign.center,
                                      title: headerList[index],
                                      field: headerList[index],
                                      type: PlutoColumnType.text());
                                }
                              }),
                              rows: List<PlutoRow>.generate(cellsList.length,
                                  (index) {
                                Map<String, PlutoCell> cells = {};
                                headerList.forEach((header) {
                                  if (header == "No.") {
                                    cells[header] = PlutoCell(value: index + 1);
                                  } else {
                                    cells[header] = PlutoCell(
                                        value: cellsList[index][header]);
                                  }
                                });
                                PlutoRow row = PlutoRow(cells: cells);
                                return row;
                              })),
                        )
                      ],
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 1.2,
                  child: Center(
                    child: LoadingWidget(
                      title: "$processInfo",
                    ),
                  ),
                )
        ],
      );
      //TableView(widget: widget, cellsList: cellsList, headerValues: headerValues, headerList: headerList);
    } else {
      return LoadingWidget();
    }
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.title = "LOADING...",
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text("$title"),
          Container(
              height: 1,
              width: MediaQuery.of(context).size.width / 4,
              child: LinearProgressIndicator()),
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

//Table View
// class TableView extends StatefulWidget {
//   const TableView({
//     super.key,
//     required this.widget,
//     required this.cellsList,
//     required this.headers,
//   });

//   final DashboardScreen widget;
//   final List<Map<String, dynamic>> cellsList;
//   final List<String> headers;

//   @override
//   State<TableView> createState() => _TableViewState();
// }

// class _TableViewState extends State<TableView> {
//   List<DataColumn2> headrsList = [];

//   @override
//   void initState() {
//     widget.headers.forEach((header) {
//       DataColumn2 headerData = DataColumn2(
//         label: Text("$header"),
//         size: ColumnSize.M,
//       );
//       headrsList.add(headerData);
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width / 1.2,
//       height: MediaQuery.of(context).size.height / 1.3,
//       child: Column(children: [
//         Expanded(
//           flex: 1,
//           child: DataTable2(
//             columnSpacing: 12,
//             horizontalMargin: 12,
//             minWidth: 600,
//             isHorizontalScrollBarVisible: true,
//             columns: headrsList,
//             rows: List<DataRow>.generate(
//                 widget.cellsList.length,
//                 (rowIndex) => DataRow(
//                         cells: List<DataCell>.generate(
//                       widget.headers.length,
//                       (cellIndex) => DataCell(
//                         FittedBox(
//                           fit: BoxFit.contain,
//                           child: Text(
//                               "${widget.cellsList[rowIndex][widget.headers[cellIndex]]}"),
//                         ), //cellsList[rowIndex][headerValues[cellIndex]] ??
//                       ),
//                     ))),
//           ),
//         ),
//       ]),
//     );
//   }
// }
