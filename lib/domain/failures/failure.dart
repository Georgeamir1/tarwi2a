import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.server({required String message}) = ServerFailure;
  const factory Failure.network({required String message}) = NetworkFailure;
  const factory Failure.validation({
    required String message,
    String? field,
  }) = ValidationFailure;
  const factory Failure.unexpected({required String message}) =
      UnexpectedFailure;
}
