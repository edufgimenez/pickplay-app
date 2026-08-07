import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/raffle_item.dart';
import '../models/raffle_history.dart';
import '../services/storage_service.dart';

class CategoryMeta {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const CategoryMeta({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _selectedCategory = 'movies';
  List<RaffleItem> _allItems = [];
  List<RaffleHistoryRecord> _history = [];
  String _coupleNames = 'Edu & Amor';
  List<String> _customCategories = [];
  bool _isLoading = true;

  // Multiplicadores/Dicionário de Categorias padrão
  static final Map<String, CategoryMeta> defaultCategories = {
    'movies': const CategoryMeta(
      id: 'movies',
      label: 'Filmes',
      icon: Icons.movie_filter_rounded,
      color: Color(0xFFFF2975),
    ),
    'series': const CategoryMeta(
      id: 'series',
      label: 'Séries',
      icon: Icons.tv_rounded,
      color: Color(0xFF8C1EFF),
    ),
    'games': const CategoryMeta(
      id: 'games',
      label: 'Jogos',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF00F2FE),
    ),
  };

  DateTime get selectedMonth => _selectedMonth;
  String get selectedCategory => _selectedCategory;
  List<RaffleItem> get allItems => _allItems;
  List<RaffleHistoryRecord> get history => _history;
  String get coupleNames => _coupleNames;
  List<String> get customCategories => _customCategories;
  bool get isLoading => _isLoading;

  String get monthKey => DateFormat('yyyy-MM').format(_selectedMonth);
  String get formattedMonthName {
    final name = DateFormat('MMMM yyyy', 'pt_BR').format(_selectedMonth);
    // Capitalizar primeira letra do mês
    return name[0].toUpperCase() + name.substring(1);
  }

  IconData _getIconForCustomCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('restaurante') || lower.contains('comida') || lower.contains('jantar') || lower.contains('almoço')) {
      return Icons.restaurant_rounded;
    } else if (lower.contains('encontro') || lower.contains('date') || lower.contains('amor') || lower.contains('romance')) {
      return Icons.favorite_rounded;
    } else if (lower.contains('viagem') || lower.contains('passeio') || lower.contains('turismo')) {
      return Icons.explore_rounded;
    } else if (lower.contains('bar') || lower.contains('drink') || lower.contains('cerveja')) {
      return Icons.local_bar_rounded;
    } else if (lower.contains('cinema') || lower.contains('teatro') || lower.contains('show')) {
      return Icons.local_activity_rounded;
    }
    return Icons.stars_rounded;
  }

  // Obter categorias ativas completas
  List<CategoryMeta> get allCategoriesList {
    List<CategoryMeta> list = [...defaultCategories.values];
    for (var cat in _customCategories) {
      list.add(CategoryMeta(
        id: cat.toLowerCase(),
        label: cat,
        icon: _getIconForCustomCategory(cat),
        color: const Color(0xFFFFC837),
      ));
    }
    return list;
  }

  // Itens filtrados para o Mês e Categoria atuais
  List<RaffleItem> get currentItems {
    return _allItems.where((item) =>
      item.monthKey == monthKey && item.category == _selectedCategory
    ).toList();
  }

  // Itens ainda NÃO sorteados para o Mês e Categoria atuais
  List<RaffleItem> get undrawnCurrentItems {
    return currentItems.where((item) => !item.isDrawn).toList();
  }

  // Construtor & Inicialização
  AppState() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _allItems = await _storage.loadItems();
    _history = await _storage.loadHistory();
    _coupleNames = await _storage.loadCoupleNames();
    _customCategories = await _storage.loadCustomCategories();

    // Se estiver totalmente vazio pela primeira vez, adicionar alguns exemplos fofos!
    if (_allItems.isEmpty) {
      _addInitialSampleData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addInitialSampleData() {
    final currentKey = monthKey;
    _allItems = [
      RaffleItem(title: 'Inception (A Origem)', category: 'movies', monthKey: currentKey),
      RaffleItem(title: 'Interstellar', category: 'movies', monthKey: currentKey),
      RaffleItem(title: 'Divertida Mente 2', category: 'movies', monthKey: currentKey),
      RaffleItem(title: 'Stranger Things', category: 'series', monthKey: currentKey),
      RaffleItem(title: 'The Last of Us', category: 'series', monthKey: currentKey),
      RaffleItem(title: 'It Takes Two', category: 'games', monthKey: currentKey),
      RaffleItem(title: 'Overcooked 2', category: 'games', monthKey: currentKey),
      RaffleItem(title: 'Stardew Valley (Co-op)', category: 'games', monthKey: currentKey),
    ];
    _storage.saveItems(_allItems);
  }

  // Métodos de seleção de mês
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  // Troca de categoria
  void setSelectedCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  // Adicionar item na lista atual
  Future<void> addItem(String title) async {
    if (title.trim().isEmpty) return;

    final newItem = RaffleItem(
      title: title.trim(),
      category: _selectedCategory,
      monthKey: monthKey,
    );

    _allItems.add(newItem);
    await _storage.saveItems(_allItems);
    notifyListeners();
  }

  // Remover item
  Future<void> removeItem(String id) async {
    _allItems.removeWhere((item) => item.id == id);
    await _storage.saveItems(_allItems);
    notifyListeners();
  }

  // Marcar/Desmarcar como sorteado
  Future<void> toggleItemDrawn(String id) async {
    final index = _allItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _allItems[index].isDrawn = !_allItems[index].isDrawn;
      await _storage.saveItems(_allItems);
      notifyListeners();
    }
  }

  // Realizar Sorteio do Vencedor
  RaffleItem? pickRandomWinner() {
    final available = undrawnCurrentItems;
    if (available.isEmpty) return null;

    final random = Random();
    final winner = available[random.nextInt(available.length)];
    return winner;
  }

  // Confirmar Sorteio e Salvar no Histórico
  Future<void> confirmRaffleWinner(RaffleItem winner) async {
    // 1. Marcar item como sorteado
    final index = _allItems.indexWhere((item) => item.id == winner.id);
    if (index != -1) {
      _allItems[index].isDrawn = true;
      await _storage.saveItems(_allItems);
    }

    // 2. Adicionar ao Histórico do Casal
    final historyRecord = RaffleHistoryRecord(
      title: winner.title,
      category: winner.category,
      monthKey: winner.monthKey,
      drawnAt: DateTime.now(),
    );

    _history.insert(0, historyRecord);
    await _storage.saveHistory(_history);
    notifyListeners();
  }

  // Adicionar categoria personalizada
  Future<void> addCustomCategory(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    if (!_customCategories.contains(cleanName)) {
      _customCategories.add(cleanName);
      await _storage.saveCustomCategories(_customCategories);
      _selectedCategory = cleanName.toLowerCase();
      notifyListeners();
    }
  }

  // Remover categoria personalizada
  Future<void> removeCustomCategory(String name) async {
    _customCategories.remove(name);
    await _storage.saveCustomCategories(_customCategories);
    if (_selectedCategory == name.toLowerCase()) {
      _selectedCategory = 'movies';
    }
    notifyListeners();
  }

  // Atualizar nome do casal
  Future<void> updateCoupleNames(String names) async {
    _coupleNames = names.trim().isEmpty ? 'Edu & Amor' : names.trim();
    await _storage.saveCoupleNames(_coupleNames);
    notifyListeners();
  }

  // Limpar histórico de um mês específico se desejado
  Future<void> clearMonthHistory(String monthKey) async {
    _history.removeWhere((record) => record.monthKey == monthKey);
    await _storage.saveHistory(_history);
    notifyListeners();
  }
}
