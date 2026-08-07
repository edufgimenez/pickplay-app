import 'package:flutter/material.dart';
import '../models/raffle_item.dart';
import '../theme/app_theme.dart';

class OptionCard extends StatelessWidget {
  final RaffleItem item;
  final VoidCallback onDelete;
  final VoidCallback onToggleDrawn;

  const OptionCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onToggleDrawn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: item.isDrawn
                ? AppTheme.backgroundCard.withOpacity(0.4)
                : AppTheme.backgroundCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.isDrawn
                  ? AppTheme.textMuted.withOpacity(0.2)
                  : AppTheme.primaryPurple.withOpacity(0.3),
            ),
            boxShadow: item.isDrawn
                ? []
                : [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: GestureDetector(
              onTap: onToggleDrawn,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isDrawn
                      ? AppTheme.accentGold.withOpacity(0.2)
                      : AppTheme.backgroundDeep,
                  border: Border.all(
                    color: item.isDrawn
                        ? AppTheme.accentGold
                        : AppTheme.textMuted.withOpacity(0.4),
                  ),
                ),
                child: Icon(
                  item.isDrawn ? Icons.emoji_events_rounded : Icons.circle_outlined,
                  size: 18,
                  color: item.isDrawn ? AppTheme.accentGold : AppTheme.textMuted,
                ),
              ),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: item.isDrawn ? AppTheme.textMuted : Colors.white,
                decoration: item.isDrawn ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: item.isDrawn
                ? const Text(
                    'Já sorteado neste mês 🎉',
                    style: TextStyle(fontSize: 12, color: AppTheme.accentGold),
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textMuted, size: 22),
              onPressed: onDelete,
            ),
          ),
        ),
      ),
    );
  }
}
