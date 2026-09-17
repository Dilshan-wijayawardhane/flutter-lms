import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../data/models/user_profile.dart';
import '../data/services/profile_service.dart';

enum ProfileState { initial, loading, success, error }

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({ProfileService? service})
      : _service = service ?? ProfileService(ApiClient.instance);

  final ProfileService _service;

  ProfileState _state = ProfileState.initial;
  UserProfile? _profile;
  String? _errorMessage;

  ProfileState get state => _state;
  UserProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ProfileState.loading;
  bool get isSuccess => _state == ProfileState.success;
  bool get hasError => _state == ProfileState.error;
  bool get hasProfile => _profile != null;

  Future<void> load({bool force = false}) async {
    if (_state == ProfileState.loading) return;
    if (!force && _profile != null) return;

    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _service.getFullProfile();
      _state = ProfileState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ProfileState.error;
    } catch (_) {
      _errorMessage = 'Could not load your profile. Please try again.';
      _state = ProfileState.error;
    }
    notifyListeners();
  }

  void applyLocalUpdate(UserProfile updated) {
    _profile = updated;
    _state = ProfileState.success;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> uploadProfileImage({
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final url = await _service.uploadProfileImage(
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType,
        onSendProgress: onSendProgress,
      );
      if (_profile != null && url != null) {
        _profile = _profile!.copyWith(profileImageUrl: url);
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProfileImage() async {
    try {
      await _service.deleteProfileImage();
      if (_profile != null) {
        _profile = _profile!.copyWith(profileImageUrl: null);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void clear() {
    _profile = null;
    _errorMessage = null;
    _state = ProfileState.initial;
    notifyListeners();
  }
}