import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/board/tile_state.dart';

class TilePreview extends StatelessWidget {
  const TilePreview({super.key, required this.tileState});

  final TileState tileState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    const tileSize = 48.0;
    return SizedBox.square(
      dimension: tileSize,
      child: CustomPaint(
        painter: TilePainter(
          tileState: tileState,
          colorScheme: colorScheme,
          onOffSwitchLabels: MediaQuery.onOffSwitchLabelsOf(context),
          highContrast: MediaQuery.highContrastOf(context),
        ),
      ),
    );
  }
}

class TilePainter extends CustomPainter {
  TilePainter({
    required this.tileState,
    required this.colorScheme,
    required this.onOffSwitchLabels,
    required this.highContrast,
  });

  final TileState tileState;
  final ColorScheme colorScheme;
  final bool onOffSwitchLabels;
  final bool highContrast;

  @override
  void paint(Canvas canvas, Size size) {
    paintTile(
      tileState,
      canvas: canvas,
      tileRect: Offset.zero & size,
      colorScheme: colorScheme,
      onOffSwitchLabels: onOffSwitchLabels,
      highContrast: highContrast,
    );
  }

  @override
  bool shouldRepaint(TilePainter oldDelegate) {
    return oldDelegate.tileState != tileState ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.onOffSwitchLabels != onOffSwitchLabels ||
        oldDelegate.highContrast != highContrast;
  }

  static void paintTile(
    TileState tileState, {
    required Canvas canvas,
    required Rect tileRect,
    required ColorScheme colorScheme,
    required bool onOffSwitchLabels,
    required bool highContrast,
    bool inCenterOfBoard = false,
  }) {
    final tileRRect = RRect.fromRectXY(
      tileRect,
      tileRect.width * 0.2,
      tileRect.height * 0.2,
    );
    final tileColorAlpha = switch (tileState) {
      .selected => 1.0,
      .crossed => 0.05,
      .empty => 0.3,
    };
    canvas.drawRRect(
      tileRRect,
      Paint()
        ..style = PaintingStyle.fill
        ..color =
            (inCenterOfBoard
                    ? Color.lerp(
                        colorScheme.primary,
                        colorScheme.secondaryFixedDim,
                        0.5,
                      )!
                    : colorScheme.primary)
                .withValues(alpha: tileColorAlpha),
    );
    if (highContrast) {
      canvas.drawRRect(
        tileRRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = colorScheme.onSurface
          ..strokeWidth = 2.0,
      );
    }

    // Draw cross if crossed
    late final iconPaint = Paint()
      ..color = colorScheme.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = tileRect.width * 0.04;
    if (tileState == TileState.crossed) {
      final t = 0.25;
      canvas.drawLine(
        Alignment(-t, -t).withinRect(tileRect),
        Alignment(t, t).withinRect(tileRect),
        iconPaint,
      );
      canvas.drawLine(
        Alignment(-t, t).withinRect(tileRect),
        Alignment(t, -t).withinRect(tileRect),
        iconPaint,
      );
    } else if (tileState == TileState.selected && onOffSwitchLabels) {
      iconPaint.color = colorScheme.onPrimary;
      final path = Path()
        ..moveTo(
          tileRect.left + tileRect.width * 0.375,
          tileRect.top + tileRect.height * 0.55,
        )
        ..lineTo(
          tileRect.left + tileRect.width * 0.45,
          tileRect.top + tileRect.height * 0.625,
        )
        ..lineTo(
          tileRect.left + tileRect.width * 0.625,
          tileRect.top + tileRect.height * 0.375,
        );
      canvas.drawPath(path, iconPaint);
    }
  }
}
