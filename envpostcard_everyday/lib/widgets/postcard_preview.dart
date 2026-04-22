import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/postcard_content.dart';
import '../models/postcard_style_variant.dart';
import '../models/studio_sticker.dart';

class PostcardPreview extends StatelessWidget {
  const PostcardPreview({
    super.key,
    required this.card,
    required this.variant,
    this.stickers = const [],
    this.selectedStickerId,
    this.armedDeleteStickerId,
    this.photoSelected = false,
    this.photoScale = 1,
    this.photoOffset = Offset.zero,
    this.onPhotoTap,
    this.onStickerTap,
    this.onStickerLongPress,
    this.onStickerDrag,
    this.onStickerScaleStart,
    this.onStickerScaleUpdate,
    this.onStickerDelete,
    this.onPhotoDrag,
    this.onPhotoScaleStart,
    this.onPhotoScaleUpdate,
    this.onStickerDrop,
  });

  final PostcardContent card;
  final PostcardStyleVariant variant;
  final List<StudioSticker> stickers;
  final String? selectedStickerId;
  final String? armedDeleteStickerId;
  final bool photoSelected;
  final double photoScale;
  final Offset photoOffset;
  final VoidCallback? onPhotoTap;
  final void Function(String stickerId)? onStickerTap;
  final void Function(String stickerId)? onStickerLongPress;
  final void Function(String stickerId, Offset delta, Size bounds)? onStickerDrag;
  final void Function(String stickerId)? onStickerScaleStart;
  final void Function(String stickerId, double gestureScale, Offset focalDelta, Size bounds)?
      onStickerScaleUpdate;
  final void Function(String stickerId)? onStickerDelete;
  final void Function(Offset delta, Size bounds)? onPhotoDrag;
  final VoidCallback? onPhotoScaleStart;
  final void Function(double gestureScale, Offset focalDelta, Size bounds)? onPhotoScaleUpdate;
  final void Function(StudioSticker sticker, Offset position, Size bounds)? onStickerDrop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scale = (width / 340).clamp(0.74, 1.03);

        return AspectRatio(
          aspectRatio: 0.78,
          child: Container(
            padding: EdgeInsets.all(variant.layout == 'polaroid' ? 12 * scale : 14 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30 * scale),
              gradient: LinearGradient(
                colors: [variant.frameColor, variant.accentColor.withValues(alpha: 0.92)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 26,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24 * scale),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12 * scale,
                  right: 12 * scale,
                  top: 10 * scale,
                  child: _airmailEdge(scale),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20 * scale),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22 * scale),
                    child: _interactiveCanvas(scale),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _interactiveCanvas(double scale) {
    return LayoutBuilder(
      builder: (context, overlay) {
        final bounds = Size(overlay.maxWidth, overlay.maxHeight);
        final selectedSticker = selectedStickerId;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPhotoTap,
                onScaleStart: (_) {
                  if (selectedSticker != null && onStickerScaleStart != null) {
                    onStickerScaleStart!.call(selectedSticker);
                    return;
                  }
                  if (!photoSelected) return;
                  onPhotoScaleStart?.call();
                },
                onScaleUpdate: (details) {
                  if (selectedSticker != null &&
                      onStickerScaleUpdate != null &&
                      details.pointerCount > 1) {
                    onStickerScaleUpdate!.call(
                      selectedSticker,
                      details.scale,
                      details.focalPointDelta,
                      bounds,
                    );
                    return;
                  }
                  if (!photoSelected) return;
                  onPhotoScaleUpdate?.call(
                    details.scale,
                    details.focalPointDelta,
                    bounds,
                  );
                },
                onPanUpdate: selectedSticker == null && onPhotoDrag != null
                    ? (details) => onPhotoDrag!.call(details.delta, bounds)
                    : null,
                child: _layoutBody(scale),
              ),
            ),
            if (onStickerDrop != null)
              Positioned.fill(
                child: DragTarget<StudioSticker>(
                  onAcceptWithDetails: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final local = box.globalToLocal(details.offset);
                    onStickerDrop!.call(details.data, local, bounds);
                  },
                  builder: (context, candidateData, rejectedData) => const SizedBox.expand(),
                ),
              ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: onStickerTap == null && onStickerDrag == null,
                child: Stack(
                  children: stickers.map((sticker) {
                    return Positioned(
                      left: overlay.maxWidth * sticker.dx,
                      top: overlay.maxHeight * sticker.dy,
                      child: GestureDetector(
                        onTap: () => onStickerTap?.call(sticker.id),
                        onLongPress: () => onStickerLongPress?.call(sticker.id),
                        onPanUpdate: (details) {
                          onStickerDrag?.call(sticker.id, details.delta, bounds);
                        },
                        child: _stickerWidget(
                          sticker,
                          overlay.maxWidth,
                          selectedStickerId == sticker.id,
                          deletable: onStickerDelete != null,
                          showDelete: armedDeleteStickerId == sticker.id,
                          onDelete: () => onStickerDelete?.call(sticker.id),
                        ),
                      ),
                    );
                    }).toList(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _layoutBody(double scale) {
    return switch (variant.layout) {
      'grid' => _buildGridLayout(scale),
      'border' => _buildBorderLayout(scale),
      'split' => _buildSplitLayout(scale),
      'polaroid' => _buildPolaroidLayout(scale),
      _ => _buildFloatingLayout(scale),
    };
  }

  Widget _buildFloatingLayout(double scale) {
    return Stack(
      children: [
        _buildFilteredPhoto(24 * scale),
        Positioned(top: 18 * scale, right: 18 * scale, child: _stamp(scale, rotation: 0.08)),
        Positioned(
          left: 14 * scale,
          right: 14 * scale,
          bottom: 14 * scale,
          child: _messagePanel(scale, compact: false),
        ),
      ],
    );
  }

  Widget _buildGridLayout(double scale) {
    final compact = scale < 0.86;
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: Stack(
            children: [
              _buildFilteredPhoto(22 * scale),
              Positioned(left: 14 * scale, top: 14 * scale, child: _stamp(scale, rotation: -0.06)),
              Positioned(left: 14 * scale, bottom: 14 * scale, child: _miniBadge(card.temperatureText, scale)),
            ],
          ),
        ),
        SizedBox(height: (compact ? 8 : 12) * scale),
        Expanded(
          flex: 7,
          child: Row(
            children: [
              Expanded(child: _messagePanel(scale, compact: true)),
              SizedBox(width: (compact ? 8 : 10) * scale),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _infoTile(
                        'AIR',
                        card.aqiLabel,
                        scale,
                        compact: compact,
                      ),
                    ),
                    SizedBox(height: (compact ? 8 : 10) * scale),
                    Expanded(
                      child: _infoTile(
                        'PLACE',
                        card.locationLabel,
                        scale,
                        compact: compact,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBorderLayout(double scale) {
    final compact = scale < 0.86;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      padding: EdgeInsets.all(12 * scale),
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: Stack(
              children: [
                _buildFilteredPhoto(18 * scale),
                Positioned(left: 12 * scale, top: 12 * scale, child: _miniBadge(variant.stampLabel, scale)),
              ],
            ),
          ),
          SizedBox(height: (compact ? 9 : 12) * scale),
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all((compact ? 13 : 16) * scale),
              decoration: BoxDecoration(
                color: variant.textPanelColor,
                borderRadius: BorderRadius.circular(18 * scale),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (compact) ...[
                    Text(
                      variant.name,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF18312F),
                        fontSize: 11.6 * scale,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      'Future Self',
                      style: TextStyle(
                        color: variant.accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.6 * scale,
                      ),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            variant.name,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF18312F),
                              fontSize: 12.5 * scale,
                              height: 1.05,
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Future Self',
                          style: TextStyle(
                            color: variant.accentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5 * scale,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: (compact ? 7 : 10) * scale),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        card.message,
                        maxLines: compact ? 6 : 7,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: (compact ? 12.8 : 14.5) * scale,
                          height: compact ? 1.46 : 1.55,
                          color: const Color(0xFF18312F),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    '${card.locationLabel}  •  ${card.temperatureText}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF5C716D),
                      fontSize: (compact ? 10.6 : 11.5) * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitLayout(double scale) {
    if (scale < 0.92) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(22 * scale),
        ),
        padding: EdgeInsets.all(10 * scale),
        child: Column(
          children: [
            Expanded(flex: 11, child: _buildFilteredPhoto(16 * scale)),
            SizedBox(height: 8 * scale),
            Expanded(
              flex: 9,
              child: Container(
                padding: EdgeInsets.all(11 * scale),
                decoration: BoxDecoration(
                  color: variant.textPanelColor,
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8 * scale,
                      runSpacing: 6 * scale,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 120 * scale),
                          child: Text(
                            variant.name,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: variant.accentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5 * scale,
                              height: 1.05,
                            ),
                          ),
                        ),
                        _miniBadge(variant.stampLabel, scale),
                      ],
                    ),
                    SizedBox(height: 6 * scale),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          card.message,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF173230),
                            height: 1.42,
                            fontSize: 11.8 * scale,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      card.locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: const Color(0xFF536966), fontSize: 10.8 * scale),
                    ),
                    SizedBox(height: 3 * scale),
                    Text(
                      '${card.weatherLabel} • ${card.temperatureText}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: const Color(0xFF536966), fontSize: 10.8 * scale),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      padding: EdgeInsets.all(12 * scale),
      child: Row(
        children: [
          Expanded(flex: 11, child: _buildFilteredPhoto(18 * scale)),
          SizedBox(width: 12 * scale),
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        variant.name,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: variant.accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.8 * scale,
                          height: 1.05,
                        ),
                      ),
                    ),
                    _miniBadge(variant.stampLabel, scale),
                  ],
                ),
                SizedBox(height: 10 * scale),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(13 * scale),
                    decoration: BoxDecoration(
                      color: variant.textPanelColor,
                      borderRadius: BorderRadius.circular(18 * scale),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        card.message,
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF173230),
                          height: 1.5,
                          fontSize: 12.7 * scale,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10 * scale),
                Container(height: 1, color: const Color(0xFFD9CFBC)),
                SizedBox(height: 8 * scale),
                Text(
                  'To: Future Me',
                  style: TextStyle(
                    color: variant.accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12 * scale,
                  ),
                ),
                SizedBox(height: 5 * scale),
                Text(
                  card.locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: const Color(0xFF536966), fontSize: 11.5 * scale),
                ),
                SizedBox(height: 3 * scale),
                Text(
                  '${card.weatherLabel} • ${card.temperatureText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: const Color(0xFF536966), fontSize: 11.5 * scale),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidLayout(double scale) {
    final compact = scale < 0.86;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EB),
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      padding: EdgeInsets.fromLTRB(
        (compact ? 12 : 14) * scale,
        (compact ? 12 : 14) * scale,
        (compact ? 12 : 14) * scale,
        (compact ? 15 : 18) * scale,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: Stack(
              children: [
                _buildFilteredPhoto(16 * scale),
                Positioned(left: 12 * scale, top: 12 * scale, child: _stamp(scale, rotation: -0.05)),
              ],
            ),
          ),
          SizedBox(height: (compact ? 11 : 16) * scale),
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all((compact ? 12 : 16) * scale),
              decoration: BoxDecoration(
                color: variant.textPanelColor,
                borderRadius: BorderRadius.circular(16 * scale),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        card.message,
                        maxLines: compact ? 4 : 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF173230),
                          height: compact ? 1.42 : 1.5,
                          fontSize: (compact ? 12.0 : 13.2) * scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      ...card.stickerLabels.take(compact ? 1 : 2).map((item) {
                        return Padding(
                          padding: EdgeInsets.only(right: 6 * scale),
                          child: _miniBadge(item, compact ? scale * 0.94 : scale),
                        );
                      }),
                      const Spacer(),
                      Expanded(
                        child: Text(
                          'Environmental Postcard',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: variant.accentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: (compact ? 9.4 : 10.0) * scale,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredPhoto(double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final shiftX = photoOffset.dx * constraints.maxWidth;
              final shiftY = photoOffset.dy * constraints.maxHeight;
              return ClipRect(
                child: Transform.translate(
                  offset: Offset(shiftX, shiftY),
                  child: Transform.scale(
                    scale: photoScale,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        variant.tintColor.withValues(alpha: variant.tintOpacity),
                        BlendMode.softLight,
                      ),
                      child: Image.file(File(card.imagePath), fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.06),
                  variant.frameColor.withValues(alpha: 0.18),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          if (photoSelected)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: const Color(0xFFCC8C5A),
                      width: 2.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _messagePanel(double scale, {required bool compact}) {
    final dense = scale < 0.86;
    return Container(
      padding: EdgeInsets.all((compact ? (dense ? 11 : 14) : (dense ? 13 : 16)) * scale),
      decoration: BoxDecoration(
        color: variant.textPanelColor,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dense) ...[
            Text(
              variant.name,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF162D2A),
                fontSize: 11.1 * scale,
                height: 1.04,
              ),
            ),
            SizedBox(height: 2 * scale),
            Text(
              'POSTCARD',
              style: TextStyle(
                fontSize: 9.0 * scale,
                letterSpacing: 0.8,
                color: variant.accentColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: Text(
                    variant.name,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF162D2A),
                      fontSize: 12.4 * scale,
                      height: 1.05,
                    ),
                  ),
                ),
                Text(
                  'POSTCARD',
                  style: TextStyle(
                    fontSize: 10 * scale,
                    letterSpacing: 1.1,
                    color: variant.accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          SizedBox(height: (dense ? 5 : 8) * scale),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                card.message,
                maxLines: dense ? (compact ? 5 : 6) : (compact ? 6 : 7),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: (compact ? (dense ? 11.2 : 12.0) : (dense ? 12.7 : 14.1)) * scale,
                  height: dense ? 1.42 : 1.48,
                  color: const Color(0xFF142725),
                  fontWeight: compact ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, double scale, {bool compact = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((compact ? 11 : 14) * scale),
      decoration: BoxDecoration(
        color: variant.textPanelColor,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: (compact ? 9.2 : 10) * scale,
              letterSpacing: 1.1,
              color: variant.accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6 * scale),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                value,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF173230),
                  fontWeight: FontWeight.w600,
                  height: compact ? 1.25 : 1.35,
                  fontSize: (compact ? 11.0 : 12.5) * scale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stamp(double scale, {required double rotation}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
        decoration: BoxDecoration(
          color: variant.accentColor.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          variant.stampLabel,
          style: TextStyle(
            fontSize: 10 * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: const Color(0xFF102523),
          ),
        ),
      ),
    );
  }

  Widget _miniBadge(String label, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 7 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF173432),
          fontSize: 10.5 * scale,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _airmailEdge(double scale) {
    return SizedBox(
      height: 6 * scale,
      child: Row(
        children: List.generate(12, (index) {
          final color = index.isEven ? const Color(0xFFD85D55) : const Color(0xFF4E8EB8);
          return Expanded(child: Container(color: color));
        }),
      ),
    );
  }

  Widget _stickerWidget(
    StudioSticker sticker,
    double width,
    bool selected,
    {required bool deletable, required bool showDelete, required VoidCallback onDelete}
  ) {
    final compact = width < 320;
    final outline = selected ? const Color(0xFF163231) : Colors.transparent;
    final body = switch (sticker.type) {
      StickerType.weatherScene => _weatherSceneSticker(sticker.label, compact: compact),
      StickerType.thermoBadge ||
      StickerType.aqiBadge ||
      StickerType.timeBadge ||
      StickerType.cityBadge => _microLabelSticker(sticker, compact: compact),
      _ => _decoIconSticker(sticker, compact: compact),
    };

    return Transform.scale(
      scale: sticker.scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: outline, width: selected ? 1.5 : 0),
            ),
            child: body,
          ),
          if (deletable && showDelete)
            Positioned(
              right: -8,
              top: -8,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF163231),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _decoIconSticker(StudioSticker sticker, {required bool compact}) {
    final size = compact ? 34.0 : 42.0;
    final rotation = ((sticker.id.hashCode % 8) - 4) * 0.03;
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _stickerTone(sticker.type),
          borderRadius: BorderRadius.circular(size * 0.38),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: _smallIcon(sticker.type, compact)),
      ),
    );
  }

  Widget _microLabelSticker(StudioSticker sticker, {required bool compact}) {
    return Transform.rotate(
      angle: -0.04,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _smallIcon(sticker.type, compact),
            SizedBox(width: compact ? 4 : 6),
            Text(
              sticker.label,
              style: TextStyle(
                color: const Color(0xFF173432),
                fontSize: compact ? 9.5 : 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _stickerTone(StickerType type) {
    return switch (type) {
      StickerType.sunBadge => const Color(0xFFFFE4A1),
      StickerType.cloudBadge => const Color(0xFFE8EDF2),
      StickerType.rainBadge => const Color(0xFFDCEEFF),
      StickerType.thunderBadge => const Color(0xFFF9D58E),
      StickerType.snowBadge => const Color(0xFFF4FBFF),
      StickerType.windBadge => const Color(0xFFE6F0EB),
      StickerType.leafBadge => const Color(0xFFDDEFD8),
      StickerType.starBadge => const Color(0xFFF7E7B8),
      StickerType.moonBadge => const Color(0xFFE8E2F3),
      StickerType.flowerBadge => const Color(0xFFF7DFD7),
      StickerType.dropBadge => const Color(0xFFD6F1F7),
      StickerType.sparkleBadge => const Color(0xFFF9E6C5),
      StickerType.shadeBadge => const Color(0xFFE9E9E9),
      StickerType.drinkBadge => const Color(0xFFFFE1C8),
      StickerType.umbrellaBadge => const Color(0xFFDCE9FF),
      StickerType.bootBadge => const Color(0xFFE7DCCB),
      _ => Colors.white,
    };
  }

  Widget _smallIcon(StickerType type, bool compact) {
    final size = compact ? 15.0 : 18.0;
    final icon = switch (type) {
      StickerType.sunBadge => Icons.wb_sunny_rounded,
      StickerType.cloudBadge => Icons.cloud_rounded,
      StickerType.rainBadge => Icons.umbrella_rounded,
      StickerType.thunderBadge => Icons.flash_on_rounded,
      StickerType.snowBadge => Icons.ac_unit_rounded,
      StickerType.windBadge => Icons.air_rounded,
      StickerType.leafBadge => Icons.spa_rounded,
      StickerType.starBadge => Icons.star_rounded,
      StickerType.moonBadge => Icons.dark_mode_rounded,
      StickerType.flowerBadge => Icons.local_florist_rounded,
      StickerType.dropBadge => Icons.water_drop_rounded,
      StickerType.sparkleBadge => Icons.auto_awesome_rounded,
      StickerType.shadeBadge => Icons.sentiment_very_satisfied_rounded,
      StickerType.drinkBadge => Icons.local_cafe_rounded,
      StickerType.umbrellaBadge => Icons.beach_access_rounded,
      StickerType.bootBadge => Icons.hiking_rounded,
      StickerType.thermoBadge => Icons.thermostat_rounded,
      StickerType.aqiBadge => Icons.blur_on_rounded,
      StickerType.timeBadge => Icons.schedule_rounded,
      StickerType.cityBadge => Icons.place_rounded,
      _ => Icons.auto_awesome_rounded,
    };
    return Icon(icon, size: size, color: const Color(0xFF24524D));
  }

  Widget _weatherSceneSticker(String weatherLabel, {required bool compact}) {
    final size = compact ? 66.0 : 84.0;
    final background = Colors.white.withValues(alpha: compact ? 0.78 : 0.84);
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(compact ? 18 : 22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _WeatherPainter(
            weatherLabel: weatherLabel,
            accent: variant.accentColor,
            ink: const Color(0xFF173432),
          ),
        ),
      ),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  const _WeatherPainter({
    required this.weatherLabel,
    required this.accent,
    required this.ink,
  });

  final String weatherLabel;
  final Color accent;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final sunPaint = Paint()..color = accent.withValues(alpha: 0.9);
    final softPaint = Paint()..color = accent.withValues(alpha: 0.22);
    final inkPaint = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.035;

    canvas.drawCircle(center, size.width * 0.19, softPaint);

    if (weatherLabel == 'Clear sky') {
      canvas.drawCircle(center, size.width * 0.14, sunPaint);
      for (var i = 0; i < 8; i++) {
        final angle = i * 0.78;
        final inner = Offset(
          center.dx + size.width * 0.20 * cos(angle),
          center.dy + size.width * 0.20 * sin(angle),
        );
        final outer = Offset(
          center.dx + size.width * 0.31 * cos(angle),
          center.dy + size.width * 0.31 * sin(angle),
        );
        canvas.drawLine(inner, outer, inkPaint);
      }
      return;
    }

    final cloudPath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.42, size.width * 0.34, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.26, size.width * 0.50, size.height * 0.32)
      ..quadraticBezierTo(size.width * 0.58, size.height * 0.20, size.width * 0.68, size.height * 0.34)
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.34, size.width * 0.80, size.height * 0.54)
      ..close();
    canvas.drawPath(cloudPath, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawPath(cloudPath, inkPaint);

    if (weatherLabel == 'Soft clouds' || weatherLabel == 'Overcast' || weatherLabel == 'Fog') {
      if (weatherLabel == 'Fog') {
        for (var i = 0; i < 3; i++) {
          final y = size.height * (0.68 + i * 0.08);
          canvas.drawLine(Offset(size.width * 0.25, y), Offset(size.width * 0.75, y), inkPaint);
        }
      }
      return;
    }

    if (weatherLabel == 'Light rain' || weatherLabel == 'Passing showers') {
      for (var i = 0; i < 4; i++) {
        final x = size.width * (0.34 + i * 0.11);
        canvas.drawLine(
          Offset(x, size.height * 0.68),
          Offset(x - size.width * 0.04, size.height * 0.82),
          inkPaint,
        );
      }
      return;
    }

    if (weatherLabel == 'Snowfall') {
      for (var i = 0; i < 3; i++) {
        final x = size.width * (0.38 + i * 0.12);
        final y = size.height * 0.75;
        canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), inkPaint);
        canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), inkPaint);
      }
      return;
    }

    if (weatherLabel == 'Thunder') {
      final bolt = Path()
        ..moveTo(size.width * 0.50, size.height * 0.56)
        ..lineTo(size.width * 0.42, size.height * 0.78)
        ..lineTo(size.width * 0.50, size.height * 0.78)
        ..lineTo(size.width * 0.44, size.height * 0.94)
        ..lineTo(size.width * 0.62, size.height * 0.68)
        ..lineTo(size.width * 0.54, size.height * 0.68)
        ..close();
      canvas.drawPath(bolt, Paint()..color = accent.withValues(alpha: 0.92));
      canvas.drawPath(bolt, inkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherPainter oldDelegate) {
    return oldDelegate.weatherLabel != weatherLabel ||
        oldDelegate.accent != accent ||
        oldDelegate.ink != ink;
  }
}
