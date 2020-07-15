import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel extends ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer();
  ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Genre> genres = Genre.values;

  List<String> Favorites = List<String>();
  List<Channel> searchResults = List<Channel>();
  SearchContext context = SearchContext(searchMode: Mode.FeaturedPopular);
  bool isRated;
  MainViewModel() {}

  Future Search() async {
    context.isMoreAvailable.value = false;
    List<Channel> retValue = List<Channel>();
    String url = '';
    switch (context.searchMode) {
      case Mode.FeaturedPopular:
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
          var res = await LoadFavorites();
          retValue.addAll(res);
          context.isMoreAvailable.value = false;
          break;
        }
      case Mode.FeaturedPopular:
        {
          String html =
              await http.read(url, headers: {'User-Agent': kUserAgent});
          var doc = parse(html);
          var h2nodes = doc.getElementsByTagName('h2');
          h2nodes.forEach((element) {});

          break;
        }
      default:
        {
          String html =
              await http.read(url, headers: {'User-Agent': kUserAgent});
          var doc = parse(html);
          var tables = doc.getElementsByTagName('table').where((element) =>
              element.attributes['class'] == 'table table-striped');

          await Future.forEach(tables, (element) async {
            var channels = await ParseChannelsFromElement(element);
            if ((channels?.length ?? 0) > 0) {
              retValue.addAll(channels);
            }
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
      retValue.forEach((element) {
        try {
          CheckFavoritesExist(element);
        } catch (ee) {}
      });
    } catch (e) {}
    return retValue;
  }

  Future Play(Channel channel) async {
    var url = (await http.get(channel.ChannelAddress)).body;
    var res = RegExp(r'File1=(?<link>.*?)\n').firstMatch(url);
    String strm = res.namedGroup('link');

    audioPlayer.play(strm, stayAwake: true);
  }

  Future ParseChannelsFromElement(Element e) async {
    try {
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
        searchResults.add(channel);
      });
      String t = 's';
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
    prefs.getKeys().forEach((channelData) async {
      Channel channel = await DeserializeToChannel(channelData);
      channel.IsInFavorites = true;
      res.add(channel);
    });
    return res;
  }

  void CheckFavoritesExist(Channel channel) async {
    final SharedPreferences prefs = await _prefs;
    channel.IsInFavorites = prefs.containsKey(channel.ChannelAddress);
  }

  Future<List<String>> GetFavorites() async {}

  Future<String> SerializeToString(Channel channel) async {
    return jsonEncode(channel);
  }

  Future<Channel> DeserializeToChannel(String jsonValue) {
    Channel.fromJson(jsonValue);
  }
}
