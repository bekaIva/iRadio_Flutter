import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:iradio/Constants/Constants.dart';
import 'package:iradio/Models/Channel.dart';
import 'package:iradio/Models/Enums.dart';
import 'package:iradio/Models/SearchContext.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel extends ChangeNotifier {
  ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Genre> genres = Genre.values;

  List<String> Favorites = List<String>();
  SearchContext context = SearchContext(searchMode: Mode.FeaturedPopular);
  bool isRated;
  MainViewModel() {}

  Future<List<Channel>> Search() async {
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
                    .replaceAll('DigitStart', '')
                    .replaceAll('_', '%20') +
                '/';
          } else {
            url = "http://www.internet-radio.com/stations/" +
                context.searchGenre
                    .toString()
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
    }
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
