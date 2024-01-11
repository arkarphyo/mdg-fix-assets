class UtilService {
  List<Map<String, dynamic>> removeDuplicates(
      List<Map<String, dynamic>> list, String key) {
    Set<dynamic> seen = Set<dynamic>();
    List<Map<String, dynamic>> result = [];

    for (Map<String, dynamic> item in list) {
      if (!seen.contains(item[key])) {
        seen.add(item[key]);
        result.add(item);
      }
    }

    return result;
  }
}
