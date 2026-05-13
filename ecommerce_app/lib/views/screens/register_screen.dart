import 'package:ecommerce_app/controllers/register_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.sessionController,
  });

  final SessionController sessionController;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController _controller = RegisterController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = await _controller.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (user == null || !mounted) {
      return;
    }

    widget.sessionController.startSession(user);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
      ),
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
                          color: AppStyle.surfaceColor,
                          borderRadius: BorderRadius.circular(
                            AppStyle.radiusLarge,
                          ),
                          border: Border.all(color: AppStyle.borderColor),
                          boxShadow: AppStyle.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Abra sua conta',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppStyle.spacingSm),
                            Text(
                              'Vamos criar um usuario novo no backend e manter sua sessao salva no dispositivo.',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppStyle.spacingLg),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Nome completo',
                                hintText: 'Seu nome',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe seu nome.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppStyle.spacingMd),
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
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Telefone',
                                hintText: '(00) 00000-0000',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe seu telefone.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppStyle.spacingMd),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _controller.obscurePassword,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                hintText: 'Crie uma senha',
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
                                  return 'Informe uma senha.';
                                }
                                if (value.length < 3) {
                                  return 'Use pelo menos 3 caracteres.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppStyle.spacingMd),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _controller.obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleRegister(),
                              decoration: InputDecoration(
                                labelText: 'Confirmar senha',
                                hintText: 'Repita sua senha',
                                prefixIcon: const Icon(Icons.verified_user_outlined),
                                suffixIcon: IconButton(
                                  onPressed: _controller
                                      .toggleConfirmPasswordVisibility,
                                  icon: Icon(
                                    _controller.obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Confirme sua senha.';
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
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _controller.isLoading ? null : _handleRegister,
                      child: _controller.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Cadastrar'),
                    ),
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
