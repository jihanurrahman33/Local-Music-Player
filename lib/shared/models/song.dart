import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

@immutable
class Song {
  const Song({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.albumId,
    this.artistId,
    this.duration,
    this.uri,
    this.artworkUri,
    this.trackNumber,
    this.year,
    this.genre,
    this.dateAdded,
    this.playCount = 0,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String? artist;
  final String? album;
  final String? albumId;
  final String? artistId;
  final Duration? duration;
  final String? uri; // file path or content URI
  final String? artworkUri;
  final int? trackNumber;
  final int? year;
  final String? genre;
  final DateTime? dateAdded;
  final int playCount;
  final bool isFavorite;

  String get displayArtist =>
      (artist == null || artist!.trim().isEmpty) ? 'Unknown Artist' : artist!;
  String get displayAlbum =>
      (album == null || album!.trim().isEmpty) ? 'Unknown Album' : album!;
  String get displayTitle => title.trim().isEmpty ? 'Unknown Title' : title;

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumId,
    String? artistId,
    Duration? duration,
    String? uri,
    String? artworkUri,
    int? trackNumber,
    int? year,
    String? genre,
    DateTime? dateAdded,
    int? playCount,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      duration: duration ?? this.duration,
      uri: uri ?? this.uri,
      artworkUri: artworkUri ?? this.artworkUri,
      trackNumber: trackNumber ?? this.trackNumber,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      dateAdded: dateAdded ?? this.dateAdded,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      title: displayTitle,
      artist: displayArtist,
      album: displayAlbum,
      duration: duration,
      artUri: artworkUri != null ? Uri.tryParse(artworkUri!) : null,
      extras: {
        'uri': uri,
        'albumId': albumId,
        'artistId': artistId,
        'trackNumber': trackNumber,
        'year': year,
        'genre': genre,
        'isFavorite': isFavorite,
      },
    );
  }

  factory Song.fromMediaItem(MediaItem item) {
    final extras = item.extras ?? const <String, dynamic>{};
    return Song(
      id: item.id,
      title: item.title,
      artist: item.artist,
      album: item.album,
      duration: item.duration,
      artworkUri: item.artUri?.toString(),
      uri: extras['uri'] as String?,
      albumId: extras['albumId'] as String?,
      artistId: extras['artistId'] as String?,
      trackNumber: extras['trackNumber'] as int?,
      year: extras['year'] as int?,
      genre: extras['genre'] as String?,
      isFavorite: extras['isFavorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
