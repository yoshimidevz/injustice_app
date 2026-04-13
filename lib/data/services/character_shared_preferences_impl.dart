import 'dart:convert';

import '../../core/failure/failure.dart';
import '../../core/typedefs/types_defs.dart';
import 'character_local_storage_interface.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/character_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/patterns/result.dart';

final class CharacterSharedPreferencesService
    implements ICharacterLocalStorage {
  // Chave de armazenamento para os personagens
  static const String _storageKey = 'characters';

  @override
  Future<CharacterResult> deleteCharacter(String id) async{ //classe do tipo Future, que irá retornar algo no futuro, e pode demorar pra acontecer.
    try{
      final currentResult = await getAllCharacters();
      return await currentResult.fold( //trata sucesso e falha depois de obter os personagens atuais
        onSuccess: (characters) async{
          final found = characters
              .where((c) => c.id == id)
              .toList();
          if(found.isEmpty){
            return Error(ApiLocalFailure('Personagem não encontrado, impossivel deletar'));
          }
          final updatedCharacters = characters
              .where((c) => c.id != id) //atualiza a lista, mantendo todos menos o removido
              .toList();
          await _saveCharacters(updatedCharacters);
          return Success(found.first); //retorna o personagem deletado
        },
        onFailure: (f) async => Error(f), //se falhar ao obter os personagens, retorna o erro
      );
    } catch(e){
      return Error(ApiLocalFailure('Erro ao deletar: $e'));
    }
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();
      return await currentResult.fold(
        onSuccess: (characters) async {
          final index = characters
            .indexWhere((c) => c.id == character.id);
          if (index == -1) {
            return Error(ApiLocalFailure('Personagem não encontrado para atualização'));
          }
          final updatedCharacters = List<Character>.from(characters);
          updatedCharacters[index] = character;
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (f) async => Error(f),
      );
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao atualizar personagem: $e'));
    }
  }

  
  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getString(_storageKey);

      if (result == null || result.isEmpty) {
        return Error(EmptyResultFailure());
      }

      final decoded = jsonDecode(result) as List<dynamic>;

      final characters = decoded
          .map((e) => CharacterMapper.fromMap(e as Map<String, dynamic>))
          .toList();

      return Success(characters);
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao obter personagens: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) {
    try{
      return getAllCharacters().then((result) => result.fold(
        onSuccess: (characters){
          final found = characters
              .where((c) => c.id == id)
              .toList();
          if(found.isEmpty){
            return Error(ApiLocalFailure('Personagem não encontrado'));
          }
          return Success(found.first);
        },
        onFailure: (f) => Error(f),
      ));
    }
    catch(e){
      return Future.value(Error(ApiLocalFailure('Erro ao obter personagem por id: $e')));
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final currentResult = await getAllCharacters();

      return await currentResult.fold(
        onSuccess: (characters) async {
          final updatedCharacters = [...characters, character];
          await _saveCharacters(updatedCharacters);
          return Success(character);
        },
        onFailure: (failure) async {
          if (failure is EmptyResultFailure) {
            await _saveCharacters([character]);
            return Success(character);
          }

          return Error(ApiLocalFailure());
        },
      );
      
    } catch (e) {
      return Error(
        ApiLocalFailure('Shared Preferences - Erro ao salvar personagem: $e'),
      );
    }
  }

  /// Salva os personagens no storage
  Future<void> _saveCharacters(List<Character> characters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        characters.map((c) => CharacterMapper.toMap(c)).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      throw ApiLocalFailure('Erro ao salvar personagens: $e');
    }
  }
}
