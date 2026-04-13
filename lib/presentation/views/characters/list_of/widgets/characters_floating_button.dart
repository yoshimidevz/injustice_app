import 'package:flutter/material.dart';
import '../../../../controllers/characters_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../domain/models/character_entity.dart';
import '../../form/form_character_view.dart';

class CharactersFab extends StatelessWidget {
  final CharactersViewModel viewModel;

  const CharactersFab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isExecuting =
          viewModel.commands.createCharacterCommand.isExecuting.value;

      return FloatingActionButton(
        onPressed: isExecuting ? null : () async {
                final newChar = await Navigator.push<Character>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormCharacterView(),
                  ),
                );
                if (newChar == null) return;
                await viewModel.commands.addCharacter(newChar);
              },
        child: isExecuting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
      );
    });
  }
}
