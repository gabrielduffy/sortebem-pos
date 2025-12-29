import 'package:flutter/material.dart';

enum PaymentMethod { credit, debit }

class PaymentMethodSelector extends StatelessWidget {
  final ValueChanged<PaymentMethod> onSelected;

  const PaymentMethodSelector({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            context,
            label: 'DÉBITO',
            method: PaymentMethod.debit,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildButton(
            context,
            label: 'CRÉDITO',
            method: PaymentMethod.credit,
            color: const Color(0xFFF97316),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, {
    required String label,
    required PaymentMethod method,
    required Color color,
  }) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white, // Garantir texto branco
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => onSelected(method),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
