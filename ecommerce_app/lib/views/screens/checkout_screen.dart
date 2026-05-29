import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/checkout_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/checkout_draft_model.dart';
import 'package:ecommerce_app/models/checkout_payment_method.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/views/screens/orders_screen.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.cartController,
    required this.sessionController,
    this.onCheckoutCompleted,
  });

  final CartController cartController;
  final SessionController sessionController;
  final Future<void> Function(OrderModel order)? onCheckoutCompleted;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutController _controller = CheckoutController();
  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();

  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _neighborhoodController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _instructionsController =
      TextEditingController();

  bool _didHydrateFields = false;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
    _bindControllers();
  }

  Future<void> _restoreDraft() async {
    final currentUser = widget.sessionController.currentUser;
    if (currentUser == null) {
      return;
    }

    await _controller.restoreDraft(userId: currentUser.id);
    _hydrateFields(force: true);
  }

  void _bindControllers() {
    _zipCodeController.addListener(
      () => _controller.updateZipCode(_zipCodeController.text),
    );
    _streetController.addListener(
      () => _controller.updateStreet(_streetController.text),
    );
    _numberController.addListener(
      () => _controller.updateNumber(_numberController.text),
    );
    _neighborhoodController.addListener(
      () => _controller.updateNeighborhood(_neighborhoodController.text),
    );
    _cityController.addListener(
      () => _controller.updateCity(_cityController.text),
    );
    _stateController.addListener(
      () => _controller.updateState(_stateController.text),
    );
    _complementController.addListener(
      () => _controller.updateComplement(_complementController.text),
    );
    _instructionsController.addListener(
      () => _controller.updateDeliveryInstructions(
        _instructionsController.text,
      ),
    );
  }

  void _hydrateFields({bool force = false}) {
    if (_didHydrateFields && !force) {
      return;
    }

    final draft = _controller.draft;
    _zipCodeController.text = draft.zipCode;
    _streetController.text = draft.street;
    _numberController.text = draft.number;
    _neighborhoodController.text = draft.neighborhood;
    _cityController.text = draft.city;
    _stateController.text = draft.state;
    _complementController.text = draft.complement;
    _instructionsController.text = draft.deliveryInstructions;
    _didHydrateFields = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _complementController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_controller.currentStep == 0) {
      final isValid = _addressFormKey.currentState?.validate() ?? false;
      if (!isValid) {
        return;
      }

      _controller.nextStep();
      return;
    }

    if (_controller.currentStep == 1) {
      _controller.nextStep();
      return;
    }

    await _confirmCheckout();
  }

  Future<void> _confirmCheckout() async {
    final currentUser = widget.sessionController.currentUser;
    if (currentUser == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sua sessao expirou. Entre novamente para continuar.'),
        ),
      );
      return;
    }

    final order = await widget.cartController.checkout(user: currentUser);

    if (!mounted) {
      return;
    }

    if (order == null) {
      final message = widget.cartController.errorMessage ??
          'Nao foi possivel concluir o checkout.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    await _controller.clearDraft();

    if (widget.onCheckoutCompleted != null) {
      await widget.onCheckoutCompleted!(order);

      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OrdersScreen(
          sessionController: widget.sessionController,
          highlightedOrderId: order.id,
          successMessage: 'Pedido #${order.id} criado com sucesso.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          widget.cartController,
        ]),
        builder: (context, _) {
          if (_controller.isLoading && !_didHydrateFields) {
            return const Center(child: CircularProgressIndicator());
          }

          final draft = _controller.draft;

          return ListView(
            padding: AppStyle.screenPadding,
            children: [
              _CheckoutHero(
                currentStep: _controller.currentStep,
                totalSteps: 3,
              ),
              const SizedBox(height: AppStyle.spacingLg),
              _StepSelector(
                currentStep: _controller.currentStep,
                onStepSelected: _controller.goToStep,
              ),
              const SizedBox(height: AppStyle.spacingLg),
              IndexedStack(
                index: _controller.currentStep,
                sizing: StackFit.loose,
                children: [
                  _AddressStep(
                    formKey: _addressFormKey,
                    zipCodeController: _zipCodeController,
                    streetController: _streetController,
                    numberController: _numberController,
                    neighborhoodController: _neighborhoodController,
                    cityController: _cityController,
                    stateController: _stateController,
                    complementController: _complementController,
                    instructionsController: _instructionsController,
                    selectedOption: draft.deliveryOption,
                    onSelectOption: _controller.updateDeliveryOption,
                  ),
                  _PaymentStep(
                    selectedMethod: draft.paymentMethod,
                    onSelectMethod: _controller.updatePaymentMethod,
                  ),
                  _ReviewStep(
                    sessionController: widget.sessionController,
                    cartController: widget.cartController,
                    draft: draft,
                  ),
                ],
              ),
              if (_controller.errorMessage != null) ...[
                const SizedBox(height: AppStyle.spacingLg),
                Container(
                  padding: const EdgeInsets.all(AppStyle.spacingMd),
                  decoration: BoxDecoration(
                    color: AppStyle.errorColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
                    border: Border.all(
                      color: AppStyle.errorColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    _controller.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppStyle.errorColor,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppStyle.spacingLg),
              Row(
                children: [
                  if (_controller.currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.cartController.isLoading
                            ? null
                            : _controller.previousStep,
                        child: const Text('Voltar'),
                      ),
                    ),
                  if (_controller.currentStep > 0)
                    const SizedBox(width: AppStyle.spacingSm),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: widget.cartController.isLoading
                          ? null
                          : _handleContinue,
                      child: widget.cartController.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _controller.currentStep == 2
                                  ? 'Confirmar pedido'
                                  : 'Continuar',
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckoutHero extends StatelessWidget {
  const _CheckoutHero({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppStyle.spacingLg),
      decoration: BoxDecoration(
        gradient: AppStyle.heroGradient,
        borderRadius: BorderRadius.circular(AppStyle.radiusLarge),
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
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Etapa ${currentStep + 1} de $totalSteps',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppStyle.spacingLg),
          Text(
            'Finalize seu pedido com mais calma.',
            style: textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppStyle.spacingSm),
          Text(
            'Preencha entrega, escolha pagamento e revise tudo antes de concluir.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepSelector extends StatelessWidget {
  const _StepSelector({
    required this.currentStep,
    required this.onStepSelected,
  });

  final int currentStep;
  final ValueChanged<int> onStepSelected;

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Entrega',
      'Pagamento',
      'Revisao',
    ];

    return Wrap(
      spacing: AppStyle.spacingSm,
      runSpacing: AppStyle.spacingSm,
      children: List.generate(steps.length, (index) {
        final selected = index == currentStep;

        return ChoiceChip(
          label: Text('${index + 1}. ${steps[index]}'),
          selected: selected,
          onSelected: (_) => onStepSelected(index),
        );
      }),
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    required this.formKey,
    required this.zipCodeController,
    required this.streetController,
    required this.numberController,
    required this.neighborhoodController,
    required this.cityController,
    required this.stateController,
    required this.complementController,
    required this.instructionsController,
    required this.selectedOption,
    required this.onSelectOption,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController zipCodeController;
  final TextEditingController streetController;
  final TextEditingController numberController;
  final TextEditingController neighborhoodController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController complementController;
  final TextEditingController instructionsController;
  final CheckoutDeliveryOption selectedOption;
  final ValueChanged<CheckoutDeliveryOption> onSelectOption;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrega',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppStyle.spacingSm),
          Text(
            'Defina onde o pedido deve chegar e como voce prefere receber.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppStyle.spacingLg),
          _LabeledField(
            label: 'CEP',
            child: TextFormField(
              controller: zipCodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Ex.: 60000-000',
                prefixIcon: Icon(Icons.pin_drop_outlined),
              ),
              validator: _requiredValidator('Informe o CEP.'),
            ),
          ),
          const SizedBox(height: AppStyle.spacingMd),
          _LabeledField(
            label: 'Rua',
            child: TextFormField(
              controller: streetController,
              decoration: const InputDecoration(
                hintText: 'Ex.: Rua das Palmeiras',
                prefixIcon: Icon(Icons.route_outlined),
              ),
              validator: _requiredValidator('Informe a rua.'),
            ),
          ),
          const SizedBox(height: AppStyle.spacingMd),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Numero',
                  child: TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(
                      hintText: '123',
                      prefixIcon: Icon(Icons.looks_one_outlined),
                    ),
                    validator: _requiredValidator('Informe o numero.'),
                  ),
                ),
              ),
              const SizedBox(width: AppStyle.spacingMd),
              Expanded(
                child: _LabeledField(
                  label: 'Complemento',
                  child: TextFormField(
                    controller: complementController,
                    decoration: const InputDecoration(
                      hintText: 'Apto, bloco...',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.spacingMd),
          _LabeledField(
            label: 'Bairro',
            child: TextFormField(
              controller: neighborhoodController,
              decoration: const InputDecoration(
                hintText: 'Ex.: Centro',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: _requiredValidator('Informe o bairro.'),
            ),
          ),
          const SizedBox(height: AppStyle.spacingMd),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Cidade',
                  child: TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      hintText: 'Ex.: Fortaleza',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: _requiredValidator('Informe a cidade.'),
                  ),
                ),
              ),
              const SizedBox(width: AppStyle.spacingMd),
              Expanded(
                child: _LabeledField(
                  label: 'Estado',
                  child: TextFormField(
                    controller: stateController,
                    decoration: const InputDecoration(
                      hintText: 'Ex.: CE',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    validator: _requiredValidator('Informe o estado.'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.spacingLg),
          Text(
            'Janela de entrega',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppStyle.spacingSm),
          ...CheckoutDeliveryOption.values.map((option) {
            final selected = option == selectedOption;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppStyle.spacingSm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
                onTap: () => onSelectOption(option),
                child: Ink(
                  padding: const EdgeInsets.all(AppStyle.spacingMd),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
                    color: selected
                        ? AppStyle.secondaryColor.withValues(alpha: 0.8)
                        : AppStyle.surfaceColor,
                    border: Border.all(
                      color: selected
                          ? AppStyle.primaryColor
                          : AppStyle.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        option == CheckoutDeliveryOption.standard
                            ? Icons.local_shipping_outlined
                            : Icons.flash_on_outlined,
                        color: selected
                            ? AppStyle.primaryColor
                            : AppStyle.textSecondaryColor,
                      ),
                      const SizedBox(width: AppStyle.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppStyle.primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: AppStyle.spacingMd),
          _LabeledField(
            label: 'Instrucoes para entrega',
            child: TextFormField(
              controller: instructionsController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ponto de referencia, horario ideal, observacoes...',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FormFieldValidator<String> _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.selectedMethod,
    required this.onSelectMethod,
  });

  final CheckoutPaymentMethod selectedMethod;
  final ValueChanged<CheckoutPaymentMethod> onSelectMethod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pagamento',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppStyle.spacingSm),
        Text(
          'Escolha como prefere concluir essa compra no momento da confirmacao.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppStyle.spacingLg),
        ...CheckoutPaymentMethod.values.map((method) {
          final selected = method == selectedMethod;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.spacingSm),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
              onTap: () => onSelectMethod(method),
              child: Ink(
                padding: const EdgeInsets.all(AppStyle.spacingLg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
                  color: selected
                      ? AppStyle.secondaryColor.withValues(alpha: 0.8)
                      : AppStyle.surfaceColor,
                  border: Border.all(
                    color:
                        selected ? AppStyle.accentColor : AppStyle.borderColor,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppStyle.accentColor.withValues(alpha: 0.14)
                            : AppStyle.secondaryColor,
                        borderRadius: BorderRadius.circular(
                          AppStyle.radiusSmall,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        method.icon,
                        color: selected
                            ? AppStyle.accentColor
                            : AppStyle.primaryColor,
                      ),
                    ),
                    const SizedBox(width: AppStyle.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppStyle.accentColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.sessionController,
    required this.cartController,
    required this.draft,
  });

  final SessionController sessionController;
  final CartController cartController;
  final CheckoutDraftModel draft;

  @override
  Widget build(BuildContext context) {
    final currentUser = sessionController.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revisao final',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppStyle.spacingSm),
        Text(
          'Confira dados, entrega, pagamento e itens antes de confirmar.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppStyle.spacingLg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppStyle.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contato',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppStyle.spacingSm),
                _ReviewLine(
                  label: 'Cliente',
                  value: currentUser?.name ?? 'Sessao indisponivel',
                ),
                const SizedBox(height: AppStyle.spacingSm),
                _ReviewLine(
                  label: 'Email',
                  value: currentUser?.email ?? '-',
                ),
                const SizedBox(height: AppStyle.spacingSm),
                _ReviewLine(
                  label: 'Telefone',
                  value: currentUser?.phone ?? '-',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppStyle.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppStyle.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrega',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppStyle.spacingSm),
                _ReviewLine(
                  label: 'Endereco',
                  value: draft.formattedAddress,
                ),
                const SizedBox(height: AppStyle.spacingSm),
                _ReviewLine(
                  label: 'Modalidade',
                  value: draft.deliveryOption.label,
                ),
                if (draft.deliveryInstructions.trim().isNotEmpty) ...[
                  const SizedBox(height: AppStyle.spacingSm),
                  _ReviewLine(
                    label: 'Observacoes',
                    value: draft.deliveryInstructions,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppStyle.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppStyle.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagamento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppStyle.spacingSm),
                _ReviewLine(
                  label: 'Metodo',
                  value: draft.paymentMethod.label,
                ),
                const SizedBox(height: AppStyle.spacingSm),
                _ReviewLine(
                  label: 'Como funciona',
                  value: draft.paymentMethod.subtitle,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppStyle.spacingMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppStyle.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo do pedido',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppStyle.spacingMd),
                ...cartController.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppStyle.spacingSm),
                    child: _ReviewLine(
                      label: '${item.quantity}x ${item.product.name}',
                      value: _formatPrice(item.subTotal),
                    ),
                  ),
                ),
                const Divider(height: AppStyle.spacingLg * 2),
                _ReviewLine(
                  label: 'Total',
                  value: _formatPrice(cartController.totalAmount),
                  emphasize: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    final fixedValue = price.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixedValue';
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasize ? textTheme.titleMedium : textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: AppStyle.spacingMd),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: emphasize
                ? textTheme.titleLarge?.copyWith(color: AppStyle.primaryColor)
                : textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppStyle.spacingXs),
        child,
      ],
    );
  }
}
