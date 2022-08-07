import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';

import '../models/auth.dart';

enum AuthMode { Singup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.Login;

  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController? _controller;
  Animation<Size>? _heightAnimation;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _heightAnimation = Tween(
      begin: const Size(double.infinity, 310),
      end: const Size(double.infinity, 400),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _heightAnimation?.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  bool _isLogin() => _authMode == AuthMode.Login;
  // bool _isSingup() => _authMode == AuthMode.Singup;

  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.Singup;
        _controller?.forward();
      } else {
        _authMode = AuthMode.Login;
        _controller?.reverse();
      }
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() => _isLoading = true);

    _formKey.currentState?.save();

    Auth auth = Provider.of(context, listen: false);

    void _showErrosDialog(String msg) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro!'),
          content: Text(msg),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ok'))
          ],
        ),
      );
    }

    try {
      if (_isLogin()) {
        // Login
        await auth.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        // Registrar
        await auth.signup(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrosDialog(error.toString());
    } catch (error) {
      _showErrosDialog('Erro inesperado.');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedContainer(
        duration: const Duration(microseconds: 300),
        curve: Curves.easeIn,
        padding: const EdgeInsets.all(16),
        width: deviceSize.width * 0.75,
        height: _heightAnimation?.value.height ??
            (_isLogin() ? deviceSize.height * 0.55 : deviceSize.height * 0.45),
        // height: _isLogin() ? 310 : 400,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (emailConfirmation) {
                  final email = emailConfirmation ?? '';

                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'Formato de e-mail inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Senha'),
                controller: _passwordController,
                obscureText: true,
                validator: (passwordConfirmation) {
                  final password = passwordConfirmation ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return 'Senha muito curta';
                  }
                  return null;
                },
                onSaved: (password) => _authData['password'] = password ?? '',
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _isLogin() ? 0 : 60,
                  maxHeight: _isLogin() ? 0 : 120,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Confirmar senha'),
                      obscureText: true,
                      validator: _isLogin()
                          ? null
                          : (passwordConfirmation) {
                              final password = passwordConfirmation ?? '';
                              if (password != _passwordController.text) {
                                return 'Senhas diferentes.';
                              }
                              return null;
                            },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                  child: _isLogin()
                      ? const Text('Entrar')
                      : const Text('Criar Conta'),
                ),
              const Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(_isLogin()
                    ? 'Deseja Registrar?'.toUpperCase()
                    : 'Já Possui Conta?'.toUpperCase()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
