import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../failures/failure.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile?>> getProfile(String userId);
  Future<Either<Failure, void>> updateProfile(UserProfile profile);
}
