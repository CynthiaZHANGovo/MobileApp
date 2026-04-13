enum StickerType {
  weatherScene,
  sunBadge,
  cloudBadge,
  rainBadge,
  thunderBadge,
  snowBadge,
  windBadge,
  leafBadge,
  starBadge,
  moonBadge,
  flowerBadge,
  dropBadge,
  sparkleBadge,
  shadeBadge,
  drinkBadge,
  umbrellaBadge,
  bootBadge,
  thermoBadge,
  aqiBadge,
  timeBadge,
  cityBadge,
}

class StudioSticker {
  const StudioSticker({
    required this.id,
    required this.type,
    required this.label,
    required this.dx,
    required this.dy,
    this.scale = 1,
  });

  final String id;
  final StickerType type;
  final String label;
  final double dx;
  final double dy;
  final double scale;

  StudioSticker copyWith({
    String? id,
    StickerType? type,
    String? label,
    double? dx,
    double? dy,
    double? scale,
  }) {
    return StudioSticker(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      scale: scale ?? this.scale,
    );
  }
}
