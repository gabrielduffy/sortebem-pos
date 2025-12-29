import 'card.dart';

class SaleResponse {
  final Purchase? purchase;
  final List<BingoCard> cards;

  SaleResponse({
    this.purchase,
    required this.cards,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      purchase: json['purchase'] != null ? Purchase.fromJson(json['purchase']) : null,
      cards: (json['cards'] as List).map((c) => BingoCard.fromJson(c)).toList(),
    );
  }
}

class Purchase {
  final int id;
  final double totalAmount;
  final String paymentStatus;

  Purchase({
    required this.id,
    required this.totalAmount,
    required this.paymentStatus,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentStatus: json['payment_status'],
    );
  }
}

class SaleRequest {
  final int roundId;
  final int quantity;
  final String paymentMethod;
  final String customerName;
  final String? customerPhone;
  final String? customerCpf;

  SaleRequest({
    required this.roundId,
    required this.quantity,
    required this.paymentMethod,
    required this.customerName,
    this.customerPhone,
    this.customerCpf,
  });

  Map<String, dynamic> toJson() {
    return {
      'round_id': roundId,
      'quantity': quantity,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_cpf': customerCpf,
    };
  }
}
