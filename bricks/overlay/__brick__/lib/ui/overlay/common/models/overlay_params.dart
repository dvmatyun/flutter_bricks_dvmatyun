class OverlayParams {
  final String? key;
  final double screenHeight;
  final double screenWidth;

  final double? overlayHeight;
  final double? overlayWidth;

  final double topOffset;
  final double leftOffset;
  final Duration animationDuration;

  /// Duration that overlay stays on the screen in place (after animation is finished)
  final Duration? overlayStayDuration;

  const OverlayParams({
    required this.screenHeight,
    required this.screenWidth,
    this.overlayHeight,
    this.overlayWidth,
    double? topOffset,
    double? leftOffset,
    this.animationDuration = const Duration(seconds: 1),
    this.overlayStayDuration,
    this.key,
  })  : topOffset = topOffset ?? 0,
        leftOffset = leftOffset ?? (screenWidth - (overlayWidth ?? 0)) / 2;

  OverlayParams copyWith({
    String? key,
    double? screenHeight,
    double? screenWidth,
    double? overlayHeight,
    double? overlayWidth,
    double? topOffset,
    Duration? animationDuration,
    Duration? overlayStayDuration,
  }) =>
      OverlayParams(
        key: key ?? this.key,
        screenHeight: screenHeight ?? this.screenHeight,
        screenWidth: screenWidth ?? this.screenWidth,
        overlayHeight: overlayHeight ?? this.overlayHeight,
        overlayWidth: overlayWidth ?? this.overlayWidth,
        topOffset: topOffset ?? this.topOffset,
        animationDuration: animationDuration ?? this.animationDuration,
        overlayStayDuration: overlayStayDuration ?? this.overlayStayDuration,
      );
}
