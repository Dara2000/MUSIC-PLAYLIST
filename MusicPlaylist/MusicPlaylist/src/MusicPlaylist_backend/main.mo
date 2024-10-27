import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor {
  type Song = {
    id: Nat;
    title: Text;
    artist: Text;
    genre: Text;
    duration: Nat; // Duration in seconds
    addedDate: Time.Time;
  };

  type Playlist = {
    id: Nat;
    name: Text;
    description: Text;
    songs: Buffer.Buffer<Song>;
    createdAt: Time.Time;
    lastModified: Time.Time;
  };

  var songs = Buffer.Buffer<Song>(0);
  var playlists = Buffer.Buffer<Playlist>(0);

  public func addSong(title: Text, artist: Text, genre: Text, duration: Nat) : async Nat {
    let id = songs.size();
    let newSong: Song = {
      id;
      title;
      artist;
      genre;
      duration;
      addedDate = Time.now();
    };
    songs.add(newSong);
    id
  };

  public func createPlaylist(name: Text, description: Text) : async Nat {
    let id = playlists.size();
    let now = Time.now();
    let newPlaylist: Playlist = {
      id;
      name;
      description;
      songs = Buffer.Buffer<Song>(0);
      createdAt = now;
      lastModified = now;
    };
    playlists.add(newPlaylist);
    id
  };

  public func addSongToPlaylist(playlistId: Nat, songId: Nat) : async Bool {
    if (playlistId >= playlists.size() or songId >= songs.size()) return false;
    var playlist = playlists.get(playlistId);
    let song = songs.get(songId);
    playlist.songs.add(song);
    
    playlist := {
      id = playlist.id;
      name = playlist.name;
      description = playlist.description;
      songs = playlist.songs;
      createdAt = playlist.createdAt;
      lastModified = Time.now();
    };
    playlists.put(playlistId, playlist);
    true
  };

  public query func getSongsByGenre(genre: Text) : async [Song] {
    let genreSongs = Buffer.Buffer<Song>(0);
    for (song in songs.vals()) {
      if (song.genre == genre) {
        genreSongs.add(song);
      };
    };
    Buffer.toArray(genreSongs)
  };

  public query func getPlaylist(id: Nat) : async ?{
    id: Nat;
    name: Text;
    description: Text;
    songs: [Song];
    createdAt: Time.Time;
    lastModified: Time.Time;
  } {
    if (id >= playlists.size()) return null;
    let playlist = playlists.get(id);
    ?{
      id = playlist.id;
      name = playlist.name;
      description = playlist.description;
      songs = Buffer.toArray(playlist.songs);
      createdAt = playlist.createdAt;
      lastModified = playlist.lastModified;
    }
  };

  public func removeSongFromPlaylist(playlistId: Nat, songId: Nat) : async Bool {
    if (playlistId >= playlists.size()) return false;
    var playlist = playlists.get(playlistId);
    let newSongs = Buffer.Buffer<Song>(0);
    var found = false;
    
    for (song in playlist.songs.vals()) {
      if (song.id != songId) {
        newSongs.add(song);
      } else {
        found := true;
      };
    };

    if (found) {
      playlist := {
        id = playlist.id;
        name = playlist.name;
        description = playlist.description;
        songs = newSongs;
        createdAt = playlist.createdAt;
        lastModified = Time.now();
      };
      playlists.put(playlistId, playlist);
    };
    found
  };
}