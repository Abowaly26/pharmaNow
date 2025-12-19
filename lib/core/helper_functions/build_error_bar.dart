import 'package:flutter/material.dart';

OverlayEntry? _currentErrorEntry;
AnimationController? _currentErrorController;

void buildErrorBar(BuildContext context, String message) {
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
        bottom: 14,
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
                    color: const Color.fromARGB(255, 205, 42, 42),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5).withOpacity(0.70),
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
                            color: const Color(0xFFFCA5A5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 234, 89, 89).withOpacity(0.55),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.error_outline,
                              color: Colors.white, size: 20),
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
    await Future.delayed(const Duration(seconds: 2));
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
