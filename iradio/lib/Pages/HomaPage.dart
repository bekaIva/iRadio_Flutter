import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iradio/Constants/Constants.dart';
import 'package:iradio/Models/Channel.dart';
import 'package:iradio/Models/Enums.dart';
import 'package:iradio/Models/SearchContext.dart';
import 'package:iradio/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

import 'ResutlsPage.dart';

class HomePage extends StatefulWidget {
  final TabController tabController;
  HomePage({this.tabController});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewmodel, child) => TabBarView(
        controller: widget.tabController,
        children: <Widget>[
          ValueListenableBuilder(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 12, right: 12),
              physics: BouncingScrollPhysics(),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: viewmodel.genres
                    .map((e) => GenreWidget(
                          genreTapped: (genre) {
                            viewmodel.context = SearchContext.Genre(genre);
                            viewmodel.Search();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ResultsPage(
                                searchCriteria: kGenresWithDisplayNames[genre],
                                loadMore: () {
                                  viewmodel.Search();
                                },
                              );
                            }));
                          },
                          genre: e,
                        ))
                    .toList(),
              ),
            ),
            valueListenable: viewmodel.showPading,
            builder: (context, value, child) => AnimatedPadding(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: value ? EdgeInsets.only(bottom: 50) : EdgeInsets.all(0),
              child: child,
            ),
          ),
          ValueListenableBuilder<List<Channel>>(
            valueListenable: viewmodel.featuredResuts,
            builder: (context, channels, child) => ValueListenableBuilder<bool>(
              valueListenable: viewmodel.isSearching,
              builder: (context, isSearching, child) => ResultsList(
                showPading: viewmodel.showPading,
                results: channels,
                isSearching: isSearching,
              ),
            ),
          ),
          ValueListenableBuilder<List<Channel>>(
            valueListenable: viewmodel.popularResuts,
            builder: (context, channels, child) => ValueListenableBuilder<bool>(
              valueListenable: viewmodel.isSearching,
              builder: (context, isSearching, child) => ResultsList(
                results: channels,
                showPading: viewmodel.showPading,
                isSearching: isSearching,
              ),
            ),
          ),
          ValueListenableBuilder<List<Channel>>(
            valueListenable: viewmodel.favorites,
            builder: (context, channels, child) => ValueListenableBuilder<bool>(
              valueListenable: viewmodel.isSearching,
              builder: (context, isSearching, child) => ResultsList(
                results: channels,
                showPading: viewmodel.showPading,
                isSearching: isSearching,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GenreWidget extends StatefulWidget {
  final Genre genre;
  final Function(Genre genre) genreTapped;
  GenreWidget({this.genre, this.genreTapped});

  @override
  _GenreWidgetState createState() => _GenreWidgetState();
}

class _GenreWidgetState extends State<GenreWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fadeController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: (Random().nextDouble() * (800 - 100) + 100).floor()));
    _fadeAnimation = CurvedAnimation(
        curve: Curves.easeOut,
        parent: Tween<double>(begin: 0, end: 1).animate(_fadeController));
    _fadeController.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          color: kPrimaryColor,
          child: Container(
            width: 100,
            height: 50,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onPressed: () {
                widget.genreTapped?.call(widget.genre);
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Center(
                  child: Text(
                    kGenresWithDisplayNames[widget.genre],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.copse(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              color: Colors.white38,
                              offset: Offset(-1, -1),
                              blurRadius: 3),
                          Shadow(
                              color: Colors.black45,
                              offset: Offset(1.5, 1.5),
                              blurRadius: 3)
                        ],
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
