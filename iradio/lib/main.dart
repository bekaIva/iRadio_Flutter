import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iradio/Pages/HomaPage.dart';
import 'package:iradio/Pages/ResutlsPage.dart';
import 'package:iradio/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import 'Models/Enums.dart';
import 'Models/SearchContext.dart';

void main() => runApp(iRadio());

class iRadio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewModel(),
      child: MaterialApp(
        theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
        home: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  MainViewModel viewModel;
  TabController _tabController;
  bool _isSearching = false;
  @override
  void initState() {
    viewModel = context.read<MainViewModel>();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() {
        print('${_tabController.indexIsChanging}');
        switch (_tabController.index) {
          case 1:
            {
              if (!_tabController.indexIsChanging &&
                  !(viewModel.featuredResuts.value.length > 0)) {
                viewModel.context = SearchContext(searchMode: Mode.Featured);
                viewModel.Search();
              }
              break;
            }
          case 2:
            {
              if (!_tabController.indexIsChanging &&
                  !(viewModel.popularResuts.value.length > 0)) {
                viewModel.context = SearchContext(searchMode: Mode.Popular);
                viewModel.Search();
              }
              break;
            }
          case 3:
            {
              if (!_tabController.indexIsChanging) {
                viewModel.context = SearchContext(searchMode: Mode.Favorites);
                viewModel.Search();
              }
              break;
            }
        }
      });
    // TODO: implement initState
    super.initState();
    // FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-3909212246838265~8072372073');
    createBannerAd(viewModel);
    setState(() {
      Wakelock.enable();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TODO: implement dispose
    setState(() {
      Wakelock.disable();
    });
    super.dispose();
  }

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    nonPersonalizedAds: true,
    keywords: ['Music', 'Game', 'movie', 'entertainment'],
  );
  BannerAd _bannerAd;
  Future createBannerAd(MainViewModel viewModel) async {
    _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3909212246838265/2684830949',
        // adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) async {
          if (event == MobileAdEvent.loaded) {
            viewModel.showPading.value = true;
          }
          if (event == MobileAdEvent.failedToLoad) {
            viewModel.showPading.value = false;
            _bannerAd?.dispose();
            Future.delayed(Duration(seconds: 20))
                .then((value) => createBannerAd(viewModel));
          }
        })
      ..load()
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                )
        ],
        title: _isSearching
            ? TextField(
                style: TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  viewModel.context = SearchContext(
                      searchMode: Mode.Keyword, searchKeyword: value);
                  viewModel.Search();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ResultsPage(
                      searchCriteria: 'Search',
                      loadMore: () {
                        viewModel.Search();
                      },
                    ),
                  ));
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: 'Search Station',
                    hintStyle: TextStyle(color: Colors.white60)),
              )
            : Text('iRadio'),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              text: 'Popular Genres',
              icon: Icon(Icons.whatshot),
            ),
            Tab(
              text: 'Featured Stations',
              icon: Icon(
                Icons.verified_user,
                size: 32,
              ),
            ),
            Tab(
              text: 'Popular Stations',
              icon: Icon(
                Icons.whatshot,
              ),
            ),
            Tab(
              text: 'Favorites',
              icon: Icon(
                Icons.favorite,
              ),
            ),
          ],
          isScrollable: false,
        ),
      ),
      body: SafeArea(
        child: HomePage(
          tabController: _tabController,
        ),
      ),
    );
  }
}
