import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';

class BookingState {
  final ProductBookedResModel? orders;
  final bool isLoading;
  final String? error;

  BookingState({this.orders, this.isLoading = false, this.error});

  BookingState copyWith({
    ProductBookedResModel? orders,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
