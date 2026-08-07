import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _tickPlayer = AudioPlayer();
  static final AudioPlayer _winPlayer = AudioPlayer();

  /// Toca um efeito sonoro de tick (contagem regressiva e roleta)
  static Future<void> playTick() async {
    try {
      await _tickPlayer.stop();
      await _tickPlayer.play(AssetSource('sounds/tick.wav'), volume: 0.8);
    } catch (_) {
      // Ignorar erros caso áudio não esteja disponível na plataforma
    }
  }

  /// Toca um som alegre de vitória quando o resultado é revelado
  static Future<void> playWinner() async {
    try {
      await _winPlayer.stop();
      await _winPlayer.play(AssetSource('sounds/winner.wav'), volume: 1.0);
    } catch (_) {
      // Ignorar erros silenciosamente
    }
  }

  static void dispose() {
    _tickPlayer.dispose();
    _winPlayer.dispose();
  }
}
