import 'package:flutter/foundation.dart';
import '../../../domain/repositories/device_token_repository.dart';

class DeviceTokenService {
  DeviceTokenService(this._repository);
  final DeviceTokenRepository _repository;

  Future<bool> registerToken({
    required String token,
    required String userId,
    String? platform,
  }) async {
    final effectivePlatform = platform ??
        (kIsWeb
            ? 'web'
            : defaultTargetPlatform == TargetPlatform.iOS
                ? 'ios'
                : 'android');
    final result = await _repository.registerToken(
      userId: userId,
      token: token,
      platform: effectivePlatform,
    );
    return result.isRight();
  }

  Future<bool> unregisterToken({required String token}) async {
    final result = await _repository.unregisterToken(token: token);
    return result.isRight();
  }
}
