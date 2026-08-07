import 'dart:async';
import 'dart:math';
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

class SpinWheelCurve extends Curve {
  const SpinWheelCurve();

  @override
  double transformInternal(double t) {
    if (t < 0.60) {
      // Giro constante em ALTA VELOCIDADE nos primeiros 6.0 segundos (80% do percurso)
      return (t / 0.60) * 0.80;
    } else {
      // Desaceleração física suave (freio) nos últimos 4.0 segundos (20% do percurso)
      final double p = (t - 0.60) / 0.40;
      final double easeOut = 1.0 - pow(1.0 - p, 3);
      return 0.80 + (easeOut * 0.20);
    }
  }
}

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

  FixedExtentScrollController? _wheelController;
  List<RaffleItem> _wheelItems = [];

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _spinTimer?.cancel();
    _wheelController?.dispose();
    _confettiController.dispose();
    SoundService.stopAll();
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
        final double pitchStep = 1.6 - (_countdown * 0.14);
        SoundService.playTick(pitch: pitchStep);
      } else {
        timer.cancel();
        _startSpinningAnimation(appState);
      }
    });
  }

  void _startSpinningAnimation(AppState appState) {
    final candidates = appState.undrawnCurrentItems;
    if (candidates.isEmpty) {
      _revealWinner();
      return;
    }

    final random = Random();

    // 1. Embaralhar completamente a ordem das opções na fita a cada sorteio
    final List<RaffleItem> shuffledCandidates = List.from(candidates)..shuffle(random);

    // 2. Definir um ponto inicial aleatório na fita
    final int initialItemIndex = random.nextInt(shuffledCandidates.length);

    // 3. Gerar a fita de 300 itens com a ordem embaralhada
    _wheelItems = List.generate(300, (index) => shuffledCandidates[index % shuffledCandidates.length]);

    // 4. Encontrar o índice de destino (distância de ~220 itens) que corresponde exatamente ao vencedor
    int baseTarget = 200 + random.nextInt(30);
    int targetIndex = baseTarget;
    while (_wheelItems[targetIndex].id != _winner?.id && targetIndex < _wheelItems.length - 1) {
      targetIndex++;
    }

    // 5. Inicializar o controller no ponto de partida aleatório
    _wheelController = FixedExtentScrollController(initialItem: initialItemIndex);

    setState(() {
      _stage = RaffleStage.spinning;
    });

    // Tocar áudio peao.mp3
    SoundService.playPeao();

    // Disparar o giro 3D rápido com desaceleração nos últimos 4s
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wheelController?.animateToItem(
        targetIndex,
        duration: const Duration(milliseconds: 10000),
        curve: const SpinWheelCurve(),
      );
    });

    final DateTime startTime = DateTime.now();
    const int totalDurationMs = 10000;

    // Timer para controlar o FadeOut do áudio e transição final
    _spinTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!mounted) return;
      final int elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
      final double progress = (elapsedMs / totalDurationMs).clamp(0.0, 1.0);

      // FadeOut do peao.mp3 nos últimos 3.5 segundos
      if (progress > 0.65) {
        final double volume = (1.0 - progress) / 0.35;
        SoundService.setPeaoVolume(volume);
      }

      if (elapsedMs >= totalDurationMs) {
        timer.cancel();
        // Pausa dramática de 800ms com a roleta 3D cravada no vencedor
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
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
                        'O Grande Sorteio',
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
                              onPressed: () {
                                SoundService.stopAll();
                                _startRaffleProcess();
                              },
                              child: const Text(
                                'Sortear Novamente',
                                style: TextStyle(
                                  color: AppTheme.accentCyan,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
        final reelList = _wheelItems.isNotEmpty ? _wheelItems : (candidates.isNotEmpty ? candidates : [_winner!]);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Selo de topo
            const Text(
              ' DESTINO EM AÇÃO ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // Gabinete 3D da Roleta Cilíndrica
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.primaryPink, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.35),
                    blurRadius: 25,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Moldura Neon Central de Alvo
                  Container(
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDeep.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.accentCyan, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentCyan.withOpacity(0.4),
                          blurRadius: 15,
                        )
                      ],
                    ),
                  ),

                  // Indicadores Laterais da Roleta
                  Positioned(
                    left: 20,
                    child: const Icon(Icons.arrow_right_rounded, color: AppTheme.accentCyan, size: 30)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 500.ms),
                  ),
                  Positioned(
                    right: 20,
                    child: const Icon(Icons.arrow_left_rounded, color: AppTheme.accentCyan, size: 30)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 500.ms),
                  ),

                  // Roleta 3D Contínua em Cilindro com Máscara de Desfoque
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.25, 0.75, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: ListWheelScrollView.useDelegate(
                      controller: _wheelController ?? FixedExtentScrollController(initialItem: 0),
                      itemExtent: 58,
                      diameterRatio: 1.8,
                      perspective: 0.003,
                      physics: const NeverScrollableScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: reelList.length,
                        builder: (context, index) {
                          final item = reelList[index];
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 45),
                            child: Text(
                              item.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Barra de Suspense Inferior
            const Text(
              'O destino está escolhendo...',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
              ' A ESCOLHA FOI... ',
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
