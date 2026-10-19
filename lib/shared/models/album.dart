import 'package:flutter/foundation.dart';
import 'song.dart';

@immutable
class Album {
  const Album({
    required this.id,
    required this.title,
    this.artist,
    this.artworkUri,
    this.year,
    this.songCount = 0,
    this.songs = const [],
  });

  final String id;
  final String title;
  final String? artist;
  final String? artworkUri;
  final int? year;
  final int songCount;
  final List<Song> songs;

  String get displayArtist =>
      (artist == null || artist!.trim().isEmpty) ? 'Unknown Artist' : artist!;
  String get displayTitle => title.trim().isEmpty ? 'Unknown Album' : title;

  Album copyWith({
    String? id,
    String? title,
    String? artist,
    String? artworkUri,
    int? year,
    int? songCount,
    List<Song>? songs,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artworkUri: artworkUri ?? this.artworkUri,
      year: year ?? this.year,
      songCount: songCount ?? this.songCount,
      songs: songs ?? this.songs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
