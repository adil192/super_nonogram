import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';

class SettingsBlob extends StatefulWidget {
  const SettingsBlob({
    super.key,
    required this.onTap,
    required this.children,
  });

  final VoidCallback? onTap;
  final List<Widget> children;

  @override
  State<SettingsBlob> createState() => _SettingsBlobState();
}

class _SettingsBlobState extends State<SettingsBlob> {
  late BlobController blobController;

  @override
  void initState() {
    blobController = BlobController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null ? null : () {
        blobController.change();
        widget.onTap?.call();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final colorScheme = Theme.of(context).colorScheme;
          return Blob.animatedRandom(
            size: constraints.minWidth,
            minGrowth: 7,
            styles: BlobStyles(
              color: colorScheme.primary.withOpacity(0.3),
              fillType: BlobFillType.fill,
            ),
            controller: blobController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.children,
            ),
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    blobController.dispose();
    super.dispose();
  }
}
