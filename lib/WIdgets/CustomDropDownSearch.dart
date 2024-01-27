//CustomDropdownSearch Widget
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

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
