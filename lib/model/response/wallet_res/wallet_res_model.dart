class WalletResModel {
  WalletResModel({required this.success, required this.data});

  final bool? success;
  final Data? data;

  factory WalletResModel.fromJson(Map<String, dynamic> json) {
    return WalletResModel(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.wallet,
    required this.transactions,
    required this.pagination,
  });

  final Wallet? wallet;
  final List<Transaction> transactions;
  final Pagination? pagination;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
      transactions: json["transactions"] == null
          ? []
          : List<Transaction>.from(
              json["transactions"]!.map((x) => Transaction.fromJson(x)),
            ),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
    );
  }
}

class Pagination {
  Pagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
  });

  final int? total;
  final int? currentPage;
  final int? totalPages;
  final int? limit;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json["total"],
      currentPage: json["currentPage"],
      totalPages: json["totalPages"],
      limit: json["limit"],
    );
  }
}

class Transaction {
  Transaction({
    required this.id,
    required this.wallet,
    required this.user,
    required this.type,
    required this.source,
    required this.amount,
    required this.balanceAfter,
    required this.reference,
    required this.notes,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? wallet;
  final String? user;
  final String? type;
  final String? source;
  final int? amount;
  final int? balanceAfter;
  final String? reference;
  final String? notes;
  final Meta? meta;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json["_id"],
      wallet: json["wallet"],
      user: json["user"],
      type: json["type"],
      source: json["source"],
      amount: json["amount"],
      balanceAfter: json["balanceAfter"],
      reference: json["reference"],
      notes: json["notes"],
      meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}

class Meta {
  Meta({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      razorpayOrderId: json["razorpayOrderId"],
      razorpayPaymentId: json["razorpayPaymentId"],
      razorpaySignature: json["razorpaySignature"],
    );
  }
}

class Wallet {
  Wallet({
    required this.id,
    required this.user,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? user;
  final num? balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json["_id"],
      user: json["user"],
      balance: json["balance"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}
