import "dart:convert";

import "package:http/http.dart" as http;

class ApiService {
  static String gssUrl =
      "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?";

  Future<List<dynamic>> fetchData({
    String hostUrl = "",
    String requestType = "",
    String sheet = "",
    String row = "",
    String data = "",
  }) async {
    String url = "";
    if (hostUrl.isEmpty) {
      hostUrl = gssUrl;
    }
    url =
        "${hostUrl}request_type=${requestType}&sheet=${sheet}&row=${row}&data=${data}";
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
