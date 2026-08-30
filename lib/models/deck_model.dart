class DeckModel {
  final String id;
  final String title;
  final String description;
  final int cardCount;

  DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cardCount,
  });

  factory DeckModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return DeckModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      cardCount: data['cardCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'cardCount': cardCount,
    };
  }
}