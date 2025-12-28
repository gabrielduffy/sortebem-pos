class RoundResponse {
  final Round? regular;
  final Round? special;

  RoundResponse({this.regular, this.special});

  factory RoundResponse.fromJson(Map<String, dynamic> json) {
    return RoundResponse(
      regular: json['regular'] != null ? Round.fromJson(json['regular']) : null,
      special: json['special'] != null ? Round.fromJson(json['special']) : null,
    );
  }
}

class Round {
  final int id;
  final int number;
  final String type;
  final double cardPrice;
  final DateTime sellingEndsAt;

  Round({
    required this.id,
    required this.number,
    required this.type,
    required this.cardPrice,
    required this.sellingEndsAt,
  });

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      id: json['id'],
      number: json['number'],
      type: json['type'],
      cardPrice: double.parse(json['card_price']),
      sellingEndsAt: DateTime.parse(json['selling_ends_at']),
    );
  }
}
