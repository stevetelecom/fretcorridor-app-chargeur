import 'package:flutter/material.dart';

/// Champ PIN (4 a 6 chiffres) avec icone "oeil" afficher/masquer - regle de
/// securite frontend du guide ultime. Reutilise partout ou un PIN est saisi.
class PinField extends StatefulWidget {
  const PinField({
    super.key,
    required this.controller,
    this.label = 'Code PIN (4 a 6 chiffres)',
  });

  final TextEditingController controller;
  final String label;

  @override
  State<PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<PinField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        counterText: '',
        suffixIcon: IconButton(
          icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          tooltip: _obscured ? 'Afficher le code' : 'Masquer le code',
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Le code PIN est requis';
        if (!RegExp(r'^\d{4,6}$').hasMatch(value)) {
          return 'Le code PIN doit contenir entre 4 et 6 chiffres';
        }
        return null;
      },
    );
  }
}
