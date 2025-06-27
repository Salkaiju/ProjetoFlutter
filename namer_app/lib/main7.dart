import 'package:flutter/material.dart';

// Data Model
class RegistrationData {
  final String name;
  final String email;
  final String gender;
  final bool agreedToTerms;
  final int age;

  RegistrationData({
    required this.name,
    required this.email,
    required this.gender,
    required this.agreedToTerms,
    required this.age,
  });
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Usuário',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const RegistrationFormScreen(),
    );
  }
}

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;

  String? _selectedGender;
  bool _agreedToTerms = false;

  final List<String> _genders = <String>['Masculino', 'Feminino', 'Outro'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O nome não pode ser vazio.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O e-mail não pode ser vazio.';
    }
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (!emailValid) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'A idade não pode ser vazia.';
    }
    final int? age = int.tryParse(value);
    if (age == null || age <= 0 || age > 150) {
      return 'Por favor, insira uma idade válida (1-150).';
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null) {
      return 'Selecione um gênero.';
    }
    return null;
  }

  String? _validateTerms(bool? value) {
    if (value == null || !value) {
      return 'Você deve concordar com os termos de serviço.';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final RegistrationData formData = RegistrationData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender!,
        agreedToTerms: _agreedToTerms,
        age: int.parse(_ageController.text.trim()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cadastro realizado com sucesso!\nNome: ${formData.name}\nE-mail: ${formData.email}\nGênero: ${formData.gender}\nIdade: ${formData.age}\nTermos aceitos: ${formData.agreedToTerms ? 'Sim' : 'Não'}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      // Clear the form after successful submission
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _ageController.clear();
      setState(() {
        _selectedGender = null;
        _agreedToTerms = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros no formulario.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              FormField<String>(
                initialValue: _selectedGender,
                validator: _validateGender,
                builder: (FormFieldState<String> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Gênero:',
                          style: Theme.of(context).textTheme.titleMedium),
                      Column(
                        children:
                            _genders.map<Widget>((String genderValue) {
                          return RadioListTile<String>(
                            title: Text(genderValue),
                            value: genderValue,
                            groupValue: _selectedGender,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                              state.didChange(newValue);
                            },
                          );
                        }).toList(),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
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
              FormField<bool>(
                initialValue: _agreedToTerms,
                validator: _validateTerms,
                builder: (FormFieldState<bool> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _agreedToTerms = newValue ?? false;
                              });
                              state.didChange(newValue);
                            },
                          ),
                          const Expanded(
                            child: Text('Eu concordo com os termos de serviço.'),
                          ),
                        ],
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.send),
                label: const Text('Enviar Cadastro'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}