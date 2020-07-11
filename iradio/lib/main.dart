import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iradio/Models/Enums.dart';
import 'package:iradio/Models/SearchContext.dart';
import 'package:iradio/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

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

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('iRadio'),
          bottom: TabBar(
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
            ],
            isScrollable: false,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              Consumer<MainViewModel>(
                builder: (context, viewmodel, widget) => Container(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    physics: BouncingScrollPhysics(),
                    child: Table(
                      children: () {
                        int i = viewmodel.genres.length ~/ 4;
                        int taken = 0;
                        List<TableRow> children = List<TableRow>();
                        for (int ii = 0; ii < i; ii++) {
                          List<Widget> row = viewmodel.genres
                              .skip(taken)
                              .take(4)
                              .map((e) => GenreWidget(
                                    genreTapped: (genre) {
                                      viewmodel.context =
                                          SearchContext.Genre(genre);
                                      viewmodel.Search();
                                    },
                                    genre: e,
                                  ))
                              .toList();
                          taken += 4;
                          children.add(TableRow(children: row));
                        }
                        if (viewmodel.genres.length > taken) {
                          var l = viewmodel.genres
                              .skip(viewmodel.genres.length - taken)
                              .map((e) => Container(
                                    child: Text(e.toString()),
                                  ))
                              .toList();

                          while (l.length < 4) {
                            l.add(Container());
                          }

                          children.add(TableRow(children: l));
                        }
                        return children;
                      }(),
                    ),
                  ),
                ),
              ),
              Container(),
              Container()
            ],
          ),
        ),
      ),
    );
  }
}

class GenreWidget extends StatelessWidget {
  final Genre genre;
  final Function(Genre genre) genreTapped;
  GenreWidget({this.genre, this.genreTapped});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        child: Card(
          child: FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onPressed: () {
              genreTapped?.call(genre);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  genre
                      .toString()
                      .replaceAll('Genre.', '')
                      .replaceAll('_', ' '),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.copse(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
    );
  }
}
