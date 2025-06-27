import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

/// Represents a user fetched from the API.
class User {
  final int id;
  final String name;
  final String username;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
  });

  /// Creates a [User] object from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}

/// Manages the state for fetching and holding a list of users.
class UserData extends ChangeNotifier {
  List<User> _users = <User>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches users from the JSONPlaceholder API.
  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final http.Response response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

      if (response.statusCode == 200) {
        final List<dynamic> userJson = jsonDecode(response.body) as List<dynamic>;
        _users = userJson.map<User>((dynamic json) => User.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        _errorMessage = 'Erro em carregar usuários: ${response.statusCode}';
        _users = <User>[]; // Clear previous data on error
      }
    } catch (e) {
      _errorMessage = 'Erro em buscar usuários: $e';
      _users = <User>[]; // Clear previous data on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de lista de usuarioss',
      home: ChangeNotifierProvider<UserData>(
        create: (BuildContext context) => UserData()..fetchUsers(), // Fetch data immediately on creation
        builder: (BuildContext context, Widget? child) => const UserListScreen(),
      ),
    );
  }
}

/// A screen that displays a list of users fetched from an API.
class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de usuario'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarrgar usuarios',
            onPressed: () {
              Provider.of<UserData>(context, listen: false).fetchUsers();
            },
          ),
        ],
      ),
      body: Consumer<UserData>(
        builder: (BuildContext context, UserData userData, Widget? child) {
          if (userData.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (userData.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      userData.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        userData.fetchUsers(); // Retry fetching data
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (userData.users.isEmpty) {
            return const Center(
              child: Text('nem um usuario achado.'),
            );
          } else {
            return ListView.builder(
              itemCount: userData.users.length,
              itemBuilder: (BuildContext context, int index) {
                final User user = userData.users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            const Icon(Icons.email, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.email,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}