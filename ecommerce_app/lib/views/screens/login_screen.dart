import 'package:ecommerce_app/controllers/login_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/views/screens/register_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.sessionController,
  });

  final SessionController sessionController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = await _controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (user != null) {
      widget.sessionController.startSession(user);
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterScreen(
          sessionController: widget.sessionController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: AppStyle.screenPadding,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyle.spacingLg),
                        decoration: BoxDecoration(
                          gradient: AppStyle.heroGradient,
                          borderRadius: BorderRadius.circular(
                            AppStyle.radiusLarge,
                          ),
                          boxShadow: AppStyle.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppStyle.spacingSm,
                                vertical: AppStyle.spacingXs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppStyle.spacingLg),
                            Text(
                              'Entre para continuar suas compras.',
                              style: textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppStyle.spacingSm),
                            Text(
                              'Use email e senha para acessar sua sessao local e buscar seus dados pela API.',
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppStyle.spacingXl),
                      Text(
                        'Acesse sua conta',
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppStyle.spacingSm),
                      Text(
                        'Digite os dados do usuario que ja existe no backend.',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppStyle.spacingLg),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'voce@email.com',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe seu email.';
                                }
                                if (!value.contains('@')) {
                                  return 'Digite um email valido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppStyle.spacingMd),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _controller.obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                hintText: 'Sua senha',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed:
                                      _controller.togglePasswordVisibility,
                                  icon: Icon(
                                    _controller.obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe sua senha.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_controller.errorMessage != null) ...[
                        const SizedBox(height: AppStyle.spacingMd),
                        _InlineMessage(
                          message: _controller.errorMessage!,
                          color: AppStyle.errorColor,
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppStyle.spacingLg,
                    AppStyle.spacingSm,
                    AppStyle.spacingLg,
                    AppStyle.spacingLg,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _controller.isLoading ? null : _handleLogin,
                          child: _controller.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: AppStyle.spacingSm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _controller.isLoading ? null : _openRegister,
                          child: const Text('Se cadastrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyle.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}
