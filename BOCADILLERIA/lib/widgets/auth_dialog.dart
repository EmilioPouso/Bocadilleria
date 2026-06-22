import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AuthDialog extends StatefulWidget {
  final bool initialIsLogin;
  const AuthDialog({super.key, this.initialIsLogin = true});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late bool isLogin;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    isLogin = widget.initialIsLogin;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor, rellena todos los campos');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      bool success;
      if (isLogin) {
        success = await auth.signIn(email, password);
      } else {
        success = await auth.register(email, password);
      }

      if (!success && mounted) {
        _showError('Correo o contraseña incorrectos');
      } else if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardHeight = mq.viewInsets.bottom;
    final keyboardOpen = keyboardHeight > 0;
    final maxW = math.min(480.0, mq.size.width - 32);
    final scale = keyboardOpen ? 0.84 : 1.0;
    final titleSize = keyboardOpen ? 21.0 : 26.0;
    final fieldPadding = keyboardOpen ? 12.0 : 16.0;
    const bottomGap = 20.0;

    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (_) {},
        onVerticalDragStart: (_) {},
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: keyboardOpen ? 6 : 24,
            bottom: keyboardOpen ? keyboardHeight + bottomGap : 24,
          ),
          child: Align(
            alignment: keyboardOpen ? const Alignment(0, -0.48) : Alignment.center,
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  elevation: 8,
                  shadowColor: Colors.black26,
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final isLoading = auth.isLoading;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(24, keyboardOpen ? 8 : 12, 24, keyboardOpen ? 18 : 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!keyboardOpen)
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                  onPressed: () => Navigator.of(context).pop(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                                  onPressed: () => Navigator.of(context).pop(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ),
                            SizedBox(height: keyboardOpen ? 0 : 4),
                            Text(
                              isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF232836),
                              ),
                            ),
                            SizedBox(height: keyboardOpen ? 4 : 8),
                            Text(
                              isLogin
                                  ? 'Accede para disfrutar de nuestros\ndeliciosos bocadillos.'
                                  : 'Regístrate para pedir tus\ndeliciosos bocadillos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: keyboardOpen ? 12 : 14,
                                color: const Color(0xFF7B8B9E),
                                height: 1.35,
                              ),
                            ),
                            SizedBox(height: keyboardOpen ? 10 : 20),
                            TextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              scrollPadding: EdgeInsets.zero,
                              onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: fieldPadding),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                                ),
                              ),
                            ),
                            SizedBox(height: keyboardOpen ? 10 : 12),
                            TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              scrollPadding: EdgeInsets.zero,
                              onSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                hintText: 'Contraseña',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: fieldPadding),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),
                            SizedBox(height: keyboardOpen ? 14 : 16),
                            SizedBox(
                              width: double.infinity,
                              height: keyboardOpen ? 46 : 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Text(
                                        isLogin ? 'Entrar' : 'Registrarme',
                                        style: TextStyle(
                                          fontSize: keyboardOpen ? 15 : 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                            if (!keyboardOpen) ...[
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
                                    style: const TextStyle(
                                      color: Color(0xFF7B8B9E),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => isLogin = !isLogin),
                                    child: Text(
                                      isLogin ? 'Regístrate' : 'Inicia sesión',
                                      style: const TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
