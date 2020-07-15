import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:iradio/Constants/Constants.dart';

import 'Enums.dart';

class Channel {
  String ChannelName;
  String ChannelLink;
  ValueNotifier<bool> IsUpdating = ValueNotifier<bool>(false);
  String ChannelAddress;
  String Refferer;
  ValueNotifier<bool> IsPlaying = ValueNotifier<bool>(false);
  bool IsInFavorites;
  List<Genre> Genres = List<Genre>();
  String OfficialLink;
  String Quality;
  String CurrentTrack;
  Channel() {}
  Channel.fromJson(String json) {}
  Future UpdateCurrentStatus() async {
    var res = await http.get(ChannelLink, headers: {'User-Agent': kUserAgent})
      ..body;
    var document = parse(res);
  }
}
