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

enum _StudioTool { template, decor, share }

enum _SharePane { caption, send }

class StudioPage extends StatefulWidget {
  const StudioPage({
    super.key,
    required this.controller,
    required this.onBackToCapture,
  });

  final PostcardAppController controller;
  final VoidCallback onBackToCapture;

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  _StudioTool? _activeTool;
  _SharePane _sharePane = _SharePane.caption;

  PostcardAppController get controller => widget.controller;

  void _shiftTool(int delta) {
    final order = _StudioTool.values;
    final current = _activeTool ?? _StudioTool.template;
    final nextIndex = (order.indexOf(current) + delta).clamp(0, order.length - 1);
    setState(() {
      _activeTool = order[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = controller.previewCard;
    final variant = controller.selectedVariant;

    if (card == null || variant == null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_mosaic_rounded, size: 42, color: Color(0xFF1E5751)),
              SizedBox(height: 14),
              Text(
                'Studio',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF163231),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final showPanel = _activeTool != null;
        final panelFactor = switch (_activeTool) {
          _StudioTool.share => 0.40,
          _StudioTool.template || _StudioTool.decor || null => 0.25,
        };
        final panelHeight = (constraints.maxHeight * panelFactor).clamp(160.0, 300.0);
        final dockHeight = 64.0;
        final bottomInset = showPanel ? panelHeight + dockHeight + 18 : dockHeight + 18;

        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(variant, condensed: showPanel),
                    SizedBox(height: showPanel ? 10 : 14),
                    Expanded(
                      child: Center(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          scale: showPanel ? 0.87 : 1.0,
                          child: RepaintBoundary(
                            key: controller.previewBoundaryKey,
                            child: PostcardPreview(
                              card: card,
                              variant: variant,
                              stickers: controller.activeStickers,
                              selectedStickerId: controller.selectedStickerId,
                              armedDeleteStickerId: controller.armedDeleteStickerId,
                              photoSelected: controller.photoSelected,
                              photoScale: controller.photoScale,
                              photoOffset: controller.photoOffset,
                              onPhotoTap: controller.selectPhoto,
                              onStickerTap: controller.selectSticker,
                              onStickerLongPress: controller.armStickerDelete,
                              onStickerDrag: controller.moveSticker,
                              onStickerScaleStart: controller.beginStickerGesture,
                              onStickerScaleUpdate: controller.updateStickerGesture,
                              onStickerDelete: controller.deleteStickerById,
                              onPhotoScaleStart: controller.beginPhotoGesture,
                              onPhotoScaleUpdate: controller.updatePhotoGesture,
                              onStickerDrop: controller.addStickerAt,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: 18,
              right: 18,
              bottom: showPanel ? dockHeight + 18 : -panelHeight,
              height: panelHeight,
              child: IgnorePointer(
                ignoring: !showPanel,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: showPanel ? 1 : 0,
                  child: _panelShell(
                    accentMode: _activeTool == _StudioTool.share,
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity.abs() < 180) return;
                        _shiftTool(velocity < 0 ? 1 : -1);
                      },
                      onVerticalDragUpdate: (details) {
                        if (details.primaryDelta != null && details.primaryDelta! > 8) {
                          setState(() {
                            _activeTool = null;
                          });
                          controller.clearStickerDeleteArm();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: switch (_activeTool) {
                          _StudioTool.template => _templatePanel(card),
                          _StudioTool.decor => _decorPanel(),
                          _StudioTool.share => _sharePanel(context, card, variant),
                          null => const SizedBox.shrink(),
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: _toolDock(),
            ),
          ],
        );
      },
    );
  }

  Widget _topBar(PostcardStyleVariant variant, {required bool condensed}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_activeTool != null) {
          setState(() {
            _activeTool = null;
          });
          controller.clearSelections();
        }
      },
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBackToCapture,
            child: Container(
              width: condensed ? 40 : 44,
              height: condensed ? 40 : 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF163231),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Studio',
              style: TextStyle(
                fontSize: condensed ? 24 : 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF163231),
              ),
            ),
          ),
          _miniOrb(variant.accentColor),
          const SizedBox(width: 8),
          _miniOrb(const Color(0xFFCC8C5A)),
        ],
      ),
    );
  }

  Widget _toolDock() {
    final items = [
      (_StudioTool.template, Icons.style_rounded),
      (_StudioTool.decor, Icons.auto_awesome_rounded),
      (_StudioTool.share, Icons.send_rounded),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: items.map((item) {
              final selected = _activeTool == item.$1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: item == items.last ? 0 : 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTool = selected ? null : item.$1;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: 50,
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF1E5751) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          item.$2,
                          size: 18,
                          color: selected ? Colors.white : const Color(0xFF516864),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _templatePanel(PostcardContent card) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.style_rounded, label: 'Template'),
          const SizedBox(height: 10),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.variants.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = controller.variants[index];
                final selected = index == controller.selectedVariantIndex;
                return GestureDetector(
                  onTap: () => controller.selectVariant(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 136,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [item.frameColor, item.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? const Color(0xFF18312F) : Colors.transparent,
                        width: 1.7,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _shortTemplateName(item.name),
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                              color: Color(0xFF132826),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            size: 18,
                            color: const Color(0xFF132826),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _contextStamp(Icons.place_rounded, card.locationLabel),
              _contextStamp(Icons.wb_sunny_rounded, card.weatherLabel),
              _contextStamp(Icons.thermostat_rounded, card.temperatureText),
              _contextStamp(Icons.air_rounded, card.aqiLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decorPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(icon: Icons.auto_awesome_rounded, label: 'Decor'),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.88,
            ),
            itemCount: controller.stickerCatalog.length,
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
                  opacity: 0.28,
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
      ],
    );
  }

  Widget _sharePanel(
    BuildContext context,
    PostcardContent card,
    PostcardStyleVariant variant,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.send_rounded, label: 'Share'),
          const SizedBox(height: 10),
          _shareModeDock(),
          const SizedBox(height: 12),
          if (_sharePane == _SharePane.caption) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F3E6),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                controller.selectedSocialCaption,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF183231),
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
          ] else ...[
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isExporting
                        ? null
                        : () async {
                            final renderedPath = await _renderPostcardToFile(card, variant);
                            if (!context.mounted) return;
                            if (renderedPath == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not render postcard image. Please try again.',
                                  ),
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isExporting
                        ? null
                        : () async {
                            final renderedPath = await _renderPostcardToFile(card, variant);
                            if (!context.mounted) return;
                            if (renderedPath == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not render postcard image. Please try again.',
                                  ),
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
                    label: Text(controller.isExporting ? 'Rendering...' : 'Send'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _shareModeDock() {
    final items = [
      (_SharePane.caption, Icons.mode_comment_outlined),
      (_SharePane.send, Icons.outbox_outlined),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
          ),
          child: Row(
            children: items.map((item) {
              final selected = _sharePane == item.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _sharePane = item.$1;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1E5751) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        item.$2,
                        size: 18,
                        color: selected ? Colors.white : const Color(0xFF536966),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<String?> _renderPostcardToFile(
    PostcardContent card,
    PostcardStyleVariant variant,
  ) async {
    final key = GlobalKey();
    var scheduled = false;
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
                final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
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
                    armedDeleteStickerId: null,
                    photoSelected: false,
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

  Widget _panelShell({required Widget child, bool accentMode = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: accentMode
                ? const Color(0xFFF6EBDD).withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: accentMode
                  ? const Color(0x66C98B5C)
                  : Colors.white.withValues(alpha: 0.42),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _catalogCard(StudioSticker sticker, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF3EE) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFF1B5952) : const Color(0x11000000),
          width: selected ? 2 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F0E0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Icon(
            _catalogIcon(sticker.type),
            size: 20,
            color: const Color(0xFF1B5952),
          ),
        ),
      ),
    );
  }

  Widget _contextStamp(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF1B5952)),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 112),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF183231),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniOrb(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  String _shortTemplateName(String name) {
    final parts = name.split(' ');
    if (parts.length <= 3) {
      return name;
    }
    return parts.take(3).join(' ');
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
      StickerType.shadeBadge => Icons.sentiment_very_satisfied_rounded,
      StickerType.drinkBadge => Icons.local_cafe_rounded,
      StickerType.umbrellaBadge => Icons.beach_access_rounded,
      StickerType.bootBadge => Icons.hiking_rounded,
      StickerType.thermoBadge => Icons.thermostat_rounded,
      StickerType.aqiBadge => Icons.blur_on_rounded,
      StickerType.timeBadge => Icons.schedule_rounded,
      StickerType.cityBadge => Icons.place_rounded,
      StickerType.thunderBadge => Icons.flash_on_rounded,
      StickerType.snowBadge => Icons.ac_unit_rounded,
      StickerType.sparkleBadge => Icons.auto_awesome_rounded,
    };
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF5E746E)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5E746E),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
