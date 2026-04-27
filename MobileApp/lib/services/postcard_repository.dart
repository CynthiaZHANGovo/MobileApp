import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/postcard_content.dart';

class PostcardRepository {
  static const _futureSelfKey = 'future_self_cards';
  static const _publicBoardKey = 'public_board_cards';
  static const _streakKey = 'daily_streak';
  static const _lastGeneratedDayKey = 'last_generated_day';

  Future<int> updateAndGetStreak(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDayText = prefs.getString(_lastGeneratedDayKey);
    final currentDayText = _dayText(now);
    final currentStreak = prefs.getInt(_streakKey) ?? 0;

    int nextStreak = 1;
    if (lastDayText != null) {
      final lastDay = DateTime.tryParse(lastDayText);
      if (lastDay != null) {
        final difference = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastDay.year, lastDay.month, lastDay.day))
            .inDays;
        if (difference == 0) {
          nextStreak = currentStreak == 0 ? 1 : currentStreak;
        } else if (difference == 1) {
          nextStreak = currentStreak + 1;
        }
      }
    }

    await prefs.setInt(_streakKey, nextStreak);
    await prefs.setString(_lastGeneratedDayKey, currentDayText);
    return nextStreak;
  }

  Future<void> saveForFutureSelf(PostcardContent card) async {
    await _appendCard(_futureSelfKey, card);
  }

  Future<void> publishToBoard(PostcardContent card) async {
    await _appendCard(_publicBoardKey, card);
  }

  Future<List<PostcardContent>> loadFutureSelfCards() async {
    return _loadCards(_futureSelfKey);
  }

  Future<List<PostcardContent>> loadPublicBoardCards() async {
    return _loadCards(_publicBoardKey);
  }

  Future<void> deleteFutureSelfCard(String createdAtIso) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_futureSelfKey) ?? [];
    final next = list.where((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return (map['createdAtIso'] as String? ?? '') != createdAtIso;
    }).toList();
    await prefs.setStringList(_futureSelfKey, next);
  }

  Future<void> _appendCard(String key, PostcardContent card) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    final next = [jsonEncode(card.toJson()), ...list];
    await prefs.setStringList(key, next.take(12).toList());
  }

  Future<List<PostcardContent>> _loadCards(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    return list
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .map(PostcardContent.fromJson)
        .toList();
  }

  String _dayText(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day).toIso8601String();
}
