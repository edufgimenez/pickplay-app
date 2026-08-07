import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/month_picker_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedMonthKey = appState.monthKey;

    // Histórico filtrado para o mês atualmente selecionado
    final monthHistory = appState.history
        .where((record) => record.monthKey == selectedMonthKey)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico do Casal 📜', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.accentCyan),
            onPressed: () {
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
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Banner de Mês Selecionado & Estatísticas
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.15),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.formattedMonthName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${monthHistory.length} sorteio(s) realizado(s)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (monthHistory.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.textMuted),
                        tooltip: 'Limpar histórico deste mês',
                        onPressed: () {
                          _confirmClearMonthHistory(context, appState, selectedMonthKey);
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Lista de Registros do Histórico
            Expanded(
              child: monthHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 60, color: AppTheme.textMuted.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum sorteio registrado neste mês!',
                            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Faça um sorteio na tela principal para alimentar o histórico',
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: monthHistory.length,
                      itemBuilder: (context, index) {
                        final record = monthHistory[index];
                        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(record.drawnAt);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPink.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.emoji_events_rounded, color: AppTheme.accentGold, size: 22),
                            ),
                            title: Text(
                              record.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              'Sorteado em: $formattedDate • ${record.category.toUpperCase()}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearMonthHistory(BuildContext context, AppState appState, String monthKey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Limpar Histórico?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deseja apagar o histórico de sorteios deste mês?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              appState.clearMonthHistory(monthKey);
              Navigator.of(ctx).pop();
            },
            child: const Text('Apagar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
