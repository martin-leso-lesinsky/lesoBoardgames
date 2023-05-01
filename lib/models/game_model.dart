class Game {
  final String objectId;
  final String collId;
  final String name;
  final String image;
  final String thumbnail;
  final int yearPublished;
  final bool statusOwn;
  final int numPlays;

  Game({
    required this.objectId,
    required this.collId,
    required this.name,
    required this.image,
    required this.thumbnail,
    required this.yearPublished,
    required this.statusOwn,
    required this.numPlays,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      objectId: json['objectid'] ?? '',
      collId: json['collid'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      statusOwn: json['status'] != null ? json['status']['own'] == '1' : false,
      numPlays:
          json['numplays'] != null ? int.tryParse(json['numplays']) ?? 0 : 0,
      yearPublished: int.tryParse(json['yearpublished']) ?? 0,
    );
  }
}
