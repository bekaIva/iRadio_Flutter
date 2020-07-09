import 'package:flutter/cupertino.dart';
import 'package:iradio/Models/Enums.dart';

class SearchContext extends ChangeNotifier {
  int currentPage;
  ValueNotifier<bool> isMoreAvailable = ValueNotifier<bool>(false);
  String searchUrl;
  Mode searchMode;
  Genre searchGenre;
  String searchKeyword;

  SearchContext(
      {this.searchMode,
      this.searchKeyword,
      this.searchGenre,
      this.currentPage = 1});
}
