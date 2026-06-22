import 'package:dartz/dartz.dart';
import '../failures/failure.dart';

abstract class DeviceTokenRepository {
  Future<Either<Failure, void>> registerToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<Either<Failure, void>> unregisterToken({required String token});

  Future<Either<Failure, List<String>>> getTokensForUser(
      {required String userId});
}
