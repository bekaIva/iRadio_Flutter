import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iradio/Models/Enums.dart';

const String kUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36';
const Color kPrimaryColor = Color(0XFF207CCA);
Map<Genre, String> kGenresWithDisplayNames = {
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
//TextStyles
