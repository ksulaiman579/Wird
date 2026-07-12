// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dua_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Dua {

 String get id; String get arabic; String? get transliteration; String get translation; String get reference; int get repetitions; int get wordCount;
/// Create a copy of Dua
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuaCopyWith<Dua> get copyWith => _$DuaCopyWithImpl<Dua>(this as Dua, _$identity);

  /// Serializes this Dua to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dua&&(identical(other.id, id) || other.id == id)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.transliteration, transliteration) || other.transliteration == transliteration)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.repetitions, repetitions) || other.repetitions == repetitions)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,arabic,transliteration,translation,reference,repetitions,wordCount);

@override
String toString() {
  return 'Dua(id: $id, arabic: $arabic, transliteration: $transliteration, translation: $translation, reference: $reference, repetitions: $repetitions, wordCount: $wordCount)';
}


}

/// @nodoc
abstract mixin class $DuaCopyWith<$Res>  {
  factory $DuaCopyWith(Dua value, $Res Function(Dua) _then) = _$DuaCopyWithImpl;
@useResult
$Res call({
 String id, String arabic, String? transliteration, String translation, String reference, int repetitions, int wordCount
});




}
/// @nodoc
class _$DuaCopyWithImpl<$Res>
    implements $DuaCopyWith<$Res> {
  _$DuaCopyWithImpl(this._self, this._then);

  final Dua _self;
  final $Res Function(Dua) _then;

/// Create a copy of Dua
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? arabic = null,Object? transliteration = freezed,Object? translation = null,Object? reference = null,Object? repetitions = null,Object? wordCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,transliteration: freezed == transliteration ? _self.transliteration : transliteration // ignore: cast_nullable_to_non_nullable
as String?,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,repetitions: null == repetitions ? _self.repetitions : repetitions // ignore: cast_nullable_to_non_nullable
as int,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Dua].
extension DuaPatterns on Dua {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dua value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dua() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dua value)  $default,){
final _that = this;
switch (_that) {
case _Dua():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dua value)?  $default,){
final _that = this;
switch (_that) {
case _Dua() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String arabic,  String? transliteration,  String translation,  String reference,  int repetitions,  int wordCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dua() when $default != null:
return $default(_that.id,_that.arabic,_that.transliteration,_that.translation,_that.reference,_that.repetitions,_that.wordCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String arabic,  String? transliteration,  String translation,  String reference,  int repetitions,  int wordCount)  $default,) {final _that = this;
switch (_that) {
case _Dua():
return $default(_that.id,_that.arabic,_that.transliteration,_that.translation,_that.reference,_that.repetitions,_that.wordCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String arabic,  String? transliteration,  String translation,  String reference,  int repetitions,  int wordCount)?  $default,) {final _that = this;
switch (_that) {
case _Dua() when $default != null:
return $default(_that.id,_that.arabic,_that.transliteration,_that.translation,_that.reference,_that.repetitions,_that.wordCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dua implements Dua {
  const _Dua({required this.id, required this.arabic, this.transliteration, required this.translation, required this.reference, required this.repetitions, required this.wordCount});
  factory _Dua.fromJson(Map<String, dynamic> json) => _$DuaFromJson(json);

@override final  String id;
@override final  String arabic;
@override final  String? transliteration;
@override final  String translation;
@override final  String reference;
@override final  int repetitions;
@override final  int wordCount;

/// Create a copy of Dua
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DuaCopyWith<_Dua> get copyWith => __$DuaCopyWithImpl<_Dua>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DuaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dua&&(identical(other.id, id) || other.id == id)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.transliteration, transliteration) || other.transliteration == transliteration)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.repetitions, repetitions) || other.repetitions == repetitions)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,arabic,transliteration,translation,reference,repetitions,wordCount);

@override
String toString() {
  return 'Dua(id: $id, arabic: $arabic, transliteration: $transliteration, translation: $translation, reference: $reference, repetitions: $repetitions, wordCount: $wordCount)';
}


}

/// @nodoc
abstract mixin class _$DuaCopyWith<$Res> implements $DuaCopyWith<$Res> {
  factory _$DuaCopyWith(_Dua value, $Res Function(_Dua) _then) = __$DuaCopyWithImpl;
@override @useResult
$Res call({
 String id, String arabic, String? transliteration, String translation, String reference, int repetitions, int wordCount
});




}
/// @nodoc
class __$DuaCopyWithImpl<$Res>
    implements _$DuaCopyWith<$Res> {
  __$DuaCopyWithImpl(this._self, this._then);

  final _Dua _self;
  final $Res Function(_Dua) _then;

/// Create a copy of Dua
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? arabic = null,Object? transliteration = freezed,Object? translation = null,Object? reference = null,Object? repetitions = null,Object? wordCount = null,}) {
  return _then(_Dua(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,transliteration: freezed == transliteration ? _self.transliteration : transliteration // ignore: cast_nullable_to_non_nullable
as String?,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,repetitions: null == repetitions ? _self.repetitions : repetitions // ignore: cast_nullable_to_non_nullable
as int,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DuaCategory {

 String get id; String get titleEnglish; int get order; List<Dua> get duas;
/// Create a copy of DuaCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuaCategoryCopyWith<DuaCategory> get copyWith => _$DuaCategoryCopyWithImpl<DuaCategory>(this as DuaCategory, _$identity);

  /// Serializes this DuaCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DuaCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.titleEnglish, titleEnglish) || other.titleEnglish == titleEnglish)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other.duas, duas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleEnglish,order,const DeepCollectionEquality().hash(duas));

@override
String toString() {
  return 'DuaCategory(id: $id, titleEnglish: $titleEnglish, order: $order, duas: $duas)';
}


}

/// @nodoc
abstract mixin class $DuaCategoryCopyWith<$Res>  {
  factory $DuaCategoryCopyWith(DuaCategory value, $Res Function(DuaCategory) _then) = _$DuaCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String titleEnglish, int order, List<Dua> duas
});




}
/// @nodoc
class _$DuaCategoryCopyWithImpl<$Res>
    implements $DuaCategoryCopyWith<$Res> {
  _$DuaCategoryCopyWithImpl(this._self, this._then);

  final DuaCategory _self;
  final $Res Function(DuaCategory) _then;

/// Create a copy of DuaCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleEnglish = null,Object? order = null,Object? duas = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleEnglish: null == titleEnglish ? _self.titleEnglish : titleEnglish // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,duas: null == duas ? _self.duas : duas // ignore: cast_nullable_to_non_nullable
as List<Dua>,
  ));
}

}


/// Adds pattern-matching-related methods to [DuaCategory].
extension DuaCategoryPatterns on DuaCategory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DuaCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DuaCategory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DuaCategory value)  $default,){
final _that = this;
switch (_that) {
case _DuaCategory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DuaCategory value)?  $default,){
final _that = this;
switch (_that) {
case _DuaCategory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String titleEnglish,  int order,  List<Dua> duas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DuaCategory() when $default != null:
return $default(_that.id,_that.titleEnglish,_that.order,_that.duas);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String titleEnglish,  int order,  List<Dua> duas)  $default,) {final _that = this;
switch (_that) {
case _DuaCategory():
return $default(_that.id,_that.titleEnglish,_that.order,_that.duas);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String titleEnglish,  int order,  List<Dua> duas)?  $default,) {final _that = this;
switch (_that) {
case _DuaCategory() when $default != null:
return $default(_that.id,_that.titleEnglish,_that.order,_that.duas);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DuaCategory implements DuaCategory {
  const _DuaCategory({required this.id, required this.titleEnglish, required this.order, required final  List<Dua> duas}): _duas = duas;
  factory _DuaCategory.fromJson(Map<String, dynamic> json) => _$DuaCategoryFromJson(json);

@override final  String id;
@override final  String titleEnglish;
@override final  int order;
 final  List<Dua> _duas;
@override List<Dua> get duas {
  if (_duas is EqualUnmodifiableListView) return _duas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_duas);
}


/// Create a copy of DuaCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DuaCategoryCopyWith<_DuaCategory> get copyWith => __$DuaCategoryCopyWithImpl<_DuaCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DuaCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DuaCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.titleEnglish, titleEnglish) || other.titleEnglish == titleEnglish)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other._duas, _duas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleEnglish,order,const DeepCollectionEquality().hash(_duas));

@override
String toString() {
  return 'DuaCategory(id: $id, titleEnglish: $titleEnglish, order: $order, duas: $duas)';
}


}

/// @nodoc
abstract mixin class _$DuaCategoryCopyWith<$Res> implements $DuaCategoryCopyWith<$Res> {
  factory _$DuaCategoryCopyWith(_DuaCategory value, $Res Function(_DuaCategory) _then) = __$DuaCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String titleEnglish, int order, List<Dua> duas
});




}
/// @nodoc
class __$DuaCategoryCopyWithImpl<$Res>
    implements _$DuaCategoryCopyWith<$Res> {
  __$DuaCategoryCopyWithImpl(this._self, this._then);

  final _DuaCategory _self;
  final $Res Function(_DuaCategory) _then;

/// Create a copy of DuaCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleEnglish = null,Object? order = null,Object? duas = null,}) {
  return _then(_DuaCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleEnglish: null == titleEnglish ? _self.titleEnglish : titleEnglish // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,duas: null == duas ? _self._duas : duas // ignore: cast_nullable_to_non_nullable
as List<Dua>,
  ));
}


}


/// @nodoc
mixin _$HisnulMuslim {

 List<DuaCategory> get categories;
/// Create a copy of HisnulMuslim
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HisnulMuslimCopyWith<HisnulMuslim> get copyWith => _$HisnulMuslimCopyWithImpl<HisnulMuslim>(this as HisnulMuslim, _$identity);

  /// Serializes this HisnulMuslim to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HisnulMuslim&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'HisnulMuslim(categories: $categories)';
}


}

/// @nodoc
abstract mixin class $HisnulMuslimCopyWith<$Res>  {
  factory $HisnulMuslimCopyWith(HisnulMuslim value, $Res Function(HisnulMuslim) _then) = _$HisnulMuslimCopyWithImpl;
@useResult
$Res call({
 List<DuaCategory> categories
});




}
/// @nodoc
class _$HisnulMuslimCopyWithImpl<$Res>
    implements $HisnulMuslimCopyWith<$Res> {
  _$HisnulMuslimCopyWithImpl(this._self, this._then);

  final HisnulMuslim _self;
  final $Res Function(HisnulMuslim) _then;

/// Create a copy of HisnulMuslim
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,}) {
  return _then(_self.copyWith(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<DuaCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [HisnulMuslim].
extension HisnulMuslimPatterns on HisnulMuslim {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HisnulMuslim value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HisnulMuslim() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HisnulMuslim value)  $default,){
final _that = this;
switch (_that) {
case _HisnulMuslim():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HisnulMuslim value)?  $default,){
final _that = this;
switch (_that) {
case _HisnulMuslim() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DuaCategory> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HisnulMuslim() when $default != null:
return $default(_that.categories);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DuaCategory> categories)  $default,) {final _that = this;
switch (_that) {
case _HisnulMuslim():
return $default(_that.categories);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DuaCategory> categories)?  $default,) {final _that = this;
switch (_that) {
case _HisnulMuslim() when $default != null:
return $default(_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HisnulMuslim implements HisnulMuslim {
  const _HisnulMuslim({required final  List<DuaCategory> categories}): _categories = categories;
  factory _HisnulMuslim.fromJson(Map<String, dynamic> json) => _$HisnulMuslimFromJson(json);

 final  List<DuaCategory> _categories;
@override List<DuaCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of HisnulMuslim
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HisnulMuslimCopyWith<_HisnulMuslim> get copyWith => __$HisnulMuslimCopyWithImpl<_HisnulMuslim>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HisnulMuslimToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HisnulMuslim&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'HisnulMuslim(categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$HisnulMuslimCopyWith<$Res> implements $HisnulMuslimCopyWith<$Res> {
  factory _$HisnulMuslimCopyWith(_HisnulMuslim value, $Res Function(_HisnulMuslim) _then) = __$HisnulMuslimCopyWithImpl;
@override @useResult
$Res call({
 List<DuaCategory> categories
});




}
/// @nodoc
class __$HisnulMuslimCopyWithImpl<$Res>
    implements _$HisnulMuslimCopyWith<$Res> {
  __$HisnulMuslimCopyWithImpl(this._self, this._then);

  final _HisnulMuslim _self;
  final $Res Function(_HisnulMuslim) _then;

/// Create a copy of HisnulMuslim
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,}) {
  return _then(_HisnulMuslim(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<DuaCategory>,
  ));
}


}


/// @nodoc
mixin _$AdhkarSet {

 List<Dhikr> get morning; List<Dhikr> get evening;
/// Create a copy of AdhkarSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdhkarSetCopyWith<AdhkarSet> get copyWith => _$AdhkarSetCopyWithImpl<AdhkarSet>(this as AdhkarSet, _$identity);

  /// Serializes this AdhkarSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdhkarSet&&const DeepCollectionEquality().equals(other.morning, morning)&&const DeepCollectionEquality().equals(other.evening, evening));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(morning),const DeepCollectionEquality().hash(evening));

@override
String toString() {
  return 'AdhkarSet(morning: $morning, evening: $evening)';
}


}

/// @nodoc
abstract mixin class $AdhkarSetCopyWith<$Res>  {
  factory $AdhkarSetCopyWith(AdhkarSet value, $Res Function(AdhkarSet) _then) = _$AdhkarSetCopyWithImpl;
@useResult
$Res call({
 List<Dhikr> morning, List<Dhikr> evening
});




}
/// @nodoc
class _$AdhkarSetCopyWithImpl<$Res>
    implements $AdhkarSetCopyWith<$Res> {
  _$AdhkarSetCopyWithImpl(this._self, this._then);

  final AdhkarSet _self;
  final $Res Function(AdhkarSet) _then;

/// Create a copy of AdhkarSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? morning = null,Object? evening = null,}) {
  return _then(_self.copyWith(
morning: null == morning ? _self.morning : morning // ignore: cast_nullable_to_non_nullable
as List<Dhikr>,evening: null == evening ? _self.evening : evening // ignore: cast_nullable_to_non_nullable
as List<Dhikr>,
  ));
}

}


/// Adds pattern-matching-related methods to [AdhkarSet].
extension AdhkarSetPatterns on AdhkarSet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdhkarSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdhkarSet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdhkarSet value)  $default,){
final _that = this;
switch (_that) {
case _AdhkarSet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdhkarSet value)?  $default,){
final _that = this;
switch (_that) {
case _AdhkarSet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Dhikr> morning,  List<Dhikr> evening)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdhkarSet() when $default != null:
return $default(_that.morning,_that.evening);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Dhikr> morning,  List<Dhikr> evening)  $default,) {final _that = this;
switch (_that) {
case _AdhkarSet():
return $default(_that.morning,_that.evening);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Dhikr> morning,  List<Dhikr> evening)?  $default,) {final _that = this;
switch (_that) {
case _AdhkarSet() when $default != null:
return $default(_that.morning,_that.evening);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdhkarSet implements AdhkarSet {
  const _AdhkarSet({required final  List<Dhikr> morning, required final  List<Dhikr> evening}): _morning = morning,_evening = evening;
  factory _AdhkarSet.fromJson(Map<String, dynamic> json) => _$AdhkarSetFromJson(json);

 final  List<Dhikr> _morning;
@override List<Dhikr> get morning {
  if (_morning is EqualUnmodifiableListView) return _morning;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_morning);
}

 final  List<Dhikr> _evening;
@override List<Dhikr> get evening {
  if (_evening is EqualUnmodifiableListView) return _evening;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evening);
}


/// Create a copy of AdhkarSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdhkarSetCopyWith<_AdhkarSet> get copyWith => __$AdhkarSetCopyWithImpl<_AdhkarSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdhkarSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdhkarSet&&const DeepCollectionEquality().equals(other._morning, _morning)&&const DeepCollectionEquality().equals(other._evening, _evening));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_morning),const DeepCollectionEquality().hash(_evening));

@override
String toString() {
  return 'AdhkarSet(morning: $morning, evening: $evening)';
}


}

/// @nodoc
abstract mixin class _$AdhkarSetCopyWith<$Res> implements $AdhkarSetCopyWith<$Res> {
  factory _$AdhkarSetCopyWith(_AdhkarSet value, $Res Function(_AdhkarSet) _then) = __$AdhkarSetCopyWithImpl;
@override @useResult
$Res call({
 List<Dhikr> morning, List<Dhikr> evening
});




}
/// @nodoc
class __$AdhkarSetCopyWithImpl<$Res>
    implements _$AdhkarSetCopyWith<$Res> {
  __$AdhkarSetCopyWithImpl(this._self, this._then);

  final _AdhkarSet _self;
  final $Res Function(_AdhkarSet) _then;

/// Create a copy of AdhkarSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? morning = null,Object? evening = null,}) {
  return _then(_AdhkarSet(
morning: null == morning ? _self._morning : morning // ignore: cast_nullable_to_non_nullable
as List<Dhikr>,evening: null == evening ? _self._evening : evening // ignore: cast_nullable_to_non_nullable
as List<Dhikr>,
  ));
}


}

// dart format on
