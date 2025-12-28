class BingoCard {
  final String code;
  final List<int> numbers;

  BingoCard({required this.code, required this.numbers});

  factory BingoCard.fromJson(Map<String, dynamic> json) {
    return BingoCard(
      code: json['code'],
      numbers: List<int>.from(json['numbers']),
    );
  }
}
