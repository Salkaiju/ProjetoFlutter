import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

// API Configuration
// IMPORTANT: Replace this with your unique endpoint from crudcrud.com.
// Crudcrud.com provides temporary endpoints that expire. If the app fails to fetch or create,
// you likely need to generate a new URL from https://crudcrud.com/ and update it here.
const String kApiBaseUrl =
    'https://crudcrud.com/api/351fdfbb130a4327b08fbd7b4cddb539/crud'; // <<< REPLACE THIS WITH YOUR NEW, VALID CRUDCRUD.COM ENDPOINT!

// Data Model
class UserModel {
  final String? id; // Null for new users
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final String email;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'age': age,
      'email': email,
    };
  }
}

// State Management with Provider
class UserProvider extends ChangeNotifier {
  List<UserModel> _users = <UserModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProvider() {
    fetchUsers(); // Fetch users when the provider is created
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri uri = Uri.parse(kApiBaseUrl);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _users = data.map<UserModel>((dynamic json) => UserModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Falhou em carregar usuários: Status ${response.statusCode}. Response: ${response.body}';
      }
    } catch (e) {
      _errorMessage = 'Erro em buscar usuários: $e. Cheque a configuração API.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri uri = Uri.parse(kApiBaseUrl);
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{'content-type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 201) {
        // Crudcrud.com returns 201 Created on success for POST
        await fetchUsers(); // Re-fetch to get the new user with its ID
        return true;
      } else {
        _errorMessage = 'Falhou em criar usuário: Status ${response.statusCode}. Resposta: ${response.body}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Falha em criar usuário: $e. Cheque o endpoint da API e o formato dos dados.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(UserModel user) async {
    if (user.id == null) {
      _errorMessage = 'Não pod e atualizar usuário sem iD.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri uri = Uri.parse('$kApiBaseUrl/${user.id}');
      final http.Response response = await http.put(
        uri,
        headers: <String, String>{'content-type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200) {
        // Crudcrud.com returns 200 OK on success for PUT
        await fetchUsers(); // Re-fetch to update the list
        return true;
      } else {
        _errorMessage = 'Falha em atualizar usuário: Status ${response.statusCode}. Resposta: ${response.body}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Falha em atualizar usuário: $e. Cheque o endpint da API e o formato dos dados.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Uri uri = Uri.parse('$kApiBaseUrl/$id');
      final http.Response response = await http.delete(uri);

      if (response.statusCode == 200) {
        // Crudcrud.com returns 200 OK on success for DELETE
        _users.removeWhere((UserModel user) => user.id == id);
        notifyListeners(); // Notify after local removal
        return true;
      } else {
        _errorMessage = 'Falha em deletar o usuário: Status ${response.statusCode}. Resposta: ${response.body}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro em deletar o usuário: $e. Cheque o API endpoint e dados.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
      create: (BuildContext context) => UserProvider(),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Gerenciamento de usuários',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueAccent,
          ),
          home: const UserListScreen(),
        );
      },
    );
  }
}

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Usuário'),
        actions: <Widget>[
          Consumer<UserProvider>(
            builder: (BuildContext context, UserProvider userProvider, Widget? child) {
              if (userProvider.isLoading && userProvider.users.isEmpty) {
                // Show a small progress indicator only when initially loading with no users
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ));
              } else if (userProvider.isLoading) {
                // Show a small progress indicator when refreshing or updating with existing users
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ));
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => userProvider.fetchUsers(),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider userProvider, Widget? child) {
          if (userProvider.isLoading && userProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      userProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => userProvider.fetchUsers(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (userProvider.users.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum usuário encontrado',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: userProvider.users.length,
            itemBuilder: (BuildContext context, int index) {
              final UserModel user = userProvider.users[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 2,
                child: ListTile(
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Text(user.email),
                  leading: const Icon(Icons.person),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => UserFormScreen(user: user),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Confirmar delete'),
                                content: Text('Se tem certeza que quer deletar ${user.firstName}?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: const Text('Deletar'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true && user.id != null) {
                            final bool success =
                                await userProvider.deleteUser(user.id!);
                            if (!context.mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Usuário deletado')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Falha em deletar: ${userProvider.errorMessage ?? "Unknown error"}')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const UserFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UserFormScreen extends StatefulWidget {
  final UserModel? user; // Null for new user, provided for editing

  const UserFormScreen({this.user, super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  String? _selectedGender;

  final List<String> _genders = <String>['Homem', 'Mulher', 'Outro'];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user?.firstName);
    _lastNameController = TextEditingController(text: widget.user?.lastName);
    _emailController = TextEditingController(text: widget.user?.email);
    _ageController = TextEditingController(text: widget.user?.age.toString());
    _selectedGender = widget.user?.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email não pode estar vazio';
    }
    // Basic email regex
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (!emailValid) {
      return 'Aloque um email válido';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName não pode estar vazio';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Idade não pode estar vazia';
    }
    final int? age = int.tryParse(value);
    if (age == null || age <= 0 || age > 150) {
      return 'Coloque uma idade válida (1-150)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Adicionar usuário' : 'Editar Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Primeiro Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (String? value) => _validateRequired(value, 'Primeiro Nome'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (String? value) => _validateRequired(value, 'Último nome'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Genero',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: _genders.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (String? value) => _validateRequired(value, 'Genero'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: _validateAge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 24),
              Consumer<UserProvider>(
                builder: (BuildContext context, UserProvider provider, Widget? child) {
                  return ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final UserModel newUser = UserModel(
                                id: widget.user?.id,
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                gender: _selectedGender!,
                                age: int.parse(_ageController.text.trim()),
                                email: _emailController.text.trim(),
                              );

                              bool success = false;
                              if (widget.user == null) {
                                success = await provider.createUser(newUser);
                              } else {
                                success = await provider.updateUser(newUser);
                              }

                              if (!context.mounted) return; // Check if the widget is still mounted
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Usuário ${widget.user == null ? 'Adicionado' : 'Atualizado'} com sucesso!')),
                                );
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Falha em ${widget.user == null ? 'Adicionar' : 'atualizar'} usuário: ${provider.errorMessage ?? "Unknown error"}')),
                                );
                              }
                            }
                          },
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ))
                        : const Icon(Icons.save),
                    label: Text(widget.user == null ? 'Salvar usuário' : 'Atualizar usuário'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}