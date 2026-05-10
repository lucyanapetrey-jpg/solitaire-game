import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static const String _prefsKey = 'solitaire_music_enabled';
  static const String _musicAsset = 'audio/background.mp3';

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  bool _initialized = false;
  bool _started = false;

  bool get enabled => _enabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefsKey) ?? true;
    try {
      // iOS: allow playback in silent mode + mix with other audio
      await AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ));
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.30);
      await _player.setSource(AssetSource(_musicAsset));
    } catch (e) {
      debugPrint('[AudioService] init failed: $e');
    }
    if (_enabled) await ensurePlaying();
  }

  /// Call this from any user-interaction (button tap) to satisfy iOS autoplay
  /// restrictions. Safe to call multiple times.
  Future<void> ensurePlaying() async {
    if (!_enabled) return;
    if (_started && _player.state == PlayerState.playing) return;
    try {
      await _player.resume();
      _started = true;
    } catch (_) {
      try {
        await _player.play(AssetSource(_musicAsset));
        _started = true;
      } catch (e) {
        debugPrint('[AudioService] play failed: $e');
      }
    }
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    if (value) {
      await ensurePlaying();
    } else {
      try { await _player.pause(); } catch (_) {}
    }
  }

  Future<void> toggle() => setEnabled(!_enabled);
}
