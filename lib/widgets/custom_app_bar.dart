import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'month_picker_dialog.dart';
import 'couple_settings_dialog.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withOpacity(0.85),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Linha 1: Marca & Configurações
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPink.withOpacity(0.5),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const CoupleSettingsDialog(),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PickPlay',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  appState.coupleNames,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.edit_rounded, color: AppTheme.accentGold, size: 12),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryPink),
                    tooltip: 'Editar nome do casal',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const CoupleSettingsDialog(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Linha 2: Seletor de Mês Ativo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDeep.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryPink),
                      onPressed: appState.previousMonth,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => MonthPickerDialog(
                            initialDate: appState.selectedMonth,
                            onMonthSelected: (date) {
                              appState.setSelectedMonth(date);
                            },
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: AppTheme.accentCyan, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            appState.formattedMonthName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryPink),
                      onPressed: appState.nextMonth,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
