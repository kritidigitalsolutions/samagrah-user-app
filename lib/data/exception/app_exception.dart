class AppException implements Exception {
  final String message;
  final String prefix;
  final dynamic
  data; // 👈 raw response data (for structured errors like isNewUser, success, etc.)

  AppException(this.message, this.prefix, [this.data]);

  @override
  String toString() {
    return "$prefix $message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message, dynamic data])
    : super(
        message ?? "Error During Communication",
        "FetchDataException: ",
        data,
      );
}

class BadRequestException extends AppException {
  BadRequestException([String? message, dynamic data])
    : super(message ?? "Invalid Request", "BadRequestException: ", data);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message, dynamic data])
    : super(message ?? "Unauthorized Request", "UnauthorizedException: ", data);
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message, dynamic data])
    : super(message ?? "Invalid Input", "InvalidInputException: ", data);
}
