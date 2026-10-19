import 'package:flutter/foundation.dart';
import 'album.dart';
import 'song.dart';

@immutable
class Artist {
  const Artist({
    required this.id,
    required this.name,
    this.songCount = 0,
    this.albumCount = 0,
    this.artworkUri,
    this.songs = const [],
    this.albums = const [],
  });

  final String id;
  final String name;
  final int songCount;
  final int albumCount;
  final String? artworkUri;
  final List<Song> songs;
  final List<Album> albums;

  String get displayName => name.trim().isEmpty ? 'Unknown Artist' : name;

  Artist copyWith({
    String? id,
    String? name,
    int? songCount,
    int? albumCount,
    String? artworkUri,
    List<Song>? songs,
    List<Album>? albums,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      songCount: songCount ?? this.songCount,
      albumCount: albumCount ?? this.albumCount,
      artworkUri: artworkUri ?? this.artworkUri,
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
