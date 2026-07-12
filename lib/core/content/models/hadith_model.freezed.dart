// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hadith_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Hadith {

 int get id; String get titleEnglish; String get arabic; String get translation; String get narrator; String get source; String get summary; int get wordCount; bool get core;
/// Create a copy of Hadith
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HadithCopyWith<Hadith> get copyWith => _$HadithCopyWithImpl<Hadith>(this as Hadith, _$identity);

  /// Serializes this Hadith to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hadith&&(identical(other.id, id) || other.id == id)&&(identical(other.titleEnglish, titleEnglish) || other.titleEnglish == titleEnglish)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.narrator, narrator) || other.narrator == narrator)&&(identical(other.source, source) || other.source == source)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.core, core) || other.core == core));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleEnglish,arabic,translation,narrator,source,summary,wordCount,core);

@override
String toString() {
  return 'Hadith(id: $id, titleEnglish: $titleEnglish, arabic: $arabic, translation: $translation, narrator: $narrator, source: $source, summary: $summary, wordCount: $wordCount, core: $core)';
}


}

/// @nodoc
abstract mixin class $HadithCopyWith<$Res>  {
  factory $HadithCopyWith(Hadith value, $Res Function(Hadith) _then) = _$HadithCopyWithImpl;
@useResult
$Res call({
 int id, String titleEnglish, String arabic, String translation, String narrator, String source, String summary, int wordCount, bool core
});




}
/// @nodoc
class _$HadithCopyWithImpl<$Res>
    implements $HadithCopyWith<$Res> {
  _$HadithCopyWithImpl(this._self, this._then);

  final Hadith _self;
  final $Res Function(Hadith) _then;

/// Create a copy of Hadith
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleEnglish = null,Object? arabic = null,Object? translation = null,Object? narrator = null,Object? source = null,Object? summary = null,Object? wordCount = null,Object? core = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titleEnglish: null == titleEnglish ? _self.titleEnglish : titleEnglish // ignore: cast_nullable_to_non_nullable
as String,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,narrator: null == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,core: null == core ? _self.core : core // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Hadith].
extension HadithPatterns on Hadith {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Hadith value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Hadith() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Hadith value)  $default,){
final _that = this;
switch (_that) {
case _Hadith():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Hadith value)?  $default,){
final _that = this;
switch (_that) {
case _Hadith() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String titleEnglish,  String arabic,  String translation,  String narrator,  String source,  String summary,  int wordCount,  bool core)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hadith() when $default != null:
return $default(_that.id,_that.titleEnglish,_that.arabic,_that.translation,_that.narrator,_that.source,_that.summary,_that.wordCount,_that.core);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String titleEnglish,  String arabic,  String translation,  String narrator,  String source,  String summary,  int wordCount,  bool core)  $default,) {final _that = this;
switch (_that) {
case _Hadith():
return $default(_that.id,_that.titleEnglish,_that.arabic,_that.translation,_that.narrator,_that.source,_that.summary,_that.wordCount,_that.core);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String titleEnglish,  String arabic,  String translation,  String narrator,  String source,  String summary,  int wordCount,  bool core)?  $default,) {final _that = this;
switch (_that) {
case _Hadith() when $default != null:
return $default(_that.id,_that.titleEnglish,_that.arabic,_that.translation,_that.narrator,_that.source,_that.summary,_that.wordCount,_that.core);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hadith implements Hadith {
  const _Hadith({required this.id, required this.titleEnglish, required this.arabic, required this.translation, required this.narrator, required this.source, required this.summary, required this.wordCount, required this.core});
  factory _Hadith.fromJson(Map<String, dynamic> json) => _$HadithFromJson(json);

@override final  int id;
@override final  String titleEnglish;
@override final  String arabic;
@override final  String translation;
@override final  String narrator;
@override final  String source;
@override final  String summary;
@override final  int wordCount;
@override final  bool core;

/// Create a copy of Hadith
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HadithCopyWith<_Hadith> get copyWith => __$HadithCopyWithImpl<_Hadith>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HadithToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hadith&&(identical(other.id, id) || other.id == id)&&(identical(other.titleEnglish, titleEnglish) || other.titleEnglish == titleEnglish)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.narrator, narrator) || other.narrator == narrator)&&(identical(other.source, source) || other.source == source)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.core, core) || other.core == core));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleEnglish,arabic,translation,narrator,source,summary,wordCount,core);

@override
String toString() {
  return 'Hadith(id: $id, titleEnglish: $titleEnglish, arabic: $arabic, translation: $translation, narrator: $narrator, source: $source, summary: $summary, wordCount: $wordCount, core: $core)';
}


}

/// @nodoc
abstract mixin class _$HadithCopyWith<$Res> implements $HadithCopyWith<$Res> {
  factory _$HadithCopyWith(_Hadith value, $Res Function(_Hadith) _then) = __$HadithCopyWithImpl;
@override @useResult
$Res call({
 int id, String titleEnglish, String arabic, String translation, String narrator, String source, String summary, int wordCount, bool core
});




}
/// @nodoc
class __$HadithCopyWithImpl<$Res>
    implements _$HadithCopyWith<$Res> {
  __$HadithCopyWithImpl(this._self, this._then);

  final _Hadith _self;
  final $Res Function(_Hadith) _then;

/// Create a copy of Hadith
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleEnglish = null,Object? arabic = null,Object? translation = null,Object? narrator = null,Object? source = null,Object? summary = null,Object? wordCount = null,Object? core = null,}) {
  return _then(_Hadith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,titleEnglish: null == titleEnglish ? _self.titleEnglish : titleEnglish // ignore: cast_nullable_to_non_nullable
as String,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,narrator: null == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,core: null == core ? _self.core : core // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
