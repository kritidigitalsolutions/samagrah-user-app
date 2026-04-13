class FestivalKitResponse {
    FestivalKitResponse({
        required this.success,
        required this.count,
        required this.data,
    });

    final bool? success;
    final int? count;
    final List<Datum> data;

    factory FestivalKitResponse.fromJson(Map<String, dynamic> json){ 
        return FestivalKitResponse(
            success: json["success"],
            count: json["count"],
            data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        );
    }

}

class Datum {
    Datum({
        required this.id,
        required this.name,
        required this.description,
        required this.image,
        required this.items,
        required this.totalPrice,
        required this.kitPrice,
        required this.savings,
        required this.festivalType,
        required this.createdAt,
        required this.updatedAt,
        required this.slug,
        required this.v,
    });

    final String? id;
    final String? name;
    final String? description;
    final String? image;
    final List<Item> items;
    final int? totalPrice;
    final int? kitPrice;
    final int? savings;
    final String? festivalType;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final String? slug;
    final int? v;

    factory Datum.fromJson(Map<String, dynamic> json){ 
        return Datum(
            id: json["_id"],
            name: json["name"],
            description: json["description"],
            image: json["image"],
            items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
            totalPrice: json["totalPrice"],
            kitPrice: json["kitPrice"],
            savings: json["savings"],
            festivalType: json["festivalType"],
            createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
            updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
            slug: json["slug"],
            v: json["__v"],
        );
    }
}

class Item {
    Item({
        required this.product,
        required this.quantity,
        required this.id,
    });

    final Product? product;
    final int? quantity;
    final String? id;

    factory Item.fromJson(Map<String, dynamic> json){ 
        return Item(
            product: json["product"] == null ? null : Product.fromJson(json["product"]),
            quantity: json["quantity"],
            id: json["_id"],
        );
    }
}

class Product {
    Product({
        required this.pricing,
        required this.media,
        required this.id,
        required this.title,
        required this.slug,
    });

    final Pricing? pricing;
    final Media? media;
    final String? id;
    final String? title;
    final String? slug;

    factory Product.fromJson(Map<String, dynamic> json){ 
        return Product(
            pricing: json["pricing"] == null ? null : Pricing.fromJson(json["pricing"]),
            media: json["media"] == null ? null : Media.fromJson(json["media"]),
            id: json["_id"],
            title: json["title"],
            slug: json["slug"],
        );
    }

}

class Media {
    Media({
        required this.images,
    });

    final List<String> images;

    factory Media.fromJson(Map<String, dynamic> json){ 
        return Media(
            images: json["Images"] == null ? [] : List<String>.from(json["Images"]!.map((x) => x)),
        );
    }


}

class Pricing {
    Pricing({
        required this.price,
        required this.mrp,
        required this.currency,
    });

    final int? price;
    final int? mrp;
    final String? currency;

    factory Pricing.fromJson(Map<String, dynamic> json){ 
        return Pricing(
            price: json["price"],
            mrp: json["mrp"],
            currency: json["currency"],
        );
    }
}
