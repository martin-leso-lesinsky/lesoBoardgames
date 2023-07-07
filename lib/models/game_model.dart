class Game {
  int? id;
  String objectId;
  String collId;
  String name;
  String image;
  String thumbnail;
  bool statusOwn;
  int numPlays;
  int yearPublished;

  Game({
    this.id,
    required this.objectId,
    required this.collId,
    required this.name,
    required this.image,
    required this.thumbnail,
    required this.statusOwn,
    required this.numPlays,
    required this.yearPublished,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'objectId': objectId,
      'collId': collId,
      'name': name,
      'image': image,
      'thumbnail': thumbnail,
      'statusOwn': statusOwn ? 1 : 0,
      'numPlays': numPlays,
      'yearPublished': yearPublished,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
        id: map['id'],
        objectId: map['objectId'],
        collId: map['collId'],
        name: map['name'],
        image: map['image'],
        thumbnail: map['thumbnail'],
        statusOwn: map['statusOwn'] == 1,
        numPlays: map['numPlays'],
        yearPublished: map['yearPublished']);
  }
}

/// TO DO  this should be used for generating list of expansions for game
class GameDetail {
  final String gameId;
  final String name;
  final int itemCount;

  GameDetail({
    required this.gameId,
    required this.name,
    required this.itemCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'name': name,
      'itemCount': itemCount,
    };
  }

  factory GameDetail.fromMap(Map<String, dynamic> map) {
    return GameDetail(
        gameId: map['id'], name: map['name'], itemCount: map['itemCount']);
  }
}
