import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Aguardar 2.8 segundos de pura emoção e transicionar para a HomeScreen
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.15),
            radius: 0.9,
            colors: [
              AppTheme.primaryPurple.withOpacity(0.25),
              AppTheme.backgroundDeep,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Conteúdo Centralizado
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo com entrada pulsante e brilho sutil
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo-icon.png',
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  )
                  .animate()
                  .scale(duration: 900.ms, curve: Curves.elasticOut)
                  .shimmer(duration: 1200.ms, delay: 900.ms),

                  const SizedBox(height: 30),

                  // Título Principal "PickPlay"
                  const Text(
                    'PickPlay',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: AppTheme.primaryPink,
                          blurRadius: 20,
                        )
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 300.ms)
                  .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),

                  // Subtítulo Romântico
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundCard.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_rounded, color: AppTheme.primaryPink, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'O Sorteador do Casal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.favorite_rounded, color: AppTheme.primaryPink, size: 16),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .scale(duration: 600.ms, delay: 600.ms),
                ],
              ),
            ),

            // Rodapé com Carregamento
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Preparando o entretenimento do casal...',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Feito com amor por EG para BR',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.favorite_rounded,
                        color: AppTheme.primaryPink,
                        size: 14,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(1, 1), end: const Offset(1.25, 1.25), duration: 700.ms),
                    ],
                  ).animate().fadeIn(duration: 800.ms, delay: 1000.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
