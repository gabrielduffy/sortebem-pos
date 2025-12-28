import 'card.dart';

class SaleRequest {
  final int roundId;
  final int quantity;
  final String paymentMethod;
  final String cardBrand;
  final String cardLastDigits;
  final String transactionId;

  SaleRequest({
    required this.roundId,
    required this.quantity,
    required this.paymentMethod,
    required this.cardBrand,
    required this.cardLastDigits,
    required this.transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'round_id': roundId,
      'quantity': quantity,
      'payment_method': paymentMethod,
      'card_brand': cardBrand,
      'card_last_digits': cardLastDigits,
      'transaction_id': transactionId,
    };
  }
}

class SaleResponse {
  final int purchaseId;
  final List<BingoCard> cards;

  SaleResponse({required this.purchaseId, required this.cards});

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      purchaseId: json['purchase_id'],
      cards: (json['cards'] as List).map((i) => BingoCard.fromJson(i)).toList(),
    );
  }
}
