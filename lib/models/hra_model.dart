const String tableHras = 'hras';

class HraFields {
  static final List<String> values = [
    objectId,
    subtype,
    collId,
    name,
    yearPublished,
    image,
    thumbnail,
    statusOwn,
    numPlays,
    gameValue,
    obtainDate
  ];

  static const String objectId = 'objectId';
  static const String subtype = 'subtype';
  static const String collId = 'collId';
  static const String name = 'name';
  static const String yearPublished = 'yearPublished';
  static const String image = 'image';
  static const String thumbnail = 'thumbnail';
  static const String statusOwn = 'statusOwn';
  static const String numPlays = 'numPlays';
  static const String gameValue = 'gameValue';
  static const String obtainDate = 'obtainDate';
}

class Hra {
  final int objectId;
  final String subtype;
  final String collId;
  final String name;
  final String yearPublished;
  final String image;
  final String thumbnail;
  final bool statusOwn;
  final int numPlays;
  final int gameValue;
  final String obtainDate;

  const Hra({
    required this.objectId,
    required this.subtype,
    required this.collId,
    required this.name,
    required this.yearPublished,
    required this.image,
    required this.thumbnail,
    required this.statusOwn,
    required this.numPlays,
    this.gameValue = 0,
    this.obtainDate = '1900', // Optional parameter
  });
  // }) : obtainDate = obtainDate ?? DateTime(2017, 9, 7, 17, 30);

  Hra copy({
    // int? id,
    int? objectId,
    String? subtype,
    String? collId,
    String? name,
    String? yearPublished,
    String? image,
    String? thumbnail,
    bool? statusOwn,
    int? numPlays,
    int? gameValue,
    String? obtainDate,
  }) =>
      Hra(
        objectId: objectId ?? this.objectId,
        subtype: subtype ?? this.subtype,
        collId: collId ?? this.collId,
        name: name ?? this.name,
        yearPublished: yearPublished ?? this.yearPublished,
        image: image ?? this.image,
        thumbnail: thumbnail ?? this.thumbnail,
        statusOwn: statusOwn ?? this.statusOwn,
        numPlays: numPlays ?? this.numPlays,
        gameValue: gameValue ?? this.gameValue,
        obtainDate: obtainDate ?? this.obtainDate,
      );

  static Hra fromJson(Map<String, Object?> json) => Hra(
        objectId: json[HraFields.objectId] as int,
        subtype: json[HraFields.subtype] as String,
        collId: json[HraFields.collId] as String,
        name: json[HraFields.name] as String,
        yearPublished: json[HraFields.yearPublished] as String? ?? 'N/A',
        image: json[HraFields.image] as String? ?? '',
        thumbnail: json[HraFields.thumbnail] as String,
        statusOwn: (json[HraFields.statusOwn] as int) == 1,
        numPlays: json[HraFields.numPlays] as int? ?? 0,
        gameValue: json[HraFields.gameValue] as int? ?? 0,
        obtainDate: json[HraFields.obtainDate] as String,
      );

  Map<String, Object?> toJson({bool includeId = true}) {
    final json = {
      HraFields.objectId: objectId,
      HraFields.subtype: subtype,
      HraFields.collId: collId,
      HraFields.name: name,
      HraFields.yearPublished: yearPublished,
      HraFields.image: image,
      HraFields.thumbnail: thumbnail,
      HraFields.statusOwn: statusOwn ? 1 : 0,
      HraFields.numPlays: numPlays,
      HraFields.gameValue: gameValue,
      HraFields.obtainDate: obtainDate,
    };

    return json;
  }
}
