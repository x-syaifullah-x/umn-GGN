import 'package:global_net/pages/wallet/transfer.dart';

class TransactionModel {
  final String sender;
  final String receiver;
  final Type type;
  final int amount;
  final int createAt;
  final String transaction_id;

  const TransactionModel({
    required this.sender,
    required this.receiver,
    required this.type,
    required this.amount,
    required this.createAt,
    required this.transaction_id,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        sender: json[transactionsFieldSender],
        receiver: json[transactionsFieldReceiver],
        type: Type.values.byName('${json[transactionsFieldType]}'),
        amount: json[transactionsFieldAmount],
        createAt: json[transactionsFieldCreateAt],
        transaction_id: json.containsKey(transactionsFieldTransactionId)
            ? json[transactionsFieldTransactionId]
            : '',
      );

  Map<String, dynamic> toJson() => throw UnimplementedError('BarException');
}

enum Type {
  transfer,
  receive,
  purchase,
  create_coupon,
  delete_coupon,
  refund,
  pay_ggn_shop,
}
