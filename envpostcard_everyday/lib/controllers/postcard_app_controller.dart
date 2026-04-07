import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/environment_snapshot.dart';
import '../models/postcard_content.dart';
import '../models/postcard_style_variant.dart';
import '../models/studio_sticker.dart';
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
  final GlobalKey previewBoundaryKey = GlobalKey();

  XFile? selectedImage;
  EnvironmentSnapshot? environment;
  List<PostcardStyleVariant> variants = const [];
  int selectedVariantIndex = 0;
  List<PostcardContent> futureCards = const [];
  bool isGenerating = false;
  bool isExporting = false;
  String? errorText;
  int streakDays = 0;
  String? generatedMessage;
  List<StudioSticker> activeStickers = const [];
  String? selectedStickerId;
  String? selectedCatalogStickerId;
  List<String> socialCaptions = const [];
  int selectedCaptionIndex = 0;

  PostcardStyleVariant? get selectedVariant =>
      variants.isEmpty ? null : variants[selectedVariantIndex];

  String get selectedSocialCaption =>
      socialCaptions.isEmpty ? '' : socialCaptions[selectedCaptionIndex];

  List<StudioSticker> get stickerCatalog {
    final liveEnvironment = environment;
    if (liveEnvironment == null) return const [];
    final cityLabel = liveEnvironment.locationLabel.split(',').first;
    return [
      StudioSticker(
        id: 'catalog-weather',
        type: StickerType.weatherScene,
        label: liveEnvironment.weatherLabel,
        dx: 0,
        dy: 0,
      ),
      const StudioSticker(id: 'catalog-sun', type: StickerType.sunBadge, label: 'Sunny', dx: 0, dy: 0),
      const StudioSticker(id: 'catalog-cloud', type: StickerType.cloudBadge, label: 'Cloud', dx: 0, dy: 0),
      const StudioSticker(id: 'catalog-rain', type: StickerType.rainBadge, label: 'Rain', dx: 0, dy: 0),
      const StudioSticker(id: 'catalog-wind', type: StickerType.windBadge, label: 'Wind', dx: 0, dy: 0),
      const StudioSticker(id: 'catalog-leaf', type: StickerType.leafBadge, label: 'Leaf', dx: 0, dy: 0),
      const StudioSticker(id: 'catalog-star', type: StickerType.starBadge, label: 'Star', dx: 0, dy: 0),
      const StudioSticker(id: 'catalog-moon', type: StickerType.moonBadge, label: 'Moon', dx: 0, dy: 0),
      const StudioSticker(id: 'catalog-flower', type: StickerType.flowerBadge, label: 'Bloom', dx: 0, dy: 0),
      const StudioSticker(id: 'catalog-drop', type: StickerType.dropBadge, label: 'Drop', dx: 0, dy: 0),
      StudioSticker(
        id: 'catalog-thermo',
        type: StickerType.thermoBadge,
        label: '${liveEnvironment.temperatureC.toStringAsFixed(0)}°C',
        dx: 0,
        dy: 0,
      ),
      StudioSticker(
        id: 'catalog-aqi',
        type: StickerType.aqiBadge,
        label: 'AQI ${liveEnvironment.aqi}',
        dx: 0,
        dy: 0,
      ),
      StudioSticker(
        id: 'catalog-time',
        type: StickerType.timeBadge,
        label:
            '${liveEnvironment.localTime.hour.toString().padLeft(2, '0')}:${liveEnvironment.localTime.minute.toString().padLeft(2, '0')}',
        dx: 0,
        dy: 0,
      ),
      StudioSticker(
        id: 'catalog-city',
        type: StickerType.cityBadge,
        label: cityLabel,
        dx: 0,
        dy: 0,
      ),
    ];
  }

  StudioSticker? get selectedCatalogSticker {
    if (selectedCatalogStickerId == null) return stickerCatalog.isEmpty ? null : stickerCatalog.first;
    for (final sticker in stickerCatalog) {
      if (sticker.id == selectedCatalogStickerId) return sticker;
    }
    return stickerCatalog.isEmpty ? null : stickerCatalog.first;
  }

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
      renderedImagePath: '',
      message: message,
      styleName: variant.name,
      stickerLabels: activeStickers.map((item) => item.label).take(4).toList(),
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
    activeStickers = const [];
    selectedStickerId = null;
    selectedCatalogStickerId = null;
    socialCaptions = const [];
    selectedCaptionIndex = 0;
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
      socialCaptions = _generatorService.generateSocialCaptions(
        environment: environment!,
        palette: palette,
        streakDays: streakDays,
      );
      selectedCaptionIndex = 0;
      variants = _styleService.buildVariants(
        environment: environment!,
        palette: palette,
        streakDays: streakDays,
      );
      selectedVariantIndex = 0;
      _resetStickers();
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
    _resetStickers();
    notifyListeners();
  }

  void selectSticker(String stickerId) {
    selectedStickerId = stickerId;
    notifyListeners();
  }

  void selectCatalogSticker(String stickerId) {
    selectedCatalogStickerId = stickerId;
    notifyListeners();
  }

  void selectCaption(int index) {
    if (index < 0 || index >= socialCaptions.length) return;
    selectedCaptionIndex = index;
    notifyListeners();
  }

  void nextCaption() {
    if (socialCaptions.isEmpty) return;
    selectedCaptionIndex = (selectedCaptionIndex + 1) % socialCaptions.length;
    notifyListeners();
  }

  void setExporting(bool value) {
    isExporting = value;
    if (!value) {
      notifyListeners();
      return;
    }
    errorText = null;
    notifyListeners();
  }

  void replaceSelectedSticker() {
    if (activeStickers.isEmpty) return;
    final template = selectedCatalogSticker;
    if (template == null) return;
    final selectedId = selectedStickerId ?? activeStickers.first.id;
    activeStickers = activeStickers.map((item) {
      if (item.id != selectedId) return item;
      return item.copyWith(type: template.type, label: template.label);
    }).toList();
    selectedStickerId = selectedId;
    notifyListeners();
  }

  void addStickerFromCatalog() {
    final template = selectedCatalogSticker;
    if (template == null) return;
    final index = activeStickers.length;
    final next = StudioSticker(
      id: 'sticker-${DateTime.now().microsecondsSinceEpoch}',
      type: template.type,
      label: template.label,
      dx: (0.10 + (index % 3) * 0.18).clamp(0.06, 0.78),
      dy: (0.10 + (index % 4) * 0.12).clamp(0.08, 0.76),
    );
    activeStickers = [...activeStickers, next];
    selectedStickerId = next.id;
    notifyListeners();
  }

  void deleteSelectedSticker() {
    final selectedId = selectedStickerId;
    if (selectedId == null) return;
    activeStickers = activeStickers.where((item) => item.id != selectedId).toList();
    selectedStickerId = activeStickers.isEmpty ? null : activeStickers.first.id;
    notifyListeners();
  }

  void moveSticker(String stickerId, Offset delta, Size bounds) {
    final width = bounds.width == 0 ? 1 : bounds.width;
    final height = bounds.height == 0 ? 1 : bounds.height;
    activeStickers = activeStickers.map((item) {
      if (item.id != stickerId) return item;
      final nextDx = (item.dx + delta.dx / width).clamp(0.04, 0.82);
      final nextDy = (item.dy + delta.dy / height).clamp(0.06, 0.82);
      return item.copyWith(dx: nextDx, dy: nextDy);
    }).toList();
    selectedStickerId = stickerId;
    notifyListeners();
  }

  Future<String?> saveForFutureSelf() async {
    final card = previewCard;
    if (card == null) return null;
    final renderedPath = await exportCurrentPostcard();
    if (renderedPath == null) return 'Could not render postcard yet.';
    await _repository.saveForFutureSelf(
      PostcardContent(
        imagePath: card.imagePath,
        renderedImagePath: renderedPath,
        message: card.message,
        styleName: card.styleName,
        stickerLabels: card.stickerLabels,
        locationLabel: card.locationLabel,
        weatherLabel: card.weatherLabel,
        temperatureText: card.temperatureText,
        aqiLabel: card.aqiLabel,
        createdAtIso: card.createdAtIso,
        streakDays: card.streakDays,
        primaryColorValue: card.primaryColorValue,
        secondaryColorValue: card.secondaryColorValue,
      ),
    );
    await refreshCollections();
    return 'Saved postcard to your album.';
  }

  Future<String?> exportPostcardPng() async {
    final renderedPath = await exportCurrentPostcard();
    if (renderedPath == null) return 'Could not render postcard yet.';
    return 'Postcard image saved to $renderedPath';
  }

  Future<String?> shareCurrentCard() async {
    final card = previewCard;
    if (card == null) return null;
    final renderedPath = await exportCurrentPostcard();
    if (renderedPath == null) return 'Could not render postcard yet.';

    final payload = [
      'Environmental Postcard',
      card.styleName,
      card.message,
      selectedSocialCaption,
      '${card.locationLabel} · ${card.weatherLabel} · ${card.temperatureText}',
      card.aqiLabel,
    ].where((item) => item.trim().isNotEmpty).join('\n');

    await SharePlus.instance.share(
      ShareParams(text: payload, files: [XFile(renderedPath)]),
    );
    return 'Postcard ready to share.';
  }

  Future<String?> exportCurrentPostcard() async {
    isExporting = true;
    errorText = null;
    notifyListeners();
    try {
      for (var attempt = 0; attempt < 6; attempt++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(Duration(milliseconds: 90 + attempt * 30));

        final boundary =
            previewBoundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) {
          continue;
        }
        if (boundary.debugNeedsPaint ||
            boundary.size.isEmpty ||
            boundary.size.width <= 0 ||
            boundary.size.height <= 0) {
          continue;
        }

        try {
          final image = await boundary.toImage(pixelRatio: 3);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData == null) {
            continue;
          }

          final directory = await getApplicationDocumentsDirectory();
          final postcardsDir = Directory('${directory.path}/postcards');
          if (!postcardsDir.existsSync()) {
            postcardsDir.createSync(recursive: true);
          }
          final path =
              '${postcardsDir.path}/postcard_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File(path);
          await file.writeAsBytes(byteData.buffer.asUint8List());
          return path;
        } catch (_) {
          continue;
        }
      }

      errorText = 'Could not render postcard image. Please wait a moment and try again.';
      notifyListeners();
      return null;
    } catch (_) {
      errorText = 'Could not render postcard image. Please wait a moment and try again.';
      notifyListeners();
      return null;
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  void _resetStickers() {
    final liveEnvironment = environment;
    if (liveEnvironment == null) return;
    activeStickers = [
      StudioSticker(
        id: 'sticker-weather',
        type: StickerType.weatherScene,
        label: liveEnvironment.weatherLabel,
        dx: 0.07,
        dy: 0.08,
      ),
      StudioSticker(
        id: 'sticker-temp',
        type: StickerType.thermoBadge,
        label: '${liveEnvironment.temperatureC.toStringAsFixed(0)}°C',
        dx: 0.72,
        dy: 0.12,
      ),
      StudioSticker(
        id: 'sticker-aqi',
        type: StickerType.aqiBadge,
        label: 'AQI ${liveEnvironment.aqi}',
        dx: 0.70,
        dy: 0.64,
      ),
    ];
    selectedStickerId = activeStickers.first.id;
    selectedCatalogStickerId = stickerCatalog.isEmpty ? null : stickerCatalog.first.id;
  }

  Future<String?> saveRenderedPostcard(String renderedPath) async {
    final card = previewCard;
    if (card == null) return null;
    await _repository.saveForFutureSelf(
      PostcardContent(
        imagePath: card.imagePath,
        renderedImagePath: renderedPath,
        message: card.message,
        styleName: card.styleName,
        stickerLabels: card.stickerLabels,
        locationLabel: card.locationLabel,
        weatherLabel: card.weatherLabel,
        temperatureText: card.temperatureText,
        aqiLabel: card.aqiLabel,
        createdAtIso: card.createdAtIso,
        streakDays: card.streakDays,
        primaryColorValue: card.primaryColorValue,
        secondaryColorValue: card.secondaryColorValue,
      ),
    );
    await refreshCollections();
    return 'Saved postcard to your album.';
  }

  Future<String?> shareRenderedPostcard(String renderedPath) async {
    final card = previewCard;
    if (card == null) return null;
    final payload = [
      'Environmental Postcard',
      card.styleName,
      card.message,
      selectedSocialCaption,
      '${card.locationLabel} · ${card.weatherLabel} · ${card.temperatureText}',
      card.aqiLabel,
    ].where((item) => item.trim().isNotEmpty).join('\n');

    await SharePlus.instance.share(
      ShareParams(text: payload, files: [XFile(renderedPath)]),
    );
    return 'Postcard ready to share.';
  }
}
