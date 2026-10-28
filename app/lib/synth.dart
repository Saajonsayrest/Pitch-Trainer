import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

const wavSampleRate = 22050;

/// Pitch in Hz for a MIDI note number, in equal temperament (A4 = 440 Hz),
/// the same tuning as a piano.
double midiToHz(int midi) => 440.0 * pow(2, (midi - 69) / 12);

Float64List _tone(int midi, double seconds) {
  final n = (seconds * wavSampleRate).round();
  final f = midiToHz(midi);
  final out = Float64List(n);
  for (var i = 0; i < n; i++) {
    final t = i / wavSampleRate;
    final attack = min(1.0, t / 0.01);
    final release = min(1.0, (seconds - t) / 0.05);
    final decay = exp(-2.5 * t / seconds);
    // Fundamental plus two quiet overtones for a warmer sound.
    final v =
        sin(2 * pi * f * t) +
        0.35 * sin(2 * pi * 2 * f * t) +
        0.15 * sin(2 * pi * 3 * f * t);
    out[i] = v * attack * release * decay;
  }
  return out;
}

Float64List _step(int root, List<int> notes, double seconds) {
  final mix = Float64List((seconds * wavSampleRate).round());
  final gain = 1 / sqrt(notes.length);
  for (final s in notes) {
    final t = _tone(root + s, seconds);
    for (var i = 0; i < mix.length; i++) {
      mix[i] += t[i] * gain * 0.7;
    }
  }
  return mix;
}

/// Builds a 16-bit mono WAV. Each step is a group of semitone offsets from
/// [root] (a MIDI number) that sound together. Steps sound one after another.
Uint8List buildWav(int root, List<List<int>> steps, double seconds) {
  final parts = [for (final s in steps) _step(root, s, seconds)];
  final total = parts.fold(0, (a, p) => a + p.length);
  final data = ByteData(44 + total * 2);
  void str(int o, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(o + i, s.codeUnitAt(i));
    }
  }

  str(0, 'RIFF');
  data.setUint32(4, 36 + total * 2, Endian.little);
  str(8, 'WAVEfmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, wavSampleRate, Endian.little);
  data.setUint32(28, wavSampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  str(36, 'data');
  data.setUint32(40, total * 2, Endian.little);
  var at = 44;
  for (final p in parts) {
    for (final v in p) {
      data.setInt16(at, (v.clamp(-1.0, 1.0) * 28000).round(), Endian.little);
      at += 2;
    }
  }
  return data.buffer.asUint8List();
}

/// The one player the whole app shares. Created on first use.
final Synth appSynth = Synth();

/// Plays tones made by [buildWav]. No sampled audio is used.
class Synth {
  Synth() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  final _player = AudioPlayer();

  Future<void> play(
    int root,
    List<List<int>> steps, {
    double stepSeconds = 0.6,
  }) async {
    final wav = buildWav(root, steps, stepSeconds);
    await _player.stop();
    await _player.play(BytesSource(wav, mimeType: 'audio/wav'));
  }

  void dispose() => _player.dispose();
}
