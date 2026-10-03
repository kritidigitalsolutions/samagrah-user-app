import 'package:samagrah/model/response/pandit_res/availability_res_model.dart';

class PanditResModel {
  PanditResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<PanditData> data;

  factory PanditResModel.fromJson(Map<String, dynamic> json) {
    return PanditResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<PanditData>.from(
              json["data"]!.map((x) => PanditData.fromJson(x)),
            ),
    );
  }
}

class PanditData {
  PanditData({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.profileImage,
    required this.bio,
    required this.ratingAverage,
    required this.ratingCount,
    required this.isPhoneVerified,
    required this.yearsOfExperience,
    required this.templeAssociated,
    required this.languagesSpoken,
    required this.isProfileComplete,
    required this.isVerified,
    required this.status,
    required this.address,
    //  required this.aadhaar,
    required this.serviceTypes,
    required this.poojaOfferings,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? phone;
  final String? fullName;
  final String? profileImage;
  final String? bio;
  final num? ratingAverage;
  final num? ratingCount;
  final bool? isPhoneVerified;
  final num? yearsOfExperience;
  final String? templeAssociated;
  final List<String> languagesSpoken;
  final bool? isProfileComplete;
  final bool? isVerified;
  final String? status;
  final PanditAddress? address;
  //  final Aadhaar? aadhaar;
  final ServiceTypes? serviceTypes;
  final List<PoojaOffering> poojaOfferings;
  final List<Availability> availability;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory PanditData.fromJson(Map<String, dynamic> json) {
    return PanditData(
      id: json["_id"],
      phone: json["phone"],
      fullName: json["fullName"],
      profileImage: json["profileImage"],
      bio: json["bio"],
      ratingAverage: json["ratingAverage"],
      ratingCount: json["ratingCount"],
      isPhoneVerified: json["isPhoneVerified"],
      yearsOfExperience: json["yearsOfExperience"],
      templeAssociated: json["templeAssociated"],
      languagesSpoken: json["languagesSpoken"] == null
          ? []
          : List<String>.from(json["languagesSpoken"]!.map((x) => x)),
      isProfileComplete: json["isProfileComplete"],
      isVerified: json["isVerified"],
      status: json["status"],
      address: json["address"] == null
          ? null
          : PanditAddress.fromJson(json["address"]),
      //  aadhaar: json["aadhaar"] == null ? null : Aadhaar.fromJson(json["aadhaar"]),
      serviceTypes: json["serviceTypes"] == null
          ? null
          : ServiceTypes.fromJson(json["serviceTypes"]),
      poojaOfferings: json["poojaOfferings"] == null
          ? []
          : List<PoojaOffering>.from(
              json["poojaOfferings"]!.map((x) => PoojaOffering.fromJson(x)),
            ),
      availability: _parsePanditAvailability(json["availability"]),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}

List<Availability> _parsePanditAvailability(dynamic value) {
  if (value is! List) return [];

  final availability = <Availability>[];
  for (final item in value) {
    if (item is! Map) continue;
    final rawDates = item["availability"];
    if (rawDates is! List) continue;

    for (final rawDate in rawDates) {
      if (rawDate is Map) {
        availability.add(
          Availability.fromJson(Map<String, dynamic>.from(rawDate)),
        );
      }
    }
  }

  availability.sort((a, b) => (a.date ?? '').compareTo(b.date ?? ''));
  return availability;
}

class PanditAddress {
  PanditAddress({
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pinCode,
  });

  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? pinCode;

  factory PanditAddress.fromJson(Map<String, dynamic> json) {
    return PanditAddress(
      line1: json["line1"],
      line2: json["line2"],
      city: json["city"],
      state: json["state"],
      pinCode: json["pinCode"],
    );
  }
}

class PoojaOffering {
  PoojaOffering({
    required this.name,
    required this.description,
    required this.isSelected,
    required this.durationHours,
    required this.travelForSpecialPooja,
    required this.standardSamagri,
    required this.customSamagri,
    required this.customSamagriItems,
    required this.customSamagriNotes,
    required this.kitId,
  });

  final String? name;
  final String? description;
  final bool? isSelected;
  final num? durationHours;
  final bool? travelForSpecialPooja;
  final bool? standardSamagri;
  final bool? customSamagri;
  final List<CustomSamagriItem> customSamagriItems;
  final List<String> customSamagriNotes;
  final String? kitId;

  factory PoojaOffering.fromJson(Map<String, dynamic> json) {
    return PoojaOffering(
      name: json["name"],
      description: json["description"],
      isSelected: json["isSelected"],
      durationHours: json["durationHours"],
      travelForSpecialPooja: json["travelForSpecialPooja"],
      standardSamagri: json["standardSamagri"],
      customSamagri: json["customSamagri"],
      kitId: json["kitId"] is String
          ? json["kitId"]
          : (json["kit"] is String
              ? json["kit"]
              : (json["kit"] is Map ? json["kit"]["_id"]?.toString() : null)),
      customSamagriItems: json["customSamagriItems"] == null
          ? []
          : List<CustomSamagriItem>.from(
              json["customSamagriItems"].map(
                (x) => CustomSamagriItem.fromJson(x),
              ),
            ),
      customSamagriNotes: json["customSamagriNotes"] == null
          ? []
          : List<String>.from(json["customSamagriNotes"].map((x) => x)),
    );
  }
}

class CustomSamagriItem {
  CustomSamagriItem({
    required this.itemName,
    required this.quantity,
    required this.size,
    required this.approvalStatus,
    required this.reviewedAt,
    required this.reviewedBy,
    required this.id,
  });

  final String? itemName;
  final int? quantity;
  final String? size;
  final String? approvalStatus;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? id;

  factory CustomSamagriItem.fromJson(Map<String, dynamic> json) {
    return CustomSamagriItem(
      itemName: json["itemName"],
      quantity: json["quantity"],
      size: json["size"],
      approvalStatus: json["approvalStatus"],
      reviewedAt: json["reviewedAt"] == null
          ? null
          : DateTime.parse(json["reviewedAt"]),
      reviewedBy: json["reviewedBy"],
      id: json["_id"],
    );
  }
}

class ServiceTypes {
  ServiceTypes({
    required this.detectedLocation,
    required this.serviceDistance,
    required this.outstationAvailability,
    required this.onlinePooja,
    required this.homeVisit,
    required this.atTemple,
    required this.travelForSpecialPoojas,
  });

  final DetectedLocation? detectedLocation;
  final ServiceDistance? serviceDistance;
  final OutstationAvailability? outstationAvailability;
  final bool? onlinePooja;
  final bool? homeVisit;
  final bool? atTemple;
  final bool? travelForSpecialPoojas;

  factory ServiceTypes.fromJson(Map<String, dynamic> json) {
    return ServiceTypes(
      detectedLocation: json["detectedLocation"] == null
          ? null
          : DetectedLocation.fromJson(json["detectedLocation"]),
      serviceDistance: json["serviceDistance"] == null
          ? null
          : ServiceDistance.fromJson(json["serviceDistance"]),
      outstationAvailability: json["outstationAvailability"] == null
          ? null
          : OutstationAvailability.fromJson(json["outstationAvailability"]),
      onlinePooja: json["onlinePooja"],
      homeVisit: json["homeVisit"],
      atTemple: json["atTemple"],
      travelForSpecialPoojas: json["travelForSpecialPoojas"],
    );
  }
}

class DetectedLocation {
  DetectedLocation({required this.city, required this.state});

  final String? city;
  final String? state;

  factory DetectedLocation.fromJson(Map<String, dynamic> json) {
    return DetectedLocation(city: json["city"], state: json["state"]);
  }
}

class OutstationAvailability {
  OutstationAvailability({
    required this.withinDistrict,
    required this.withinState,
    required this.anywhereInIndia,
  });

  final bool? withinDistrict;
  final bool? withinState;
  final bool? anywhereInIndia;

  factory OutstationAvailability.fromJson(Map<String, dynamic> json) {
    return OutstationAvailability(
      withinDistrict: json["withinDistrict"],
      withinState: json["withinState"],
      anywhereInIndia: json["anywhereInIndia"],
    );
  }
}

class ServiceDistance {
  ServiceDistance({required this.selected, required this.customKm});

  final String? selected;
  final num? customKm;

  factory ServiceDistance.fromJson(Map<String, dynamic> json) {
    return ServiceDistance(
      selected: json["selected"],
      customKm: json["customKm"],
    );
  }
}
