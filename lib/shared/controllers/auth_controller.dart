import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user.dart';
import '../../modules/renja/renja_controller.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final currentUser = Rx<User?>(null);
  final errorMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  /// Check if user is already logged in
  void _checkLoginStatus() {
    isLoggedIn.value = _authRepository.isLoggedIn();
    if (isLoggedIn.value) {
      currentUser.value = _authRepository.getCurrentUser();
    }
  }

  /// Login with username and password
  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _authRepository.login(username, password);

      if (response.success) {
        currentUser.value = response.data.user;
        isLoggedIn.value = true;
        errorMessage.value = null;

        // Refetch renja data after successful login
        try {
          final renjaController = Get.find<RenjaController>();
          await renjaController.loadAll();
        } catch (e) {
          // Silently handle if RenjaController is not yet initialized
          // The controller will load data when the page is opened
        }

        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = null;
  }
}
