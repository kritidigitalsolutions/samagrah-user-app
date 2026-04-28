class BannerResModel {
  BannerResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<BannerData> data;

  factory BannerResModel.fromJson(Map<String, dynamic> json) {
    return BannerResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<BannerData>.from(
              json["data"]!.map((x) => BannerData.fromJson(x)),
            ),
    );
  }
}

class BannerData {
  BannerData({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.description,
    required this.image,
    required this.priceOff,
    required this.status,
  });

  final String? id;
  final String? title;
  final String? subTitle;
  final String? description;
  final String? image;
  final String? priceOff;
  final String? status;

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json["_id"],
      title: json["title"],
      subTitle: json["subTitle"],
      description: json["description"],
      image: json["image"],
      priceOff: json["priceOff"],
      status: json["status"],
    );
  }
}
