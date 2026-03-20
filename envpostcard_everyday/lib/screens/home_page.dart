import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/postcard_content.dart';
import '../models/environment_snapshot.dart';
import '../services/environment_service.dart';
import '../services/photo_palette_service.dart';
import '../services/postcard_generator_service.dart';
import '../services/postcard_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();
  final _environmentService = EnvironmentService();
  final _paletteService = PhotoPaletteService();
  final _generatorService = PostcardGeneratorService();
  final _repository = PostcardRepository();

  XFile? _selectedImage;
  EnvironmentSnapshot? _environment;
  PostcardContent? _currentCard;
  List<PostcardContent> _futureCards = const [];
  List<PostcardContent> _boardCards = const [];
  bool _isGenerating = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final futureCards = await _repository.loadFutureSelfCards();
    final boardCards = await _repository.loadPublicBoardCards();
    if (!mounted) return;
    setState(() {
      _futureCards = futureCards;
      _boardCards = boardCards;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1800,
    );
    if (file == null || !mounted) return;
    setState(() {
      _selectedImage = file;
      _currentCard = null;
      _errorText = null;
    });
  }

  Future<void> _generatePostcard() async {
    final image = _selectedImage;
    if (image == null) {
      setState(() {
        _errorText = '请先拍一张照片，作为今天的环境输入。';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorText = null;
    });

    try {
      final environment = await _environmentService.collect();
      final palette = await _paletteService.analyze(image.path);
      final streak = await _repository.updateAndGetStreak(DateTime.now());
      final message = await _generatorService.generateMessage(
        environment: environment,
        palette: palette,
        streakDays: streak,
      );

      final card = PostcardContent(
        imagePath: image.path,
        message: message,
        locationLabel: environment.locationLabel,
        weatherLabel: environment.weatherLabel,
        temperatureText: '${environment.temperatureC.toStringAsFixed(0)}°C',
        aqiLabel: environment.aqiLabel,
        createdAtIso: DateTime.now().toIso8601String(),
        streakDays: streak,
        primaryColorValue: palette.primary.toARGB32(),
        secondaryColorValue: palette.secondary.toARGB32(),
      );

      if (!mounted) return;
      setState(() {
        _environment = environment;
        _currentCard = card;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = '$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveForFutureSelf() async {
    final card = _currentCard;
    if (card == null) return;
    await _repository.saveForFutureSelf(card);
    await _loadCollections();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已存入“寄给未来的自己”')));
  }

  Future<void> _publishToBoard() async {
    final card = _currentCard;
    if (card == null) return;
    await _repository.publishToBoard(card);
    await _loadCollections();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已发布到公共环境邮局')));
  }

  Future<void> _shareCard() async {
    final card = _currentCard;
    if (card == null) return;
    final payload = [
      'Environmental Postcard',
      card.message,
      '${card.locationLabel} · ${card.weatherLabel} · ${card.temperatureText}',
      'AQI 状态：${card.aqiLabel}',
    ].join('\n');

    await SharePlus.instance.share(
      ShareParams(text: payload, files: [XFile(card.imagePath)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E2A2A), Color(0xFF1F4D47), Color(0xFFF4E9C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadCollections,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
              children: [
                Text(
                  'Environmental Postcard',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '把你看到的世界、真实环境数据与 AI 感知，折叠成一张可以流通的数字明信片。',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                _buildCapturePanel(),
                if (_errorText != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _errorText!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFFD4C7),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isGenerating ? null : _generatePostcard,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? '生成中...' : '生成今日环境明信片'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE7B65B),
                    foregroundColor: const Color(0xFF19312F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                if (_currentCard != null) _buildCurrentPostcard(_currentCard!),
                const SizedBox(height: 22),
                _buildCollectionSection(
                  title: '寄给未来的自己',
                  cards: _futureCards,
                  emptyText: '生成后的明信片可以被存档，等待未来再次被打开。',
                ),
                const SizedBox(height: 18),
                _buildCollectionSection(
                  title: '公共环境邮局',
                  cards: _boardCards,
                  emptyText: '这里展示你发布出去的环境切片，让个人感知进入公共流通。',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapturePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _selectedImage == null
                  ? Container(
                      color: Colors.black.withValues(alpha: 0.18),
                      child: const Center(
                        child: Text(
                          '今天，你主动注意到了什么？',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ),
                    )
                  : Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('拍照'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('相册'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPostcard(PostcardContent card) {
    final primary = Color(card.primaryColorValue);
    final secondary = Color(card.secondaryColorValue);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.file(
              File(card.imagePath),
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            card.message,
            style: const TextStyle(
              fontSize: 19,
              height: 1.65,
              color: Color(0xFF10201F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(card.locationLabel),
              _metaChip(card.weatherLabel),
              _metaChip(card.temperatureText),
              _metaChip(card.aqiLabel),
              _metaChip('连续 ${card.streakDays} 天'),
            ],
          ),
          if (_environment != null) ...[
            const SizedBox(height: 12),
            Text(
              '生成时间：${DateFormat('yyyy-MM-dd HH:mm').format(_environment!.localTime)}',
              style: const TextStyle(color: Color(0xAA10201F)),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _saveForFutureSelf,
                  child: const Text('发送给未来的自己'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _publishToBoard,
                  child: const Text('发布到环境邮局'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _shareCard,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF163231),
                side: const BorderSide(color: Color(0x55163231)),
              ),
              child: const Text('分享给他人'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionSection({
    required String title,
    required List<PostcardContent> cards,
    required String emptyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF173634),
            ),
          ),
          const SizedBox(height: 10),
          if (cards.isEmpty)
            Text(
              emptyText,
              style: const TextStyle(height: 1.5, color: Color(0xFF4F6764)),
            )
          else
            ...cards.take(3).map(_buildMiniCard),
        ],
      ),
    );
  }

  Widget _buildMiniCard(PostcardContent card) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(card.imagePath),
              width: 76,
              height: 76,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: Color(0xFF163231),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${card.locationLabel} · ${card.weatherLabel}',
                  style: const TextStyle(color: Color(0xFF627B77)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF193331),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
