import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../models/environment_snapshot.dart';
import '../models/postcard_content.dart';
import '../models/postcard_style_variant.dart';
import '../services/environment_service.dart';
import '../services/photo_palette_service.dart';
import '../services/postcard_generator_service.dart';
import '../services/postcard_repository.dart';
import '../services/postcard_style_service.dart';

class PostcardAppController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final EnvironmentService _environmentService = EnvironmentService();
  final PhotoPaletteService _paletteService = PhotoPaletteService();
  final PostcardGeneratorService _generatorService = PostcardGeneratorService();
  final PostcardStyleService _styleService = PostcardStyleService();
  final PostcardRepository _repository = PostcardRepository();

  XFile? selectedImage;
  EnvironmentSnapshot? environment;
  List<PostcardStyleVariant> variants = const [];
  int selectedVariantIndex = 0;
  List<PostcardContent> futureCards = const [];
  List<PostcardContent> boardCards = const [];
  bool isGenerating = false;
  String? errorText;
  int streakDays = 0;
  String? generatedMessage;

  PostcardStyleVariant? get selectedVariant =>
      variants.isEmpty ? null : variants[selectedVariantIndex];

  PostcardContent? get previewCard {
    final image = selectedImage;
    final variant = selectedVariant;
    final message = generatedMessage;
    final liveEnvironment = environment;
    if (image == null || variant == null || message == null || liveEnvironment == null) {
      return null;
    }

    return PostcardContent(
      imagePath: image.path,
      message: message,
      styleName: variant.name,
      stickerLabels: variant.stickerLabels,
      locationLabel: liveEnvironment.locationLabel,
      weatherLabel: liveEnvironment.weatherLabel,
      temperatureText: '${liveEnvironment.temperatureC.toStringAsFixed(0)}°C',
      aqiLabel: liveEnvironment.aqiLabel,
      createdAtIso: DateTime.now().toIso8601String(),
      streakDays: streakDays == 0 ? 1 : streakDays,
      primaryColorValue: variant.frameColor.toARGB32(),
      secondaryColorValue: variant.accentColor.toARGB32(),
    );
  }

  Future<void> initialize() async {
    await refreshCollections();
  }

  Future<void> refreshCollections() async {
    futureCards = await _repository.loadFutureSelfCards();
    boardCards = await _repository.loadPublicBoardCards();
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2000,
    );
    if (file == null) return;
    selectedImage = file;
    generatedMessage = null;
    variants = const [];
    selectedVariantIndex = 0;
    errorText = null;
    notifyListeners();
  }

  Future<bool> generatePostcard() async {
    final image = selectedImage;
    if (image == null) {
      errorText = 'Choose a photo first to build today\'s postcard.';
      notifyListeners();
      return false;
    }

    isGenerating = true;
    errorText = null;
    notifyListeners();

    try {
      environment = await _environmentService.collect();
      final palette = await _paletteService.analyze(image.path);
      streakDays = await _repository.updateAndGetStreak(DateTime.now());
      generatedMessage = await _generatorService.generateMessage(
        environment: environment!,
        palette: palette,
        streakDays: streakDays,
      );
      variants = _styleService.buildVariants(
        environment: environment!,
        palette: palette,
        streakDays: streakDays,
      );
      selectedVariantIndex = 0;
      notifyListeners();
      return true;
    } catch (error) {
      errorText = '$error';
      notifyListeners();
      return false;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  void selectVariant(int index) {
    if (index < 0 || index >= variants.length) return;
    selectedVariantIndex = index;
    notifyListeners();
  }

  Future<String?> saveForFutureSelf() async {
    final card = previewCard;
    if (card == null) return null;
    await _repository.saveForFutureSelf(card);
    await refreshCollections();
    return 'Saved to Future Self.';
  }

  Future<String?> publishToBoard() async {
    final card = previewCard;
    if (card == null) return null;
    await _repository.publishToBoard(card);
    await refreshCollections();
    return 'Published to the Post Office.';
  }

  Future<void> shareCurrentCard() async {
    final card = previewCard;
    if (card == null) return;
    final payload = [
      'Environmental Postcard',
      card.styleName,
      card.message,
      '${card.locationLabel} · ${card.weatherLabel} · ${card.temperatureText}',
      card.aqiLabel,
    ].join('\n');

    await SharePlus.instance.share(
      ShareParams(text: payload, files: [XFile(card.imagePath)]),
    );
  }
}
