import "dart:convert";

import "package:http/http.dart" as http;

class ApiService {
  Future<List<dynamic>> fetchData(String url) async {
    final response = await http.get(
      Uri.parse(
        url,
      ),
    );
    if (response.statusCode == 200) {
      json.decode(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<String>> getSheet(String url) async {
    List<String> responsedata = [];
    List<dynamic> sheetList = [];
    final response = await http.get(
      Uri.parse(
        url,
      ),
    );
    if (response.statusCode == 200) {
      sheetList = json.decode(response.body);
      sheetList.forEach((val) {
        responsedata.add(val.toString());
      });
      return responsedata;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> getHeader(String url) async {
    List<dynamic> responsedata = [];
    final response = await http.get(
      Uri.parse(
        url,
      ),
    );
    if (response.statusCode == 200) {
      responsedata = json.decode(response.body);
      return responsedata;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
