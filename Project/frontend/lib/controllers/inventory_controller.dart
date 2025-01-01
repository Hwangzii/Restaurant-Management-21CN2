import 'package:app/models/item.dart';
import 'package:app/services/api_service.dart';

class InventoryController {
  final ApiService apiService = ApiService();

  List<Item> allItems = [];
  List<Item> displayedItems = [];
  String searchQuery = '';

  Future<void> loadItems() async {
    allItems = await apiService.getItems();
    _applyFilter();
  }

  Future<void> createItem(Item item) async {
    await apiService.createItem(item);
    await loadItems();
  }

  Future<void> updateItem(Item item) async {
    await apiService.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await apiService.deleteItem(id);
    await loadItems();
  }

  void setSearchQuery(String query) {
    searchQuery = query.toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    if (searchQuery.isEmpty) {
      displayedItems = List.from(allItems);
    } else {
      displayedItems = allItems
          .where((item) => item.itemName.toLowerCase().contains(searchQuery))
          .toList();
    }
  }

  Future<void> createOrUpdateItem(Item item) async {
    if (item.itemId == 0) {
      await createItem(item);
    } else {
      await updateItem(item);
    }
  }
}
