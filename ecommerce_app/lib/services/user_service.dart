import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/api_client_service.dart';

class UserService {
  UserService({ApiClientService? apiClient})
      : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<List<UserModel>> getUsers() async {
    final data = await _apiClient.getList('/users');

    return data.cast<Map<String, dynamic>>().map(UserModel.fromMap).toList();
  }

  Future<UserModel> getUserById(int id) async {
    final data = await _apiClient.getMap('/users/$id');
    return UserModel.fromMap(data);
  }

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _apiClient.postMap(
      '/users/',
      body: {
        'id': null,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    return UserModel.fromMap(data);
  }
}
