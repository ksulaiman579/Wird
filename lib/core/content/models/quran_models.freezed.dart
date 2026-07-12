// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quran_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SurahMeta {

 int get number; String get nameArabic; String get nameTransliterated; String get nameEnglish; int get ayahCount; String get revelationType; int get startJuz;
/// Create a copy of SurahMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurahMetaCopyWith<SurahMeta> get copyWith => _$SurahMetaCopyWithImpl<SurahMeta>(this as SurahMeta, _$identity);

  /// Serializes this SurahMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurahMeta&&(identical(other.number, number) || other.number == number)&&(identical(other.nameArabic, nameArabic) || other.nameArabic == nameArabic)&&(identical(other.nameTransliterated, nameTransliterated) || other.nameTransliterated == nameTransliterated)&&(identical(other.nameEnglish, nameEnglish) || other.nameEnglish == nameEnglish)&&(identical(other.ayahCount, ayahCount) || other.ayahCount == ayahCount)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.startJuz, startJuz) || other.startJuz == startJuz));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,nameArabic,nameTransliterated,nameEnglish,ayahCount,revelationType,startJuz);

@override
String toString() {
  return 'SurahMeta(number: $number, nameArabic: $nameArabic, nameTransliterated: $nameTransliterated, nameEnglish: $nameEnglish, ayahCount: $ayahCount, revelationType: $revelationType, startJuz: $startJuz)';
}


}

/// @nodoc
abstract mixin class $SurahMetaCopyWith<$Res>  {
  factory $SurahMetaCopyWith(SurahMeta value, $Res Function(SurahMeta) _then) = _$SurahMetaCopyWithImpl;
@useResult
$Res call({
 int number, String nameArabic, String nameTransliterated, String nameEnglish, int ayahCount, String revelationType, int startJuz
});




}
/// @nodoc
class _$SurahMetaCopyWithImpl<$Res>
    implements $SurahMetaCopyWith<$Res> {
  _$SurahMetaCopyWithImpl(this._self, this._then);

  final SurahMeta _self;
  final $Res Function(SurahMeta) _then;

/// Create a copy of SurahMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? nameArabic = null,Object? nameTransliterated = null,Object? nameEnglish = null,Object? ayahCount = null,Object? revelationType = null,Object? startJuz = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,nameArabic: null == nameArabic ? _self.nameArabic : nameArabic // ignore: cast_nullable_to_non_nullable
as String,nameTransliterated: null == nameTransliterated ? _self.nameTransliterated : nameTransliterated // ignore: cast_nullable_to_non_nullable
as String,nameEnglish: null == nameEnglish ? _self.nameEnglish : nameEnglish // ignore: cast_nullable_to_non_nullable
as String,ayahCount: null == ayahCount ? _self.ayahCount : ayahCount // ignore: cast_nullable_to_non_nullable
as int,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,startJuz: null == startJuz ? _self.startJuz : startJuz // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SurahMeta].
extension SurahMetaPatterns on SurahMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurahMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurahMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurahMeta value)  $default,){
final _that = this;
switch (_that) {
case _SurahMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurahMeta value)?  $default,){
final _that = this;
switch (_that) {
case _SurahMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String nameArabic,  String nameTransliterated,  String nameEnglish,  int ayahCount,  String revelationType,  int startJuz)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurahMeta() when $default != null:
return $default(_that.number,_that.nameArabic,_that.nameTransliterated,_that.nameEnglish,_that.ayahCount,_that.revelationType,_that.startJuz);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String nameArabic,  String nameTransliterated,  String nameEnglish,  int ayahCount,  String revelationType,  int startJuz)  $default,) {final _that = this;
switch (_that) {
case _SurahMeta():
return $default(_that.number,_that.nameArabic,_that.nameTransliterated,_that.nameEnglish,_that.ayahCount,_that.revelationType,_that.startJuz);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String nameArabic,  String nameTransliterated,  String nameEnglish,  int ayahCount,  String revelationType,  int startJuz)?  $default,) {final _that = this;
switch (_that) {
case _SurahMeta() when $default != null:
return $default(_that.number,_that.nameArabic,_that.nameTransliterated,_that.nameEnglish,_that.ayahCount,_that.revelationType,_that.startJuz);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurahMeta implements SurahMeta {
  const _SurahMeta({required this.number, required this.nameArabic, required this.nameTransliterated, required this.nameEnglish, required this.ayahCount, required this.revelationType, required this.startJuz});
  factory _SurahMeta.fromJson(Map<String, dynamic> json) => _$SurahMetaFromJson(json);

@override final  int number;
@override final  String nameArabic;
@override final  String nameTransliterated;
@override final  String nameEnglish;
@override final  int ayahCount;
@override final  String revelationType;
@override final  int startJuz;

/// Create a copy of SurahMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurahMetaCopyWith<_SurahMeta> get copyWith => __$SurahMetaCopyWithImpl<_SurahMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurahMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurahMeta&&(identical(other.number, number) || other.number == number)&&(identical(other.nameArabic, nameArabic) || other.nameArabic == nameArabic)&&(identical(other.nameTransliterated, nameTransliterated) || other.nameTransliterated == nameTransliterated)&&(identical(other.nameEnglish, nameEnglish) || other.nameEnglish == nameEnglish)&&(identical(other.ayahCount, ayahCount) || other.ayahCount == ayahCount)&&(identical(other.revelationType, revelationType) || other.revelationType == revelationType)&&(identical(other.startJuz, startJuz) || other.startJuz == startJuz));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,nameArabic,nameTransliterated,nameEnglish,ayahCount,revelationType,startJuz);

@override
String toString() {
  return 'SurahMeta(number: $number, nameArabic: $nameArabic, nameTransliterated: $nameTransliterated, nameEnglish: $nameEnglish, ayahCount: $ayahCount, revelationType: $revelationType, startJuz: $startJuz)';
}


}

/// @nodoc
abstract mixin class _$SurahMetaCopyWith<$Res> implements $SurahMetaCopyWith<$Res> {
  factory _$SurahMetaCopyWith(_SurahMeta value, $Res Function(_SurahMeta) _then) = __$SurahMetaCopyWithImpl;
@override @useResult
$Res call({
 int number, String nameArabic, String nameTransliterated, String nameEnglish, int ayahCount, String revelationType, int startJuz
});




}
/// @nodoc
class __$SurahMetaCopyWithImpl<$Res>
    implements _$SurahMetaCopyWith<$Res> {
  __$SurahMetaCopyWithImpl(this._self, this._then);

  final _SurahMeta _self;
  final $Res Function(_SurahMeta) _then;

/// Create a copy of SurahMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? nameArabic = null,Object? nameTransliterated = null,Object? nameEnglish = null,Object? ayahCount = null,Object? revelationType = null,Object? startJuz = null,}) {
  return _then(_SurahMeta(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,nameArabic: null == nameArabic ? _self.nameArabic : nameArabic // ignore: cast_nullable_to_non_nullable
as String,nameTransliterated: null == nameTransliterated ? _self.nameTransliterated : nameTransliterated // ignore: cast_nullable_to_non_nullable
as String,nameEnglish: null == nameEnglish ? _self.nameEnglish : nameEnglish // ignore: cast_nullable_to_non_nullable
as String,ayahCount: null == ayahCount ? _self.ayahCount : ayahCount // ignore: cast_nullable_to_non_nullable
as int,revelationType: null == revelationType ? _self.revelationType : revelationType // ignore: cast_nullable_to_non_nullable
as String,startJuz: null == startJuz ? _self.startJuz : startJuz // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AyahRef {

 int get surah; int get ayah;
/// Create a copy of AyahRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahRefCopyWith<AyahRef> get copyWith => _$AyahRefCopyWithImpl<AyahRef>(this as AyahRef, _$identity);

  /// Serializes this AyahRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahRef&&(identical(other.surah, surah) || other.surah == surah)&&(identical(other.ayah, ayah) || other.ayah == ayah));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surah,ayah);

@override
String toString() {
  return 'AyahRef(surah: $surah, ayah: $ayah)';
}


}

/// @nodoc
abstract mixin class $AyahRefCopyWith<$Res>  {
  factory $AyahRefCopyWith(AyahRef value, $Res Function(AyahRef) _then) = _$AyahRefCopyWithImpl;
@useResult
$Res call({
 int surah, int ayah
});




}
/// @nodoc
class _$AyahRefCopyWithImpl<$Res>
    implements $AyahRefCopyWith<$Res> {
  _$AyahRefCopyWithImpl(this._self, this._then);

  final AyahRef _self;
  final $Res Function(AyahRef) _then;

/// Create a copy of AyahRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surah = null,Object? ayah = null,}) {
  return _then(_self.copyWith(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AyahRef].
extension AyahRefPatterns on AyahRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyahRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyahRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyahRef value)  $default,){
final _that = this;
switch (_that) {
case _AyahRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyahRef value)?  $default,){
final _that = this;
switch (_that) {
case _AyahRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int surah,  int ayah)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahRef() when $default != null:
return $default(_that.surah,_that.ayah);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int surah,  int ayah)  $default,) {final _that = this;
switch (_that) {
case _AyahRef():
return $default(_that.surah,_that.ayah);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int surah,  int ayah)?  $default,) {final _that = this;
switch (_that) {
case _AyahRef() when $default != null:
return $default(_that.surah,_that.ayah);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AyahRef implements AyahRef {
  const _AyahRef({required this.surah, required this.ayah});
  factory _AyahRef.fromJson(Map<String, dynamic> json) => _$AyahRefFromJson(json);

@override final  int surah;
@override final  int ayah;

/// Create a copy of AyahRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahRefCopyWith<_AyahRef> get copyWith => __$AyahRefCopyWithImpl<_AyahRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AyahRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahRef&&(identical(other.surah, surah) || other.surah == surah)&&(identical(other.ayah, ayah) || other.ayah == ayah));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surah,ayah);

@override
String toString() {
  return 'AyahRef(surah: $surah, ayah: $ayah)';
}


}

/// @nodoc
abstract mixin class _$AyahRefCopyWith<$Res> implements $AyahRefCopyWith<$Res> {
  factory _$AyahRefCopyWith(_AyahRef value, $Res Function(_AyahRef) _then) = __$AyahRefCopyWithImpl;
@override @useResult
$Res call({
 int surah, int ayah
});




}
/// @nodoc
class __$AyahRefCopyWithImpl<$Res>
    implements _$AyahRefCopyWith<$Res> {
  __$AyahRefCopyWithImpl(this._self, this._then);

  final _AyahRef _self;
  final $Res Function(_AyahRef) _then;

/// Create a copy of AyahRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surah = null,Object? ayah = null,}) {
  return _then(_AyahRef(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$JuzSpan {

 int get juz; AyahRef get start; AyahRef get end;
/// Create a copy of JuzSpan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JuzSpanCopyWith<JuzSpan> get copyWith => _$JuzSpanCopyWithImpl<JuzSpan>(this as JuzSpan, _$identity);

  /// Serializes this JuzSpan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JuzSpan&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,juz,start,end);

@override
String toString() {
  return 'JuzSpan(juz: $juz, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $JuzSpanCopyWith<$Res>  {
  factory $JuzSpanCopyWith(JuzSpan value, $Res Function(JuzSpan) _then) = _$JuzSpanCopyWithImpl;
@useResult
$Res call({
 int juz, AyahRef start, AyahRef end
});


$AyahRefCopyWith<$Res> get start;$AyahRefCopyWith<$Res> get end;

}
/// @nodoc
class _$JuzSpanCopyWithImpl<$Res>
    implements $JuzSpanCopyWith<$Res> {
  _$JuzSpanCopyWithImpl(this._self, this._then);

  final JuzSpan _self;
  final $Res Function(JuzSpan) _then;

/// Create a copy of JuzSpan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? juz = null,Object? start = null,Object? end = null,}) {
  return _then(_self.copyWith(
juz: null == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as AyahRef,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as AyahRef,
  ));
}
/// Create a copy of JuzSpan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRefCopyWith<$Res> get start {
  
  return $AyahRefCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of JuzSpan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRefCopyWith<$Res> get end {
  
  return $AyahRefCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}


/// Adds pattern-matching-related methods to [JuzSpan].
extension JuzSpanPatterns on JuzSpan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JuzSpan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JuzSpan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JuzSpan value)  $default,){
final _that = this;
switch (_that) {
case _JuzSpan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JuzSpan value)?  $default,){
final _that = this;
switch (_that) {
case _JuzSpan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int juz,  AyahRef start,  AyahRef end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JuzSpan() when $default != null:
return $default(_that.juz,_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int juz,  AyahRef start,  AyahRef end)  $default,) {final _that = this;
switch (_that) {
case _JuzSpan():
return $default(_that.juz,_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int juz,  AyahRef start,  AyahRef end)?  $default,) {final _that = this;
switch (_that) {
case _JuzSpan() when $default != null:
return $default(_that.juz,_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JuzSpan implements JuzSpan {
  const _JuzSpan({required this.juz, required this.start, required this.end});
  factory _JuzSpan.fromJson(Map<String, dynamic> json) => _$JuzSpanFromJson(json);

@override final  int juz;
@override final  AyahRef start;
@override final  AyahRef end;

/// Create a copy of JuzSpan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JuzSpanCopyWith<_JuzSpan> get copyWith => __$JuzSpanCopyWithImpl<_JuzSpan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JuzSpanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JuzSpan&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,juz,start,end);

@override
String toString() {
  return 'JuzSpan(juz: $juz, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$JuzSpanCopyWith<$Res> implements $JuzSpanCopyWith<$Res> {
  factory _$JuzSpanCopyWith(_JuzSpan value, $Res Function(_JuzSpan) _then) = __$JuzSpanCopyWithImpl;
@override @useResult
$Res call({
 int juz, AyahRef start, AyahRef end
});


@override $AyahRefCopyWith<$Res> get start;@override $AyahRefCopyWith<$Res> get end;

}
/// @nodoc
class __$JuzSpanCopyWithImpl<$Res>
    implements _$JuzSpanCopyWith<$Res> {
  __$JuzSpanCopyWithImpl(this._self, this._then);

  final _JuzSpan _self;
  final $Res Function(_JuzSpan) _then;

/// Create a copy of JuzSpan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? juz = null,Object? start = null,Object? end = null,}) {
  return _then(_JuzSpan(
juz: null == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as AyahRef,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as AyahRef,
  ));
}

/// Create a copy of JuzSpan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRefCopyWith<$Res> get start {
  
  return $AyahRefCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of JuzSpan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRefCopyWith<$Res> get end {
  
  return $AyahRefCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}


/// @nodoc
mixin _$QuranMeta {

 List<SurahMeta> get surahs; List<JuzSpan> get juzMap;
/// Create a copy of QuranMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuranMetaCopyWith<QuranMeta> get copyWith => _$QuranMetaCopyWithImpl<QuranMeta>(this as QuranMeta, _$identity);

  /// Serializes this QuranMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuranMeta&&const DeepCollectionEquality().equals(other.surahs, surahs)&&const DeepCollectionEquality().equals(other.juzMap, juzMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(surahs),const DeepCollectionEquality().hash(juzMap));

@override
String toString() {
  return 'QuranMeta(surahs: $surahs, juzMap: $juzMap)';
}


}

/// @nodoc
abstract mixin class $QuranMetaCopyWith<$Res>  {
  factory $QuranMetaCopyWith(QuranMeta value, $Res Function(QuranMeta) _then) = _$QuranMetaCopyWithImpl;
@useResult
$Res call({
 List<SurahMeta> surahs, List<JuzSpan> juzMap
});




}
/// @nodoc
class _$QuranMetaCopyWithImpl<$Res>
    implements $QuranMetaCopyWith<$Res> {
  _$QuranMetaCopyWithImpl(this._self, this._then);

  final QuranMeta _self;
  final $Res Function(QuranMeta) _then;

/// Create a copy of QuranMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surahs = null,Object? juzMap = null,}) {
  return _then(_self.copyWith(
surahs: null == surahs ? _self.surahs : surahs // ignore: cast_nullable_to_non_nullable
as List<SurahMeta>,juzMap: null == juzMap ? _self.juzMap : juzMap // ignore: cast_nullable_to_non_nullable
as List<JuzSpan>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuranMeta].
extension QuranMetaPatterns on QuranMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuranMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuranMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuranMeta value)  $default,){
final _that = this;
switch (_that) {
case _QuranMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuranMeta value)?  $default,){
final _that = this;
switch (_that) {
case _QuranMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SurahMeta> surahs,  List<JuzSpan> juzMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuranMeta() when $default != null:
return $default(_that.surahs,_that.juzMap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SurahMeta> surahs,  List<JuzSpan> juzMap)  $default,) {final _that = this;
switch (_that) {
case _QuranMeta():
return $default(_that.surahs,_that.juzMap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SurahMeta> surahs,  List<JuzSpan> juzMap)?  $default,) {final _that = this;
switch (_that) {
case _QuranMeta() when $default != null:
return $default(_that.surahs,_that.juzMap);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuranMeta implements QuranMeta {
  const _QuranMeta({required final  List<SurahMeta> surahs, required final  List<JuzSpan> juzMap}): _surahs = surahs,_juzMap = juzMap;
  factory _QuranMeta.fromJson(Map<String, dynamic> json) => _$QuranMetaFromJson(json);

 final  List<SurahMeta> _surahs;
@override List<SurahMeta> get surahs {
  if (_surahs is EqualUnmodifiableListView) return _surahs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surahs);
}

 final  List<JuzSpan> _juzMap;
@override List<JuzSpan> get juzMap {
  if (_juzMap is EqualUnmodifiableListView) return _juzMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_juzMap);
}


/// Create a copy of QuranMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuranMetaCopyWith<_QuranMeta> get copyWith => __$QuranMetaCopyWithImpl<_QuranMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuranMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuranMeta&&const DeepCollectionEquality().equals(other._surahs, _surahs)&&const DeepCollectionEquality().equals(other._juzMap, _juzMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_surahs),const DeepCollectionEquality().hash(_juzMap));

@override
String toString() {
  return 'QuranMeta(surahs: $surahs, juzMap: $juzMap)';
}


}

/// @nodoc
abstract mixin class _$QuranMetaCopyWith<$Res> implements $QuranMetaCopyWith<$Res> {
  factory _$QuranMetaCopyWith(_QuranMeta value, $Res Function(_QuranMeta) _then) = __$QuranMetaCopyWithImpl;
@override @useResult
$Res call({
 List<SurahMeta> surahs, List<JuzSpan> juzMap
});




}
/// @nodoc
class __$QuranMetaCopyWithImpl<$Res>
    implements _$QuranMetaCopyWith<$Res> {
  __$QuranMetaCopyWithImpl(this._self, this._then);

  final _QuranMeta _self;
  final $Res Function(_QuranMeta) _then;

/// Create a copy of QuranMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surahs = null,Object? juzMap = null,}) {
  return _then(_QuranMeta(
surahs: null == surahs ? _self._surahs : surahs // ignore: cast_nullable_to_non_nullable
as List<SurahMeta>,juzMap: null == juzMap ? _self._juzMap : juzMap // ignore: cast_nullable_to_non_nullable
as List<JuzSpan>,
  ));
}


}


/// @nodoc
mixin _$Ayah {

 int get ayah; String get arabic; String get translation; String get transliteration; int get juz; int get wordCount;
/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahCopyWith<Ayah> get copyWith => _$AyahCopyWithImpl<Ayah>(this as Ayah, _$identity);

  /// Serializes this Ayah to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ayah&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.transliteration, transliteration) || other.transliteration == transliteration)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ayah,arabic,translation,transliteration,juz,wordCount);

@override
String toString() {
  return 'Ayah(ayah: $ayah, arabic: $arabic, translation: $translation, transliteration: $transliteration, juz: $juz, wordCount: $wordCount)';
}


}

/// @nodoc
abstract mixin class $AyahCopyWith<$Res>  {
  factory $AyahCopyWith(Ayah value, $Res Function(Ayah) _then) = _$AyahCopyWithImpl;
@useResult
$Res call({
 int ayah, String arabic, String translation, String transliteration, int juz, int wordCount
});




}
/// @nodoc
class _$AyahCopyWithImpl<$Res>
    implements $AyahCopyWith<$Res> {
  _$AyahCopyWithImpl(this._self, this._then);

  final Ayah _self;
  final $Res Function(Ayah) _then;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ayah = null,Object? arabic = null,Object? translation = null,Object? transliteration = null,Object? juz = null,Object? wordCount = null,}) {
  return _then(_self.copyWith(
ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,transliteration: null == transliteration ? _self.transliteration : transliteration // ignore: cast_nullable_to_non_nullable
as String,juz: null == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Ayah].
extension AyahPatterns on Ayah {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ayah value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ayah() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ayah value)  $default,){
final _that = this;
switch (_that) {
case _Ayah():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ayah value)?  $default,){
final _that = this;
switch (_that) {
case _Ayah() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ayah,  String arabic,  String translation,  String transliteration,  int juz,  int wordCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ayah() when $default != null:
return $default(_that.ayah,_that.arabic,_that.translation,_that.transliteration,_that.juz,_that.wordCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ayah,  String arabic,  String translation,  String transliteration,  int juz,  int wordCount)  $default,) {final _that = this;
switch (_that) {
case _Ayah():
return $default(_that.ayah,_that.arabic,_that.translation,_that.transliteration,_that.juz,_that.wordCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ayah,  String arabic,  String translation,  String transliteration,  int juz,  int wordCount)?  $default,) {final _that = this;
switch (_that) {
case _Ayah() when $default != null:
return $default(_that.ayah,_that.arabic,_that.translation,_that.transliteration,_that.juz,_that.wordCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ayah implements Ayah {
  const _Ayah({required this.ayah, required this.arabic, required this.translation, required this.transliteration, required this.juz, required this.wordCount});
  factory _Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);

@override final  int ayah;
@override final  String arabic;
@override final  String translation;
@override final  String transliteration;
@override final  int juz;
@override final  int wordCount;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahCopyWith<_Ayah> get copyWith => __$AyahCopyWithImpl<_Ayah>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AyahToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ayah&&(identical(other.ayah, ayah) || other.ayah == ayah)&&(identical(other.arabic, arabic) || other.arabic == arabic)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.transliteration, transliteration) || other.transliteration == transliteration)&&(identical(other.juz, juz) || other.juz == juz)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ayah,arabic,translation,transliteration,juz,wordCount);

@override
String toString() {
  return 'Ayah(ayah: $ayah, arabic: $arabic, translation: $translation, transliteration: $transliteration, juz: $juz, wordCount: $wordCount)';
}


}

/// @nodoc
abstract mixin class _$AyahCopyWith<$Res> implements $AyahCopyWith<$Res> {
  factory _$AyahCopyWith(_Ayah value, $Res Function(_Ayah) _then) = __$AyahCopyWithImpl;
@override @useResult
$Res call({
 int ayah, String arabic, String translation, String transliteration, int juz, int wordCount
});




}
/// @nodoc
class __$AyahCopyWithImpl<$Res>
    implements _$AyahCopyWith<$Res> {
  __$AyahCopyWithImpl(this._self, this._then);

  final _Ayah _self;
  final $Res Function(_Ayah) _then;

/// Create a copy of Ayah
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ayah = null,Object? arabic = null,Object? translation = null,Object? transliteration = null,Object? juz = null,Object? wordCount = null,}) {
  return _then(_Ayah(
ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,arabic: null == arabic ? _self.arabic : arabic // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,transliteration: null == transliteration ? _self.transliteration : transliteration // ignore: cast_nullable_to_non_nullable
as String,juz: null == juz ? _self.juz : juz // ignore: cast_nullable_to_non_nullable
as int,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Surah {

 int get surah; List<Ayah> get ayahs;
/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurahCopyWith<Surah> get copyWith => _$SurahCopyWithImpl<Surah>(this as Surah, _$identity);

  /// Serializes this Surah to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Surah&&(identical(other.surah, surah) || other.surah == surah)&&const DeepCollectionEquality().equals(other.ayahs, ayahs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surah,const DeepCollectionEquality().hash(ayahs));

@override
String toString() {
  return 'Surah(surah: $surah, ayahs: $ayahs)';
}


}

/// @nodoc
abstract mixin class $SurahCopyWith<$Res>  {
  factory $SurahCopyWith(Surah value, $Res Function(Surah) _then) = _$SurahCopyWithImpl;
@useResult
$Res call({
 int surah, List<Ayah> ayahs
});




}
/// @nodoc
class _$SurahCopyWithImpl<$Res>
    implements $SurahCopyWith<$Res> {
  _$SurahCopyWithImpl(this._self, this._then);

  final Surah _self;
  final $Res Function(Surah) _then;

/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surah = null,Object? ayahs = null,}) {
  return _then(_self.copyWith(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayahs: null == ayahs ? _self.ayahs : ayahs // ignore: cast_nullable_to_non_nullable
as List<Ayah>,
  ));
}

}


/// Adds pattern-matching-related methods to [Surah].
extension SurahPatterns on Surah {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Surah value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Surah() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Surah value)  $default,){
final _that = this;
switch (_that) {
case _Surah():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Surah value)?  $default,){
final _that = this;
switch (_that) {
case _Surah() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int surah,  List<Ayah> ayahs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Surah() when $default != null:
return $default(_that.surah,_that.ayahs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int surah,  List<Ayah> ayahs)  $default,) {final _that = this;
switch (_that) {
case _Surah():
return $default(_that.surah,_that.ayahs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int surah,  List<Ayah> ayahs)?  $default,) {final _that = this;
switch (_that) {
case _Surah() when $default != null:
return $default(_that.surah,_that.ayahs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Surah implements Surah {
  const _Surah({required this.surah, required final  List<Ayah> ayahs}): _ayahs = ayahs;
  factory _Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);

@override final  int surah;
 final  List<Ayah> _ayahs;
@override List<Ayah> get ayahs {
  if (_ayahs is EqualUnmodifiableListView) return _ayahs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ayahs);
}


/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurahCopyWith<_Surah> get copyWith => __$SurahCopyWithImpl<_Surah>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurahToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Surah&&(identical(other.surah, surah) || other.surah == surah)&&const DeepCollectionEquality().equals(other._ayahs, _ayahs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,surah,const DeepCollectionEquality().hash(_ayahs));

@override
String toString() {
  return 'Surah(surah: $surah, ayahs: $ayahs)';
}


}

/// @nodoc
abstract mixin class _$SurahCopyWith<$Res> implements $SurahCopyWith<$Res> {
  factory _$SurahCopyWith(_Surah value, $Res Function(_Surah) _then) = __$SurahCopyWithImpl;
@override @useResult
$Res call({
 int surah, List<Ayah> ayahs
});




}
/// @nodoc
class __$SurahCopyWithImpl<$Res>
    implements _$SurahCopyWith<$Res> {
  __$SurahCopyWithImpl(this._self, this._then);

  final _Surah _self;
  final $Res Function(_Surah) _then;

/// Create a copy of Surah
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surah = null,Object? ayahs = null,}) {
  return _then(_Surah(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayahs: null == ayahs ? _self._ayahs : ayahs // ignore: cast_nullable_to_non_nullable
as List<Ayah>,
  ));
}


}

// dart format on
