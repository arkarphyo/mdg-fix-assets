import "dart:convert";

import "package:http/http.dart" as http;

class ApiService {
  static String gssUrl =
      "https://script.google.com/macros/s/AKfycbwr1L7s80xL344tVZsYLq5oPnFMvVBqK9vLCy92m2R1GxW0Tj_fzTsvU8bwyZg7yo4JUg/exec?";
  static String cctvUrl =
      "https://script.google.com/macros/s/AKfycbyXMyFZhBKUU_44R3D-Fr97iv-rxj_guCKBxUPTO8k5xhAVR6nFPLrnVS_0JdWtm4WUWg/exec?";
  static String mobileService =
      "https://script.google.com/macros/s/AKfycbyPcBD_oh4WLIURnZC45cSf6-VY8rNOe7rSwqBMbbTiGe-X7iT7GWfLncyWPqizy168Cw/exec?";

  Future<List<dynamic>> fetchData({
    String hostUrl = "",
    String requestType = "",
    String sheet = "",
    String row = "",
    String column = "",
    String data = "",
  }) async {
    try {
      String url = "";
      if (hostUrl.isEmpty) {
        hostUrl = gssUrl;
      }
      url =
          "${hostUrl}request_type=${requestType}&sheet=${sheet}&row=${row}&column=${column}&data=${data}";
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
    } catch (e) {
      return [
        {"success": false}
      ];
    }
  }

  Future<List<String>> getSheet(String url) async {
    if (url.isEmpty) {
      url = gssUrl;
    } else if (url == "cctv") {
      url = cctvUrl;
    }
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
        print(val.toString());
        responsedata.add(val.toString());
      });
      return responsedata;
    } else {
      return [];
    }
  }

  Future<List<dynamic>> getHeader(String url) async {
    if (url.isEmpty) {
      url = gssUrl;
    }
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
