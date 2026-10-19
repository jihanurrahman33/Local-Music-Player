import 'package:flutter/foundation.dart';
import 'song.dart';

@immutable
class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.songCount = 0,
    this.songs = const [],
    this.artworkUri,
  });

  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int songCount;
  final List<Song> songs;
  final String? artworkUri;

  String get displayName => name.trim().isEmpty ? 'Untitled Playlist' : name;

  Playlist copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? songCount,
    List<Song>? songs,
    String? artworkUri,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songCount: songCount ?? this.songCount,
      songs: songs ?? this.songs,
      artworkUri: artworkUri ?? this.artworkUri,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
