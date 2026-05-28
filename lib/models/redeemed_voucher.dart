class RedeemedVoucher {
  final int id;
  final int? couponId;
  final String title;
  final String code;
  final DateTime date;
  final String? billType;
  final String? consumerNumber;
  final String? providerName;
  final double? amountPaid;

  RedeemedVoucher({
    required this.id,
    this.couponId,
    required this.title,
    required this.code,
    required this.date,
    this.billType,
    this.consumerNumber,
    this.providerName,
    this.amountPaid,
  });

  factory RedeemedVoucher.fromJson(Map<String, dynamic> json) {
    String displayTitle = 'Voucher #${json['id']}';
    if (json['bill_type'] != null) {
      final type = json['bill_type'].toString().replaceAll('_', ' ').toUpperCase();
      final amount = json['amount_paid'] != null ? '₹${json['amount_paid']}' : '';
      displayTitle = '$amount $type'.trim();
    }

    return RedeemedVoucher(
      id: json['id'],
      couponId: json['reward_id'],
      title: displayTitle,
      code: json['voucher_code'],
      date: DateTime.parse(json['timestamp']),
      billType: json['bill_type'],
      consumerNumber: json['consumer_number'],
      providerName: json['provider_name'],
      amountPaid: json['amount_paid'] != null ? (json['amount_paid'] as num).toDouble() : null,
    );
  }
}
