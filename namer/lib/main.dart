import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(NamerApp());
}

class NamerApp extends StatelessWidget {
  NamerApp({ super.key });
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NamerAppState(),
      child: MaterialApp(
        title: "Namer app",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)
        ),
        home: HomePage(),
      )
    );
  }
}

class NamerAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }

    notifyListeners();
  }

  void deleteFavorite(wordPair) {
    favorites.removeWhere((element) => element == wordPair);
    notifyListeners();
  }

  bool isFavorite() {
    return favorites.contains(current);
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError("No widget for index $selectedIndex.");
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home")
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text("Favorites")
                    )
                  ]
                )
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              )
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<NamerAppState>();
    var pair = appState.current;
    var icon = appState.isFavorite() ? Icons.favorite : Icons.favorite_outline;

    return
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(wordPair: pair),
            SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  child: Row(
                    children: [
                      Icon(icon),
                      SizedBox(width: 4,),
                      Text("Favorite")
                    ],
                  ),
                ),
                SizedBox(width: 12,),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text("Next")
                ),
              ],
            )
          ],
        ),
      );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<NamerAppState>();

    if (appState.favorites.isEmpty) {
      return SafeArea(
        child: Container(
          height: double.infinity,
          padding: EdgeInsets.all(24.0),
          child: Text("No favorites saved."),
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("You have ${appState.favorites.length} favorite${appState.favorites.length > 1 ? 's' : ''} saved."),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.deleteFavorite(pair);
              },
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(pair.asLowerCase),
            dense: true,
            horizontalTitleGap: 0,
          )
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  final WordPair wordPair;

  BigCard({
    super.key,
    required this.wordPair
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              wordPair.first,
              style: textStyle.copyWith(fontWeight: FontWeight.w200),
              semanticsLabel: "${wordPair.first} ${wordPair.second}",
            ),
            Text(
              wordPair.second,
              style: textStyle.copyWith(fontWeight: FontWeight.bold),
              semanticsLabel: "${wordPair.first} ${wordPair.second}",
            ),
          ],
        ),
      ),
    );
  }
}