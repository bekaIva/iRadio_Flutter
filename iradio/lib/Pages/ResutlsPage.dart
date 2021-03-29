import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iradio/Constants/Constants.dart';
import 'package:iradio/Models/Channel.dart';
import 'package:iradio/Models/SearchContext.dart';
import 'package:iradio/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

class ResultsPage extends StatelessWidget {
  final Function loadMore;
  final String searchCriteria;
  ResultsPage({this.searchCriteria, this.loadMore});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(searchCriteria),
      ),
      body: Consumer<MainViewModel>(
        builder: (context, viewModel, child) => ValueListenableBuilder<bool>(
          valueListenable: viewModel.isSearching,
          builder: (context, isSearching, child) =>
              ValueListenableBuilder<List<Channel>>(
            valueListenable: viewModel.searchResults,
            builder: (context, results, child) => ResultsList(
              showPading: viewModel.showPading,
              results: results,
              scrollEnd: loadMore,
              isSearching: isSearching,
            ),
          ),
        ),
      ),
    );
  }
}

class ResultsList extends StatefulWidget {
  final ValueNotifier<bool> showPading;
  final Function scrollEnd;
  final bool isSearching;
  final List<Channel> results;
  ResultsList(
      {Key key,
      @required this.results,
      this.isSearching,
      this.scrollEnd,
      @required this.showPading});

  @override
  _ResultsListState createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList>
    with SingleTickerProviderStateMixin {
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(
        parent: Tween<double>(begin: 0, end: 1).animate(_fadeController),
        curve: Curves.easeIn);
    // TODO: implement initState
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) widget.scrollEnd?.call();
    });
    _fadeController.forward();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.showPading,
      builder: (context, value, child) => AnimatedPadding(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: value ? EdgeInsets.only(bottom: 50) : EdgeInsets.all(0),
        child: child,
      ),
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: (widget.results?.length ?? 0) > 0 || widget.isSearching
                    ? ListView.separated(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (_, index) {
                          return ChanelWidget(
                            channel: widget.results[index],
                          );
                        },
                        itemCount: widget.results.length,
                      )
                    : Align(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'There\'s nothing...',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                shadows: [
                                  Shadow(
                                      offset: Offset(1, 1),
                                      color: Colors.black38,
                                      blurRadius: 2)
                                ]),
                          ),
                        ),
                      ),
              )
            ],
          ),
          if (widget.isSearching)
            Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kPrimaryColor),
              ),
            )
        ],
      ),
    );
  }
}

class ChanelWidget extends StatefulWidget {
  final Channel channel;
  ChanelWidget({this.channel});
  @override
  _ChanelWidgetState createState() => _ChanelWidgetState();
}

class _ChanelWidgetState extends State<ChanelWidget>
    with TickerProviderStateMixin {
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;
  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _fadeAnimation = CurvedAnimation(
        curve: Curves.easeIn,
        parent: Tween<double>(begin: 0, end: 1).animate(_fadeController));

    _fadeController.forward();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    widget.channel.IsPlaying.addListener(playingChanged);
    playingChanged();
    // TODO: implement initState
  }

  @override
  void didUpdateWidget(covariant ChanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.channel.IsPlaying.removeListener(playingChanged);
    widget.channel.IsPlaying.addListener(playingChanged);
    playingChanged();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    widget.channel.IsPlaying.removeListener(playingChanged);
    super.dispose();
  }

  void playingChanged() {
    if (widget.channel.IsPlaying.value)
      _controller.forward();
    else
      _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)),
                    child: ClipOval(
                      child: Material(
                        child: InkWell(
                          onTap: () async {
                            try {
                              await viewModel.Play(widget.channel);
                            } catch (e) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Can\'t open stream!')));
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedIcon(
                                color: kPrimaryColor,
                                icon: AnimatedIcons.play_pause,
                                progress: _controller),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                    child: Text(
                                  widget.channel.ChannelName,
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w400),
                                )),
                                Flexible(
                                    child: Text(
                                  widget.channel.CurrentTrack,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                )),
                              ],
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: widget.channel.IsInFavorites,
                            builder: (context, isInFavorite, child) => Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35)),
                              child: ClipOval(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (isInFavorite)
                                        viewModel.RemoveFromFavorites(
                                            widget.channel);
                                      else
                                        viewModel.AddToFavorites(
                                            widget.channel);
                                    },
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Icon(
                                        Icons.favorite,
                                        size: 20,
                                        color:
                                            widget.channel.IsInFavorites.value
                                                ? kPrimaryColor
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      if ((widget.channel.Genres?.length ?? 0) > 0)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: widget.channel.Genres
                                .map((e) => FlatButton(
                                      onPressed: () {
                                        viewModel.context =
                                            SearchContext.Genre(e);
                                        viewModel.Search();
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return ResultsPage(
                                            searchCriteria:
                                                kGenresWithDisplayNames[e],
                                            loadMore: () {
                                              viewModel.Search();
                                            },
                                          );
                                        }));
                                      },
                                      child: Text(
                                        kGenresWithDisplayNames[e],
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
