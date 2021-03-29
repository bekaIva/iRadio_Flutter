import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart' hide Element;
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:iradio/Constants/Constants.dart';
import 'package:iradio/Models/Channel.dart';
import 'package:iradio/Models/Enums.dart';
import 'package:iradio/Models/SearchContext.dart';
import 'package:just_audio/just_audio.dart' as justAudio;
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel extends ChangeNotifier {
  final ValueNotifier<bool> showPading = ValueNotifier<bool>(false);
  ValueNotifier<Channel> _currentTrack = ValueNotifier<Channel>(null);
  justAudio.AudioPlayer justAudioPlayer = justAudio.AudioPlayer();
  ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Map<Genre, String> genresWithDisplayNames = {
    Genre.jazz: 'jazz',
    Genre.top_40: 'Top 40',
    Genre.country: 'Country',
    Genre.blues: 'Blues',
    Genre.easy_listening: 'Easy listening',
    Genre.rock: 'Rock',
    Genre.classical: 'Classical',
    Genre.DigitStart80s: '80s',
    Genre.chillout: 'Chillout',
    Genre.oldies: 'Oldies',
    Genre.reggae: 'Reggae',
    Genre.dance: 'Dance',
    Genre.ambient: 'Ambient',
    Genre.trance: 'Trance',
    Genre.hip_hop: 'Hip Hop',
    Genre.smooth_jazz: 'Smooth Jazz',
    Genre.DigitStart70s: '70s',
    Genre.house: 'House',
    Genre.lounge: 'Lounge',
    Genre.drum_and_bass: 'Drum And Bass',
    Genre.metal: 'Metal',
    Genre.meditation: 'Meditation',
    Genre.techno: 'Techno',
    Genre.DigitStart60s: '60s',
    Genre.heavy_metal: 'Heavy Metal',
    Genre.soul: 'Soul',
    Genre.pop: 'Pop',
    Genre.DigitStart90s: '90s',
    Genre.psytrance: 'Psytrance',
    Genre.latin: 'Latin',
    Genre.funk: 'Funk',
    Genre.rap: 'Rap',
    Genre.rockabilly: 'Rockabilly',
    Genre.DigitStart50s: '50s',
    Genre.minimal: 'Minimal',
    Genre.bollywood: 'Bollywood',
    Genre.greek: 'Greek',
    Genre.comedy: 'Comedy',
    Genre.hindi: 'Hindi',
    Genre.alternative: 'Alternative',
    Genre.reggaeton: 'Reggaeton',
    Genre.new_age: 'New Age',
    Genre.salsa: 'Salsa',
    Genre.bluegrass: 'Bluegrass',
    Genre.edm: 'Edm',
    Genre.manele: 'Manele',
    Genre.swing: 'Swing',
    Genre.talk: 'Talk',
    Genre.japanese: 'Japanese',
    Genre.dancehall: 'Dancehall',
    Genre.disco: 'Disco',
    Genre.electronic: 'Electronic',
    Genre.classic_rock: 'Classic Rock',
    Genre.chill: 'Chill',
    Genre.psychedelic: 'Psychedelic',
    Genre.dubstep: 'Dubstep',
    Genre.dub: 'Dub',
    Genre.rnb: 'Rnb',
    Genre.hardstyle: 'Hardstyle',
    Genre.progressive: 'Progressive',
    Genre.indie: 'Indie',
    Genre.goa: 'Goa',
    Genre.romantic: 'Romantic',
    Genre.kizomba: 'Kizomba',
    Genre.eurodance: 'Eurodance',
    Genre.folk: 'Folk',
    Genre.hardcore: 'Hardcore',
    Genre.soundtracks: 'Soundtracks',
    Genre.celtic: 'Celtic',
    Genre.americana: 'Americana',
    Genre.electro: 'Electro',
    Genre.jungle: 'Jungle',
    Genre.new_wave: 'New Wave',
    Genre.opera: 'Opera',
    Genre.goth: 'Goth',
    Genre.punk: 'Punk',
    Genre.jewish: 'Jewish',
    Genre.downtempo: 'Downtempo',
    Genre.garage: 'Garage',
    Genre.indian: 'Indian',
  };
  List<Genre> genres = Genre.values;

  List<String> Favorites = List<String>();
  ValueNotifier<List<Channel>> favorites = ValueNotifier<List<Channel>>([]);
  ValueNotifier<List<Channel>> searchResults = ValueNotifier<List<Channel>>([]);

  ValueNotifier<List<Channel>> featuredResuts =
      ValueNotifier<List<Channel>>([]);

  ValueNotifier<List<Channel>> popularResuts = ValueNotifier<List<Channel>>([]);

  SearchContext context = SearchContext(searchMode: Mode.Featured);
  bool isRated;
  MainViewModel() {}

  Future<void> Search() async {
    try {
      isSearching.value = true;
      context.isMoreAvailable.value = false;
      String url = '';
      switch (context.searchMode) {
        case Mode.Popular:
        case Mode.Featured:
          {
            url = 'http://www.internet-radio.com/';
            break;
          }
        case Mode.Genre:
          {
            if (context.currentPage <= 1) {
              url = 'http://www.internet-radio.com/stations/' +
                  context.searchGenre
                      .toString()
                      .split('.')
                      .last
                      .replaceAll('DigitStart', '')
                      .replaceAll('_', '%20') +
                  '/';
            } else {
              url = "http://www.internet-radio.com/stations/" +
                  context.searchGenre
                      .toString()
                      .split('.')
                      .last
                      .replaceAll("DigitStart", "")
                      .replaceAll("_", "%20") +
                  "/page" +
                  context.currentPage.toString();
            }
            break;
          }
        case Mode.Keyword:
          {
            if (context.currentPage <= 1) {
              url = "http://www.internet-radio.com/search/?radio=" +
                  context.searchKeyword.replaceAll(" ", "+");
            } else {
              url = "http://www.internet-radio.com/search/?radio=" +
                  context.searchKeyword.replaceAll(" ", "+") +
                  "&page=/page" +
                  context.currentPage.toString();
            }
            break;
          }
      }
      switch (context.searchMode) {
        case Mode.Favorites:
          {
            favorites.value = await LoadFavorites();

            context.isMoreAvailable.value = false;
            break;
          }
        case Mode.Featured:
          {
            String html =
                await http.read(url, headers: {'User-Agent': kUserAgent});
            var doc = parse(html);
            var h2nodes = doc.getElementsByTagName('h2');
            await Future.forEach(h2nodes, (element) async {
              if (element.innerHtml.contains('Featured Radio Stations') &&
                  element.parent.localName == 'div' &&
                  element.parent.attributes['class'] == 'col-md-6') {
                var featuredNode = element.parent;
                featuredResuts.value =
                    await ParseChannelsFromElement(featuredNode);
              }
            });

            break;
          }
        case Mode.Popular:
          {
            String html =
                await http.read(url, headers: {'User-Agent': kUserAgent});
            var doc = parse(html);
            var h2nodes = doc.getElementsByTagName('h2');
            await Future.forEach(h2nodes, (element) async {
              if (element.innerHtml.contains('Popular Radio Stations') &&
                  element.parent.localName == 'div' &&
                  element.parent.attributes['class'] == 'col-md-6') {
                var featuredNode = element.parent;
                popularResuts.value =
                    await ParseChannelsFromElement(featuredNode);
                print(popularResuts.value.length);
              }
            });

            break;
          }
        default:
          {
            print(url);
            String html =
                await http.read(url, headers: {'User-Agent': kUserAgent});
            var doc = parse(html);
            var tables = doc.getElementsByTagName('table').where((element) =>
                element.attributes['class'] == 'table table-striped');
            if (context.currentPage <= 1) searchResults.value = [];
            await Future.forEach(tables, (element) async {
              searchResults.value ??= [];
              searchResults.value
                  .addAll(await ParseChannelsFromElement(element));
            });

            var linodes = doc
                .getElementsByTagName('ul')
                .where((element) => element.attributes['class'] == 'pagination')
                .expand((element) => element.getElementsByTagName('li'));
            linodes.forEach((element) {
              if (element.attributes['class'] == 'next') {
                context.isMoreAvailable.value = true;
                context.currentPage++;
              }
            });
            break;
          }
      }
      try {
        searchResults.value.forEach((element) {
          try {
            CheckFavoritesExist(element);
          } catch (ee) {}
        });
      } catch (e) {}
    } finally {
      isSearching.value = false;
    }
  }

  Future Play(Channel channel) async {
    try {
      if (channel == _currentTrack.value &&
          _currentTrack.value.IsPlaying.value &&
          justAudioPlayer.playing) {
        justAudioPlayer.pause();
        _currentTrack.value.IsPlaying.value = false;
        return;
      }
      if (_currentTrack?.value?.IsPlaying?.value ?? false) {
        _currentTrack.value.IsPlaying.value = false;
      }
      var url = (await http.get(channel.ChannelAddress)).body;
      var res = RegExp(r'(?<link>https{0,1}:.*)').firstMatch(url);
      String strm = res.namedGroup('link');
      _currentTrack.value = channel;
      var ares = await justAudioPlayer.setUrl(strm);
      _currentTrack.value.IsPlaying.value = true;
      justAudioPlayer.play();
    } catch (e) {
      print('err');
      throw e;
      // TODO
    } finally {}
  }

  Future<List<Channel>> ParseChannelsFromElement(Element e) async {
    try {
      Channel currentChannel;
      Channel previousChannel;
      List<Channel> channels = List<Channel>();
      var trnodes = e.getElementsByTagName('tr');
      trnodes.forEach((element) {
        Channel channel = Channel();

        var trdecents = element.getElementsByTagName('*');
        trdecents.forEach((element) {
          if (element.localName == 'i' &&
              element.attributes['class'] ==
                  'jp-play text-danger mdi-av-play-circle-outline' &&
              element.attributes.containsKey('onclick')) {
            try {
              String val = element.attributes['onclick'];
              RegExp r = RegExp(r'https{0,1}://.*\.(m3u|pls)');
              String address = r.firstMatch(val).group(0);
              if ((address?.length ?? 0) > 0) {
                channel.ChannelAddress = address;
              }
            } catch (e) {}
          }
          if (element.localName == 'b' && element.parent.localName == 'td') {
            channel.CurrentTrack = element.text;
          }
          if (element.localName == 'h4' &&
              element.attributes['class'] == 'text-danger' &&
              element.parent.localName == 'td') {
            channel.ChannelName = element.text;

            var textNode = element.parent.nodes.firstWhere((node) =>
                node.nodeType == 3 &&
                (node.text?.contains('Genres: ') ?? false));
            if (textNode != null) {
              var genreNodes = textNode.parent.getElementsByTagName('a')?.where(
                  (element) =>
                      (element.attributes['onclick']?.contains('genreclick')) ??
                      false);
              genreNodes.forEach((element) {
                String genre = element.text ?? '';

                if (genre.length > 0 && int.tryParse(genre[0]) != null) {
                  genre = 'DigitStart' + genre;
                }
                var g = EnumToString.fromString(Genre.values, genre);
                if (g != null) channel.Genres.add(g);
              });
            }
            var andoes = element.getElementsByTagName('a');
            if (andoes.length > 0) {
              var anode = andoes.first;
              if ((anode.attributes['href']?.startsWith('/station/')) ??
                  false) {
                channel.ChannelLink =
                    "https://www.internet-radio.com" + anode.attributes["href"];
              }
            }
          }
        });
        if (_currentTrack?.value?.ChannelAddress == channel.ChannelAddress) {
          channel = _currentTrack.value;
        }
        previousChannel?.NextChannel = channel;
        channel.PrevChannel = previousChannel;
        previousChannel = channel;
        for (int i = 0; i < favorites.value.length; i++) {
          try {
            if (channel.ChannelAddress == favorites.value[i].ChannelAddress) {
              channel.IsInFavorites.value =
                  favorites.value[i].IsInFavorites.value;
              favorites.value[i] = channel;
              break;
            }
          } on Exception catch (e) {
            // TODO
          }
        }
        channels.add(channel);
      });
      return channels;
    } catch (e) {}
  }

  Future AddToFavorites(Channel channel) async {
    final SharedPreferences prefs = await _prefs;
    var channelData = await SerializeToString(channel);
    prefs.setString(channel.ChannelAddress, channelData);
    CheckFavoritesExist(channel);
  }

  Future UpdateIfInFavorites(Channel channel) async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.containsKey(channel.ChannelAddress)) {
      String channelData = await SerializeToString(channel);
      prefs.setString(channel.ChannelAddress, channelData);
    }
  }

  Future RemoveFromFavorites(Channel channel) async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.containsKey(channel.ChannelAddress)) {
      prefs.remove(channel.ChannelAddress);
    }
    CheckFavoritesExist(channel);
  }

  Future<List<Channel>> LoadFavorites() async {
    final SharedPreferences prefs = await _prefs;
    List<Channel> res = List<Channel>();
    prefs.getKeys().forEach((channelKey) async {
      Channel channel = await DeserializeToChannel(prefs.getString(channelKey));
      channel.IsInFavorites.value = true;
      if (_currentTrack?.value?.ChannelAddress == channel.ChannelAddress) {
        channel = _currentTrack.value;
      }
      var channelInFeatured = featuredResuts.value.firstWhere(
          (element) => element.ChannelAddress == channel.ChannelAddress,
          orElse: () => null);
      var channelInPopular = popularResuts.value.firstWhere(
          (element) => element.ChannelAddress == channel.ChannelAddress,
          orElse: () => null);
      var channelInSearch = searchResults.value.firstWhere(
          (element) => element.ChannelAddress == channel.ChannelAddress,
          orElse: () => null);
      if (channelInSearch != null) channel = channelInSearch;
      if (channelInPopular != null) channel = channelInPopular;
      if (channelInFeatured != null) channel = channelInFeatured;
      channel.IsInFavorites.value = true;
      res.add(channel);
    });
    return res;
  }

  void CheckFavoritesExist(Channel channel) async {
    final SharedPreferences prefs = await _prefs;
    channel.IsInFavorites.value = prefs.containsKey(channel.ChannelAddress);
  }

  Future<List<String>> GetFavorites() async {}

  Future<String> SerializeToString(Channel channel) async {
    return jsonEncode(channel.toJson());
  }

  Future<Channel> DeserializeToChannel(String jsonValue) async {
    return Channel.fromJson(jsonDecode(jsonValue));
  }
}
