import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _tickPlayer = AudioPlayer();
  static final AudioPlayer _peaoPlayer = AudioPlayer();
  static final AudioPlayer _winPlayer = AudioPlayer();

  /// Toca o som de tick para a contagem regressiva de 5 segundos
  static Future<void> playTick({double pitch = 1.0}) async {
    try {
      await _tickPlayer.stop();
      await _tickPlayer.setPlaybackRate(pitch.clamp(0.8, 1.8));
      await _tickPlayer.play(AssetSource('sounds/tick.wav'), volume: 0.85);
    } catch (_) {}
  }

  /// Toca a música peao.mp3 durante os 10 segundos da roleta
  static Future<void> playPeao() async {
    try {
      await _peaoPlayer.stop();
      await _peaoPlayer.setVolume(1.0);
      await _peaoPlayer.play(AssetSource('sounds/peao.mp3'));
    } catch (_) {}
  }

  /// Ajusta suavemente o volume do peao.mp3 para criar efeito de fadeout
  static Future<void> setPeaoVolume(double volume) async {
    try {
      await _peaoPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  /// Para o som do peão
  static Future<void> stopPeao() async {
    try {
      await _peaoPlayer.stop();
    } catch (_) {}
  }

  /// Toca o áudio de comemoração (comemoracao.mp3) quando o vencedor é revelado
  static Future<void> playWinner() async {
    try {
      await _peaoPlayer.stop();
      await _winPlayer.stop();
      await _winPlayer.play(AssetSource('sounds/comemoracao.mp3'), volume: 1.0);
    } catch (_) {}
  }

  static void dispose() {
    _tickPlayer.dispose();
    _peaoPlayer.dispose();
    _winPlayer.dispose();
  }
}
