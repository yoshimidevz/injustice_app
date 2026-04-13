import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/models/account_entity.dart';
import '../../../../../domain/models/character_entity.dart';
import '../../../../../domain/models/extensions/character_ui.dart';
import '../../../../controllers/characters_state_viewmodel.dart';
import '../../../../controllers/characters_view_model.dart';
import '../../../../widgets/account_summary_card.dart';
import '../../../../widgets/empty_state.dart';
import '../../../../widgets/loading_indicator.dart';
import '../../../../widgets/star_rating.dart';
import '../../form/form_character_view.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersBody extends StatelessWidget {
  final CharactersViewModel viewModel;
  final Account account;

  const CharactersBody({
    super.key,
    required this.viewModel,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isLoading =
          viewModel.commands.getAllCharactersCommand.isExecuting.value;

      final characters = viewModel.charactersState.sortedCharacters.value;

      return RefreshIndicator(
        onRefresh: () async {
          await viewModel.commands.getAllCharactersCommand.execute();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: AccountSummaryCard(account: account),
              ),
            ),

            SliverToBoxAdapter(child: FilterPanel(viewModel: viewModel)),

            if (isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingIndicator(message: 'Carregando personagens...'),
              )
            else if (characters.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState.noCharacters(),
              )
            else
              SliverPadding(
                padding: AppSpacing.paddingMd,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final character = characters[index];
                    return CharacterListItem(
                      character: character,
                      onDelete: () async {
                        await viewModel.commands.deleteCharacter(character.id);
                      },
                      onTap: () async {
                        final edited = await Navigator.push<Character?>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormCharacterView(
                              character: character,
                            ),
                          ),
                        );
                        
                        if (edited != null) {
                          await viewModel.commands.updateCharacter(edited);
                        }
                      },
                    );
                  }, childCount: characters.length),
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// Item da lista de personagens
class CharacterListItem extends StatelessWidget {
  final Character character;
  final Future<void> Function() onDelete;
  final Future<void> Function() onTap;

  const CharacterListItem({
    super.key,
    required this.character,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(character.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onTap();
          return false;
        } else {
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar exclusão'),
                  content: Text('Deseja realmente excluir ${character.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              ) ??
              false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: Card(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: character.rarity.color,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              character.name,
                              style: context.textStyles.titleMedium?.semiBold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Nv. ${character.level}',
                            style: context.textStyles.labelLarge?.withColor(
                              Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            character.characterClass.icon,
                            size: 16,
                            color: character.characterClass.color,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            character.characterClass.displayName,
                            style: context.textStyles.bodySmall?.withColor(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      StarRating(stars: character.stars, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterPanel extends StatelessWidget {
  final CharactersViewModel viewModel;
  const FilterPanel({super.key, required this.viewModel});

  CharactersStateViewmodel get state => viewModel.charactersState;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final filtersCount = state.activeFiltersCount.value;
      final isExpanded = state.isFilterPanelExpanded.value;

      return Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: state.toggleFilterPanel,
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Filtros',
                      style: context.textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (filtersCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          filtersCount.toString(),
                          style: context.textStyles.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classe',
                      style: context.textStyles.labelMedium?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Aqui viriam os chips de filtro por classe
                    // ...
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}