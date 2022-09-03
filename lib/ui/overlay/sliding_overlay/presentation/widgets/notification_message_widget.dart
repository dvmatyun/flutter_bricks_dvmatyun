import 'package:flutter/material.dart';

/// NotificationMessageWidget
class NotificationMessageWidget extends StatelessWidget {
  const NotificationMessageWidget({
    required this.child,
    required this.decoration,
    this.height,
    this.width,
    this.onClose,
    Key? key,
  }) : super(key: key);

  final double? height;
  final double? width;
  final VoidCallback? onClose;
  final Widget child;
  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SizedBox(
          height: height,
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: DecoratedBox(
                decoration: decoration,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      child,
                      if (onClose != null)
                        IconButton(
                          //constraints: BoxConstraints.tight(const Size.square(24)),
                          splashRadius: 24,
                          padding: EdgeInsets.zero,
                          onPressed: onClose,
                          icon: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.white,
                          ),
                        )
                      else
                        const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
} // NotificationMessageWidget
