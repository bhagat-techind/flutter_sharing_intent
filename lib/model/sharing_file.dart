// ignore_for_file: constant_identifier_names

class SharedFile {
  /// Image or Video path or text
  /// NOTE. for iOS only the file is always copied
  String? value;

  /// Video thumbnail
  String? thumbnail;

  /// Video duration in milliseconds
  int? duration;

  /// Whether its a video or image or file
  SharedMediaType type = SharedMediaType.other;

  SharedFile({
    required this.value,
    this.thumbnail,
    this.duration,
    this.type = SharedMediaType.other,
  });

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

enum SharedMediaType { text, url, image, video, file, other }
