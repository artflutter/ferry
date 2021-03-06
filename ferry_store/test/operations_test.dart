import 'package:test/test.dart';

import 'package:ferry_store/ferry_store.dart';

void main() {
  final data = {
    'Query': {
      'posts': [
        {'\$ref': 'Post:123'}
      ]
    },
    'Post:123': {
      'id': '123',
      '__typename': 'Post',
    },
  };

  group('CRUD operations', () {
    test('starts empty', () {
      final store = MemoryStore();
      expect(store.valueStream.value, equals({}));
    });
    test('can include seeded data', () {
      final store = MemoryStore(data);
      expect(store.valueStream.value, equals(data));
    });

    test('can get data', () {
      final store = MemoryStore(data);

      for (var entry in data.entries) {
        expect(store.get(entry.key), equals(entry.value));
      }
    });

    test('can put data', () {
      final store = MemoryStore();

      for (var entry in data.entries) {
        store.put(entry.key, entry.value);
      }
      expect(store.valueStream.value, equals(data));
    });

    test('can put all data', () {
      final store = MemoryStore();

      store.putAll(data);
      expect(store.valueStream.value, equals(data));
    });

    test('can delete data', () {
      final store = MemoryStore(data);

      store.delete(data.keys.first);
      expect(
        store.valueStream.value,
        equals({data.keys.last: data.values.last}),
      );
    });

    test('can clear data', () {
      final store = MemoryStore(data);

      store.clear();
      expect(store.valueStream.value, equals({}));
    });
  });

  group('watch operation', () {
    test('gets initial data when watching', () async {
      final store = MemoryStore(data);

      expect(store.valueStream, emits(data));
    });

    test('dispose method triggers done event', () async {
      final store = MemoryStore(data);

      expect(store.valueStream, emitsInOrder([data, emitsDone]));

      await store.dispose();
    });

    test('put method triggers new data', () async {
      final store = MemoryStore(data);

      final newPostKey = 'Post:456';
      final newPostValue = {
        'id': '456',
        '__typename': 'Post',
      };

      expect(
        store.valueStream,
        emitsInOrder([
          data,
          {...data, newPostKey: newPostValue},
        ]),
      );

      store.put(newPostKey, newPostValue);
    });
  });
}
