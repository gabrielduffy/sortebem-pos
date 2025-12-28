import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.max = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          icon: Icons.remove,
          onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
        ),
        Container(
          width: 80,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onTap: quantity < max ? () => onChanged(quantity + 1) : null,
        ),
      ],
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: onTap != null ? const Color(0xFFF97316) : Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
