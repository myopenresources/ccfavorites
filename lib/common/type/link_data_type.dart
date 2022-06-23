class LinkDataType {
  String id;
  String fileName;
  String urlName;
  String url;
  String remarks;
  String filePath;
  bool selected;

  LinkDataType(this.id, this.fileName, this.filePath, this.urlName, this.url,
      this.remarks, this.selected);

  factory LinkDataType.fromJson(String id, String fileName, String filePath,
      String urlName, Map<String, dynamic> json) {
    String remarks = json.containsKey('remarks') ? json['remarks'] : '';
    return LinkDataType(
        id, fileName, filePath, urlName, json['url'], remarks, false);
  }
}
