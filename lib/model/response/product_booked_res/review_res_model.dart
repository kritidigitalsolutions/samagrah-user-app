import 'package:samagrah/model/response/product_res/product_response_model.dart';

class ReviewResModel {
  ReviewResModel({required this.success, required this.data});

  final bool? success;
  final Data? data;

  factory ReviewResModel.fromJson(Map<String, dynamic> json) {
    return ReviewResModel(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.ratings,
    required this.reviews,
    required this.pagination,
  });

  final Ratings? ratings;
  final List<Review> reviews;
  final Pagination? pagination;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      ratings: json["ratings"] == null
          ? null
          : Ratings.fromJson(json["ratings"]),
      reviews: json["reviews"] == null
          ? []
          : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
    );
  }
}

class Pagination {
  Pagination({
    required this.totalReviews,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
  });

  final int? totalReviews;
  final int? currentPage;
  final int? totalPages;
  final int? limit;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalReviews: json["totalReviews"],
      currentPage: json["currentPage"],
      totalPages: json["totalPages"],
      limit: json["limit"],
    );
  }
}

// class Ratings {
//     Ratings({
//         required this.average,
//         required this.totalReviews,
//         required this.counts,
//     });

//     final int? average;
//     final int? totalReviews;
//     final Counts? counts;

//     factory Ratings.fromJson(Map<String, dynamic> json){
//         return Ratings(
//             average: json["average"],
//             totalReviews: json["totalReviews"],
//             counts: json["counts"] == null ? null : Counts.fromJson(json["counts"]),
//         );
//     }

// }

// class Counts {
//     Counts({
//         required this.rating1,
//         required this.rating2,
//         required this.rating3,
//         required this.rating4,
//         required this.rating5,
//     });

//     final int? rating1;
//     final int? rating2;
//     final int? rating3;
//     final int? rating4;
//     final int? rating5;

//     factory Counts.fromJson(Map<String, dynamic> json){
//         return Counts(
//             rating1: json["rating1"],
//             rating2: json["rating2"],
//             rating3: json["rating3"],
//             rating4: json["rating4"],
//             rating5: json["rating5"],
//         );
//     }
// }

class Review {
  Review({
    required this.id,
    required this.product,
    required this.user,
    required this.v,
    required this.comment,
    required this.createdAt,
    required this.rating,
    required this.updatedAt,
  });

  final String? id;
  final String? product;
  final User? user;
  final int? v;
  final String? comment;
  final DateTime? createdAt;
  final int? rating;
  final DateTime? updatedAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json["_id"],
      product: json["product"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      v: json["__v"],
      comment: json["comment"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      rating: json["rating"],
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }
}

class User {
  User({required this.id, required this.name, required this.profileImage});

  final String? id;
  final String? name;
  final String? profileImage;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      name: json["name"],
      profileImage: json["profileImage"],
    );
  }
}
