// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarEmojiMeta = const VerificationMeta(
    'avatarEmoji',
  );
  @override
  late final GeneratedColumn<String> avatarEmoji = GeneratedColumn<String>(
    'avatar_emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, avatarEmoji, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_emoji')) {
      context.handle(
        _avatarEmojiMeta,
        avatarEmoji.isAcceptableOrUnknown(
          data['avatar_emoji']!,
          _avatarEmojiMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarEmoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_emoji'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String name;
  final String? avatarEmoji;
  final DateTime createdAt;
  const UserProfile({
    required this.id,
    required this.name,
    this.avatarEmoji,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarEmoji != null) {
      map['avatar_emoji'] = Variable<String>(avatarEmoji);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      avatarEmoji: avatarEmoji == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarEmoji),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarEmoji: serializer.fromJson<String?>(json['avatarEmoji']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'avatarEmoji': serializer.toJson<String?>(avatarEmoji),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    Value<String?> avatarEmoji = const Value.absent(),
    DateTime? createdAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarEmoji: avatarEmoji.present ? avatarEmoji.value : this.avatarEmoji,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarEmoji: data.avatarEmoji.present
          ? data.avatarEmoji.value
          : this.avatarEmoji,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarEmoji: $avatarEmoji, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, avatarEmoji, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarEmoji == this.avatarEmoji &&
          other.createdAt == this.createdAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> avatarEmoji;
  final Value<DateTime> createdAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarEmoji = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.avatarEmoji = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? avatarEmoji,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarEmoji != null) 'avatar_emoji': avatarEmoji,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? avatarEmoji,
    Value<DateTime>? createdAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarEmoji.present) {
      map['avatar_emoji'] = Variable<String>(avatarEmoji.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarEmoji: $avatarEmoji, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserPlansTable extends UserPlans
    with TableInfo<$UserPlansTable, UserPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quranSelectionTypeMeta =
      const VerificationMeta('quranSelectionType');
  @override
  late final GeneratedColumn<String> quranSelectionType =
      GeneratedColumn<String>(
        'quran_selection_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _quranSelectionJsonMeta =
      const VerificationMeta('quranSelectionJson');
  @override
  late final GeneratedColumn<String> quranSelectionJson =
      GeneratedColumn<String>(
        'quran_selection_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _dailyMinutesMeta = const VerificationMeta(
    'dailyMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyMinutes = GeneratedColumn<int>(
    'daily_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reciterMeta = const VerificationMeta(
    'reciter',
  );
  @override
  late final GeneratedColumn<String> reciter = GeneratedColumn<String>(
    'reciter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Husary_128kbps'),
  );
  static const VerificationMeta _weeklyGoalMeta = const VerificationMeta(
    'weeklyGoal',
  );
  @override
  late final GeneratedColumn<int> weeklyGoal = GeneratedColumn<int>(
    'weekly_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    quranSelectionType,
    quranSelectionJson,
    direction,
    dailyMinutes,
    reciter,
    weeklyGoal,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('quran_selection_type')) {
      context.handle(
        _quranSelectionTypeMeta,
        quranSelectionType.isAcceptableOrUnknown(
          data['quran_selection_type']!,
          _quranSelectionTypeMeta,
        ),
      );
    }
    if (data.containsKey('quran_selection_json')) {
      context.handle(
        _quranSelectionJsonMeta,
        quranSelectionJson.isAcceptableOrUnknown(
          data['quran_selection_json']!,
          _quranSelectionJsonMeta,
        ),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('daily_minutes')) {
      context.handle(
        _dailyMinutesMeta,
        dailyMinutes.isAcceptableOrUnknown(
          data['daily_minutes']!,
          _dailyMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyMinutesMeta);
    }
    if (data.containsKey('reciter')) {
      context.handle(
        _reciterMeta,
        reciter.isAcceptableOrUnknown(data['reciter']!, _reciterMeta),
      );
    }
    if (data.containsKey('weekly_goal')) {
      context.handle(
        _weeklyGoalMeta,
        weeklyGoal.isAcceptableOrUnknown(data['weekly_goal']!, _weeklyGoalMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      quranSelectionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quran_selection_type'],
      ),
      quranSelectionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quran_selection_json'],
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      dailyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_minutes'],
      )!,
      reciter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reciter'],
      )!,
      weeklyGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_goal'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserPlansTable createAlias(String alias) {
    return $UserPlansTable(attachedDatabase, alias);
  }
}

class UserPlan extends DataClass implements Insertable<UserPlan> {
  final int id;
  final String scope;
  final String? quranSelectionType;
  final String? quranSelectionJson;
  final String direction;
  final int dailyMinutes;
  final String reciter;
  final int weeklyGoal;
  final DateTime createdAt;
  const UserPlan({
    required this.id,
    required this.scope,
    this.quranSelectionType,
    this.quranSelectionJson,
    required this.direction,
    required this.dailyMinutes,
    required this.reciter,
    required this.weeklyGoal,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || quranSelectionType != null) {
      map['quran_selection_type'] = Variable<String>(quranSelectionType);
    }
    if (!nullToAbsent || quranSelectionJson != null) {
      map['quran_selection_json'] = Variable<String>(quranSelectionJson);
    }
    map['direction'] = Variable<String>(direction);
    map['daily_minutes'] = Variable<int>(dailyMinutes);
    map['reciter'] = Variable<String>(reciter);
    map['weekly_goal'] = Variable<int>(weeklyGoal);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserPlansCompanion toCompanion(bool nullToAbsent) {
    return UserPlansCompanion(
      id: Value(id),
      scope: Value(scope),
      quranSelectionType: quranSelectionType == null && nullToAbsent
          ? const Value.absent()
          : Value(quranSelectionType),
      quranSelectionJson: quranSelectionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(quranSelectionJson),
      direction: Value(direction),
      dailyMinutes: Value(dailyMinutes),
      reciter: Value(reciter),
      weeklyGoal: Value(weeklyGoal),
      createdAt: Value(createdAt),
    );
  }

  factory UserPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlan(
      id: serializer.fromJson<int>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      quranSelectionType: serializer.fromJson<String?>(
        json['quranSelectionType'],
      ),
      quranSelectionJson: serializer.fromJson<String?>(
        json['quranSelectionJson'],
      ),
      direction: serializer.fromJson<String>(json['direction']),
      dailyMinutes: serializer.fromJson<int>(json['dailyMinutes']),
      reciter: serializer.fromJson<String>(json['reciter']),
      weeklyGoal: serializer.fromJson<int>(json['weeklyGoal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scope': serializer.toJson<String>(scope),
      'quranSelectionType': serializer.toJson<String?>(quranSelectionType),
      'quranSelectionJson': serializer.toJson<String?>(quranSelectionJson),
      'direction': serializer.toJson<String>(direction),
      'dailyMinutes': serializer.toJson<int>(dailyMinutes),
      'reciter': serializer.toJson<String>(reciter),
      'weeklyGoal': serializer.toJson<int>(weeklyGoal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserPlan copyWith({
    int? id,
    String? scope,
    Value<String?> quranSelectionType = const Value.absent(),
    Value<String?> quranSelectionJson = const Value.absent(),
    String? direction,
    int? dailyMinutes,
    String? reciter,
    int? weeklyGoal,
    DateTime? createdAt,
  }) => UserPlan(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    quranSelectionType: quranSelectionType.present
        ? quranSelectionType.value
        : this.quranSelectionType,
    quranSelectionJson: quranSelectionJson.present
        ? quranSelectionJson.value
        : this.quranSelectionJson,
    direction: direction ?? this.direction,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    reciter: reciter ?? this.reciter,
    weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    createdAt: createdAt ?? this.createdAt,
  );
  UserPlan copyWithCompanion(UserPlansCompanion data) {
    return UserPlan(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      quranSelectionType: data.quranSelectionType.present
          ? data.quranSelectionType.value
          : this.quranSelectionType,
      quranSelectionJson: data.quranSelectionJson.present
          ? data.quranSelectionJson.value
          : this.quranSelectionJson,
      direction: data.direction.present ? data.direction.value : this.direction,
      dailyMinutes: data.dailyMinutes.present
          ? data.dailyMinutes.value
          : this.dailyMinutes,
      reciter: data.reciter.present ? data.reciter.value : this.reciter,
      weeklyGoal: data.weeklyGoal.present
          ? data.weeklyGoal.value
          : this.weeklyGoal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPlan(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('quranSelectionType: $quranSelectionType, ')
          ..write('quranSelectionJson: $quranSelectionJson, ')
          ..write('direction: $direction, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('reciter: $reciter, ')
          ..write('weeklyGoal: $weeklyGoal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scope,
    quranSelectionType,
    quranSelectionJson,
    direction,
    dailyMinutes,
    reciter,
    weeklyGoal,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlan &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.quranSelectionType == this.quranSelectionType &&
          other.quranSelectionJson == this.quranSelectionJson &&
          other.direction == this.direction &&
          other.dailyMinutes == this.dailyMinutes &&
          other.reciter == this.reciter &&
          other.weeklyGoal == this.weeklyGoal &&
          other.createdAt == this.createdAt);
}

class UserPlansCompanion extends UpdateCompanion<UserPlan> {
  final Value<int> id;
  final Value<String> scope;
  final Value<String?> quranSelectionType;
  final Value<String?> quranSelectionJson;
  final Value<String> direction;
  final Value<int> dailyMinutes;
  final Value<String> reciter;
  final Value<int> weeklyGoal;
  final Value<DateTime> createdAt;
  const UserPlansCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.quranSelectionType = const Value.absent(),
    this.quranSelectionJson = const Value.absent(),
    this.direction = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    this.reciter = const Value.absent(),
    this.weeklyGoal = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserPlansCompanion.insert({
    this.id = const Value.absent(),
    required String scope,
    this.quranSelectionType = const Value.absent(),
    this.quranSelectionJson = const Value.absent(),
    this.direction = const Value.absent(),
    required int dailyMinutes,
    this.reciter = const Value.absent(),
    this.weeklyGoal = const Value.absent(),
    required DateTime createdAt,
  }) : scope = Value(scope),
       dailyMinutes = Value(dailyMinutes),
       createdAt = Value(createdAt);
  static Insertable<UserPlan> custom({
    Expression<int>? id,
    Expression<String>? scope,
    Expression<String>? quranSelectionType,
    Expression<String>? quranSelectionJson,
    Expression<String>? direction,
    Expression<int>? dailyMinutes,
    Expression<String>? reciter,
    Expression<int>? weeklyGoal,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (quranSelectionType != null)
        'quran_selection_type': quranSelectionType,
      if (quranSelectionJson != null)
        'quran_selection_json': quranSelectionJson,
      if (direction != null) 'direction': direction,
      if (dailyMinutes != null) 'daily_minutes': dailyMinutes,
      if (reciter != null) 'reciter': reciter,
      if (weeklyGoal != null) 'weekly_goal': weeklyGoal,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserPlansCompanion copyWith({
    Value<int>? id,
    Value<String>? scope,
    Value<String?>? quranSelectionType,
    Value<String?>? quranSelectionJson,
    Value<String>? direction,
    Value<int>? dailyMinutes,
    Value<String>? reciter,
    Value<int>? weeklyGoal,
    Value<DateTime>? createdAt,
  }) {
    return UserPlansCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      quranSelectionType: quranSelectionType ?? this.quranSelectionType,
      quranSelectionJson: quranSelectionJson ?? this.quranSelectionJson,
      direction: direction ?? this.direction,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      reciter: reciter ?? this.reciter,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (quranSelectionType.present) {
      map['quran_selection_type'] = Variable<String>(quranSelectionType.value);
    }
    if (quranSelectionJson.present) {
      map['quran_selection_json'] = Variable<String>(quranSelectionJson.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (dailyMinutes.present) {
      map['daily_minutes'] = Variable<int>(dailyMinutes.value);
    }
    if (reciter.present) {
      map['reciter'] = Variable<String>(reciter.value);
    }
    if (weeklyGoal.present) {
      map['weekly_goal'] = Variable<int>(weeklyGoal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPlansCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('quranSelectionType: $quranSelectionType, ')
          ..write('quranSelectionJson: $quranSelectionJson, ')
          ..write('direction: $direction, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('reciter: $reciter, ')
          ..write('weeklyGoal: $weeklyGoal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SrsItemsTable extends SrsItems with TableInfo<$SrsItemsTable, SrsItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SrsItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentKeyMeta = const VerificationMeta(
    'contentKey',
  );
  @override
  late final GeneratedColumn<String> contentKey = GeneratedColumn<String>(
    'content_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _learningStepMeta = const VerificationMeta(
    'learningStep',
  );
  @override
  late final GeneratedColumn<int> learningStep = GeneratedColumn<int>(
    'learning_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _introducedAtMeta = const VerificationMeta(
    'introducedAt',
  );
  @override
  late final GeneratedColumn<DateTime> introducedAt = GeneratedColumn<DateTime>(
    'introduced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentType,
    contentKey,
    orderIndex,
    wordCount,
    status,
    easeFactor,
    intervalDays,
    repetitions,
    learningStep,
    dueDate,
    introducedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'srs_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SrsItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('content_key')) {
      context.handle(
        _contentKeyMeta,
        contentKey.isAcceptableOrUnknown(data['content_key']!, _contentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_contentKeyMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    } else if (isInserting) {
      context.missing(_wordCountMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('learning_step')) {
      context.handle(
        _learningStepMeta,
        learningStep.isAcceptableOrUnknown(
          data['learning_step']!,
          _learningStepMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('introduced_at')) {
      context.handle(
        _introducedAtMeta,
        introducedAt.isAcceptableOrUnknown(
          data['introduced_at']!,
          _introducedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SrsItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SrsItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      contentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_key'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      learningStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_step'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      introducedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}introduced_at'],
      ),
    );
  }

  @override
  $SrsItemsTable createAlias(String alias) {
    return $SrsItemsTable(attachedDatabase, alias);
  }
}

class SrsItem extends DataClass implements Insertable<SrsItem> {
  final int id;
  final String contentType;
  final String contentKey;
  final int orderIndex;
  final int wordCount;
  final String status;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final int learningStep;
  final DateTime? dueDate;
  final DateTime? introducedAt;
  const SrsItem({
    required this.id,
    required this.contentType,
    required this.contentKey,
    required this.orderIndex,
    required this.wordCount,
    required this.status,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.learningStep,
    this.dueDate,
    this.introducedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_type'] = Variable<String>(contentType);
    map['content_key'] = Variable<String>(contentKey);
    map['order_index'] = Variable<int>(orderIndex);
    map['word_count'] = Variable<int>(wordCount);
    map['status'] = Variable<String>(status);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval_days'] = Variable<int>(intervalDays);
    map['repetitions'] = Variable<int>(repetitions);
    map['learning_step'] = Variable<int>(learningStep);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || introducedAt != null) {
      map['introduced_at'] = Variable<DateTime>(introducedAt);
    }
    return map;
  }

  SrsItemsCompanion toCompanion(bool nullToAbsent) {
    return SrsItemsCompanion(
      id: Value(id),
      contentType: Value(contentType),
      contentKey: Value(contentKey),
      orderIndex: Value(orderIndex),
      wordCount: Value(wordCount),
      status: Value(status),
      easeFactor: Value(easeFactor),
      intervalDays: Value(intervalDays),
      repetitions: Value(repetitions),
      learningStep: Value(learningStep),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      introducedAt: introducedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(introducedAt),
    );
  }

  factory SrsItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SrsItem(
      id: serializer.fromJson<int>(json['id']),
      contentType: serializer.fromJson<String>(json['contentType']),
      contentKey: serializer.fromJson<String>(json['contentKey']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      status: serializer.fromJson<String>(json['status']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      learningStep: serializer.fromJson<int>(json['learningStep']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      introducedAt: serializer.fromJson<DateTime?>(json['introducedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentType': serializer.toJson<String>(contentType),
      'contentKey': serializer.toJson<String>(contentKey),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'wordCount': serializer.toJson<int>(wordCount),
      'status': serializer.toJson<String>(status),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'repetitions': serializer.toJson<int>(repetitions),
      'learningStep': serializer.toJson<int>(learningStep),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'introducedAt': serializer.toJson<DateTime?>(introducedAt),
    };
  }

  SrsItem copyWith({
    int? id,
    String? contentType,
    String? contentKey,
    int? orderIndex,
    int? wordCount,
    String? status,
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    int? learningStep,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> introducedAt = const Value.absent(),
  }) => SrsItem(
    id: id ?? this.id,
    contentType: contentType ?? this.contentType,
    contentKey: contentKey ?? this.contentKey,
    orderIndex: orderIndex ?? this.orderIndex,
    wordCount: wordCount ?? this.wordCount,
    status: status ?? this.status,
    easeFactor: easeFactor ?? this.easeFactor,
    intervalDays: intervalDays ?? this.intervalDays,
    repetitions: repetitions ?? this.repetitions,
    learningStep: learningStep ?? this.learningStep,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    introducedAt: introducedAt.present ? introducedAt.value : this.introducedAt,
  );
  SrsItem copyWithCompanion(SrsItemsCompanion data) {
    return SrsItem(
      id: data.id.present ? data.id.value : this.id,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      contentKey: data.contentKey.present
          ? data.contentKey.value
          : this.contentKey,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      status: data.status.present ? data.status.value : this.status,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      learningStep: data.learningStep.present
          ? data.learningStep.value
          : this.learningStep,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      introducedAt: data.introducedAt.present
          ? data.introducedAt.value
          : this.introducedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SrsItem(')
          ..write('id: $id, ')
          ..write('contentType: $contentType, ')
          ..write('contentKey: $contentKey, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('wordCount: $wordCount, ')
          ..write('status: $status, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions, ')
          ..write('learningStep: $learningStep, ')
          ..write('dueDate: $dueDate, ')
          ..write('introducedAt: $introducedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentType,
    contentKey,
    orderIndex,
    wordCount,
    status,
    easeFactor,
    intervalDays,
    repetitions,
    learningStep,
    dueDate,
    introducedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SrsItem &&
          other.id == this.id &&
          other.contentType == this.contentType &&
          other.contentKey == this.contentKey &&
          other.orderIndex == this.orderIndex &&
          other.wordCount == this.wordCount &&
          other.status == this.status &&
          other.easeFactor == this.easeFactor &&
          other.intervalDays == this.intervalDays &&
          other.repetitions == this.repetitions &&
          other.learningStep == this.learningStep &&
          other.dueDate == this.dueDate &&
          other.introducedAt == this.introducedAt);
}

class SrsItemsCompanion extends UpdateCompanion<SrsItem> {
  final Value<int> id;
  final Value<String> contentType;
  final Value<String> contentKey;
  final Value<int> orderIndex;
  final Value<int> wordCount;
  final Value<String> status;
  final Value<double> easeFactor;
  final Value<int> intervalDays;
  final Value<int> repetitions;
  final Value<int> learningStep;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> introducedAt;
  const SrsItemsCompanion({
    this.id = const Value.absent(),
    this.contentType = const Value.absent(),
    this.contentKey = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.status = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.learningStep = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.introducedAt = const Value.absent(),
  });
  SrsItemsCompanion.insert({
    this.id = const Value.absent(),
    required String contentType,
    required String contentKey,
    required int orderIndex,
    required int wordCount,
    this.status = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.learningStep = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.introducedAt = const Value.absent(),
  }) : contentType = Value(contentType),
       contentKey = Value(contentKey),
       orderIndex = Value(orderIndex),
       wordCount = Value(wordCount);
  static Insertable<SrsItem> custom({
    Expression<int>? id,
    Expression<String>? contentType,
    Expression<String>? contentKey,
    Expression<int>? orderIndex,
    Expression<int>? wordCount,
    Expression<String>? status,
    Expression<double>? easeFactor,
    Expression<int>? intervalDays,
    Expression<int>? repetitions,
    Expression<int>? learningStep,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? introducedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentType != null) 'content_type': contentType,
      if (contentKey != null) 'content_key': contentKey,
      if (orderIndex != null) 'order_index': orderIndex,
      if (wordCount != null) 'word_count': wordCount,
      if (status != null) 'status': status,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (repetitions != null) 'repetitions': repetitions,
      if (learningStep != null) 'learning_step': learningStep,
      if (dueDate != null) 'due_date': dueDate,
      if (introducedAt != null) 'introduced_at': introducedAt,
    });
  }

  SrsItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? contentType,
    Value<String>? contentKey,
    Value<int>? orderIndex,
    Value<int>? wordCount,
    Value<String>? status,
    Value<double>? easeFactor,
    Value<int>? intervalDays,
    Value<int>? repetitions,
    Value<int>? learningStep,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? introducedAt,
  }) {
    return SrsItemsCompanion(
      id: id ?? this.id,
      contentType: contentType ?? this.contentType,
      contentKey: contentKey ?? this.contentKey,
      orderIndex: orderIndex ?? this.orderIndex,
      wordCount: wordCount ?? this.wordCount,
      status: status ?? this.status,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      learningStep: learningStep ?? this.learningStep,
      dueDate: dueDate ?? this.dueDate,
      introducedAt: introducedAt ?? this.introducedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (contentKey.present) {
      map['content_key'] = Variable<String>(contentKey.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (learningStep.present) {
      map['learning_step'] = Variable<int>(learningStep.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (introducedAt.present) {
      map['introduced_at'] = Variable<DateTime>(introducedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SrsItemsCompanion(')
          ..write('id: $id, ')
          ..write('contentType: $contentType, ')
          ..write('contentKey: $contentKey, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('wordCount: $wordCount, ')
          ..write('status: $status, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions, ')
          ..write('learningStep: $learningStep, ')
          ..write('dueDate: $dueDate, ')
          ..write('introducedAt: $introducedAt')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTable extends ReviewLogs
    with TableInfo<$ReviewLogsTable, ReviewLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES srs_items (id)',
    ),
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalBeforeMeta = const VerificationMeta(
    'intervalBefore',
  );
  @override
  late final GeneratedColumn<int> intervalBefore = GeneratedColumn<int>(
    'interval_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalAfterMeta = const VerificationMeta(
    'intervalAfter',
  );
  @override
  late final GeneratedColumn<int> intervalAfter = GeneratedColumn<int>(
    'interval_after',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    reviewedAt,
    grade,
    intervalBefore,
    intervalAfter,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('interval_before')) {
      context.handle(
        _intervalBeforeMeta,
        intervalBefore.isAcceptableOrUnknown(
          data['interval_before']!,
          _intervalBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalBeforeMeta);
    }
    if (data.containsKey('interval_after')) {
      context.handle(
        _intervalAfterMeta,
        intervalAfter.isAcceptableOrUnknown(
          data['interval_after']!,
          _intervalAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalAfterMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      )!,
      intervalBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_before'],
      )!,
      intervalAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_after'],
      )!,
    );
  }

  @override
  $ReviewLogsTable createAlias(String alias) {
    return $ReviewLogsTable(attachedDatabase, alias);
  }
}

class ReviewLog extends DataClass implements Insertable<ReviewLog> {
  final int id;
  final int itemId;
  final DateTime reviewedAt;
  final int grade;
  final int intervalBefore;
  final int intervalAfter;
  const ReviewLog({
    required this.id,
    required this.itemId,
    required this.reviewedAt,
    required this.grade,
    required this.intervalBefore,
    required this.intervalAfter,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    map['grade'] = Variable<int>(grade);
    map['interval_before'] = Variable<int>(intervalBefore);
    map['interval_after'] = Variable<int>(intervalAfter);
    return map;
  }

  ReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      reviewedAt: Value(reviewedAt),
      grade: Value(grade),
      intervalBefore: Value(intervalBefore),
      intervalAfter: Value(intervalAfter),
    );
  }

  factory ReviewLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLog(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
      grade: serializer.fromJson<int>(json['grade']),
      intervalBefore: serializer.fromJson<int>(json['intervalBefore']),
      intervalAfter: serializer.fromJson<int>(json['intervalAfter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
      'grade': serializer.toJson<int>(grade),
      'intervalBefore': serializer.toJson<int>(intervalBefore),
      'intervalAfter': serializer.toJson<int>(intervalAfter),
    };
  }

  ReviewLog copyWith({
    int? id,
    int? itemId,
    DateTime? reviewedAt,
    int? grade,
    int? intervalBefore,
    int? intervalAfter,
  }) => ReviewLog(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    grade: grade ?? this.grade,
    intervalBefore: intervalBefore ?? this.intervalBefore,
    intervalAfter: intervalAfter ?? this.intervalAfter,
  );
  ReviewLog copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLog(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      grade: data.grade.present ? data.grade.value : this.grade,
      intervalBefore: data.intervalBefore.present
          ? data.intervalBefore.value
          : this.intervalBefore,
      intervalAfter: data.intervalAfter.present
          ? data.intervalAfter.value
          : this.intervalAfter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLog(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('grade: $grade, ')
          ..write('intervalBefore: $intervalBefore, ')
          ..write('intervalAfter: $intervalAfter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, reviewedAt, grade, intervalBefore, intervalAfter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLog &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.reviewedAt == this.reviewedAt &&
          other.grade == this.grade &&
          other.intervalBefore == this.intervalBefore &&
          other.intervalAfter == this.intervalAfter);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLog> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<DateTime> reviewedAt;
  final Value<int> grade;
  final Value<int> intervalBefore;
  final Value<int> intervalAfter;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.grade = const Value.absent(),
    this.intervalBefore = const Value.absent(),
    this.intervalAfter = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    required DateTime reviewedAt,
    required int grade,
    required int intervalBefore,
    required int intervalAfter,
  }) : itemId = Value(itemId),
       reviewedAt = Value(reviewedAt),
       grade = Value(grade),
       intervalBefore = Value(intervalBefore),
       intervalAfter = Value(intervalAfter);
  static Insertable<ReviewLog> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<DateTime>? reviewedAt,
    Expression<int>? grade,
    Expression<int>? intervalBefore,
    Expression<int>? intervalAfter,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (grade != null) 'grade': grade,
      if (intervalBefore != null) 'interval_before': intervalBefore,
      if (intervalAfter != null) 'interval_after': intervalAfter,
    });
  }

  ReviewLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? itemId,
    Value<DateTime>? reviewedAt,
    Value<int>? grade,
    Value<int>? intervalBefore,
    Value<int>? intervalAfter,
  }) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      grade: grade ?? this.grade,
      intervalBefore: intervalBefore ?? this.intervalBefore,
      intervalAfter: intervalAfter ?? this.intervalAfter,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (intervalBefore.present) {
      map['interval_before'] = Variable<int>(intervalBefore.value);
    }
    if (intervalAfter.present) {
      map['interval_after'] = Variable<int>(intervalAfter.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('grade: $grade, ')
          ..write('intervalBefore: $intervalBefore, ')
          ..write('intervalAfter: $intervalAfter')
          ..write(')'))
        .toString();
  }
}

class $DailySessionsTable extends DailySessions
    with TableInfo<$DailySessionsTable, DailySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newItemsPlannedMeta = const VerificationMeta(
    'newItemsPlanned',
  );
  @override
  late final GeneratedColumn<int> newItemsPlanned = GeneratedColumn<int>(
    'new_items_planned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newItemsDoneMeta = const VerificationMeta(
    'newItemsDone',
  );
  @override
  late final GeneratedColumn<int> newItemsDone = GeneratedColumn<int>(
    'new_items_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewsPlannedMeta = const VerificationMeta(
    'reviewsPlanned',
  );
  @override
  late final GeneratedColumn<int> reviewsPlanned = GeneratedColumn<int>(
    'reviews_planned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewsDoneMeta = const VerificationMeta(
    'reviewsDone',
  );
  @override
  late final GeneratedColumn<int> reviewsDone = GeneratedColumn<int>(
    'reviews_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    newItemsPlanned,
    newItemsDone,
    reviewsPlanned,
    reviewsDone,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('new_items_planned')) {
      context.handle(
        _newItemsPlannedMeta,
        newItemsPlanned.isAcceptableOrUnknown(
          data['new_items_planned']!,
          _newItemsPlannedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newItemsPlannedMeta);
    }
    if (data.containsKey('new_items_done')) {
      context.handle(
        _newItemsDoneMeta,
        newItemsDone.isAcceptableOrUnknown(
          data['new_items_done']!,
          _newItemsDoneMeta,
        ),
      );
    }
    if (data.containsKey('reviews_planned')) {
      context.handle(
        _reviewsPlannedMeta,
        reviewsPlanned.isAcceptableOrUnknown(
          data['reviews_planned']!,
          _reviewsPlannedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewsPlannedMeta);
    }
    if (data.containsKey('reviews_done')) {
      context.handle(
        _reviewsDoneMeta,
        reviewsDone.isAcceptableOrUnknown(
          data['reviews_done']!,
          _reviewsDoneMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySession(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      newItemsPlanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_items_planned'],
      )!,
      newItemsDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_items_done'],
      )!,
      reviewsPlanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviews_planned'],
      )!,
      reviewsDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviews_done'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $DailySessionsTable createAlias(String alias) {
    return $DailySessionsTable(attachedDatabase, alias);
  }
}

class DailySession extends DataClass implements Insertable<DailySession> {
  final String day;
  final int newItemsPlanned;
  final int newItemsDone;
  final int reviewsPlanned;
  final int reviewsDone;
  final bool completed;
  const DailySession({
    required this.day,
    required this.newItemsPlanned,
    required this.newItemsDone,
    required this.reviewsPlanned,
    required this.reviewsDone,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['new_items_planned'] = Variable<int>(newItemsPlanned);
    map['new_items_done'] = Variable<int>(newItemsDone);
    map['reviews_planned'] = Variable<int>(reviewsPlanned);
    map['reviews_done'] = Variable<int>(reviewsDone);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  DailySessionsCompanion toCompanion(bool nullToAbsent) {
    return DailySessionsCompanion(
      day: Value(day),
      newItemsPlanned: Value(newItemsPlanned),
      newItemsDone: Value(newItemsDone),
      reviewsPlanned: Value(reviewsPlanned),
      reviewsDone: Value(reviewsDone),
      completed: Value(completed),
    );
  }

  factory DailySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySession(
      day: serializer.fromJson<String>(json['day']),
      newItemsPlanned: serializer.fromJson<int>(json['newItemsPlanned']),
      newItemsDone: serializer.fromJson<int>(json['newItemsDone']),
      reviewsPlanned: serializer.fromJson<int>(json['reviewsPlanned']),
      reviewsDone: serializer.fromJson<int>(json['reviewsDone']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'newItemsPlanned': serializer.toJson<int>(newItemsPlanned),
      'newItemsDone': serializer.toJson<int>(newItemsDone),
      'reviewsPlanned': serializer.toJson<int>(reviewsPlanned),
      'reviewsDone': serializer.toJson<int>(reviewsDone),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  DailySession copyWith({
    String? day,
    int? newItemsPlanned,
    int? newItemsDone,
    int? reviewsPlanned,
    int? reviewsDone,
    bool? completed,
  }) => DailySession(
    day: day ?? this.day,
    newItemsPlanned: newItemsPlanned ?? this.newItemsPlanned,
    newItemsDone: newItemsDone ?? this.newItemsDone,
    reviewsPlanned: reviewsPlanned ?? this.reviewsPlanned,
    reviewsDone: reviewsDone ?? this.reviewsDone,
    completed: completed ?? this.completed,
  );
  DailySession copyWithCompanion(DailySessionsCompanion data) {
    return DailySession(
      day: data.day.present ? data.day.value : this.day,
      newItemsPlanned: data.newItemsPlanned.present
          ? data.newItemsPlanned.value
          : this.newItemsPlanned,
      newItemsDone: data.newItemsDone.present
          ? data.newItemsDone.value
          : this.newItemsDone,
      reviewsPlanned: data.reviewsPlanned.present
          ? data.reviewsPlanned.value
          : this.reviewsPlanned,
      reviewsDone: data.reviewsDone.present
          ? data.reviewsDone.value
          : this.reviewsDone,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySession(')
          ..write('day: $day, ')
          ..write('newItemsPlanned: $newItemsPlanned, ')
          ..write('newItemsDone: $newItemsDone, ')
          ..write('reviewsPlanned: $reviewsPlanned, ')
          ..write('reviewsDone: $reviewsDone, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    day,
    newItemsPlanned,
    newItemsDone,
    reviewsPlanned,
    reviewsDone,
    completed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySession &&
          other.day == this.day &&
          other.newItemsPlanned == this.newItemsPlanned &&
          other.newItemsDone == this.newItemsDone &&
          other.reviewsPlanned == this.reviewsPlanned &&
          other.reviewsDone == this.reviewsDone &&
          other.completed == this.completed);
}

class DailySessionsCompanion extends UpdateCompanion<DailySession> {
  final Value<String> day;
  final Value<int> newItemsPlanned;
  final Value<int> newItemsDone;
  final Value<int> reviewsPlanned;
  final Value<int> reviewsDone;
  final Value<bool> completed;
  final Value<int> rowid;
  const DailySessionsCompanion({
    this.day = const Value.absent(),
    this.newItemsPlanned = const Value.absent(),
    this.newItemsDone = const Value.absent(),
    this.reviewsPlanned = const Value.absent(),
    this.reviewsDone = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySessionsCompanion.insert({
    required String day,
    required int newItemsPlanned,
    this.newItemsDone = const Value.absent(),
    required int reviewsPlanned,
    this.reviewsDone = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       newItemsPlanned = Value(newItemsPlanned),
       reviewsPlanned = Value(reviewsPlanned);
  static Insertable<DailySession> custom({
    Expression<String>? day,
    Expression<int>? newItemsPlanned,
    Expression<int>? newItemsDone,
    Expression<int>? reviewsPlanned,
    Expression<int>? reviewsDone,
    Expression<bool>? completed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (newItemsPlanned != null) 'new_items_planned': newItemsPlanned,
      if (newItemsDone != null) 'new_items_done': newItemsDone,
      if (reviewsPlanned != null) 'reviews_planned': reviewsPlanned,
      if (reviewsDone != null) 'reviews_done': reviewsDone,
      if (completed != null) 'completed': completed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySessionsCompanion copyWith({
    Value<String>? day,
    Value<int>? newItemsPlanned,
    Value<int>? newItemsDone,
    Value<int>? reviewsPlanned,
    Value<int>? reviewsDone,
    Value<bool>? completed,
    Value<int>? rowid,
  }) {
    return DailySessionsCompanion(
      day: day ?? this.day,
      newItemsPlanned: newItemsPlanned ?? this.newItemsPlanned,
      newItemsDone: newItemsDone ?? this.newItemsDone,
      reviewsPlanned: reviewsPlanned ?? this.reviewsPlanned,
      reviewsDone: reviewsDone ?? this.reviewsDone,
      completed: completed ?? this.completed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (newItemsPlanned.present) {
      map['new_items_planned'] = Variable<int>(newItemsPlanned.value);
    }
    if (newItemsDone.present) {
      map['new_items_done'] = Variable<int>(newItemsDone.value);
    }
    if (reviewsPlanned.present) {
      map['reviews_planned'] = Variable<int>(reviewsPlanned.value);
    }
    if (reviewsDone.present) {
      map['reviews_done'] = Variable<int>(reviewsDone.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySessionsCompanion(')
          ..write('day: $day, ')
          ..write('newItemsPlanned: $newItemsPlanned, ')
          ..write('newItemsDone: $newItemsDone, ')
          ..write('reviewsPlanned: $reviewsPlanned, ')
          ..write('reviewsDone: $reviewsDone, ')
          ..write('completed: $completed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [achievementId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementId};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      achievementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String achievementId;
  final DateTime unlockedAt;
  const Achievement({required this.achievementId, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['achievement_id'] = Variable<String>(achievementId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      achievementId: Value(achievementId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      achievementId: serializer.fromJson<String>(json['achievementId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'achievementId': serializer.toJson<String>(achievementId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  Achievement copyWith({String? achievementId, DateTime? unlockedAt}) =>
      Achievement(
        achievementId: achievementId ?? this.achievementId,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('achievementId: $achievementId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(achievementId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.achievementId == this.achievementId &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> achievementId;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.achievementId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String achievementId,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : achievementId = Value(achievementId),
       unlockedAt = Value(unlockedAt);
  static Insertable<Achievement> custom({
    Expression<String>? achievementId,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementId != null) 'achievement_id': achievementId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? achievementId,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('achievementId: $achievementId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreakStateTable extends StreakState
    with TableInfo<$StreakStateTable, StreakStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _freezeTokensMeta = const VerificationMeta(
    'freezeTokens',
  );
  @override
  late final GeneratedColumn<int> freezeTokens = GeneratedColumn<int>(
    'freeze_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCompletedDayMeta = const VerificationMeta(
    'lastCompletedDay',
  );
  @override
  late final GeneratedColumn<DateTime> lastCompletedDay =
      GeneratedColumn<DateTime>(
        'last_completed_day',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentStreak,
    longestStreak,
    freezeTokens,
    lastCompletedDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('freeze_tokens')) {
      context.handle(
        _freezeTokensMeta,
        freezeTokens.isAcceptableOrUnknown(
          data['freeze_tokens']!,
          _freezeTokensMeta,
        ),
      );
    }
    if (data.containsKey('last_completed_day')) {
      context.handle(
        _lastCompletedDayMeta,
        lastCompletedDay.isAcceptableOrUnknown(
          data['last_completed_day']!,
          _lastCompletedDayMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreakStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      freezeTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freeze_tokens'],
      )!,
      lastCompletedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_day'],
      ),
    );
  }

  @override
  $StreakStateTable createAlias(String alias) {
    return $StreakStateTable(attachedDatabase, alias);
  }
}

class StreakStateData extends DataClass implements Insertable<StreakStateData> {
  final int id;
  final int currentStreak;
  final int longestStreak;
  final int freezeTokens;
  final DateTime? lastCompletedDay;
  const StreakStateData({
    required this.id,
    required this.currentStreak,
    required this.longestStreak,
    required this.freezeTokens,
    this.lastCompletedDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    map['freeze_tokens'] = Variable<int>(freezeTokens);
    if (!nullToAbsent || lastCompletedDay != null) {
      map['last_completed_day'] = Variable<DateTime>(lastCompletedDay);
    }
    return map;
  }

  StreakStateCompanion toCompanion(bool nullToAbsent) {
    return StreakStateCompanion(
      id: Value(id),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      freezeTokens: Value(freezeTokens),
      lastCompletedDay: lastCompletedDay == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedDay),
    );
  }

  factory StreakStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakStateData(
      id: serializer.fromJson<int>(json['id']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      freezeTokens: serializer.fromJson<int>(json['freezeTokens']),
      lastCompletedDay: serializer.fromJson<DateTime?>(
        json['lastCompletedDay'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'freezeTokens': serializer.toJson<int>(freezeTokens),
      'lastCompletedDay': serializer.toJson<DateTime?>(lastCompletedDay),
    };
  }

  StreakStateData copyWith({
    int? id,
    int? currentStreak,
    int? longestStreak,
    int? freezeTokens,
    Value<DateTime?> lastCompletedDay = const Value.absent(),
  }) => StreakStateData(
    id: id ?? this.id,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    freezeTokens: freezeTokens ?? this.freezeTokens,
    lastCompletedDay: lastCompletedDay.present
        ? lastCompletedDay.value
        : this.lastCompletedDay,
  );
  StreakStateData copyWithCompanion(StreakStateCompanion data) {
    return StreakStateData(
      id: data.id.present ? data.id.value : this.id,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      freezeTokens: data.freezeTokens.present
          ? data.freezeTokens.value
          : this.freezeTokens,
      lastCompletedDay: data.lastCompletedDay.present
          ? data.lastCompletedDay.value
          : this.lastCompletedDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakStateData(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('freezeTokens: $freezeTokens, ')
          ..write('lastCompletedDay: $lastCompletedDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentStreak,
    longestStreak,
    freezeTokens,
    lastCompletedDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakStateData &&
          other.id == this.id &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.freezeTokens == this.freezeTokens &&
          other.lastCompletedDay == this.lastCompletedDay);
}

class StreakStateCompanion extends UpdateCompanion<StreakStateData> {
  final Value<int> id;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<int> freezeTokens;
  final Value<DateTime?> lastCompletedDay;
  const StreakStateCompanion({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.freezeTokens = const Value.absent(),
    this.lastCompletedDay = const Value.absent(),
  });
  StreakStateCompanion.insert({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.freezeTokens = const Value.absent(),
    this.lastCompletedDay = const Value.absent(),
  });
  static Insertable<StreakStateData> custom({
    Expression<int>? id,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<int>? freezeTokens,
    Expression<DateTime>? lastCompletedDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (freezeTokens != null) 'freeze_tokens': freezeTokens,
      if (lastCompletedDay != null) 'last_completed_day': lastCompletedDay,
    });
  }

  StreakStateCompanion copyWith({
    Value<int>? id,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<int>? freezeTokens,
    Value<DateTime?>? lastCompletedDay,
  }) {
    return StreakStateCompanion(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      freezeTokens: freezeTokens ?? this.freezeTokens,
      lastCompletedDay: lastCompletedDay ?? this.lastCompletedDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (freezeTokens.present) {
      map['freeze_tokens'] = Variable<int>(freezeTokens.value);
    }
    if (lastCompletedDay.present) {
      map['last_completed_day'] = Variable<DateTime>(lastCompletedDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakStateCompanion(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('freezeTokens: $freezeTokens, ')
          ..write('lastCompletedDay: $lastCompletedDay')
          ..write(')'))
        .toString();
  }
}

class $DuaSelectionsTable extends DuaSelections
    with TableInfo<$DuaSelectionsTable, DuaSelection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DuaSelectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _duaIdMeta = const VerificationMeta('duaId');
  @override
  late final GeneratedColumn<String> duaId = GeneratedColumn<String>(
    'dua_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [duaId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dua_selections';
  @override
  VerificationContext validateIntegrity(
    Insertable<DuaSelection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dua_id')) {
      context.handle(
        _duaIdMeta,
        duaId.isAcceptableOrUnknown(data['dua_id']!, _duaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_duaIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {duaId};
  @override
  DuaSelection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DuaSelection(
      duaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dua_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $DuaSelectionsTable createAlias(String alias) {
    return $DuaSelectionsTable(attachedDatabase, alias);
  }
}

class DuaSelection extends DataClass implements Insertable<DuaSelection> {
  final String duaId;
  final DateTime addedAt;
  const DuaSelection({required this.duaId, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dua_id'] = Variable<String>(duaId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  DuaSelectionsCompanion toCompanion(bool nullToAbsent) {
    return DuaSelectionsCompanion(duaId: Value(duaId), addedAt: Value(addedAt));
  }

  factory DuaSelection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DuaSelection(
      duaId: serializer.fromJson<String>(json['duaId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'duaId': serializer.toJson<String>(duaId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  DuaSelection copyWith({String? duaId, DateTime? addedAt}) => DuaSelection(
    duaId: duaId ?? this.duaId,
    addedAt: addedAt ?? this.addedAt,
  );
  DuaSelection copyWithCompanion(DuaSelectionsCompanion data) {
    return DuaSelection(
      duaId: data.duaId.present ? data.duaId.value : this.duaId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DuaSelection(')
          ..write('duaId: $duaId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(duaId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DuaSelection &&
          other.duaId == this.duaId &&
          other.addedAt == this.addedAt);
}

class DuaSelectionsCompanion extends UpdateCompanion<DuaSelection> {
  final Value<String> duaId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const DuaSelectionsCompanion({
    this.duaId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DuaSelectionsCompanion.insert({
    required String duaId,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : duaId = Value(duaId),
       addedAt = Value(addedAt);
  static Insertable<DuaSelection> custom({
    Expression<String>? duaId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (duaId != null) 'dua_id': duaId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DuaSelectionsCompanion copyWith({
    Value<String>? duaId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return DuaSelectionsCompanion(
      duaId: duaId ?? this.duaId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (duaId.present) {
      map['dua_id'] = Variable<String>(duaId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DuaSelectionsCompanion(')
          ..write('duaId: $duaId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadStateTable extends DownloadState
    with TableInfo<$DownloadStateTable, DownloadStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('notDownloaded'),
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<String> quality = GeneratedColumn<String>(
    'quality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reciterMeta = const VerificationMeta(
    'reciter',
  );
  @override
  late final GeneratedColumn<String> reciter = GeneratedColumn<String>(
    'reciter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    surahNumber,
    status,
    quality,
    reciter,
    progress,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('reciter')) {
      context.handle(
        _reciterMeta,
        reciter.isAcceptableOrUnknown(data['reciter']!, _reciterMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surahNumber};
  @override
  DownloadStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadStateData(
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality'],
      ),
      reciter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reciter'],
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $DownloadStateTable createAlias(String alias) {
    return $DownloadStateTable(attachedDatabase, alias);
  }
}

class DownloadStateData extends DataClass
    implements Insertable<DownloadStateData> {
  final int surahNumber;
  final String status;
  final String? quality;
  final String? reciter;
  final double progress;
  final DateTime? updatedAt;
  const DownloadStateData({
    required this.surahNumber,
    required this.status,
    this.quality,
    this.reciter,
    required this.progress,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah_number'] = Variable<int>(surahNumber);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<String>(quality);
    }
    if (!nullToAbsent || reciter != null) {
      map['reciter'] = Variable<String>(reciter);
    }
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  DownloadStateCompanion toCompanion(bool nullToAbsent) {
    return DownloadStateCompanion(
      surahNumber: Value(surahNumber),
      status: Value(status),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      reciter: reciter == null && nullToAbsent
          ? const Value.absent()
          : Value(reciter),
      progress: Value(progress),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DownloadStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadStateData(
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      status: serializer.fromJson<String>(json['status']),
      quality: serializer.fromJson<String?>(json['quality']),
      reciter: serializer.fromJson<String?>(json['reciter']),
      progress: serializer.fromJson<double>(json['progress']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surahNumber': serializer.toJson<int>(surahNumber),
      'status': serializer.toJson<String>(status),
      'quality': serializer.toJson<String?>(quality),
      'reciter': serializer.toJson<String?>(reciter),
      'progress': serializer.toJson<double>(progress),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  DownloadStateData copyWith({
    int? surahNumber,
    String? status,
    Value<String?> quality = const Value.absent(),
    Value<String?> reciter = const Value.absent(),
    double? progress,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => DownloadStateData(
    surahNumber: surahNumber ?? this.surahNumber,
    status: status ?? this.status,
    quality: quality.present ? quality.value : this.quality,
    reciter: reciter.present ? reciter.value : this.reciter,
    progress: progress ?? this.progress,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DownloadStateData copyWithCompanion(DownloadStateCompanion data) {
    return DownloadStateData(
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      status: data.status.present ? data.status.value : this.status,
      quality: data.quality.present ? data.quality.value : this.quality,
      reciter: data.reciter.present ? data.reciter.value : this.reciter,
      progress: data.progress.present ? data.progress.value : this.progress,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadStateData(')
          ..write('surahNumber: $surahNumber, ')
          ..write('status: $status, ')
          ..write('quality: $quality, ')
          ..write('reciter: $reciter, ')
          ..write('progress: $progress, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(surahNumber, status, quality, reciter, progress, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadStateData &&
          other.surahNumber == this.surahNumber &&
          other.status == this.status &&
          other.quality == this.quality &&
          other.reciter == this.reciter &&
          other.progress == this.progress &&
          other.updatedAt == this.updatedAt);
}

class DownloadStateCompanion extends UpdateCompanion<DownloadStateData> {
  final Value<int> surahNumber;
  final Value<String> status;
  final Value<String?> quality;
  final Value<String?> reciter;
  final Value<double> progress;
  final Value<DateTime?> updatedAt;
  const DownloadStateCompanion({
    this.surahNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.quality = const Value.absent(),
    this.reciter = const Value.absent(),
    this.progress = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DownloadStateCompanion.insert({
    this.surahNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.quality = const Value.absent(),
    this.reciter = const Value.absent(),
    this.progress = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<DownloadStateData> custom({
    Expression<int>? surahNumber,
    Expression<String>? status,
    Expression<String>? quality,
    Expression<String>? reciter,
    Expression<double>? progress,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (surahNumber != null) 'surah_number': surahNumber,
      if (status != null) 'status': status,
      if (quality != null) 'quality': quality,
      if (reciter != null) 'reciter': reciter,
      if (progress != null) 'progress': progress,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DownloadStateCompanion copyWith({
    Value<int>? surahNumber,
    Value<String>? status,
    Value<String?>? quality,
    Value<String?>? reciter,
    Value<double>? progress,
    Value<DateTime?>? updatedAt,
  }) {
    return DownloadStateCompanion(
      surahNumber: surahNumber ?? this.surahNumber,
      status: status ?? this.status,
      quality: quality ?? this.quality,
      reciter: reciter ?? this.reciter,
      progress: progress ?? this.progress,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(quality.value);
    }
    if (reciter.present) {
      map['reciter'] = Variable<String>(reciter.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadStateCompanion(')
          ..write('surahNumber: $surahNumber, ')
          ..write('status: $status, ')
          ..write('quality: $quality, ')
          ..write('reciter: $reciter, ')
          ..write('progress: $progress, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ContentPacksTable extends ContentPacks
    with TableInfo<$ContentPacksTable, ContentPack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentPacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageOrCollectionMeta =
      const VerificationMeta('languageOrCollection');
  @override
  late final GeneratedColumn<String> languageOrCollection =
      GeneratedColumn<String>(
        'language_or_collection',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _editionOrCollectionMeta =
      const VerificationMeta('editionOrCollection');
  @override
  late final GeneratedColumn<String> editionOrCollection =
      GeneratedColumn<String>(
        'edition_or_collection',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('notDownloaded'),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    languageOrCollection,
    editionOrCollection,
    status,
    progress,
    sha256,
    installedAt,
    data,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentPack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('language_or_collection')) {
      context.handle(
        _languageOrCollectionMeta,
        languageOrCollection.isAcceptableOrUnknown(
          data['language_or_collection']!,
          _languageOrCollectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageOrCollectionMeta);
    }
    if (data.containsKey('edition_or_collection')) {
      context.handle(
        _editionOrCollectionMeta,
        editionOrCollection.isAcceptableOrUnknown(
          data['edition_or_collection']!,
          _editionOrCollectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_editionOrCollectionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {type, editionOrCollection},
  ];
  @override
  ContentPack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentPack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      languageOrCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_or_collection'],
      )!,
      editionOrCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition_or_collection'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
    );
  }

  @override
  $ContentPacksTable createAlias(String alias) {
    return $ContentPacksTable(attachedDatabase, alias);
  }
}

class ContentPack extends DataClass implements Insertable<ContentPack> {
  final int id;
  final String type;
  final String languageOrCollection;
  final String editionOrCollection;
  final String status;
  final double progress;
  final String? sha256;
  final DateTime? installedAt;
  final String? data;
  const ContentPack({
    required this.id,
    required this.type,
    required this.languageOrCollection,
    required this.editionOrCollection,
    required this.status,
    required this.progress,
    this.sha256,
    this.installedAt,
    this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['language_or_collection'] = Variable<String>(languageOrCollection);
    map['edition_or_collection'] = Variable<String>(editionOrCollection);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<DateTime>(installedAt);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    return map;
  }

  ContentPacksCompanion toCompanion(bool nullToAbsent) {
    return ContentPacksCompanion(
      id: Value(id),
      type: Value(type),
      languageOrCollection: Value(languageOrCollection),
      editionOrCollection: Value(editionOrCollection),
      status: Value(status),
      progress: Value(progress),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      installedAt: installedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAt),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
    );
  }

  factory ContentPack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentPack(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      languageOrCollection: serializer.fromJson<String>(
        json['languageOrCollection'],
      ),
      editionOrCollection: serializer.fromJson<String>(
        json['editionOrCollection'],
      ),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      installedAt: serializer.fromJson<DateTime?>(json['installedAt']),
      data: serializer.fromJson<String?>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'languageOrCollection': serializer.toJson<String>(languageOrCollection),
      'editionOrCollection': serializer.toJson<String>(editionOrCollection),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'sha256': serializer.toJson<String?>(sha256),
      'installedAt': serializer.toJson<DateTime?>(installedAt),
      'data': serializer.toJson<String?>(data),
    };
  }

  ContentPack copyWith({
    int? id,
    String? type,
    String? languageOrCollection,
    String? editionOrCollection,
    String? status,
    double? progress,
    Value<String?> sha256 = const Value.absent(),
    Value<DateTime?> installedAt = const Value.absent(),
    Value<String?> data = const Value.absent(),
  }) => ContentPack(
    id: id ?? this.id,
    type: type ?? this.type,
    languageOrCollection: languageOrCollection ?? this.languageOrCollection,
    editionOrCollection: editionOrCollection ?? this.editionOrCollection,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    sha256: sha256.present ? sha256.value : this.sha256,
    installedAt: installedAt.present ? installedAt.value : this.installedAt,
    data: data.present ? data.value : this.data,
  );
  ContentPack copyWithCompanion(ContentPacksCompanion data) {
    return ContentPack(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      languageOrCollection: data.languageOrCollection.present
          ? data.languageOrCollection.value
          : this.languageOrCollection,
      editionOrCollection: data.editionOrCollection.present
          ? data.editionOrCollection.value
          : this.editionOrCollection,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentPack(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('languageOrCollection: $languageOrCollection, ')
          ..write('editionOrCollection: $editionOrCollection, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('sha256: $sha256, ')
          ..write('installedAt: $installedAt, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    languageOrCollection,
    editionOrCollection,
    status,
    progress,
    sha256,
    installedAt,
    data,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentPack &&
          other.id == this.id &&
          other.type == this.type &&
          other.languageOrCollection == this.languageOrCollection &&
          other.editionOrCollection == this.editionOrCollection &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.sha256 == this.sha256 &&
          other.installedAt == this.installedAt &&
          other.data == this.data);
}

class ContentPacksCompanion extends UpdateCompanion<ContentPack> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> languageOrCollection;
  final Value<String> editionOrCollection;
  final Value<String> status;
  final Value<double> progress;
  final Value<String?> sha256;
  final Value<DateTime?> installedAt;
  final Value<String?> data;
  const ContentPacksCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.languageOrCollection = const Value.absent(),
    this.editionOrCollection = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.data = const Value.absent(),
  });
  ContentPacksCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String languageOrCollection,
    required String editionOrCollection,
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.data = const Value.absent(),
  }) : type = Value(type),
       languageOrCollection = Value(languageOrCollection),
       editionOrCollection = Value(editionOrCollection);
  static Insertable<ContentPack> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? languageOrCollection,
    Expression<String>? editionOrCollection,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<String>? sha256,
    Expression<DateTime>? installedAt,
    Expression<String>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (languageOrCollection != null)
        'language_or_collection': languageOrCollection,
      if (editionOrCollection != null)
        'edition_or_collection': editionOrCollection,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (sha256 != null) 'sha256': sha256,
      if (installedAt != null) 'installed_at': installedAt,
      if (data != null) 'data': data,
    });
  }

  ContentPacksCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? languageOrCollection,
    Value<String>? editionOrCollection,
    Value<String>? status,
    Value<double>? progress,
    Value<String?>? sha256,
    Value<DateTime?>? installedAt,
    Value<String?>? data,
  }) {
    return ContentPacksCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      languageOrCollection: languageOrCollection ?? this.languageOrCollection,
      editionOrCollection: editionOrCollection ?? this.editionOrCollection,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      sha256: sha256 ?? this.sha256,
      installedAt: installedAt ?? this.installedAt,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (languageOrCollection.present) {
      map['language_or_collection'] = Variable<String>(
        languageOrCollection.value,
      );
    }
    if (editionOrCollection.present) {
      map['edition_or_collection'] = Variable<String>(
        editionOrCollection.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentPacksCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('languageOrCollection: $languageOrCollection, ')
          ..write('editionOrCollection: $editionOrCollection, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('sha256: $sha256, ')
          ..write('installedAt: $installedAt, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentKeyMeta = const VerificationMeta(
    'contentKey',
  );
  @override
  late final GeneratedColumn<String> contentKey = GeneratedColumn<String>(
    'content_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentType,
    contentKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('content_key')) {
      context.handle(
        _contentKeyMeta,
        contentKey.isAcceptableOrUnknown(data['content_key']!, _contentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_contentKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      contentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final String contentType;
  final String contentKey;
  final DateTime createdAt;
  const Bookmark({
    required this.id,
    required this.contentType,
    required this.contentKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_type'] = Variable<String>(contentType);
    map['content_key'] = Variable<String>(contentKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      contentType: Value(contentType),
      contentKey: Value(contentKey),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      contentType: serializer.fromJson<String>(json['contentType']),
      contentKey: serializer.fromJson<String>(json['contentKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentType': serializer.toJson<String>(contentType),
      'contentKey': serializer.toJson<String>(contentKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith({
    int? id,
    String? contentType,
    String? contentKey,
    DateTime? createdAt,
  }) => Bookmark(
    id: id ?? this.id,
    contentType: contentType ?? this.contentType,
    contentKey: contentKey ?? this.contentKey,
    createdAt: createdAt ?? this.createdAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      contentKey: data.contentKey.present
          ? data.contentKey.value
          : this.contentKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('contentType: $contentType, ')
          ..write('contentKey: $contentKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contentType, contentKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.contentType == this.contentType &&
          other.contentKey == this.contentKey &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<String> contentType;
  final Value<String> contentKey;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.contentType = const Value.absent(),
    this.contentKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required String contentType,
    required String contentKey,
    required DateTime createdAt,
  }) : contentType = Value(contentType),
       contentKey = Value(contentKey),
       createdAt = Value(createdAt);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<String>? contentType,
    Expression<String>? contentKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentType != null) 'content_type': contentType,
      if (contentKey != null) 'content_key': contentKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<String>? contentType,
    Value<String>? contentKey,
    Value<DateTime>? createdAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      contentType: contentType ?? this.contentType,
      contentKey: contentKey ?? this.contentKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (contentKey.present) {
      map['content_key'] = Variable<String>(contentKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('contentType: $contentType, ')
          ..write('contentKey: $contentKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TasbihSessionsTable extends TasbihSessions
    with TableInfo<$TasbihSessionsTable, TasbihSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasbihSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _presetLabelMeta = const VerificationMeta(
    'presetLabel',
  );
  @override
  late final GeneratedColumn<String> presetLabel = GeneratedColumn<String>(
    'preset_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedCountMeta = const VerificationMeta(
    'completedCount',
  );
  @override
  late final GeneratedColumn<int> completedCount = GeneratedColumn<int>(
    'completed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    presetLabel,
    targetCount,
    completedCount,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbih_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasbihSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('preset_label')) {
      context.handle(
        _presetLabelMeta,
        presetLabel.isAcceptableOrUnknown(
          data['preset_label']!,
          _presetLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_presetLabelMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('completed_count')) {
      context.handle(
        _completedCountMeta,
        completedCount.isAcceptableOrUnknown(
          data['completed_count']!,
          _completedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedCountMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasbihSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      presetLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_label'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      completedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_count'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $TasbihSessionsTable createAlias(String alias) {
    return $TasbihSessionsTable(attachedDatabase, alias);
  }
}

class TasbihSession extends DataClass implements Insertable<TasbihSession> {
  final int id;
  final String presetLabel;
  final int targetCount;
  final int completedCount;
  final DateTime completedAt;
  const TasbihSession({
    required this.id,
    required this.presetLabel,
    required this.targetCount,
    required this.completedCount,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['preset_label'] = Variable<String>(presetLabel);
    map['target_count'] = Variable<int>(targetCount);
    map['completed_count'] = Variable<int>(completedCount);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  TasbihSessionsCompanion toCompanion(bool nullToAbsent) {
    return TasbihSessionsCompanion(
      id: Value(id),
      presetLabel: Value(presetLabel),
      targetCount: Value(targetCount),
      completedCount: Value(completedCount),
      completedAt: Value(completedAt),
    );
  }

  factory TasbihSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihSession(
      id: serializer.fromJson<int>(json['id']),
      presetLabel: serializer.fromJson<String>(json['presetLabel']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      completedCount: serializer.fromJson<int>(json['completedCount']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'presetLabel': serializer.toJson<String>(presetLabel),
      'targetCount': serializer.toJson<int>(targetCount),
      'completedCount': serializer.toJson<int>(completedCount),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  TasbihSession copyWith({
    int? id,
    String? presetLabel,
    int? targetCount,
    int? completedCount,
    DateTime? completedAt,
  }) => TasbihSession(
    id: id ?? this.id,
    presetLabel: presetLabel ?? this.presetLabel,
    targetCount: targetCount ?? this.targetCount,
    completedCount: completedCount ?? this.completedCount,
    completedAt: completedAt ?? this.completedAt,
  );
  TasbihSession copyWithCompanion(TasbihSessionsCompanion data) {
    return TasbihSession(
      id: data.id.present ? data.id.value : this.id,
      presetLabel: data.presetLabel.present
          ? data.presetLabel.value
          : this.presetLabel,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      completedCount: data.completedCount.present
          ? data.completedCount.value
          : this.completedCount,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihSession(')
          ..write('id: $id, ')
          ..write('presetLabel: $presetLabel, ')
          ..write('targetCount: $targetCount, ')
          ..write('completedCount: $completedCount, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, presetLabel, targetCount, completedCount, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihSession &&
          other.id == this.id &&
          other.presetLabel == this.presetLabel &&
          other.targetCount == this.targetCount &&
          other.completedCount == this.completedCount &&
          other.completedAt == this.completedAt);
}

class TasbihSessionsCompanion extends UpdateCompanion<TasbihSession> {
  final Value<int> id;
  final Value<String> presetLabel;
  final Value<int> targetCount;
  final Value<int> completedCount;
  final Value<DateTime> completedAt;
  const TasbihSessionsCompanion({
    this.id = const Value.absent(),
    this.presetLabel = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.completedCount = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  TasbihSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String presetLabel,
    required int targetCount,
    required int completedCount,
    required DateTime completedAt,
  }) : presetLabel = Value(presetLabel),
       targetCount = Value(targetCount),
       completedCount = Value(completedCount),
       completedAt = Value(completedAt);
  static Insertable<TasbihSession> custom({
    Expression<int>? id,
    Expression<String>? presetLabel,
    Expression<int>? targetCount,
    Expression<int>? completedCount,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (presetLabel != null) 'preset_label': presetLabel,
      if (targetCount != null) 'target_count': targetCount,
      if (completedCount != null) 'completed_count': completedCount,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  TasbihSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? presetLabel,
    Value<int>? targetCount,
    Value<int>? completedCount,
    Value<DateTime>? completedAt,
  }) {
    return TasbihSessionsCompanion(
      id: id ?? this.id,
      presetLabel: presetLabel ?? this.presetLabel,
      targetCount: targetCount ?? this.targetCount,
      completedCount: completedCount ?? this.completedCount,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (presetLabel.present) {
      map['preset_label'] = Variable<String>(presetLabel.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (completedCount.present) {
      map['completed_count'] = Variable<int>(completedCount.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihSessionsCompanion(')
          ..write('id: $id, ')
          ..write('presetLabel: $presetLabel, ')
          ..write('targetCount: $targetCount, ')
          ..write('completedCount: $completedCount, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $LibraryDownloadsTable extends LibraryDownloads
    with TableInfo<$LibraryDownloadsTable, LibraryDownload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryDownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, path, sizeBytes, downloadedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryDownload> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  LibraryDownload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryDownload(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $LibraryDownloadsTable createAlias(String alias) {
    return $LibraryDownloadsTable(attachedDatabase, alias);
  }
}

class LibraryDownload extends DataClass implements Insertable<LibraryDownload> {
  final String bookId;
  final String path;
  final int sizeBytes;
  final DateTime downloadedAt;
  const LibraryDownload({
    required this.bookId,
    required this.path,
    required this.sizeBytes,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['path'] = Variable<String>(path);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  LibraryDownloadsCompanion toCompanion(bool nullToAbsent) {
    return LibraryDownloadsCompanion(
      bookId: Value(bookId),
      path: Value(path),
      sizeBytes: Value(sizeBytes),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory LibraryDownload.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryDownload(
      bookId: serializer.fromJson<String>(json['bookId']),
      path: serializer.fromJson<String>(json['path']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'path': serializer.toJson<String>(path),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  LibraryDownload copyWith({
    String? bookId,
    String? path,
    int? sizeBytes,
    DateTime? downloadedAt,
  }) => LibraryDownload(
    bookId: bookId ?? this.bookId,
    path: path ?? this.path,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  LibraryDownload copyWithCompanion(LibraryDownloadsCompanion data) {
    return LibraryDownload(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      path: data.path.present ? data.path.value : this.path,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryDownload(')
          ..write('bookId: $bookId, ')
          ..write('path: $path, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, path, sizeBytes, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryDownload &&
          other.bookId == this.bookId &&
          other.path == this.path &&
          other.sizeBytes == this.sizeBytes &&
          other.downloadedAt == this.downloadedAt);
}

class LibraryDownloadsCompanion extends UpdateCompanion<LibraryDownload> {
  final Value<String> bookId;
  final Value<String> path;
  final Value<int> sizeBytes;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const LibraryDownloadsCompanion({
    this.bookId = const Value.absent(),
    this.path = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryDownloadsCompanion.insert({
    required String bookId,
    required String path,
    required int sizeBytes,
    required DateTime downloadedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       path = Value(path),
       sizeBytes = Value(sizeBytes),
       downloadedAt = Value(downloadedAt);
  static Insertable<LibraryDownload> custom({
    Expression<String>? bookId,
    Expression<String>? path,
    Expression<int>? sizeBytes,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (path != null) 'path': path,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryDownloadsCompanion copyWith({
    Value<String>? bookId,
    Value<String>? path,
    Value<int>? sizeBytes,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return LibraryDownloadsCompanion(
      bookId: bookId ?? this.bookId,
      path: path ?? this.path,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryDownloadsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('path: $path, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $UserPlansTable userPlans = $UserPlansTable(this);
  late final $SrsItemsTable srsItems = $SrsItemsTable(this);
  late final $ReviewLogsTable reviewLogs = $ReviewLogsTable(this);
  late final $DailySessionsTable dailySessions = $DailySessionsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $StreakStateTable streakState = $StreakStateTable(this);
  late final $DuaSelectionsTable duaSelections = $DuaSelectionsTable(this);
  late final $DownloadStateTable downloadState = $DownloadStateTable(this);
  late final $ContentPacksTable contentPacks = $ContentPacksTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $TasbihSessionsTable tasbihSessions = $TasbihSessionsTable(this);
  late final $LibraryDownloadsTable libraryDownloads = $LibraryDownloadsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    userPlans,
    srsItems,
    reviewLogs,
    dailySessions,
    achievements,
    streakState,
    duaSelections,
    downloadState,
    contentPacks,
    bookmarks,
    tasbihSessions,
    libraryDownloads,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> avatarEmoji,
      required DateTime createdAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> avatarEmoji,
      Value<DateTime> createdAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarEmoji => $composableBuilder(
    column: $table.avatarEmoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarEmoji => $composableBuilder(
    column: $table.avatarEmoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarEmoji => $composableBuilder(
    column: $table.avatarEmoji,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarEmoji = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                avatarEmoji: avatarEmoji,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> avatarEmoji = const Value.absent(),
                required DateTime createdAt,
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                avatarEmoji: avatarEmoji,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$UserPlansTableCreateCompanionBuilder =
    UserPlansCompanion Function({
      Value<int> id,
      required String scope,
      Value<String?> quranSelectionType,
      Value<String?> quranSelectionJson,
      Value<String> direction,
      required int dailyMinutes,
      Value<String> reciter,
      Value<int> weeklyGoal,
      required DateTime createdAt,
    });
typedef $$UserPlansTableUpdateCompanionBuilder =
    UserPlansCompanion Function({
      Value<int> id,
      Value<String> scope,
      Value<String?> quranSelectionType,
      Value<String?> quranSelectionJson,
      Value<String> direction,
      Value<int> dailyMinutes,
      Value<String> reciter,
      Value<int> weeklyGoal,
      Value<DateTime> createdAt,
    });

class $$UserPlansTableFilterComposer
    extends Composer<_$AppDatabase, $UserPlansTable> {
  $$UserPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quranSelectionType => $composableBuilder(
    column: $table.quranSelectionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quranSelectionJson => $composableBuilder(
    column: $table.quranSelectionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reciter => $composableBuilder(
    column: $table.reciter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyGoal => $composableBuilder(
    column: $table.weeklyGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPlansTable> {
  $$UserPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quranSelectionType => $composableBuilder(
    column: $table.quranSelectionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quranSelectionJson => $composableBuilder(
    column: $table.quranSelectionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reciter => $composableBuilder(
    column: $table.reciter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyGoal => $composableBuilder(
    column: $table.weeklyGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPlansTable> {
  $$UserPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get quranSelectionType => $composableBuilder(
    column: $table.quranSelectionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quranSelectionJson => $composableBuilder(
    column: $table.quranSelectionJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reciter =>
      $composableBuilder(column: $table.reciter, builder: (column) => column);

  GeneratedColumn<int> get weeklyGoal => $composableBuilder(
    column: $table.weeklyGoal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPlansTable,
          UserPlan,
          $$UserPlansTableFilterComposer,
          $$UserPlansTableOrderingComposer,
          $$UserPlansTableAnnotationComposer,
          $$UserPlansTableCreateCompanionBuilder,
          $$UserPlansTableUpdateCompanionBuilder,
          (UserPlan, BaseReferences<_$AppDatabase, $UserPlansTable, UserPlan>),
          UserPlan,
          PrefetchHooks Function()
        > {
  $$UserPlansTableTableManager(_$AppDatabase db, $UserPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String?> quranSelectionType = const Value.absent(),
                Value<String?> quranSelectionJson = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> dailyMinutes = const Value.absent(),
                Value<String> reciter = const Value.absent(),
                Value<int> weeklyGoal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserPlansCompanion(
                id: id,
                scope: scope,
                quranSelectionType: quranSelectionType,
                quranSelectionJson: quranSelectionJson,
                direction: direction,
                dailyMinutes: dailyMinutes,
                reciter: reciter,
                weeklyGoal: weeklyGoal,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scope,
                Value<String?> quranSelectionType = const Value.absent(),
                Value<String?> quranSelectionJson = const Value.absent(),
                Value<String> direction = const Value.absent(),
                required int dailyMinutes,
                Value<String> reciter = const Value.absent(),
                Value<int> weeklyGoal = const Value.absent(),
                required DateTime createdAt,
              }) => UserPlansCompanion.insert(
                id: id,
                scope: scope,
                quranSelectionType: quranSelectionType,
                quranSelectionJson: quranSelectionJson,
                direction: direction,
                dailyMinutes: dailyMinutes,
                reciter: reciter,
                weeklyGoal: weeklyGoal,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPlansTable,
      UserPlan,
      $$UserPlansTableFilterComposer,
      $$UserPlansTableOrderingComposer,
      $$UserPlansTableAnnotationComposer,
      $$UserPlansTableCreateCompanionBuilder,
      $$UserPlansTableUpdateCompanionBuilder,
      (UserPlan, BaseReferences<_$AppDatabase, $UserPlansTable, UserPlan>),
      UserPlan,
      PrefetchHooks Function()
    >;
typedef $$SrsItemsTableCreateCompanionBuilder =
    SrsItemsCompanion Function({
      Value<int> id,
      required String contentType,
      required String contentKey,
      required int orderIndex,
      required int wordCount,
      Value<String> status,
      Value<double> easeFactor,
      Value<int> intervalDays,
      Value<int> repetitions,
      Value<int> learningStep,
      Value<DateTime?> dueDate,
      Value<DateTime?> introducedAt,
    });
typedef $$SrsItemsTableUpdateCompanionBuilder =
    SrsItemsCompanion Function({
      Value<int> id,
      Value<String> contentType,
      Value<String> contentKey,
      Value<int> orderIndex,
      Value<int> wordCount,
      Value<String> status,
      Value<double> easeFactor,
      Value<int> intervalDays,
      Value<int> repetitions,
      Value<int> learningStep,
      Value<DateTime?> dueDate,
      Value<DateTime?> introducedAt,
    });

final class $$SrsItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SrsItemsTable, SrsItem> {
  $$SrsItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReviewLogsTable, List<ReviewLog>>
  _reviewLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewLogs,
    aliasName: 'srs_items__id__review_logs__item_id',
  );

  $$ReviewLogsTableProcessedTableManager get reviewLogsRefs {
    final manager = $$ReviewLogsTableTableManager(
      $_db,
      $_db.reviewLogs,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SrsItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SrsItemsTable> {
  $$SrsItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentKey => $composableBuilder(
    column: $table.contentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get introducedAt => $composableBuilder(
    column: $table.introducedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reviewLogsRefs(
    Expression<bool> Function($$ReviewLogsTableFilterComposer f) f,
  ) {
    final $$ReviewLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableFilterComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SrsItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SrsItemsTable> {
  $$SrsItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentKey => $composableBuilder(
    column: $table.contentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get introducedAt => $composableBuilder(
    column: $table.introducedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SrsItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SrsItemsTable> {
  $$SrsItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentKey => $composableBuilder(
    column: $table.contentKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get introducedAt => $composableBuilder(
    column: $table.introducedAt,
    builder: (column) => column,
  );

  Expression<T> reviewLogsRefs<T extends Object>(
    Expression<T> Function($$ReviewLogsTableAnnotationComposer a) f,
  ) {
    final $$ReviewLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SrsItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SrsItemsTable,
          SrsItem,
          $$SrsItemsTableFilterComposer,
          $$SrsItemsTableOrderingComposer,
          $$SrsItemsTableAnnotationComposer,
          $$SrsItemsTableCreateCompanionBuilder,
          $$SrsItemsTableUpdateCompanionBuilder,
          (SrsItem, $$SrsItemsTableReferences),
          SrsItem,
          PrefetchHooks Function({bool reviewLogsRefs})
        > {
  $$SrsItemsTableTableManager(_$AppDatabase db, $SrsItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SrsItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SrsItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SrsItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> contentKey = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> learningStep = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> introducedAt = const Value.absent(),
              }) => SrsItemsCompanion(
                id: id,
                contentType: contentType,
                contentKey: contentKey,
                orderIndex: orderIndex,
                wordCount: wordCount,
                status: status,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                repetitions: repetitions,
                learningStep: learningStep,
                dueDate: dueDate,
                introducedAt: introducedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentType,
                required String contentKey,
                required int orderIndex,
                required int wordCount,
                Value<String> status = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> learningStep = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> introducedAt = const Value.absent(),
              }) => SrsItemsCompanion.insert(
                id: id,
                contentType: contentType,
                contentKey: contentKey,
                orderIndex: orderIndex,
                wordCount: wordCount,
                status: status,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                repetitions: repetitions,
                learningStep: learningStep,
                dueDate: dueDate,
                introducedAt: introducedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SrsItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reviewLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (reviewLogsRefs) db.reviewLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reviewLogsRefs)
                    await $_getPrefetchedData<
                      SrsItem,
                      $SrsItemsTable,
                      ReviewLog
                    >(
                      currentTable: table,
                      referencedTable: $$SrsItemsTableReferences
                          ._reviewLogsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SrsItemsTableReferences(
                        db,
                        table,
                        p0,
                      ).reviewLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SrsItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SrsItemsTable,
      SrsItem,
      $$SrsItemsTableFilterComposer,
      $$SrsItemsTableOrderingComposer,
      $$SrsItemsTableAnnotationComposer,
      $$SrsItemsTableCreateCompanionBuilder,
      $$SrsItemsTableUpdateCompanionBuilder,
      (SrsItem, $$SrsItemsTableReferences),
      SrsItem,
      PrefetchHooks Function({bool reviewLogsRefs})
    >;
typedef $$ReviewLogsTableCreateCompanionBuilder =
    ReviewLogsCompanion Function({
      Value<int> id,
      required int itemId,
      required DateTime reviewedAt,
      required int grade,
      required int intervalBefore,
      required int intervalAfter,
    });
typedef $$ReviewLogsTableUpdateCompanionBuilder =
    ReviewLogsCompanion Function({
      Value<int> id,
      Value<int> itemId,
      Value<DateTime> reviewedAt,
      Value<int> grade,
      Value<int> intervalBefore,
      Value<int> intervalAfter,
    });

final class $$ReviewLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLog> {
  $$ReviewLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SrsItemsTable _itemIdTable(_$AppDatabase db) =>
      db.srsItems.createAlias('review_logs__item_id__srs_items__id');

  $$SrsItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$SrsItemsTableTableManager(
      $_db,
      $_db.srsItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalBefore => $composableBuilder(
    column: $table.intervalBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalAfter => $composableBuilder(
    column: $table.intervalAfter,
    builder: (column) => ColumnFilters(column),
  );

  $$SrsItemsTableFilterComposer get itemId {
    final $$SrsItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.srsItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SrsItemsTableFilterComposer(
            $db: $db,
            $table: $db.srsItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalBefore => $composableBuilder(
    column: $table.intervalBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalAfter => $composableBuilder(
    column: $table.intervalAfter,
    builder: (column) => ColumnOrderings(column),
  );

  $$SrsItemsTableOrderingComposer get itemId {
    final $$SrsItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.srsItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SrsItemsTableOrderingComposer(
            $db: $db,
            $table: $db.srsItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get intervalBefore => $composableBuilder(
    column: $table.intervalBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalAfter => $composableBuilder(
    column: $table.intervalAfter,
    builder: (column) => column,
  );

  $$SrsItemsTableAnnotationComposer get itemId {
    final $$SrsItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.srsItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SrsItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.srsItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogsTable,
          ReviewLog,
          $$ReviewLogsTableFilterComposer,
          $$ReviewLogsTableOrderingComposer,
          $$ReviewLogsTableAnnotationComposer,
          $$ReviewLogsTableCreateCompanionBuilder,
          $$ReviewLogsTableUpdateCompanionBuilder,
          (ReviewLog, $$ReviewLogsTableReferences),
          ReviewLog,
          PrefetchHooks Function({bool itemId})
        > {
  $$ReviewLogsTableTableManager(_$AppDatabase db, $ReviewLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<int> grade = const Value.absent(),
                Value<int> intervalBefore = const Value.absent(),
                Value<int> intervalAfter = const Value.absent(),
              }) => ReviewLogsCompanion(
                id: id,
                itemId: itemId,
                reviewedAt: reviewedAt,
                grade: grade,
                intervalBefore: intervalBefore,
                intervalAfter: intervalAfter,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int itemId,
                required DateTime reviewedAt,
                required int grade,
                required int intervalBefore,
                required int intervalAfter,
              }) => ReviewLogsCompanion.insert(
                id: id,
                itemId: itemId,
                reviewedAt: reviewedAt,
                grade: grade,
                intervalBefore: intervalBefore,
                intervalAfter: intervalAfter,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReviewLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$ReviewLogsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$ReviewLogsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogsTable,
      ReviewLog,
      $$ReviewLogsTableFilterComposer,
      $$ReviewLogsTableOrderingComposer,
      $$ReviewLogsTableAnnotationComposer,
      $$ReviewLogsTableCreateCompanionBuilder,
      $$ReviewLogsTableUpdateCompanionBuilder,
      (ReviewLog, $$ReviewLogsTableReferences),
      ReviewLog,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$DailySessionsTableCreateCompanionBuilder =
    DailySessionsCompanion Function({
      required String day,
      required int newItemsPlanned,
      Value<int> newItemsDone,
      required int reviewsPlanned,
      Value<int> reviewsDone,
      Value<bool> completed,
      Value<int> rowid,
    });
typedef $$DailySessionsTableUpdateCompanionBuilder =
    DailySessionsCompanion Function({
      Value<String> day,
      Value<int> newItemsPlanned,
      Value<int> newItemsDone,
      Value<int> reviewsPlanned,
      Value<int> reviewsDone,
      Value<bool> completed,
      Value<int> rowid,
    });

class $$DailySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $DailySessionsTable> {
  $$DailySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newItemsPlanned => $composableBuilder(
    column: $table.newItemsPlanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newItemsDone => $composableBuilder(
    column: $table.newItemsDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewsPlanned => $composableBuilder(
    column: $table.reviewsPlanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewsDone => $composableBuilder(
    column: $table.reviewsDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySessionsTable> {
  $$DailySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newItemsPlanned => $composableBuilder(
    column: $table.newItemsPlanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newItemsDone => $composableBuilder(
    column: $table.newItemsDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewsPlanned => $composableBuilder(
    column: $table.reviewsPlanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewsDone => $composableBuilder(
    column: $table.reviewsDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySessionsTable> {
  $$DailySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get newItemsPlanned => $composableBuilder(
    column: $table.newItemsPlanned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newItemsDone => $composableBuilder(
    column: $table.newItemsDone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewsPlanned => $composableBuilder(
    column: $table.reviewsPlanned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewsDone => $composableBuilder(
    column: $table.reviewsDone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$DailySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySessionsTable,
          DailySession,
          $$DailySessionsTableFilterComposer,
          $$DailySessionsTableOrderingComposer,
          $$DailySessionsTableAnnotationComposer,
          $$DailySessionsTableCreateCompanionBuilder,
          $$DailySessionsTableUpdateCompanionBuilder,
          (
            DailySession,
            BaseReferences<_$AppDatabase, $DailySessionsTable, DailySession>,
          ),
          DailySession,
          PrefetchHooks Function()
        > {
  $$DailySessionsTableTableManager(_$AppDatabase db, $DailySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int> newItemsPlanned = const Value.absent(),
                Value<int> newItemsDone = const Value.absent(),
                Value<int> reviewsPlanned = const Value.absent(),
                Value<int> reviewsDone = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySessionsCompanion(
                day: day,
                newItemsPlanned: newItemsPlanned,
                newItemsDone: newItemsDone,
                reviewsPlanned: reviewsPlanned,
                reviewsDone: reviewsDone,
                completed: completed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required int newItemsPlanned,
                Value<int> newItemsDone = const Value.absent(),
                required int reviewsPlanned,
                Value<int> reviewsDone = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySessionsCompanion.insert(
                day: day,
                newItemsPlanned: newItemsPlanned,
                newItemsDone: newItemsDone,
                reviewsPlanned: reviewsPlanned,
                reviewsDone: reviewsDone,
                completed: completed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySessionsTable,
      DailySession,
      $$DailySessionsTableFilterComposer,
      $$DailySessionsTableOrderingComposer,
      $$DailySessionsTableAnnotationComposer,
      $$DailySessionsTableCreateCompanionBuilder,
      $$DailySessionsTableUpdateCompanionBuilder,
      (
        DailySession,
        BaseReferences<_$AppDatabase, $DailySessionsTable, DailySession>,
      ),
      DailySession,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String achievementId,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> achievementId,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> achievementId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                achievementId: achievementId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String achievementId,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                achievementId: achievementId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$StreakStateTableCreateCompanionBuilder =
    StreakStateCompanion Function({
      Value<int> id,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<int> freezeTokens,
      Value<DateTime?> lastCompletedDay,
    });
typedef $$StreakStateTableUpdateCompanionBuilder =
    StreakStateCompanion Function({
      Value<int> id,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<int> freezeTokens,
      Value<DateTime?> lastCompletedDay,
    });

class $$StreakStateTableFilterComposer
    extends Composer<_$AppDatabase, $StreakStateTable> {
  $$StreakStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freezeTokens => $composableBuilder(
    column: $table.freezeTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCompletedDay => $composableBuilder(
    column: $table.lastCompletedDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakStateTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakStateTable> {
  $$StreakStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freezeTokens => $composableBuilder(
    column: $table.freezeTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCompletedDay => $composableBuilder(
    column: $table.lastCompletedDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakStateTable> {
  $$StreakStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freezeTokens => $composableBuilder(
    column: $table.freezeTokens,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompletedDay => $composableBuilder(
    column: $table.lastCompletedDay,
    builder: (column) => column,
  );
}

class $$StreakStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakStateTable,
          StreakStateData,
          $$StreakStateTableFilterComposer,
          $$StreakStateTableOrderingComposer,
          $$StreakStateTableAnnotationComposer,
          $$StreakStateTableCreateCompanionBuilder,
          $$StreakStateTableUpdateCompanionBuilder,
          (
            StreakStateData,
            BaseReferences<_$AppDatabase, $StreakStateTable, StreakStateData>,
          ),
          StreakStateData,
          PrefetchHooks Function()
        > {
  $$StreakStateTableTableManager(_$AppDatabase db, $StreakStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<int> freezeTokens = const Value.absent(),
                Value<DateTime?> lastCompletedDay = const Value.absent(),
              }) => StreakStateCompanion(
                id: id,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                freezeTokens: freezeTokens,
                lastCompletedDay: lastCompletedDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<int> freezeTokens = const Value.absent(),
                Value<DateTime?> lastCompletedDay = const Value.absent(),
              }) => StreakStateCompanion.insert(
                id: id,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                freezeTokens: freezeTokens,
                lastCompletedDay: lastCompletedDay,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakStateTable,
      StreakStateData,
      $$StreakStateTableFilterComposer,
      $$StreakStateTableOrderingComposer,
      $$StreakStateTableAnnotationComposer,
      $$StreakStateTableCreateCompanionBuilder,
      $$StreakStateTableUpdateCompanionBuilder,
      (
        StreakStateData,
        BaseReferences<_$AppDatabase, $StreakStateTable, StreakStateData>,
      ),
      StreakStateData,
      PrefetchHooks Function()
    >;
typedef $$DuaSelectionsTableCreateCompanionBuilder =
    DuaSelectionsCompanion Function({
      required String duaId,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$DuaSelectionsTableUpdateCompanionBuilder =
    DuaSelectionsCompanion Function({
      Value<String> duaId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$DuaSelectionsTableFilterComposer
    extends Composer<_$AppDatabase, $DuaSelectionsTable> {
  $$DuaSelectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get duaId => $composableBuilder(
    column: $table.duaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DuaSelectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DuaSelectionsTable> {
  $$DuaSelectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get duaId => $composableBuilder(
    column: $table.duaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DuaSelectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DuaSelectionsTable> {
  $$DuaSelectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get duaId =>
      $composableBuilder(column: $table.duaId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$DuaSelectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DuaSelectionsTable,
          DuaSelection,
          $$DuaSelectionsTableFilterComposer,
          $$DuaSelectionsTableOrderingComposer,
          $$DuaSelectionsTableAnnotationComposer,
          $$DuaSelectionsTableCreateCompanionBuilder,
          $$DuaSelectionsTableUpdateCompanionBuilder,
          (
            DuaSelection,
            BaseReferences<_$AppDatabase, $DuaSelectionsTable, DuaSelection>,
          ),
          DuaSelection,
          PrefetchHooks Function()
        > {
  $$DuaSelectionsTableTableManager(_$AppDatabase db, $DuaSelectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DuaSelectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DuaSelectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DuaSelectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> duaId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DuaSelectionsCompanion(
                duaId: duaId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String duaId,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => DuaSelectionsCompanion.insert(
                duaId: duaId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DuaSelectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DuaSelectionsTable,
      DuaSelection,
      $$DuaSelectionsTableFilterComposer,
      $$DuaSelectionsTableOrderingComposer,
      $$DuaSelectionsTableAnnotationComposer,
      $$DuaSelectionsTableCreateCompanionBuilder,
      $$DuaSelectionsTableUpdateCompanionBuilder,
      (
        DuaSelection,
        BaseReferences<_$AppDatabase, $DuaSelectionsTable, DuaSelection>,
      ),
      DuaSelection,
      PrefetchHooks Function()
    >;
typedef $$DownloadStateTableCreateCompanionBuilder =
    DownloadStateCompanion Function({
      Value<int> surahNumber,
      Value<String> status,
      Value<String?> quality,
      Value<String?> reciter,
      Value<double> progress,
      Value<DateTime?> updatedAt,
    });
typedef $$DownloadStateTableUpdateCompanionBuilder =
    DownloadStateCompanion Function({
      Value<int> surahNumber,
      Value<String> status,
      Value<String?> quality,
      Value<String?> reciter,
      Value<double> progress,
      Value<DateTime?> updatedAt,
    });

class $$DownloadStateTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadStateTable> {
  $$DownloadStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reciter => $composableBuilder(
    column: $table.reciter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadStateTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadStateTable> {
  $$DownloadStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reciter => $composableBuilder(
    column: $table.reciter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadStateTable> {
  $$DownloadStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get reciter =>
      $composableBuilder(column: $table.reciter, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadStateTable,
          DownloadStateData,
          $$DownloadStateTableFilterComposer,
          $$DownloadStateTableOrderingComposer,
          $$DownloadStateTableAnnotationComposer,
          $$DownloadStateTableCreateCompanionBuilder,
          $$DownloadStateTableUpdateCompanionBuilder,
          (
            DownloadStateData,
            BaseReferences<
              _$AppDatabase,
              $DownloadStateTable,
              DownloadStateData
            >,
          ),
          DownloadStateData,
          PrefetchHooks Function()
        > {
  $$DownloadStateTableTableManager(_$AppDatabase db, $DownloadStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> surahNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> quality = const Value.absent(),
                Value<String?> reciter = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => DownloadStateCompanion(
                surahNumber: surahNumber,
                status: status,
                quality: quality,
                reciter: reciter,
                progress: progress,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> surahNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> quality = const Value.absent(),
                Value<String?> reciter = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => DownloadStateCompanion.insert(
                surahNumber: surahNumber,
                status: status,
                quality: quality,
                reciter: reciter,
                progress: progress,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadStateTable,
      DownloadStateData,
      $$DownloadStateTableFilterComposer,
      $$DownloadStateTableOrderingComposer,
      $$DownloadStateTableAnnotationComposer,
      $$DownloadStateTableCreateCompanionBuilder,
      $$DownloadStateTableUpdateCompanionBuilder,
      (
        DownloadStateData,
        BaseReferences<_$AppDatabase, $DownloadStateTable, DownloadStateData>,
      ),
      DownloadStateData,
      PrefetchHooks Function()
    >;
typedef $$ContentPacksTableCreateCompanionBuilder =
    ContentPacksCompanion Function({
      Value<int> id,
      required String type,
      required String languageOrCollection,
      required String editionOrCollection,
      Value<String> status,
      Value<double> progress,
      Value<String?> sha256,
      Value<DateTime?> installedAt,
      Value<String?> data,
    });
typedef $$ContentPacksTableUpdateCompanionBuilder =
    ContentPacksCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> languageOrCollection,
      Value<String> editionOrCollection,
      Value<String> status,
      Value<double> progress,
      Value<String?> sha256,
      Value<DateTime?> installedAt,
      Value<String?> data,
    });

class $$ContentPacksTableFilterComposer
    extends Composer<_$AppDatabase, $ContentPacksTable> {
  $$ContentPacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageOrCollection => $composableBuilder(
    column: $table.languageOrCollection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editionOrCollection => $composableBuilder(
    column: $table.editionOrCollection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentPacksTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentPacksTable> {
  $$ContentPacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageOrCollection => $composableBuilder(
    column: $table.languageOrCollection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editionOrCollection => $composableBuilder(
    column: $table.editionOrCollection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentPacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentPacksTable> {
  $$ContentPacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get languageOrCollection => $composableBuilder(
    column: $table.languageOrCollection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get editionOrCollection => $composableBuilder(
    column: $table.editionOrCollection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$ContentPacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentPacksTable,
          ContentPack,
          $$ContentPacksTableFilterComposer,
          $$ContentPacksTableOrderingComposer,
          $$ContentPacksTableAnnotationComposer,
          $$ContentPacksTableCreateCompanionBuilder,
          $$ContentPacksTableUpdateCompanionBuilder,
          (
            ContentPack,
            BaseReferences<_$AppDatabase, $ContentPacksTable, ContentPack>,
          ),
          ContentPack,
          PrefetchHooks Function()
        > {
  $$ContentPacksTableTableManager(_$AppDatabase db, $ContentPacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentPacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentPacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentPacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> languageOrCollection = const Value.absent(),
                Value<String> editionOrCollection = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<String?> data = const Value.absent(),
              }) => ContentPacksCompanion(
                id: id,
                type: type,
                languageOrCollection: languageOrCollection,
                editionOrCollection: editionOrCollection,
                status: status,
                progress: progress,
                sha256: sha256,
                installedAt: installedAt,
                data: data,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String languageOrCollection,
                required String editionOrCollection,
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<String?> data = const Value.absent(),
              }) => ContentPacksCompanion.insert(
                id: id,
                type: type,
                languageOrCollection: languageOrCollection,
                editionOrCollection: editionOrCollection,
                status: status,
                progress: progress,
                sha256: sha256,
                installedAt: installedAt,
                data: data,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentPacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentPacksTable,
      ContentPack,
      $$ContentPacksTableFilterComposer,
      $$ContentPacksTableOrderingComposer,
      $$ContentPacksTableAnnotationComposer,
      $$ContentPacksTableCreateCompanionBuilder,
      $$ContentPacksTableUpdateCompanionBuilder,
      (
        ContentPack,
        BaseReferences<_$AppDatabase, $ContentPacksTable, ContentPack>,
      ),
      ContentPack,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      required String contentType,
      required String contentKey,
      required DateTime createdAt,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<String> contentType,
      Value<String> contentKey,
      Value<DateTime> createdAt,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentKey => $composableBuilder(
    column: $table.contentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentKey => $composableBuilder(
    column: $table.contentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentKey => $composableBuilder(
    column: $table.contentKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> contentKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                contentType: contentType,
                contentKey: contentKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentType,
                required String contentKey,
                required DateTime createdAt,
              }) => BookmarksCompanion.insert(
                id: id,
                contentType: contentType,
                contentKey: contentKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;
typedef $$TasbihSessionsTableCreateCompanionBuilder =
    TasbihSessionsCompanion Function({
      Value<int> id,
      required String presetLabel,
      required int targetCount,
      required int completedCount,
      required DateTime completedAt,
    });
typedef $$TasbihSessionsTableUpdateCompanionBuilder =
    TasbihSessionsCompanion Function({
      Value<int> id,
      Value<String> presetLabel,
      Value<int> targetCount,
      Value<int> completedCount,
      Value<DateTime> completedAt,
    });

class $$TasbihSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetLabel => $composableBuilder(
    column: $table.presetLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasbihSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetLabel => $composableBuilder(
    column: $table.presetLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasbihSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get presetLabel => $composableBuilder(
    column: $table.presetLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$TasbihSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasbihSessionsTable,
          TasbihSession,
          $$TasbihSessionsTableFilterComposer,
          $$TasbihSessionsTableOrderingComposer,
          $$TasbihSessionsTableAnnotationComposer,
          $$TasbihSessionsTableCreateCompanionBuilder,
          $$TasbihSessionsTableUpdateCompanionBuilder,
          (
            TasbihSession,
            BaseReferences<_$AppDatabase, $TasbihSessionsTable, TasbihSession>,
          ),
          TasbihSession,
          PrefetchHooks Function()
        > {
  $$TasbihSessionsTableTableManager(
    _$AppDatabase db,
    $TasbihSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasbihSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasbihSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasbihSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> presetLabel = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<int> completedCount = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => TasbihSessionsCompanion(
                id: id,
                presetLabel: presetLabel,
                targetCount: targetCount,
                completedCount: completedCount,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String presetLabel,
                required int targetCount,
                required int completedCount,
                required DateTime completedAt,
              }) => TasbihSessionsCompanion.insert(
                id: id,
                presetLabel: presetLabel,
                targetCount: targetCount,
                completedCount: completedCount,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasbihSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasbihSessionsTable,
      TasbihSession,
      $$TasbihSessionsTableFilterComposer,
      $$TasbihSessionsTableOrderingComposer,
      $$TasbihSessionsTableAnnotationComposer,
      $$TasbihSessionsTableCreateCompanionBuilder,
      $$TasbihSessionsTableUpdateCompanionBuilder,
      (
        TasbihSession,
        BaseReferences<_$AppDatabase, $TasbihSessionsTable, TasbihSession>,
      ),
      TasbihSession,
      PrefetchHooks Function()
    >;
typedef $$LibraryDownloadsTableCreateCompanionBuilder =
    LibraryDownloadsCompanion Function({
      required String bookId,
      required String path,
      required int sizeBytes,
      required DateTime downloadedAt,
      Value<int> rowid,
    });
typedef $$LibraryDownloadsTableUpdateCompanionBuilder =
    LibraryDownloadsCompanion Function({
      Value<String> bookId,
      Value<String> path,
      Value<int> sizeBytes,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });

class $$LibraryDownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryDownloadsTable> {
  $$LibraryDownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryDownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryDownloadsTable> {
  $$LibraryDownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryDownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryDownloadsTable> {
  $$LibraryDownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$LibraryDownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryDownloadsTable,
          LibraryDownload,
          $$LibraryDownloadsTableFilterComposer,
          $$LibraryDownloadsTableOrderingComposer,
          $$LibraryDownloadsTableAnnotationComposer,
          $$LibraryDownloadsTableCreateCompanionBuilder,
          $$LibraryDownloadsTableUpdateCompanionBuilder,
          (
            LibraryDownload,
            BaseReferences<
              _$AppDatabase,
              $LibraryDownloadsTable,
              LibraryDownload
            >,
          ),
          LibraryDownload,
          PrefetchHooks Function()
        > {
  $$LibraryDownloadsTableTableManager(
    _$AppDatabase db,
    $LibraryDownloadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryDownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryDownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryDownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryDownloadsCompanion(
                bookId: bookId,
                path: path,
                sizeBytes: sizeBytes,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String path,
                required int sizeBytes,
                required DateTime downloadedAt,
                Value<int> rowid = const Value.absent(),
              }) => LibraryDownloadsCompanion.insert(
                bookId: bookId,
                path: path,
                sizeBytes: sizeBytes,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryDownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryDownloadsTable,
      LibraryDownload,
      $$LibraryDownloadsTableFilterComposer,
      $$LibraryDownloadsTableOrderingComposer,
      $$LibraryDownloadsTableAnnotationComposer,
      $$LibraryDownloadsTableCreateCompanionBuilder,
      $$LibraryDownloadsTableUpdateCompanionBuilder,
      (
        LibraryDownload,
        BaseReferences<_$AppDatabase, $LibraryDownloadsTable, LibraryDownload>,
      ),
      LibraryDownload,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$UserPlansTableTableManager get userPlans =>
      $$UserPlansTableTableManager(_db, _db.userPlans);
  $$SrsItemsTableTableManager get srsItems =>
      $$SrsItemsTableTableManager(_db, _db.srsItems);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db, _db.reviewLogs);
  $$DailySessionsTableTableManager get dailySessions =>
      $$DailySessionsTableTableManager(_db, _db.dailySessions);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$StreakStateTableTableManager get streakState =>
      $$StreakStateTableTableManager(_db, _db.streakState);
  $$DuaSelectionsTableTableManager get duaSelections =>
      $$DuaSelectionsTableTableManager(_db, _db.duaSelections);
  $$DownloadStateTableTableManager get downloadState =>
      $$DownloadStateTableTableManager(_db, _db.downloadState);
  $$ContentPacksTableTableManager get contentPacks =>
      $$ContentPacksTableTableManager(_db, _db.contentPacks);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$TasbihSessionsTableTableManager get tasbihSessions =>
      $$TasbihSessionsTableTableManager(_db, _db.tasbihSessions);
  $$LibraryDownloadsTableTableManager get libraryDownloads =>
      $$LibraryDownloadsTableTableManager(_db, _db.libraryDownloads);
}
