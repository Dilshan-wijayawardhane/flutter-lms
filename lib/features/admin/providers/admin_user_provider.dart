import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/load_state.dart';
import '../../student/data/models/user_profile.dart';
import '../data/services/admin_user_service.dart';

class AdminUserProvider extends ChangeNotifier {
  AdminUserProvider({AdminUserService? service})
      : _service = service ?? AdminUserService(ApiClient.instance);

  final AdminUserService _service;

  LoadState _state = LoadState.initial;
  List<UserProfile> _users = const [];
  String? _error;
  String _search = '';
  String? _roleFilter;
  String? _statusFilter;

  LoadState get state => _state;
  List<UserProfile> get users => _users;
  String? get errorMessage => _error;
  String get search => _search;
  String? get roleFilter => _roleFilter;
  String? get statusFilter => _statusFilter;

  Future<void> load({bool force = false}) async {
    if (_state == LoadState.loading) return;
    if (!force && _state == LoadState.success) return;

    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _users = await _service.list(
        search: _search,
        role: _roleFilter,
        status: _statusFilter,
      );
      _state = LoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Could not load users.';
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> setSearch(String q) async {
    _search = q;
    await load(force: true);
  }

  Future<void> setFilters({String? role, String? status}) async {
    _roleFilter = role;
    _statusFilter = status;
    await load(force: true);
  }

  Future<void> clearFilters() async {
    _roleFilter = null;
    _statusFilter = null;
    await load(force: true);
  }

  Future<bool> suspend(String userId) async {
    try {
      final updated = await _service.suspend(userId);
      _replace(updated);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reactivate(String userId) async {
    try {
      final updated = await _service.reactivate(userId);
      _replace(updated);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      return false;
    }
  }

  UserProfile? byId(String id) {
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  void _replace(UserProfile u) {
    _users = _users.map((x) => x.id == u.id ? u : x).toList();
    notifyListeners();
  }
}