import '../../core/typedefs/types_defs.dart';
import '../../domain/models/character_entity.dart';

abstract interface class ICharacterRepository {
  Future<CharacterResult> getCharacterById(String id);
  Future<ListCharacterResult> getAllCharacters();
  Future<CharacterResult> saveCharacter(Character character);
  Future<CharacterResult> deleteCharacter(String id); // aqui o contrato do repositorio precisa dizer o que vai retornar e o que precisa receber
  Future<CharacterResult> updateCharacter(Character character);
}