import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:wird/features/dua/dua_theme_groups.dart';

void main() {
  test('every Hisnul Muslim category lands in exactly one theme group', () {
    final raw =
        File('assets/data/hisnul_muslim.json').readAsStringSync();
    final categories =
        ((jsonDecode(raw) as Map<String, dynamic>)['categories'] as List)
            .cast<Map<String, dynamic>>();
    final allIds = {for (final c in categories) c['id'] as String};

    final seen = <String>{};
    for (final group in duaThemeGroups) {
      for (final id in group.categoryIds) {
        expect(seen.add(id), isTrue,
            reason: '$id appears in more than one group');
        expect(allIds.contains(id), isTrue,
            reason: '$id in group "${group.id}" does not exist in the JSON');
      }
    }
    expect(seen, allIds,
        reason: 'unmapped categories: ${allIds.difference(seen)}');
  });
}
