class Person {
  Person({
    required this.id,
    required this.name,
    this.birth,
    this.death,
    this.gender,
    this.notes,
  });

  final String id;
  final String name;
  final DateTime? birth;
  final DateTime? death;
  final String? gender;
  final String? notes;

  Person copyWith({String? name, DateTime? birth, DateTime? death, String? gender, String? notes}) =>
      Person(
        id: id,
        name: name ?? this.name,
        birth: birth ?? this.birth,
        death: death ?? this.death,
        gender: gender ?? this.gender,
        notes: notes ?? this.notes,
      );
}

class RelationshipGraph {
  final Map<String, Person> _people = {};
  final Map<String, Set<String>> _parentOf = {};   // child -> parents
  final Map<String, Set<String>> _childrenOf = {}; // parent -> children
  final Map<String, Set<String>> _spousesOf = {};

  Iterable<Person> get people => _people.values;

  void upsert(Person p) => _people[p.id] = p;

  void addParent({required String childId, required String parentId}) {
    _parentOf.putIfAbsent(childId, () => {}).add(parentId);
    _childrenOf.putIfAbsent(parentId, () => {}).add(childId);
  }

  void addSpouse(String a, String b) {
    _spousesOf.putIfAbsent(a, () => {}).add(b);
    _spousesOf.putIfAbsent(b, () => {}).add(a);
  }

  Set<String> parentsOf(String id) => _parentOf[id] ?? const {};
  Set<String> childrenOf(String id) => _childrenOf[id] ?? const {};
  Set<String> spousesOf(String id) => _spousesOf[id] ?? const {};

  int generationOf(String id, {String? rootId}) {
    final root = rootId ?? _findRoot();
    if (root == null || id == root) return 0;
    final visited = <String>{};
    final queue = <(String, int)>[(root, 0)];
    while (queue.isNotEmpty) {
      final (cur, gen) = queue.removeAt(0);
      if (!visited.add(cur)) continue;
      if (cur == id) return gen;
      for (final c in childrenOf(cur)) {
        queue.add((c, gen + 1));
      }
    }
    return 0;
  }

  String? _findRoot() {
    for (final id in _people.keys) {
      if (parentsOf(id).isEmpty) return id;
    }
    return _people.keys.isEmpty ? null : _people.keys.first;
  }
}
