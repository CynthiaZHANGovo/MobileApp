import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/postcard_app_controller.dart';
import '../models/postcard_content.dart';
import '../models/postcard_style_variant.dart';
import '../models/studio_sticker.dart';
import '../widgets/postcard_preview.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key, required this.controller});

  final PostcardAppController controller;

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  int _panelIndex = 0;

  PostcardAppController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final card = controller.previewCard;
    final variant = controller.selectedVariant;

    if (card == null || variant == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Studio',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF163231),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Generate a postcard first. Then you can switch templates, edit stickers, and export the final image.',
                  style: TextStyle(
                    color: Color(0xFF637875),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      children: [
        _header(variant),
        const SizedBox(height: 18),
        RepaintBoundary(
          key: controller.previewBoundaryKey,
          child: PostcardPreview(
            card: card,
            variant: variant,
            stickers: controller.activeStickers,
            selectedStickerId: controller.selectedStickerId,
            photoScale: controller.photoScale,
            photoOffset: controller.photoOffset,
            onStickerTap: controller.selectSticker,
            onStickerDrag: controller.moveSticker,
            onPhotoScaleStart: controller.beginPhotoGesture,
            onPhotoScaleUpdate: controller.updatePhotoGesture,
            onStickerDrop: controller.addStickerAt,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _StudioChip(icon: Icons.pan_tool_alt_outlined, label: 'Pinch photo'),
            _StudioChip(icon: Icons.open_with_rounded, label: 'Drag sticker'),
            _StudioChip(icon: Icons.download_done_rounded, label: 'Export ready'),
          ],
        ),
        const SizedBox(height: 18),
        _panelSwitcher(),
        const SizedBox(height: 18),
        if (_panelIndex == 0) ...[
          _variantPicker(),
          const SizedBox(height: 18),
          _contextGrid(card),
        ],
        if (_panelIndex == 1) _stickerEditor(),
        if (_panelIndex == 2) _sharePanel(context, card, variant),
      ],
    );
  }

  Widget _header(PostcardStyleVariant variant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(label: 'Studio'),
          SizedBox(height: 10),
          const Text(
            'Studio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF173230),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _templatePill(variant.name, variant.accentColor),
              _templatePill(variant.stampLabel, const Color(0xFF4F726C)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            variant.tagline,
            style: const TextStyle(
              color: Color(0xFF617773),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelSwitcher() {
    final labels = ['Canvas', 'Stickers', 'Share'];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == _panelIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 6),
              child: FilledButton(
                onPressed: () => setState(() {
                  _panelIndex = index;
                }),
                style: FilledButton.styleFrom(
                  backgroundColor: selected
                      ? const Color(0xFF1E5751)
                      : const Color(0xFFF2EAD8),
                  foregroundColor: selected
                      ? Colors.white
                      : const Color(0xFF183231),
                  elevation: 0,
                ),
                child: Text(labels[index]),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _variantPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionEyebrow(label: 'Canvas'),
        const SizedBox(height: 8),
        const Text(
          'Postcard Templates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF163231),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 134,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.variants.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = controller.variants[index];
              final selected = index == controller.selectedVariantIndex;
              return GestureDetector(
                onTap: () => controller.selectVariant(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 188,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [item.frameColor, item.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected ? const Color(0xFF18312F) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Color(0xFF132826),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xCC132826),
                          height: 1.35,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        selected ? 'Selected' : 'Tap to preview',
                        style: const TextStyle(
                          color: Color(0xFF132826),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _stickerEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionEyebrow(label: 'Decor'),
        const SizedBox(height: 8),
        const Text(
          'Sticker Tray',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF163231),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.stickerCatalog.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final sticker = controller.stickerCatalog[index];
              final selected = sticker.id == controller.selectedCatalogStickerId;
              return LongPressDraggable<StudioSticker>(
                data: sticker,
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: 1.08,
                    child: _catalogCard(sticker, false),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.30,
                  child: _catalogCard(sticker, selected),
                ),
                child: GestureDetector(
                  onTap: () {
                    controller.selectCatalogSticker(sticker.id);
                    controller.addStickerTemplate(sticker);
                  },
                  child: _catalogCard(sticker, selected),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: controller.replaceSelectedSticker,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Replace'),
            ),
            OutlinedButton.icon(
              onPressed: controller.deleteSelectedSticker,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete'),
            ),
            FilledButton.tonalIcon(
              onPressed: controller.resetPhotoAdjustments,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Photo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sharePanel(
    BuildContext context,
    PostcardContent card,
    PostcardStyleVariant variant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _socialCaptionCard(context),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: controller.isExporting
              ? null
              : () async {
                  final renderedPath = await _renderPostcardToFile(card, variant);
                  if (!context.mounted) return;
                  if (renderedPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not render postcard image. Please try again.'),
                      ),
                    );
                    return;
                  }
                  final message = await controller.saveRenderedPostcard(renderedPath);
                  if (context.mounted && message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
          child: Text(controller.isExporting ? 'Saving...' : 'Save to Album'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: controller.isExporting
              ? null
              : () async {
                  final renderedPath = await _renderPostcardToFile(card, variant);
                  if (!context.mounted) return;
                  if (renderedPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not render postcard image. Please try again.'),
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Postcard image saved to $renderedPath')),
                  );
                },
          icon: const Icon(Icons.download_outlined),
          label: Text(controller.isExporting ? 'Rendering...' : 'Export PNG'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: controller.isExporting
              ? null
              : () async {
                  final renderedPath = await _renderPostcardToFile(card, variant);
                  if (!context.mounted) return;
                  if (renderedPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not render postcard image. Please try again.'),
                      ),
                    );
                    return;
                  }
                  final message = await controller.shareRenderedPostcard(renderedPath);
                  if (context.mounted && message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
          icon: const Icon(Icons.share_outlined),
          label: Text(controller.isExporting ? 'Rendering...' : 'Share Postcard'),
        ),
      ],
    );
  }

  Widget _socialCaptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Social Caption',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF163231),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A short caption that works well with the postcard when you post it.',
            style: TextStyle(
              color: Color(0xFF617773),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3E6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              controller.selectedSocialCaption,
              style: const TextStyle(
                color: Color(0xFF183231),
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.nextCaption,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Change'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: controller.selectedSocialCaption),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Caption copied.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.content_copy_outlined),
                  label: const Text('Copy'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _renderPostcardToFile(
    PostcardContent card,
    PostcardStyleVariant variant,
  ) async {
    final key = GlobalKey();
    bool scheduled = false;
    controller.setExporting(true);
    try {
      final path = await showDialog<String?>(
        context: context,
        barrierDismissible: false,
        barrierColor: const Color(0x05000000),
        builder: (dialogContext) {
          if (!scheduled) {
            scheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await Future<void>.delayed(const Duration(milliseconds: 120));
              final boundary =
                  key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
              if (boundary == null) {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                return;
              }

              try {
                final image = await boundary.toImage(pixelRatio: 3);
                final byteData =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                if (byteData == null) {
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  return;
                }
                final directory = await getApplicationDocumentsDirectory();
                final postcardsDir = Directory('${directory.path}/postcards');
                if (!postcardsDir.existsSync()) {
                  postcardsDir.createSync(recursive: true);
                }
                final filePath =
                    '${postcardsDir.path}/postcard_${DateTime.now().millisecondsSinceEpoch}.png';
                final file = File(filePath);
                await file.writeAsBytes(byteData.buffer.asUint8List());
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(filePath);
                }
              } catch (_) {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }
            });
          }

          return Center(
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 360,
                child: RepaintBoundary(
                  key: key,
                  child: PostcardPreview(
                    card: card,
                    variant: variant,
                    stickers: controller.activeStickers,
                    selectedStickerId: null,
                    photoScale: controller.photoScale,
                    photoOffset: controller.photoOffset,
                  ),
                ),
              ),
            ),
          );
        },
      );
      return path;
    } finally {
      controller.setExporting(false);
    }
  }

  IconData _catalogIcon(StickerType type) {
    return switch (type) {
      StickerType.weatherScene => Icons.auto_awesome,
      StickerType.sunBadge => Icons.wb_sunny_rounded,
      StickerType.cloudBadge => Icons.cloud_rounded,
      StickerType.rainBadge => Icons.grain_rounded,
      StickerType.windBadge => Icons.air_rounded,
      StickerType.leafBadge => Icons.spa_rounded,
      StickerType.starBadge => Icons.star_rounded,
      StickerType.moonBadge => Icons.nightlight_round,
      StickerType.flowerBadge => Icons.local_florist_rounded,
      StickerType.dropBadge => Icons.water_drop_rounded,
      StickerType.thermoBadge => Icons.thermostat_rounded,
      StickerType.aqiBadge => Icons.blur_on_rounded,
      StickerType.timeBadge => Icons.schedule_rounded,
      StickerType.cityBadge => Icons.place_rounded,
      StickerType.thunderBadge => Icons.flash_on_rounded,
      StickerType.snowBadge => Icons.ac_unit_rounded,
      StickerType.sparkleBadge => Icons.auto_awesome_rounded,
    };
  }

  Widget _catalogCard(StudioSticker sticker, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? const Color(0xFF1B5952) : const Color(0x12000000),
          width: selected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F0E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_catalogIcon(sticker.type), color: const Color(0xFF1B5952)),
          ),
          const Spacer(),
          Text(
            sticker.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF183231),
              fontWeight: FontWeight.w700,
              height: 1.25,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contextGrid(PostcardContent card) {
    final items = [
      ('Location', card.locationLabel),
      ('Weather', card.weatherLabel),
      ('Air', card.aqiLabel),
      ('Streak', 'Day ${card.streakDays}'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.$1.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF6E847F),
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                item.$2,
                style: const TextStyle(
                  color: Color(0xFF173230),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _templatePill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF59706B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _StudioChip extends StatelessWidget {
  const _StudioChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1B5952)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF59706B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
