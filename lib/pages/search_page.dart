import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/api/api.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    @visibleForTesting this.showPreviousPuzzles = true,
  });

  final bool showPreviousPuzzles;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  bool _disableInput = false;

  bool _failedSearch = false;

  static final _privacyPolicyUri = Uri.parse(
    'https://supernonogram.adil.hanney.org/privacy_policy.html',
  );
  static const _contentWidth = 600.0;

  void _createPuzzle() async {
    if (_disableInput) return;
    if (!_formKey.currentState!.validate()) return;

    _failedSearch = false;
    _disableInput = true;
    if (mounted) setState(() {});

    try {
      final query = _searchController.text;
      final baseFilename = Uri.encodeComponent(query);
      final fileNgb = '/$baseFilename.ngb';
      final filePng = '/$baseFilename.png';
      final fileJson = '/$baseFilename.json';

      if (!await FileManager.doesFileExist(fileNgb)) {
        final (info, srcImage, board) = await PixabayApi.getBoardFromSearch(
          query,
        );
        if (info == null || srcImage == null || board == null) {
          _failedSearch = true;
          return;
        }

        final ngb = Ngb.writeNgb(board);
        await FileManager.writeFile(fileNgb, string: ngb);
        await FileManager.writeFile(filePng, bytes: srcImage);
        await FileManager.writeFile(fileJson, string: jsonEncode(info));
        PreviousPuzzles.recordPuzzle(query);
      }

      if (mounted) GoRouter.of(context).push('/play?query=$baseFilename');
    } catch (_) {
      _failedSearch = true;
      rethrow;
    } finally {
      _disableInput = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.title.appName)),
      body: Center(
        child: SingleChildScrollView(
          padding: const .all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(t.search.createNewPuzzle, style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(labelText: t.search.prompt),
                    style: TextStyle(color: colorScheme.onSurface),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.search.enterPrompt;
                      }
                      return null;
                    },
                    enabled: !_disableInput,
                  ),
                ),
                if (_failedSearch) ...[
                  const SizedBox(height: 8),
                  Text(
                    t.search.failedToGenerateBoard,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _disableInput ? null : _createPuzzle,
                  child: Text(t.search.create),
                ),
                const SizedBox(height: 32),
                if (widget.showPreviousPuzzles) const PreviousPuzzles(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Material(
        color: colorScheme.surface,
        child: SafeArea(
          minimum: const .symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: _contentWidth,
            child: RichText(
              textAlign: .center,
              text: TextSpan(
                style: textTheme.bodySmall,
                children: [
                  t.search.privacyInformation(
                    link: (text) => TextSpan(
                      text: text,
                      style: TextStyle(color: colorScheme.primary),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(_privacyPolicyUri);
                        },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PreviousPuzzles extends StatefulWidget {
  const PreviousPuzzles({super.key});

  @override
  State<PreviousPuzzles> createState() => _PreviousPuzzlesState();

  // Insert [puzzle] in the correct position to stay sorted.
  static void recordPuzzle(String puzzle) {
    final puzzles = _PreviousPuzzlesState._puzzles.value.toList();
    bool inserted = false;
    for (var i = 0; i < puzzles.length; i++) {
      final cmp = puzzles[i].compareTo(puzzle);
      if (cmp == 0) {
        inserted = true;
        break;
      } else if (cmp > 0) {
        puzzles.insert(i, puzzle);
        inserted = true;
        break;
      }
    }
    if (!inserted) puzzles.add(puzzle);
    _PreviousPuzzlesState._puzzles.value = puzzles;
  }
}

class _PreviousPuzzlesState extends State<PreviousPuzzles> {
  static final ValueNotifier<List<String>> _puzzles = ValueNotifier([]);

  static const double _separation = 16,
      _imageSize = 100,
      _imagePadding = 8,
      _textSize = 16,
      _totalWidth = _imageSize + _imagePadding * 2 + _separation,
      _totalHeight = _totalWidth + _textSize * 2;

  @override
  void initState() {
    super.initState();
    _loadPreviousPuzzles();
  }

  @override
  void didUpdateWidget(covariant PreviousPuzzles oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadPreviousPuzzles();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPreviousPuzzles() async {
    _PreviousPuzzlesState._puzzles.value = await FileManager.listPuzzles();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _totalHeight,
      child: ValueListenableBuilder(
        valueListenable: _puzzles,
        builder: (context, puzzles, child) {
          return ListView.builder(
            key: ValueKey(puzzles),
            scrollDirection: Axis.horizontal,
            itemCount: puzzles.length,
            itemExtent: _totalWidth,
            itemBuilder: (context, index) {
              if (index >= puzzles.length) {
                return const SizedBox.shrink();
              }

              final puzzle = puzzles[index];
              return GestureDetector(
                onTap: () {
                  final baseFilename = Uri.encodeComponent(puzzle);
                  GoRouter.of(context).push('/play?query=$baseFilename');
                },
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(_imagePadding),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image(
                            image: FileManager.getPuzzleImage(puzzle),
                          ),
                        ),
                      ),
                      Text(
                        puzzle,
                        style: const TextStyle(fontSize: _textSize),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
