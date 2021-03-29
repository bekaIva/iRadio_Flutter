import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:iradio/Constants/Constants.dart';

import 'Enums.dart';

class Channel {
  Channel NextChannel;
  Channel PrevChannel;
  String ChannelName;
  String ChannelLink;
  ValueNotifier<bool> IsUpdating = ValueNotifier<bool>(false);
  String ChannelAddress;
  String Refferer;
  ValueNotifier<bool> IsPlaying = ValueNotifier<bool>(false);
  ValueNotifier<bool> IsInFavorites = ValueNotifier<bool>(false);
  List<Genre> Genres = List<Genre>();
  String OfficialLink;
  String Quality;
  String CurrentTrack;
  Channel(
      {this.ChannelName,
      this.ChannelLink,
      this.ChannelAddress,
      this.OfficialLink,
      this.Quality});
  Channel.fromJson(Map<String, dynamic> json) {
    ChannelName = json['ChannelName'] as String;
    ChannelLink = json['ChannelLink'] as String;
    ChannelAddress = json['ChannelAddress'] as String;
    OfficialLink = json['OfficialLink'] as String;
    Quality = json['Quality'] as String;
    CurrentTrack = json['CurrentTrack'] as String;
  }
  Map<String, dynamic> toJson() {
    return {
      'ChannelName': ChannelName,
      'ChannelLink': ChannelLink,
      'ChannelAddress': ChannelAddress,
      'OfficialLink': OfficialLink,
      'Quality': Quality,
      'CurrentTrack': CurrentTrack
    };
  }

  Future UpdateCurrentStatus() async {
    var res = await http.get(ChannelLink, headers: {'User-Agent': kUserAgent})
      ..body;
    var document = parse(res);
  }
}
