import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

typedef ShowCustomBar = void Function(
  BuildContext context,
  String message, {
  MessageType type,
  Color? backgroundColor,
  Color? borderColor,
  Color? accentColor,
  Color? iconBackgroundColor,
  IconData? icon,
  Duration? duration,
});

enum MessageType {
  error,
  success,
  warning,
  info,
}

Map<MessageType, Map<String, dynamic>> _getMessageTypeStyles() {
  return {
    MessageType.error: {
      'backgroundColor': ColorManager.redColor,
      'borderColor': const Color(0xFFFCA5A5).withOpacity(0.80),
      'accentColor': const Color(0xFFFCA5A5),
      'iconBackgroundColor': const Color(0xFFFCA5A5).withOpacity(0.45),
      'icon': Icons.error_outline,
    },
    MessageType.success: {
      'backgroundColor': const Color.fromARGB(255, 42, 205, 42),
      'borderColor': const Color(0xFFA5FCA5).withOpacity(0.70),
      'accentColor': const Color(0xFFA5FCA5),
      'iconBackgroundColor':
          const Color.fromARGB(255, 89, 234, 89).withOpacity(0.55),
      'icon': Icons.check_circle_outline,
    },
    MessageType.warning: {
      'backgroundColor': const Color(0xFFF59E0B),
      'borderColor': const Color(0xFFFCD34D).withOpacity(0.70),
      'accentColor': const Color.fromARGB(255, 255, 212, 137),
      'iconBackgroundColor': const Color(0xFFFCD34D).withOpacity(0.20),
      'icon': Icons.warning_amber_rounded,
    },
    MessageType.info: {
      'backgroundColor': const Color(0x1A3B82F6),
      'borderColor': const Color(0xFF60A5FA).withOpacity(0.70),
      'accentColor': const Color(0xFF3B82F6),
      'iconBackgroundColor': const Color(0xFF60A5FA).withOpacity(0.20),
      'icon': Icons.info_outline,
    },
  };
}

OverlayEntry? _currentErrorEntry;
AnimationController? _currentErrorController;

void showCustomBar(
  BuildContext context,
  String message, {
  MessageType type = MessageType.error,
  Color? backgroundColor,
  Color? borderColor,
  Color? accentColor,
  Color? iconBackgroundColor,
  IconData? icon,
  Duration? duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  final navigator = Navigator.of(context);

  _currentErrorController?.stop();
  _currentErrorController?.dispose();
  _currentErrorController = null;

  _currentErrorEntry?.remove();
  _currentErrorEntry = null;

  final textTheme = Theme.of(context).textTheme;
  final safeMessage = message.trim().isEmpty
      ? 'Something went wrong. Please try again.'
      : message.trim();

  // Get default styles based on message type
  final messageTypeStyles = _getMessageTypeStyles();
  final defaultStyle =
      messageTypeStyles[type] ?? messageTypeStyles[MessageType.error]!;

  // Resolve colors with fallback to type defaults and then hardcoded defaults
  final resolvedBackgroundColor =
      backgroundColor ?? defaultStyle['backgroundColor'] as Color;
  final resolvedBorderColor =
      borderColor ?? defaultStyle['borderColor'] as Color;
  final resolvedAccentColor =
      accentColor ?? defaultStyle['accentColor'] as Color;
  final resolvedIconBg =
      iconBackgroundColor ?? defaultStyle['iconBackgroundColor'] as Color;
  final resolvedIcon = icon ?? defaultStyle['icon'] as IconData;

  final controller = AnimationController(
    vsync: navigator,
    duration: const Duration(milliseconds: 180),
    reverseDuration: const Duration(milliseconds: 160),
  );
  _currentErrorController = controller;

  final curve = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
  final opacity = Tween<double>(begin: 0, end: 1).animate(curve);
  final offset = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
      .animate(curve);

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 16,
        right: 16,
        bottom: 65.h,
        child: IgnorePointer(
          ignoring: false,
          child: Material(
            color: Colors.transparent,
            child: FadeTransition(
              opacity: opacity,
              child: SlideTransition(
                position: offset,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: resolvedBackgroundColor,
                    border: Border.all(
                      color: resolvedBorderColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: DefaultTextStyle(
                    style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 36,
                          decoration: BoxDecoration(
                            color: resolvedAccentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: resolvedIconBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              Icon(resolvedIcon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            safeMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: (textTheme.bodyMedium ?? const TextStyle())
                                .copyWith(color: Colors.white, height: 1.2),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  _currentErrorEntry = entry;
  overlay.insert(entry);
  controller.forward();

  Future<void>(() async {
    await Future.delayed(duration ?? const Duration(seconds: 3));
    if (_currentErrorController != controller) return;
    await controller.reverse();
    if (_currentErrorEntry == entry) {
      entry.remove();
      _currentErrorEntry = null;
    }
    controller.dispose();
    if (_currentErrorController == controller) {
      _currentErrorController = null;
    }
  });
}
