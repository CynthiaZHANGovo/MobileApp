
import 'package:flutter/material.dart';
import 'package:environmental_postcard/models/postcard.dart';
import 'package:environmental_postcard/repositories/postcard_repository.dart';

class PostcardProvider extends ChangeNotifier {
  final PostcardRepository _repository = PostcardRepository();
  List<Postcard> _postcards = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Postcard> get postcards => _postcards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PostcardProvider() {
    loadPostcards();
  }

  Future<void> savePostcard(Postcard postcard) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.savePostcard(postcard);
      _postcards.insert(0, postcard); // Add to the beginning of the list
      _errorMessage = null; // Clear any previous errors on success
    } catch (e) {
      _errorMessage = 'Failed to save postcard: $e';
      print('Error saving postcard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPostcards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _postcards = await _repository.loadPostcards();
      _errorMessage = null; // Clear any previous errors on success
    } catch (e) {
      _errorMessage = 'Failed to load postcards: $e';
      print('Error loading postcards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
