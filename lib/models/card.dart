class BingoCard {
  final int? id;
  final String code;
  final List<List<int>> numbers;

  BingoCard({
    this.id,
    required this.code,
    required this.numbers,
  });

  factory BingoCard.fromJson(Map<String, dynamic> json) {
    var numbersJson = json['numbers'] as List;
    List<List<int>> parsedNumbers = numbersJson.map((list) => (list as List).map((n) => n as int).toList()).toList();
    
    return BingoCard(
      id: json['id'],
      code: json['code'],
      numbers: parsedNumbers,
    );
  }
}
