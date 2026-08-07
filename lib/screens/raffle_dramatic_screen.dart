import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../providers/app_state.dart';
import '../models/raffle_item.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_overlay.dart';

import '../services/sound_service.dart';

enum RaffleStage { countdown, spinning, revealed }

class RaffleDramaticScreen extends StatefulWidget {
  const RaffleDramaticScreen({super.key});

  @override
  State<RaffleDramaticScreen> createState() => _RaffleDramaticScreenState();
}

class _RaffleDramaticScreenState extends State<RaffleDramaticScreen> {
  RaffleStage _stage = RaffleStage.countdown;
  int _countdown = 5;
  Timer? _countdownTimer;
  Timer? _spinTimer;
  
  late ConfettiController _confettiController;
  RaffleItem? _winner;
  int _spinIndex = 0;

  final List<String> _suspenseMessages = [
    "🍿 Preparando a pipoca e o suspense...",
    "🔮 Consultando o oráculo do casal...",
    "🎲 Misturando as escolhas secretas...",
    "⚡ Quase lá! O destino está decidindo...",
    "✨ E O ESCOLHIDO É... ✨",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    
    // Iniciar sorteio na construção da tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRaffleProcess();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _spinTimer?.cancel();
    _confettiController.dispose();
    SoundService.stopPeao();
    super.dispose();
  }

  void _startRaffleProcess() {
    final appState = Provider.of<AppState>(context, listen: false);
    _winner = appState.pickRandomWinner();

    if (_winner == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _stage = RaffleStage.countdown;
      _countdown = 5;
    });

    // Tocar o primeiro som de tick (5s)
    SoundService.playTick(pitch: 0.9);

    // Contagem Regressiva de 5 Segundos com Tom Crescente
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
        // Aumenta o tom (pitch) a cada segundo para criar suspense!
        final double pitchStep = 1.6 - (_countdown * 0.14);
        SoundService.playTick(pitch: pitchStep);
      } else {
        timer.cancel();
        _startSpinningAnimation(appState);
      }
    });
  }

  void _startSpinningAnimation(AppState appState) {
    setState(() {
      _stage = RaffleStage.spinning;
    });

    final candidates = appState.undrawnCurrentItems;
    int ticks = 0;
    // Roleta rodando por exatamente 10 segundos (100 ticks x 100ms)
    const maxTicks = 100;

    // Iniciar a música peao.mp3
    SoundService.playPeao();

    _spinTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      ticks++;
      setState(() {
        _spinIndex = ticks % candidates.length;
      });

      // Efeito FadeOut nos últimos 3 segundos (do tick 70 ao 100)
      if (ticks > 70) {
        final double fadeVolume = (100 - ticks) / 30.0;
        SoundService.setPeaoVolume(fadeVolume);
      }

      if (ticks >= maxTicks) {
        timer.cancel();
        _revealWinner();
      }
    });
  }

  void _revealWinner() {
    setState(() {
      _stage = RaffleStage.revealed;
    });
    _confettiController.play();
    SoundService.playWinner();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final candidates = appState.undrawnCurrentItems;

    return Scaffold(
      body: ConfettiOverlay(
        controller: _confettiController,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header com botão de fechar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'O Grande Sorteio 🎲',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 48), // Espaçador equilibrado
                    ],
                  ),
                ),

                // Conteúdo Principal Dinâmico por Estágio
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildStageContent(appState, candidates),
                    ),
                  ),
                ),

                // Rodapé de Ações
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _stage == RaffleStage.revealed
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryPink,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                ),
                                onPressed: () {
                                  if (_winner != null) {
                                    appState.confirmRaffleWinner(_winner!);
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Aceitar & Salvar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _startRaffleProcess,
                              child: const Text(
                                'Sortear Novamente',
                                style: TextStyle(
                                  color: AppTheme.accentCyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(height: 50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent(AppState appState, List<RaffleItem> candidates) {
    switch (_stage) {
      case RaffleStage.countdown:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Círculo Pulsante da Contagem
            Container(
              width: 160,
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            )
            .animate(key: ValueKey('circle_$_countdown'))
            .scale(duration: 400.ms, curve: Curves.elasticOut),

            const SizedBox(height: 40),

            // Mensagem de Suspense
            Text(
              _suspenseMessages[5 - _countdown],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            )
            .animate(key: ValueKey('text_$_countdown'))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.2, end: 0),
          ],
        );

      case RaffleStage.spinning:
        final currentSpinnedTitle = candidates.isNotEmpty
            ? candidates[_spinIndex % candidates.length].title
            : _winner?.title ?? '';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 50)
                .animate()
                .rotate(duration: 1000.ms),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentCyan, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentCyan.withOpacity(0.4),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Text(
                currentSpinnedTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Girando a roleta...',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
            ),
          ],
        );

      case RaffleStage.revealed:
        final categoryMeta = appState.allCategoriesList.firstWhere(
          (c) => c.id.toLowerCase() == _winner?.category.toLowerCase(),
          orElse: () => CategoryMeta(
            id: _winner?.category ?? '',
            label: _winner?.category ?? '',
            icon: Icons.star_rounded,
            color: AppTheme.primaryPurple,
          ),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '✨ A ESCOLHA FOI... ✨',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
                letterSpacing: 1.2,
              ),
            ).animate().scale(duration: 500.ms),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.backgroundCard,
                    AppTheme.backgroundCardLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.primaryPink, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.5),
                    blurRadius: 25,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    categoryMeta.icon,
                    size: 50,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _winner?.title ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Categoria: ${categoryMeta.label}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .shimmer(duration: 1500.ms),
          ],
        );
    }
  }
}
