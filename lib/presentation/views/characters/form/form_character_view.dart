import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/models/character_entity.dart';

class FormCharacterView extends StatefulWidget{
  final Character? character;
  const FormCharacterView({super.key, this.character});

  @override
  State<FormCharacterView> createState() =>
  _FormCharacterViewState();
}

class _FormCharacterViewState extends State<FormCharacterView>{
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _levelCtrl;
  late final TextEditingController _attackCtrl;
  late final TextEditingController _healthCtrl;
  late final TextEditingController _threatCtrl;
  late final TextEditingController _starsCtrl;

  late CharacterClass _selectedClass;
  late CharacterRarity _selectedRarity;
  late CharacterAlignment _selectedAlignment;

  @override
  void initState(){
    super.initState();
    final c = widget.character;
    _nameCtrl = TextEditingController(text: c?.name ?? "");
    _levelCtrl = TextEditingController(text: c?.level.toString() ?? "1");
    _attackCtrl = TextEditingController(text: c?.attack.toString() ?? "0");
    _healthCtrl = TextEditingController(text: c?.health.toString() ?? "0");
    _threatCtrl = TextEditingController(text: c?.threat.toString() ?? "0");
    _starsCtrl = TextEditingController(text: c?.stars.toString() ?? "1");
    _selectedClass = c?.characterClass ?? CharacterClass.poderoso;
    _selectedRarity = c?.rarity ?? CharacterRarity.prata;
    _selectedAlignment = c?.alignment ?? CharacterAlignment.heroi;
  }

  @override
  void dispose(){
    _nameCtrl.dispose();
    _levelCtrl.dispose();
    _attackCtrl.dispose();
    _healthCtrl.dispose();
    _threatCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  void _save(){
    if(!_formKey.currentState!.validate()) return;
      final isEditing = widget.character != null;
      final now = DateTime.now();
      final character = Character(
        id: isEditing ? widget.character!.id : const Uuid().v4(),
        name: _nameCtrl.text,
        characterClass: _selectedClass,
        rarity: _selectedRarity,
        level: int.parse(_levelCtrl.text),
        attack: int.parse(_attackCtrl.text),
        health: int.parse(_healthCtrl.text),
        threat: int.parse(_threatCtrl.text),
        stars: int.parse(_starsCtrl.text),
        alignment: _selectedAlignment,
        createdAt: isEditing ? widget.character!.createdAt : now,
        updatedAt: now,
      );
      Navigator.of(context).pop(character);
  }

  @override
  Widget build(BuildContext context){
    final isEditing = widget.character != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Editar Personagem" : "Criar Personagem")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Nome", border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _levelCtrl,
                decoration: const InputDecoration(labelText: "Nível(1-80)", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if(value == null || value.trim().isEmpty) return "Informe o nível";
                  final n = int.tryParse(value);
                  if(n == null || n < 1 || n > 80) return "Nível deve ser um número inteiro entre 1 e 80";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _attackCtrl,
                decoration: const InputDecoration(labelText: "Ataque", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if(value == null || value.trim().isEmpty) return "Informe o ataque";
                  final n = int.tryParse(value);
                  if(n == null || n < 0) return "Ataque deve ser um número inteiro não negativo";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _healthCtrl,
                decoration: const InputDecoration(labelText: "Vida", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if(value == null || value.trim().isEmpty) return "Informe a vida";
                  final n = int.tryParse(value);
                  if(n == null || n < 0) return "Vida deve ser um número inteiro não negativo";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _threatCtrl,
                decoration: const InputDecoration(labelText: "Ameaça", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if(value == null || value.trim().isEmpty) return "Informe a ameaça";
                  final n = int.tryParse(value);
                  if(n == null || n < 0) return "Ameaça deve ser um número inteiro não negativo";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _starsCtrl,
                decoration: const InputDecoration(labelText: "Estrelas(1-5)", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if(value == null || value.trim().isEmpty) return "Informe as estrelas";
                  final n = int.tryParse(value);
                  if(n == null || n < 1 || n > 5) return "Estrelas deve ser um número inteiro entre 1 e 5";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CharacterClass>(
                value: _selectedClass,
                items: CharacterClass.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
                onChanged: (c) => setState(() => _selectedClass = c!),
                decoration: const InputDecoration(labelText: "Classe", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CharacterRarity>(
                value: _selectedRarity,
                items: CharacterRarity.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase()))).toList(),
                onChanged: (r) => setState(() => _selectedRarity = r!),
                decoration: const InputDecoration(labelText: "Raridade", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CharacterAlignment>(
                value: _selectedAlignment,
                items: CharacterAlignment.values.map((a) => DropdownMenuItem(value: a, child: Text(a.name.toUpperCase()))).toList(),
                onChanged: (a) => setState(() => _selectedAlignment = a!),
                decoration: const InputDecoration(labelText: "Alinhamento", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? "Salvar Alterações" : "Criar Personagem"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}