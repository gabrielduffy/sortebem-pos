class Terminal {
  final String terminalId;
  final Establishment establishment;

  Terminal({required this.terminalId, required this.establishment});

  factory Terminal.fromJson(Map<String, dynamic> json) {
    return Terminal(
      terminalId: json['terminal_id'],
      establishment: Establishment.fromJson(json['establishment']),
    );
  }
}

class Establishment {
  final int id;
  final String name;

  Establishment({required this.id, required this.name});

  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      id: json['id'],
      name: json['name'],
    );
  }
}
