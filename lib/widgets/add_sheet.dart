import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import 'capsule.dart';

/// Шторка «Добавить подписку». В демо любая ссылка превращается во встроенную подписку.
Future<void> showAddSheet(BuildContext context) {
  final state = AppScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Tokens.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      side: BorderSide(color: Tokens.edge),
    ),
    builder: (ctx) => AddSheet(state: state),
  );
}

class AddSheet extends StatefulWidget {
  const AddSheet({super.key, required this.state});

  final AppState state;

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  final TextEditingController _url = TextEditingController();
  bool _loading = false;
  bool _error = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _fill() {
    setState(() {
      _url.text = 'https://example.com/sub/demo';
      _error = false;
    });
  }

  Future<void> _add() async {
    if (_url.text.trim().isEmpty) {
      setState(() => _error = true);
      return;
    }
    setState(() {
      _error = false;
      _loading = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.state.addDemoSubscription();
    Navigator.of(context).pop();
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: c),
      );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 26 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Добавить подписку',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: Tokens.text),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _url,
            autocorrect: false,
            keyboardType: TextInputType.url,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Tokens.text),
            decoration: InputDecoration(
              hintText: 'Ссылка подписки',
              hintStyle: const TextStyle(color: Tokens.mute),
              filled: true,
              fillColor: Tokens.glass,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: _border(Tokens.edge),
              enabledBorder: _border(_error ? Tokens.red : Tokens.edge),
              focusedBorder: _border(_error ? Tokens.red : Tokens.blue),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: SoftButton('Из буфера', _fill)),
              const SizedBox(width: 10),
              Expanded(child: SoftButton('Скан QR', _fill)),
            ],
          ),
          const SizedBox(height: 10),
          Capsule(
            radius: 28,
            color: Tokens.blue,
            borderColor: Tokens.blue,
            onTap: _loading ? null : _add,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                _loading ? 'Загрузка…' : 'Добавить',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Tokens.onBlue),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Демо: данные встроены, сеть не используется.', style: Tokens.caption),
        ],
      ),
    );
  }
}
