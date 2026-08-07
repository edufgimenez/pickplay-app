import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/option_card.dart';
import 'raffle_dramatic_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _itemController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem(AppState appState) {
    if (_itemController.text.trim().isNotEmpty) {
      appState.addItem(_itemController.text);
      _itemController.clear();
      _focusNode.requestFocus();
    }
  }

  String _getHintTextForCategory(String category) {
    switch (category) {
      case 'movies':
        return 'Adicionar filme (ex: Interstellar)...';
      case 'series':
        return 'Adicionar série (ex: Stranger Things)...';
      case 'games':
        return 'Adicionar jogo (ex: Stardew Valley)...';
      default:
        return 'Adicionar opção nesta categoria...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final undrawnItems = appState.undrawnCurrentItems;
    final currentItems = appState.currentItems;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Abas de Categoria
            const CategoryTabBar(),
            const SizedBox(height: 16),

            // Campo de Input para Adicionar Opção
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryPink),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _addItem(appState),
                        decoration: InputDecoration(
                          hintText: _getHintTextForCategory(appState.selectedCategory),
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                      ),
                      onPressed: () => _addItem(appState),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Título e Contador da Lista
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Opções do Mês (${currentItems.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${undrawnItems.length} disponíveis para sortear',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Lista de Opções
            Expanded(
              child: currentItems.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 60, color: AppTheme.textMuted.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              'Nenhuma opção cadastrada!',
                              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Adicione opções no campo acima para começar',
                              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: currentItems.length,
                      itemBuilder: (context, index) {
                        final item = currentItems[index];
                        return OptionCard(
                          item: item,
                          onDelete: () => appState.removeItem(item.id),
                          onToggleDrawn: () => appState.toggleItemDrawn(item.id),
                        );
                      },
                    ),
            ),

            // Barra Inferior com Ações & Botão de Sorteio
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  // Botão Ver Histórico
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.backgroundDeep,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.history_rounded, color: AppTheme.accentCyan),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Botão Principal SORTEAR AGORA! (Ativo apenas com 2+ opções)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final canRaffle = undrawnItems.length >= 2;
                        final String buttonLabel = undrawnItems.isEmpty
                            ? 'ADICIONE OPÇÕES PARA SORTEAR'
                            : (undrawnItems.length == 1
                                ? 'ADICIONE +1 OPÇÃO PARA SORTEAR'
                                : '✨ SORTEAR AGORA! ✨');

                        return SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: canRaffle ? 8 : 0,
                              shadowColor: AppTheme.primaryPink.withOpacity(0.5),
                            ),
                            onPressed: canRaffle
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RaffleDramaticScreen(),
                                      ),
                                    );
                                  }
                                : null,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: canRaffle ? AppTheme.primaryGradient : null,
                                color: canRaffle ? null : AppTheme.backgroundDeep,
                                border: canRaffle
                                    ? null
                                    : Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      color: canRaffle ? Colors.white : AppTheme.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      buttonLabel,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: canRaffle ? Colors.white : AppTheme.textSecondary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate(target: canRaffle ? 1 : 0)
                           .shimmer(duration: 2000.ms, delay: 3000.ms),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
