// ignore_for_file: constant_identifier_names

class SharedFile {
  /// Image or Video path or text
  /// NOTE. for iOS only the file is always copied
  final String value;

  /// Video thumbnail
  final String? thumbnail;

  /// Video duration in milliseconds
  final int? duration;

  /// Whether its a video or image or file
  final SharedMediaType type;

  SharedFile(
      {required this.value,
      this.thumbnail,
      this.duration,
      this.type = SharedMediaType.FILE});

  SharedFile.fromJson(Map<String, dynamic> json)
      : value = json['value'],
        thumbnail = json['thumbnail'],
        duration = json['duration'],
        type = SharedMediaType.values[json['type']];

  @override
  String toString() {
    return "{ value:$value, thumbnail:$thumbnail, duration:$duration, type:$type }";
  }
}

enum SharedMediaType { TEXT, IMAGE, VIDEO, FILE, URL }
