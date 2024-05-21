import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_nonogram/api/api.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/i18n/strings.g.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  bool _disableInput = false;

  bool _failedSearch = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.title.appName),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.search.createNewPuzzle,
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: t.search.prompt,
                    ),
                    style: TextStyle(
                      color: colorScheme.onBackground,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.search.enterPrompt;
                      }
                      return null;
                    },
                    enabled: !_disableInput,
                  ),
                  if (_failedSearch) ...[
                    const SizedBox(height: 8),
                    Text(
                      t.search.failedToGenerateBoard,
                      style: TextStyle(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _disableInput
                        ? null
                        : () async {
                            if (_disableInput) return;
                            if (!_formKey.currentState!.validate()) return;
                            _failedSearch = false;
                            setState(() => _disableInput = true);
                            try {
                              final query = _searchController.text;
                              final file = '/${Uri.encodeComponent(query)}.ngb';
                              if (!await FileManager.doesFileExist(file)) {
                                final (info, srcImage, board) =
                                    await PixabayApi.getBoardFromSearch(query);
                                if (info == null ||
                                    srcImage == null ||
                                    board == null) {
                                  _failedSearch = true;
                                  return;
                                }
                                final ngb = Ngb.writeNgb(board);
                                await FileManager.writeFile(file, string: ngb);
                                await FileManager.writeFile(
                                    '/${Uri.encodeComponent(query)}.png',
                                    bytes: srcImage);
                                await FileManager.writeFile(
                                    '/${Uri.encodeComponent(query)}.json',
                                    string: jsonEncode(info));
                              }
                              if (!mounted) return;
                              GoRouter.of(context).push(
                                  '/play?query=${Uri.encodeComponent(query)}');
                            } finally {
                              setState(() => _disableInput = false);
                            }
                          },
                    child: Text(
                      t.search.create,
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
