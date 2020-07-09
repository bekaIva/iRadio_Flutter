import 'package:flutter/material.dart';
import 'package:iradio/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

void main() => runApp(iRadio());

class iRadio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewModel(),
      child: MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity),
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
  List<TabContent> tabContents = [
    TabContent(title: 'test', icon: Icons.add),
    TabContent(title: 'test', icon: Icons.add),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabContents.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            tabs: tabContents.map((e) {
              return Tab(
                icon:Icon(e.icon),
                text: e.title,
              );
            }).toList(),
          ),
        ),
        drawer: Drawer(),
        body: SafeArea(
          child: TabBarView(
            children: tabContents.map((e) {
              return TabWidget(
                tabContent: e,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class TabContent {
  final String title;
  final IconData icon;
  const TabContent({this.title, this.icon});
}

class TabWidget extends StatelessWidget {
  final TabContent tabContent;
  TabWidget({this.tabContent});
  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              tabContent.icon,
              color: textStyle.color,
              size: 128.0,
            ),
            Text(
              tabContent.title,
              style: textStyle,
            )
          ],
        ),
      ),
    );
  }
}
