import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/raffle_item.dart';
import '../models/raffle_history.dart';

class StorageService {
  static const String _keyItems = 'pickplay_raffle_items';
  static const String _keyHistory = 'pickplay_raffle_history';
  static const String _keyCoupleNames = 'pickplay_couple_names';
  static const String _keyCustomCategories = 'pickplay_custom_categories';
  static const String _keyFirstLaunch = 'pickplay_is_first_launch';

  // Verificar primeira execução
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  // Marcar primeira execução como concluída
  Future<void> markFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  // Carregar todos os itens salvos
  Future<List<RaffleItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_keyItems);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => RaffleItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Salvar lista de itens
  Future<void> saveItems(List<RaffleItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keyItems, jsonEncode(jsonList));
  }

  // Carregar histórico
  Future<List<RaffleHistoryRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_keyHistory);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => RaffleHistoryRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Salvar histórico
  Future<void> saveHistory(List<RaffleHistoryRecord> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(jsonList));
  }

  // Nome do casal (Padrão: "Nosso Casal")
  Future<String> loadCoupleNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCoupleNames) ?? 'Nosso Casal';
  }

  Future<void> saveCoupleNames(String names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCoupleNames, names);
  }

  // Categorias personalizadas extras
  Future<List<String>> loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCustomCategories) ?? [];
  }

  Future<void> saveCustomCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCustomCategories, categories);
  }
}
