import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String currencySymbol;
  final ValueChanged<double>? onChanged;
  final String? Function(String?)? validator;
  final bool autofocus;

  const MoneyInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.currencySymbol = 'Rp ',
    this.onChanged,
    this.validator,
    this.autofocus = false,
  });

  @override
  State<MoneyInput> createState() => _MoneyInputState();
}

class _MoneyInputState extends State<MoneyInput> {
  late TextEditingController _controller;
  final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value) {
    // Remove any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.isEmpty) {
      _controller.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      widget.onChanged?.call(0);
      return;
    }

    final number = int.parse(digitsOnly);
    final formatted = _formatter.format(number);

    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    widget.onChanged?.call(number.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixText: widget.currencySymbol,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.attach_money),
      ),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      onChanged: _onChanged,
      validator: widget.validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value.replaceAll('.', ''));
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }
}
