//LOADING WIDGET
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
              width: MediaQuery.of(context).size.width / 8,
              child: LinearProgressIndicator(
                color: color,
              )),
        ],
      ),
    );
  }
}
