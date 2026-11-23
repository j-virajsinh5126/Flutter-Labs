
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const QuoteApp());
}

// =====================================================
// QUOTE MODEL
// =====================================================

class Quote {
  final int id;
  final String quote;
  final String author;

  const Quote({
    required this.id,
    required this.quote,
    required this.author,
  });

  // JSON TO DART OBJECT
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as int,
      quote: json['quote'] as String,
      author: json['author'] as String,
    );
  }

  // DART OBJECT TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
    };
  }
}

// =====================================================
// API SERVICE
// =====================================================

class QuoteService {
  static const String apiUrl =
      'https://dummyjson.com/quotes/random';

  static Future<Quote> fetchQuote() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        final quote = Quote.fromJson(data);

        if (quote.quote.trim().isEmpty) {
          throw Exception('The API returned an empty quote.');
        }

        return quote;
      } else {
        throw Exception(
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Unable to connect to the server.');
    }
  }
}

// =====================================================
// FAVORITE STORAGE SERVICE
// =====================================================

class FavoriteService {
  static const String storageKey = 'favorite_quotes';

  // LOAD FAVORITES
  static Future<List<Quote>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final savedQuotes = prefs.getStringList(storageKey) ?? [];

    return savedQuotes.map((item) {
      return Quote.fromJson(
        jsonDecode(item) as Map<String, dynamic>,
      );
    }).toList();
  }

  // SAVE FAVORITES
  static Future<void> saveFavorites(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();

    final data = quotes.map((quote) {
      return jsonEncode(quote.toJson());
    }).toList();

    await prefs.setStringList(storageKey, data);
  }
}

// =====================================================
// MAIN APPLICATION
// =====================================================

class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Quotes',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F3FA),
      ),

      home: const QuoteHomePage(),
    );
  }
}

// =====================================================
// HOME PAGE
// =====================================================

class QuoteHomePage extends StatefulWidget {
  const QuoteHomePage({super.key});

  @override
  State<QuoteHomePage> createState() => _QuoteHomePageState();
}

class _QuoteHomePageState extends State<QuoteHomePage> {

  late Future<Quote> quoteFuture;

  List<Quote> favorites = [];

  bool isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();

    quoteFuture = QuoteService.fetchQuote();

    loadFavorites();
  }

  // LOAD SAVED FAVORITES
  Future<void> loadFavorites() async {
    try {
      final saved = await FavoriteService.loadFavorites();

      if (!mounted) return;

      setState(() {
        favorites = saved;
        isLoadingFavorites = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingFavorites = false;
      });
    }
  }

  // FETCH ANOTHER QUOTE
  void getAnotherQuote() {
    setState(() {
      quoteFuture = QuoteService.fetchQuote();
    });
  }

  // CHECK FAVORITE
  bool isFavorite(Quote quote) {
    return favorites.any((item) => item.id == quote.id);
  }

  // ADD OR REMOVE FAVORITE
  Future<void> toggleFavorite(Quote quote) async {

    if (isLoadingFavorites) return;

    final alreadyFavorite = isFavorite(quote);

    final updatedFavorites = [...favorites];

    if (alreadyFavorite) {
      updatedFavorites.removeWhere(
        (item) => item.id == quote.id,
      );
    } else {
      updatedFavorites.add(quote);
    }

    try {
      await FavoriteService.saveFavorites(updatedFavorites);

      if (!mounted) return;

      setState(() {
        favorites = updatedFavorites;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alreadyFavorite
                ? 'Removed from favorites'
                : 'Added to favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save favorite.'),
        ),
      );
    }
  }

  // SHARE QUOTE
  Future<void> shareQuote(Quote quote) async {
    final message =
        '"${quote.quote}"\n\n- ${quote.author}\n\nShared via Daily Quotes App';

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'Inspirational Quote',
      ),
    );
  }

  // OPEN FAVORITES SCREEN
  void openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FavoritesPage(
            favorites: favorites,

            onRemove: (quote) async {
              final updated = [...favorites];

              updated.removeWhere(
                (item) => item.id == quote.id,
              );

              await FavoriteService.saveFavorites(updated);

              if (!mounted) return;

              setState(() {
                favorites = updated;
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,

        title: const Text(
          'Daily Quotes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          // FAVORITES BUTTON
          IconButton(
            onPressed: openFavorites,
            tooltip: 'Favorite Quotes',

            icon: Badge(
              label: Text('${favorites.length}'),
              isLabelVisible: favorites.isNotEmpty,
              child: const Icon(Icons.favorite),
            ),
          ),
        ],
      ),

      // BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 20),

              // HEADER
              const Icon(
                Icons.format_quote,
                size: 65,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 10),

              const Text(
                'Daily Inspiration',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Get inspired with a new quote every day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 35),

              // FUTURE BUILDER
              FutureBuilder<Quote>(
                future: quoteFuture,

                builder: (context, snapshot) {

                  // LOADING STATE
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const QuoteLoadingWidget();
                  }

                  // ERROR STATE
                  if (snapshot.hasError) {
                    return QuoteErrorWidget(
                      message: snapshot.error.toString(),
                      onRetry: getAnotherQuote,
                    );
                  }

                  // EMPTY RESPONSE STATE
                  if (!snapshot.hasData ||
                      snapshot.data!.quote.trim().isEmpty) {
                    return QuoteEmptyWidget(
                      onRetry: getAnotherQuote,
                    );
                  }

                  final quote = snapshot.data!;

                  // SUCCESS STATE
                  return QuoteCard(
                    quote: quote,

                    isFavorite: isFavorite(quote),

                    onFavorite: () {
                      toggleFavorite(quote);
                    },

                    onShare: () {
                      shareQuote(quote);
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

              // FETCH ANOTHER QUOTE BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: getAnotherQuote,

                  icon: const Icon(Icons.refresh),

                  label: const Text(
                    'Get Another Quote',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // FAVORITES SCREEN BUTTON
              OutlinedButton.icon(
                onPressed: openFavorites,
                icon: const Icon(Icons.favorite_border),
                label: const Text('View Favorite Quotes'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.all(15),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Stay positive. Keep learning. Keep growing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// QUOTE CARD
// =====================================================

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.isFavorite,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple,
            Color(0xFF673AB7),
            Color(0xFF512DA8),
          ],
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [

          const Icon(
            Icons.format_quote,
            color: Colors.white70,
            size: 50,
          ),

          const SizedBox(height: 15),

          // QUOTE TEXT
          Text(
            quote.quote,
            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 25),

          // AUTHOR
          Container(
            width: 55,
            height: 2,
            color: Colors.white70,
          ),

          const SizedBox(height: 15),

          Text(
            '- ${quote.author}',
            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          // ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // FAVORITE
              IconButton(
                onPressed: onFavorite,

                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.redAccent
                      : Colors.white,
                  size: 30,
                ),

                tooltip: 'Add to favorites',
              ),

              const SizedBox(width: 25),

              // SHARE
              IconButton(
                onPressed: onShare,

                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 27,
                ),

                tooltip: 'Share Quote',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// LOADING WIDGET
// =====================================================

class QuoteLoadingWidget extends StatelessWidget {
  const QuoteLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          CircularProgressIndicator(
            color: Colors.deepPurple,
          ),

          SizedBox(height: 20),

          Text(
            'Fetching an inspirational quote...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ERROR WIDGET
// =====================================================

class QuoteErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const QuoteErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          const Icon(
            Icons.cloud_off,
            color: Colors.red,
            size: 65,
          ),

          const SizedBox(height: 15),

          const Text(
            'Something Went Wrong!',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// EMPTY RESPONSE WIDGET
// =====================================================

class QuoteEmptyWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const QuoteEmptyWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          const Icon(
            Icons.format_quote,
            size: 60,
            color: Colors.grey,
          ),

          const SizedBox(height: 15),

          const Text(
            'No Quote Available',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Fetch Again'),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FAVORITES SCREEN
// =====================================================

class FavoritesPage extends StatefulWidget {
  final List<Quote> favorites;
  final Future<void> Function(Quote) onRemove;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onRemove,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  late List<Quote> favoriteQuotes;

  @override
  void initState() {
    super.initState();
    favoriteQuotes = [...widget.favorites];
  }

  Future<void> removeFavorite(Quote quote) async {
    await widget.onRemove(quote);

    if (!mounted) return;

    setState(() {
      favoriteQuotes.removeWhere(
        (item) => item.id == quote.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorite removed'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quotes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: favoriteQuotes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 75,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No Favorite Quotes Yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )

          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoriteQuotes.length,

              itemBuilder: (context, index) {
                final quote = favoriteQuotes[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  child: Padding(
                    padding: const EdgeInsets.all(15),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Icon(
                          Icons.format_quote,
                          color: Colors.deepPurple,
                          size: 30,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          quote.quote,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            Expanded(
                              child: Text(
                                '- ${quote.author}',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                removeFavorite(quote);
                              },

                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),

                              tooltip: 'Remove Favorite',
                            ),

                            IconButton(
                              onPressed: () {
                                SharePlus.instance.share(
                                  ShareParams(
                                    text: '"${quote.quote}"\n\n- ${quote.author}',
                                    subject: 'Inspirational Quote',
                                  ),
                                );
                              },

                              icon: const Icon(
                                Icons.share,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
