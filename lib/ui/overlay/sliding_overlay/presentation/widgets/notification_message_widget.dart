import 'package:flutter/material.dart';

/// NotificationMessageWidget
class NotificationMessageWidget extends StatelessWidget {
  const NotificationMessageWidget({
    required this.child,
    this.height,
    this.width,
    this.onClose,
    Key? key,
  }) : super(key: key);

  final double? height;
  final double? width;
  final VoidCallback? onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SizedBox(
          height: height,
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Material(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    child,
                    onClose != null
                        ? IconButton(
                            //constraints: BoxConstraints.tight(const Size.square(24)),
                            splashRadius: 24,
                            padding: EdgeInsets.zero,
                            onPressed: onClose,
                            icon: const Icon(
                              Icons.close,
                              size: 24,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
} // NotificationMessageWidget