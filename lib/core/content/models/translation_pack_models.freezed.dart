// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_pack_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranslationEditionEntry {

 String get id; String get language; String get languageCode; String get author; String get link; String? get sha256;
/// Create a copy of TranslationEditionEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationEditionEntryCopyWith<TranslationEditionEntry> get copyWith => _$TranslationEditionEntryCopyWithImpl<TranslationEditionEntry>(this as TranslationEditionEntry, _$identity);

  /// Serializes this TranslationEditionEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationEditionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.language, language) || other.language == language)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.author, author) || other.author == author)&&(identical(other.link, link) || other.link == link)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,language,languageCode,author,link,sha256);

@override
String toString() {
  return 'TranslationEditionEntry(id: $id, language: $language, languageCode: $languageCode, author: $author, link: $link, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class $TranslationEditionEntryCopyWith<$Res>  {
  factory $TranslationEditionEntryCopyWith(TranslationEditionEntry value, $Res Function(TranslationEditionEntry) _then) = _$TranslationEditionEntryCopyWithImpl;
@useResult
$Res call({
 String id, String language, String languageCode, String author, String link, String? sha256
});




}
/// @nodoc
class _$TranslationEditionEntryCopyWithImpl<$Res>
    implements $TranslationEditionEntryCopyWith<$Res> {
  _$TranslationEditionEntryCopyWithImpl(this._self, this._then);

  final TranslationEditionEntry _self;
  final $Res Function(TranslationEditionEntry) _then;

/// Create a copy of TranslationEditionEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? language = null,Object? languageCode = null,Object? author = null,Object? link = null,Object? sha256 = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationEditionEntry].
extension TranslationEditionEntryPatterns on TranslationEditionEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationEditionEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationEditionEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationEditionEntry value)  $default,){
final _that = this;
switch (_that) {
case _TranslationEditionEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationEditionEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationEditionEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String language,  String languageCode,  String author,  String link,  String? sha256)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationEditionEntry() when $default != null:
return $default(_that.id,_that.language,_that.languageCode,_that.author,_that.link,_that.sha256);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String language,  String languageCode,  String author,  String link,  String? sha256)  $default,) {final _that = this;
switch (_that) {
case _TranslationEditionEntry():
return $default(_that.id,_that.language,_that.languageCode,_that.author,_that.link,_that.sha256);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String language,  String languageCode,  String author,  String link,  String? sha256)?  $default,) {final _that = this;
switch (_that) {
case _TranslationEditionEntry() when $default != null:
return $default(_that.id,_that.language,_that.languageCode,_that.author,_that.link,_that.sha256);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationEditionEntry implements TranslationEditionEntry {
  const _TranslationEditionEntry({required this.id, required this.language, required this.languageCode, required this.author, required this.link, this.sha256});
  factory _TranslationEditionEntry.fromJson(Map<String, dynamic> json) => _$TranslationEditionEntryFromJson(json);

@override final  String id;
@override final  String language;
@override final  String languageCode;
@override final  String author;
@override final  String link;
@override final  String? sha256;

/// Create a copy of TranslationEditionEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationEditionEntryCopyWith<_TranslationEditionEntry> get copyWith => __$TranslationEditionEntryCopyWithImpl<_TranslationEditionEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationEditionEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationEditionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.language, language) || other.language == language)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.author, author) || other.author == author)&&(identical(other.link, link) || other.link == link)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,language,languageCode,author,link,sha256);

@override
String toString() {
  return 'TranslationEditionEntry(id: $id, language: $language, languageCode: $languageCode, author: $author, link: $link, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class _$TranslationEditionEntryCopyWith<$Res> implements $TranslationEditionEntryCopyWith<$Res> {
  factory _$TranslationEditionEntryCopyWith(_TranslationEditionEntry value, $Res Function(_TranslationEditionEntry) _then) = __$TranslationEditionEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String language, String languageCode, String author, String link, String? sha256
});




}
/// @nodoc
class __$TranslationEditionEntryCopyWithImpl<$Res>
    implements _$TranslationEditionEntryCopyWith<$Res> {
  __$TranslationEditionEntryCopyWithImpl(this._self, this._then);

  final _TranslationEditionEntry _self;
  final $Res Function(_TranslationEditionEntry) _then;

/// Create a copy of TranslationEditionEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? language = null,Object? languageCode = null,Object? author = null,Object? link = null,Object? sha256 = freezed,}) {
  return _then(_TranslationEditionEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TranslationAllowlist {

 List<TranslationEditionEntry> get editions;
/// Create a copy of TranslationAllowlist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationAllowlistCopyWith<TranslationAllowlist> get copyWith => _$TranslationAllowlistCopyWithImpl<TranslationAllowlist>(this as TranslationAllowlist, _$identity);

  /// Serializes this TranslationAllowlist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationAllowlist&&const DeepCollectionEquality().equals(other.editions, editions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(editions));

@override
String toString() {
  return 'TranslationAllowlist(editions: $editions)';
}


}

/// @nodoc
abstract mixin class $TranslationAllowlistCopyWith<$Res>  {
  factory $TranslationAllowlistCopyWith(TranslationAllowlist value, $Res Function(TranslationAllowlist) _then) = _$TranslationAllowlistCopyWithImpl;
@useResult
$Res call({
 List<TranslationEditionEntry> editions
});




}
/// @nodoc
class _$TranslationAllowlistCopyWithImpl<$Res>
    implements $TranslationAllowlistCopyWith<$Res> {
  _$TranslationAllowlistCopyWithImpl(this._self, this._then);

  final TranslationAllowlist _self;
  final $Res Function(TranslationAllowlist) _then;

/// Create a copy of TranslationAllowlist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? editions = null,}) {
  return _then(_self.copyWith(
editions: null == editions ? _self.editions : editions // ignore: cast_nullable_to_non_nullable
as List<TranslationEditionEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationAllowlist].
extension TranslationAllowlistPatterns on TranslationAllowlist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationAllowlist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationAllowlist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationAllowlist value)  $default,){
final _that = this;
switch (_that) {
case _TranslationAllowlist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationAllowlist value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationAllowlist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TranslationEditionEntry> editions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationAllowlist() when $default != null:
return $default(_that.editions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TranslationEditionEntry> editions)  $default,) {final _that = this;
switch (_that) {
case _TranslationAllowlist():
return $default(_that.editions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TranslationEditionEntry> editions)?  $default,) {final _that = this;
switch (_that) {
case _TranslationAllowlist() when $default != null:
return $default(_that.editions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationAllowlist implements TranslationAllowlist {
  const _TranslationAllowlist({required final  List<TranslationEditionEntry> editions}): _editions = editions;
  factory _TranslationAllowlist.fromJson(Map<String, dynamic> json) => _$TranslationAllowlistFromJson(json);

 final  List<TranslationEditionEntry> _editions;
@override List<TranslationEditionEntry> get editions {
  if (_editions is EqualUnmodifiableListView) return _editions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_editions);
}


/// Create a copy of TranslationAllowlist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationAllowlistCopyWith<_TranslationAllowlist> get copyWith => __$TranslationAllowlistCopyWithImpl<_TranslationAllowlist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationAllowlistToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationAllowlist&&const DeepCollectionEquality().equals(other._editions, _editions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_editions));

@override
String toString() {
  return 'TranslationAllowlist(editions: $editions)';
}


}

/// @nodoc
abstract mixin class _$TranslationAllowlistCopyWith<$Res> implements $TranslationAllowlistCopyWith<$Res> {
  factory _$TranslationAllowlistCopyWith(_TranslationAllowlist value, $Res Function(_TranslationAllowlist) _then) = __$TranslationAllowlistCopyWithImpl;
@override @useResult
$Res call({
 List<TranslationEditionEntry> editions
});




}
/// @nodoc
class __$TranslationAllowlistCopyWithImpl<$Res>
    implements _$TranslationAllowlistCopyWith<$Res> {
  __$TranslationAllowlistCopyWithImpl(this._self, this._then);

  final _TranslationAllowlist _self;
  final $Res Function(_TranslationAllowlist) _then;

/// Create a copy of TranslationAllowlist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? editions = null,}) {
  return _then(_TranslationAllowlist(
editions: null == editions ? _self._editions : editions // ignore: cast_nullable_to_non_nullable
as List<TranslationEditionEntry>,
  ));
}


}

// dart format on
