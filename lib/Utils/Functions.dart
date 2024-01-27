import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class Functions {
  List<PlutoColumn> setColum(
      List<PlutoColumn> plutoColumns,
      List<String> headerList,
      List<Map<String, dynamic>> showHideHeaderList,
      Map<String, dynamic> _controllers) {
    plutoColumns = List<PlutoColumn>.generate(headerList.length, (index) {
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
    return plutoColumns;
  }
}
