class Contract {
  String type;
  double strikePrice;
  double bid;
  double ask;
  String longShort;

  Contract({
    required this.type,
    required this.strikePrice,
    required this.bid,
    required this.ask,
    required this.longShort,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      type: json['type'],
      strikePrice: json['strike_price'].toDouble(),
      bid: json['bid'].toDouble(),
      ask: json['ask'].toDouble(),
      longShort: json['long_short'],
    );
  }
}
