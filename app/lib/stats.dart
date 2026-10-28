import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything saved on the phone: progress, streak and the learner's answers
/// from the welcome questions. Nothing leaves the device.
class Stats extends ChangeNotifier {
  int xp = 0;
  int streak = 0;
  int correct = 0;
  int total = 0;
  final Set<String> done = {};

  /// Lessons tried but not passed yet.
  final Set<String> tried = {};

  /// Days (yyyy-mm-dd) with at least one answer.
  final Set<String> days = {};

  /// Per skill: [correct, total].
  final Map<String, List<int>> skill = {};

  bool onboarded = false;
  final Set<String> goals = {};
  String experience = '';
  String instrument = '';
  String ear = '';
  int dailyMinutes = 8;
  String dailyDoneDay = '';
  String _lastDay = '';

  static String day(DateTime d) => d.toIso8601String().substring(0, 10);

  bool get dailyDoneToday => dailyDoneDay == day(DateTime.now());

  /// Questions in a daily session, from the daily goal.
  int get dailyQuestions => (dailyMinutes * 1.5).round().clamp(6, 24);

  /// Monday to Sunday of this week: true where there was practice.
  List<bool> get weekPips {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return [
      for (var i = 0; i < 7; i++)
        days.contains(day(monday.add(Duration(days: i)))),
    ];
  }

  double accuracyOf(String id) {
    final v = skill[id];
    if (v == null || v[1] == 0) return 0;
    return v[0] / v[1];
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    xp = p.getInt('xp') ?? 0;
    streak = p.getInt('streak') ?? 0;
    correct = p.getInt('correct') ?? 0;
    total = p.getInt('total') ?? 0;
    _lastDay = p.getString('lastDay') ?? '';
    done
      ..clear()
      ..addAll(p.getStringList('done') ?? const []);
    tried
      ..clear()
      ..addAll(p.getStringList('tried') ?? const []);
    days
      ..clear()
      ..addAll(p.getStringList('days') ?? const []);
    skill.clear();
    final raw = p.getString('skill');
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      m.forEach((k, v) => skill[k] = (v as List).cast<int>());
    }
    onboarded = p.getBool('onboarded') ?? false;
    goals
      ..clear()
      ..addAll(p.getStringList('goals') ?? const []);
    experience = p.getString('experience') ?? '';
    instrument = p.getString('instrument') ?? '';
    ear = p.getString('ear') ?? '';
    dailyMinutes = p.getInt('dailyMinutes') ?? 8;
    dailyDoneDay = p.getString('dailyDoneDay') ?? '';
    notifyListeners();
  }

  Future<void> record(bool right, {String? skillId}) async {
    total++;
    if (right) {
      correct++;
      xp += 10;
    }
    if (skillId != null) {
      final v = skill.putIfAbsent(skillId, () => [0, 0]);
      v[1]++;
      if (right) v[0]++;
    }
    final today = day(DateTime.now());
    days.add(today);
    if (_lastDay != today) {
      final yesterday = day(DateTime.now().subtract(const Duration(days: 1)));
      streak = _lastDay == yesterday ? streak + 1 : 1;
      _lastDay = today;
    }
    notifyListeners();
    await _save();
  }

  /// Saves the result of a lesson attempt.
  Future<void> finishLesson(String lessonId, bool passed) async {
    if (passed) {
      if (done.add(lessonId)) xp += 50;
      tried.remove(lessonId);
    } else if (!done.contains(lessonId)) {
      tried.add(lessonId);
    }
    notifyListeners();
    await _save();
  }

  Future<void> finishDaily() async {
    dailyDoneDay = day(DateTime.now());
    xp += 30;
    notifyListeners();
    await _save();
  }

  Future<void> saveProfile({
    Set<String>? goals,
    String? experience,
    String? instrument,
    String? ear,
    int? dailyMinutes,
    bool? onboarded,
  }) async {
    if (goals != null) {
      this.goals
        ..clear()
        ..addAll(goals);
    }
    this.experience = experience ?? this.experience;
    this.instrument = instrument ?? this.instrument;
    this.ear = ear ?? this.ear;
    this.dailyMinutes = dailyMinutes ?? this.dailyMinutes;
    this.onboarded = onboarded ?? this.onboarded;
    notifyListeners();
    await _save();
  }

  /// Clears progress. The welcome answers and the daily goal stay.
  Future<void> reset() async {
    xp = streak = correct = total = 0;
    _lastDay = '';
    dailyDoneDay = '';
    done.clear();
    tried.clear();
    days.clear();
    skill.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('xp', xp);
    await p.setInt('streak', streak);
    await p.setInt('correct', correct);
    await p.setInt('total', total);
    await p.setString('lastDay', _lastDay);
    await p.setStringList('done', done.toList());
    await p.setStringList('tried', tried.toList());
    await p.setStringList('days', days.toList());
    await p.setString('skill', jsonEncode(skill));
    await p.setBool('onboarded', onboarded);
    await p.setStringList('goals', goals.toList());
    await p.setString('experience', experience);
    await p.setString('instrument', instrument);
    await p.setString('ear', ear);
    await p.setInt('dailyMinutes', dailyMinutes);
    await p.setString('dailyDoneDay', dailyDoneDay);
  }
}
