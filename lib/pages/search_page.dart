import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_nonogram/api/api.dart';
import 'package:super_nonogram/api/file_manager.dart';
import 'package:super_nonogram/board/ngb.dart';
import 'package:super_nonogram/misc/title.dart';

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
        title: const TitleText(),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create a new puzzle',
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Prompt',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a prompt';
                    }
                    return null;
                  },
                  enabled: !_disableInput,
                ),
                if (_failedSearch) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Failed to generate board, please try another prompt',
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _disableInput ? null : () async {
                    if (_disableInput) return;
                    if (!_formKey.currentState!.validate()) return;
                    _failedSearch = false;
                    setState(() => _disableInput = true);
                    try {
                      final query = _searchController.text;
                      final file = '/${Uri.encodeComponent(query)}.ngb';
                      if (!await FileManager.doesFileExist(file)) {
                        final board = await PixabayApi.getBoardFromSearch(query);
                        if (board == null) {
                          _failedSearch = true;
                          return;
                        }
                        final ngb = Ngb.writeNgb(board);
                        await FileManager.writeFile(file, ngb);
                      }
                      if (!mounted) return;
                      GoRouter.of(context).push('/play/${Uri.encodeComponent(query)}');
                    } finally {
                      setState(() => _disableInput = false);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
