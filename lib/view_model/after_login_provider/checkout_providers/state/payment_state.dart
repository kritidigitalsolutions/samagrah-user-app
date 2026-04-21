class PaymentState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const PaymentState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  PaymentState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
