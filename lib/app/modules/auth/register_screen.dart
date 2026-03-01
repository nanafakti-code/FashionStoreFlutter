import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../../config/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedCountryCode = 'ES';
  final List<Map<String, String>> _customCountries = [
    {
      'code': 'ES',
      'dialCode': '34',
      'name': 'España',
      'type': 'url',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Bandera_de_Espa%C3%B1a.svg/330px-Bandera_de_Espa%C3%B1a.svg.png'
    },
    {
      'code': 'US',
      'dialCode': '1',
      'name': 'Estados Unidos',
      'type': 'url',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Flag_of_the_United_States.svg/250px-Flag_of_the_United_States.svg.png'
    },
    {
      'code': 'GB',
      'dialCode': '44',
      'name': 'Reino Unido',
      'type': 'url',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Flag_of_the_United_Kingdom_%281-2%29.svg/250px-Flag_of_the_United_Kingdom_%281-2%29.svg.png'
    },
    {
      'code': 'FR',
      'dialCode': '33',
      'name': 'Francia',
      'type': 'url',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Flag_of_France.svg/250px-Flag_of_France.svg.png'
    },
    {
      'code': 'DE',
      'dialCode': '49',
      'name': 'Alemania',
      'type': 'url',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Flag_of_Germany.svg/250px-Flag_of_Germany.svg.png'
    },
    {
      'code': 'IT',
      'dialCode': '39',
      'name': 'Italia',
      'type': 'url',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQcvN1aLbnH25UfvAQnuP8el8I7FFnvx2BZBcDvdlY93HNfn07hCeDPAjOsBnGE2ckBht_FFfSuN_Qg5JB8X1FAtQ1WTg23cH4Dc05LyqwJ&s=10'
    },
    {
      'code': 'PT',
      'dialCode': '351',
      'name': 'Portugal',
      'type': 'url',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWCfqAbatP9RuM3jcjw1TpaACeOzQbj8QiGgIltJeWGXNvPVUHNfADFBqzPjVqdBkJhBgN8XXDa2YAWYbCyGrHtBHWc0arse2wcx2bSvHtOQ&s=10'
    },
  ];

  bool _obscurePassword = true;
  String _completePhoneNumber = '';

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty ||
        name.isEmpty ||
        lastName.isEmpty ||
        password.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor completa todos los campos obligatorios')),
      );
      return;
    }

    // Phone number validation and construction
    final selectedCountry =
        _customCountries.firstWhere((c) => c['code'] == _selectedCountryCode);
    final selectedDialCode = selectedCountry['dialCode'];

    if (_phoneController.text.length < 6) {
      // Basic length validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de teléfono inválido')),
      );
      return;
    }
    _completePhoneNumber = '+$selectedDialCode${_phoneController.text}';

    // Validación de contraseña
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z]).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La contraseña debe tener al menos 8 caracteres, una mayúscula y una minúscula')),
      );
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).register(
          email,
          password,
          name,
          lastName,
          _completePhoneNumber,
        );

    if (success && mounted) {
      context.go(AppRoutes.home);
    } else if (mounted) {
      final error = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Error al registrarse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo1.png', height: 180),
                const SizedBox(height: 8),
                Text('FashionStore',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                        letterSpacing: 2)),
                const SizedBox(height: 8),
                Text('Crear Cuenta',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico *',
                    hintText: 'tu@correo.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.cream.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Tu nombre',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.cream.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),
                // Apellidos
                TextField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Apellidos *',
                    hintText: 'Tus apellidos',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.cream.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),
                // Teléfono con Selector Personalizado
                Row(
                  children: [
                    Container(
                      height: 56, // Altura estándar del TextField
                      decoration: BoxDecoration(
                        color: AppColors.cream.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCountryCode = newValue!;
                            });
                          },
                          items: _customCountries.map<DropdownMenuItem<String>>(
                              (Map<String, String> country) {
                            return DropdownMenuItem<String>(
                              value: country['code'],
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: country['type'] == 'base64'
                                        ? Image.memory(
                                            base64Decode(country['image']!),
                                            width: 30,
                                            height: 20,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            country['image']!,
                                            width: 30,
                                            height: 20,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.flag,
                                                        size: 20),
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('+${country['dialCode']}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Teléfono *',
                          hintText: 'Tu número de teléfono',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.cream.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleRegister(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña *',
                    hintText: 'Crea una contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.cream.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 24),
                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Crear Cuenta',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                // Login Link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Inicia Sesión',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
