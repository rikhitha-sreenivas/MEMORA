class FlashcardModel {
  final String id;
  final String question;
  final String answer;

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FlashcardModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return FlashcardModel(
      id: id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}