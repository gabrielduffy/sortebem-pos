import 'package:flutter/material.dart';
import '../models/round.dart';
import '../utils/formatters.dart';

class RoundSelector extends StatelessWidget {
  final Round? regular;
  final Round? special;
  final Round? selected;
  final ValueChanged<Round> onSelected;

  const RoundSelector({
    super.key,
    this.regular,
    this.special,
    this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (regular != null)
          _buildOption(regular!, context),
        if (special != null && regular != null)
          const SizedBox(height: 12),
        if (special != null)
          _buildOption(special!, context),
      ],
    );
  }

  Widget _buildOption(Round round, BuildContext context) {
    final isSelected = selected?.id == round.id;
    return GestureDetector(
      onTap: () => onSelected(round),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF97316) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  round.type == 'regular' ? 'Rodada Regular' : 'Rodada Especial',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '#${round.number}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              Formatters.currency(round.cardPrice),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
