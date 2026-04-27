import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class IGetCharacterByIdUseCase
    implements IUseCase<CharacterResult, CharacterIdParams> {}
abstract interface class IGetAllCharactersUseCase
    implements IUseCase<ListCharacterResult, NoParams> {}
abstract interface class ISaveCharacterUseCase
    implements IUseCase<CharacterResult, CharacterParams> {}
abstract interface class IDeleteCharacterUseCase
    implements IUseCase<CharacterResult, CharacterIdParams> {} // dentro do padrão de usecase, o contrato precisa dizer o que vai retornar e o que precisa receber
abstract interface class IUpdateCharacterUseCase
    implements IUseCase<CharacterResult, CharacterParams> {} // e aqui tb