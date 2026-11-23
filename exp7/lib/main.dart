
import 'package:flutter/material.dart';

void main() {
  runApp(const NewsDashboardApp());
}

// =====================================================
// NEWS MODEL
// =====================================================

class NewsArticle {
  final int id;
  final String title;
  final String description;
  final String category;
  final String author;
  final String date;
  final IconData icon;
  final Color color;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.author,
    required this.date,
    required this.icon,
    required this.color,
  });
}

// =====================================================
// NEWS DATA
// =====================================================

const List<NewsArticle> newsArticles = [
  NewsArticle(
    id: 1,
    title: 'Technology is Changing the Future',
    description:
        'Artificial Intelligence and modern technology are '
        'transforming industries around the world.',
    category: 'Technology',
    author: 'Rahul Sharma',
    date: 'Nov 23, 2026',
    icon: Icons.computer,
    color: Colors.blue,
  ),
  NewsArticle(
    id: 2,
    title: 'India Wins an Exciting Cricket Match',
    description:
        'India delivers an outstanding performance in an '
        'exciting international cricket match.',
    category: 'Sports',
    author: 'Amit Patel',
    date: 'Nov 22, 2026',
    icon: Icons.sports_cricket,
    color: Colors.orange,
  ),
  NewsArticle(
    id: 3,
    title: 'Stock Market Shows Positive Growth',
    description:
        'The stock market experiences positive movement '
        'as investors show confidence.',
    category: 'Business',
    author: 'Neha Shah',
    date: 'Nov 21, 2026',
    icon: Icons.trending_up,
    color: Colors.green,
  ),
  NewsArticle(
    id: 4,
    title: 'New Discoveries in Space Research',
    description:
        'Scientists are exploring new possibilities '
        'through advanced space research.',
    category: 'Science',
    author: 'Riya Mehta',
    date: 'Nov 20, 2026',
    icon: Icons.rocket_launch,
    color: Colors.deepPurple,
  ),
  NewsArticle(
    id: 5,
    title: 'Latest Smartphone Technology',
    description:
        'New smartphone innovations bring improved '
        'performance and better user experiences.',
    category: 'Technology',
    author: 'Karan Joshi',
    date: 'Nov 19, 2026',
    icon: Icons.smartphone,
    color: Colors.indigo,
  ),
  NewsArticle(
    id: 6,
    title: 'Football Championship Updates',
    description:
        'Teams prepare for an exciting championship '
        'with high expectations.',
    category: 'Sports',
    author: 'Jay Mehta',
    date: 'Nov 18, 2026',
    icon: Icons.sports_soccer,
    color: Colors.teal,
  ),
  NewsArticle(
    id: 7,
    title: 'Startup Ecosystem Expanding',
    description:
        'Young entrepreneurs are introducing innovative '
        'ideas and creating new opportunities.',
    category: 'Business',
    author: 'Priya Patel',
    date: 'Nov 17, 2026',
    icon: Icons.business,
    color: Colors.brown,
  ),
  NewsArticle(
    id: 8,
    title: 'Amazing Developments in Healthcare',
    description:
        'New scientific research is improving healthcare '
        'and medical treatment.',
    category: 'Science',
    author: 'Ankit Shah',
    date: 'Nov 16, 2026',
    icon: Icons.science,
    color: Colors.pink,
  ),
];

// =====================================================
// CATEGORY MODEL
// =====================================================

class NewsCategory {
  final String name;
  final IconData icon;
  final Color color;

  const NewsCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<NewsCategory> categories = [
  NewsCategory(
    name: 'Technology',
    icon: Icons.computer,
    color: Colors.blue,
  ),
  NewsCategory(
    name: 'Sports',
    icon: Icons.sports_cricket,
    color: Colors.orange,
  ),
  NewsCategory(
    name: 'Business',
    icon: Icons.business,
    color: Colors.green,
  ),
  NewsCategory(
    name: 'Science',
    icon: Icons.science,
    color: Colors.deepPurple,
  ),
];

// =====================================================
// MAIN APPLICATION
// =====================================================

class NewsDashboardApp extends StatelessWidget {
  const NewsDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NewsHub',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      ),

      home: const NewsDashboardPage(),
    );
  }
}

// =====================================================
// NEWS DASHBOARD SCREEN
// =====================================================

class NewsDashboardPage extends StatefulWidget {
  const NewsDashboardPage({super.key});

  @override
  State<NewsDashboardPage> createState() =>
      _NewsDashboardPageState();
}

class _NewsDashboardPageState extends State<NewsDashboardPage> {

  String selectedCategory = 'All';

  bool isGridView = false;

  bool isRefreshing = false;

  int refreshCount = 0;

  // FILTER NEWS ARTICLES
  List<NewsArticle> get filteredArticles {
    if (selectedCategory == 'All') {
      return newsArticles;
    }

    return newsArticles.where((article) {
      return article.category == selectedCategory;
    }).toList();
  }

  // PULL TO REFRESH
  Future<void> refreshNews() async {
    setState(() {
      isRefreshing = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      refreshCount++;
      isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('News refreshed successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // OPEN ARTICLE DETAILS
  void openArticle(NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return NewsDetailsPage(article: article);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final articles = filteredArticles;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshNews,

          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            slivers: [

              // =========================================
              // SLIVER APP BAR
              // =========================================

              SliverAppBar(
                expandedHeight: 190,
                pinned: true,
                floating: false,
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,

                title: const Text(
                  'NewsHub',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                actions: [
                  IconButton(
                    onPressed: refreshNews,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh News',
                  ),

                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications clicked'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                  ),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.indigo,
                          Colors.deepPurple,
                        ],
                      ),
                    ),

                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(
                        20, 90, 20, 20,
                      ),

                      child: Row(
                        children: [

                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.indigo,
                            ),
                          ),

                          SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'Stay Updated with News',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // =========================================
              // DASHBOARD HEADING
              // =========================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 20, 16, 12,
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Explore News',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Updated $refreshCount times',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =========================================
              // CATEGORY HEADING
              // =========================================

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // =========================================
              // SLIVER GRID FOR CATEGORIES
              // =========================================

              SliverPadding(
                padding: const EdgeInsets.all(12),

                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.1,
                  ),

                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];

                      return CategoryCard(
                        category: category,
                        isSelected:
                            selectedCategory == category.name,

                        onTap: () {
                          setState(() {
                            selectedCategory =
                                selectedCategory == category.name
                                    ? 'All'
                                    : category.name;
                          });
                        },
                      );
                    },

                    childCount: categories.length,
                  ),
                ),
              ),

              // =========================================
              // FEATURED SECTION HEADING
              // =========================================

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16, 10, 16, 12,
                  ),
                  child: Text(
                    'Featured Article',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // =========================================
              // FEATURED ARTICLE USING STACK
              // =========================================

              SliverToBoxAdapter(
                child: FeaturedArticleCard(
                  article: newsArticles.first,
                  onTap: () {
                    openArticle(newsArticles.first);
                  },
                ),
              ),

              // =========================================
              // NEWS HEADING AND VIEW SWITCH
              // =========================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 18, 16, 10,
                  ),

                  child: Row(
                    children: [

                      Expanded(
                        child: Text(
                          selectedCategory == 'All'
                              ? 'Latest News'
                              : '$selectedCategory News',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // LIST / GRID VIEW BUTTONS

                      IconButton(
                        tooltip: 'List View',
                        onPressed: () {
                          setState(() {
                            isGridView = false;
                          });
                        },
                        icon: Icon(
                          Icons.view_list,
                          color: !isGridView
                              ? Colors.indigo
                              : Colors.grey,
                        ),
                      ),

                      IconButton(
                        tooltip: 'Grid View',
                        onPressed: () {
                          setState(() {
                            isGridView = true;
                          });
                        },
                        icon: Icon(
                          Icons.grid_view,
                          color: isGridView
                              ? Colors.indigo
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =========================================
              // FILTERED NEWS CONTENT
              // SLIVER LIST OR SLIVER GRID
              // =========================================

              if (articles.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('No news articles found'),
                    ),
                  ),
                )

              else if (isGridView)

                // SLIVER GRID FOR NEWS
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),

                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),

                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final article = articles[index];

                        return NewsGridCard(
                          article: article,
                          onTap: () {
                            openArticle(article);
                          },
                        );
                      },

                      childCount: articles.length,
                    ),
                  ),
                )

              else

                // SLIVER LIST FOR NEWS
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),

                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final article = articles[index];

                        return NewsListCard(
                          article: article,
                          onTap: () {
                            openArticle(article);
                          },
                        );
                      },

                      childCount: articles.length,
                    ),
                  ),
                ),

              // =========================================
              // FOOTER
              // =========================================

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Center(
                    child: Text(
                      'You have reached the end of the news feed.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
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
// CATEGORY CARD
// =====================================================

class CategoryCard extends StatelessWidget {
  final NewsCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.20)
              : Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: isSelected
                ? category.color
                : Colors.transparent,
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
            ),
          ],
        ),

        child: Row(
          children: [

            Icon(
              category.icon,
              color: category.color,
              size: 28,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// FEATURED ARTICLE USING STACK
// =====================================================

class FeaturedArticleCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 15),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: article.color,
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),

          // STACK WIDGET
          child: Stack(
            fit: StackFit.expand,
            children: [

              // BACKGROUND ICON
              Container(
                color: article.color.withValues(alpha: 0.85),
                child: Icon(
                  article.icon,
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),

              // GRADIENT OVERLAY
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),

              // TEXT ON TOP
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${article.category} • ${article.author}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
// NEWS LIST CARD USING CARD AND LISTTILE
// =====================================================

class NewsListCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsListCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,

      child: ListTile(
        contentPadding: const EdgeInsets.all(10),

        leading: Container(
          width: 65,
          height: 65,

          decoration: BoxDecoration(
            color: article.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(
            article.icon,
            size: 35,
            color: article.color,
          ),
        ),

        title: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 6),

              Text(
                '${article.author} • ${article.date}',
                style: const TextStyle(
                  color: Colors.indigo,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),

        onTap: onTap,
      ),
    );
  }
}

// =====================================================
// NEWS GRID CARD
// =====================================================

class NewsGridCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsGridCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGE AREA
            Expanded(
              flex: 3,

              child: Container(
                width: double.infinity,
                color: article.color.withValues(alpha: 0.15),

                child: Icon(
                  article.icon,
                  size: 65,
                  color: article.color,
                ),
              ),
            ),

            // ARTICLE INFORMATION
            Expanded(
              flex: 2,

              child: Padding(
                padding: const EdgeInsets.all(10),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      article.category.toUpperCase(),
                      style: TextStyle(
                        color: article.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      article.author,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// NEWS DETAILS SCREEN
// =====================================================

class NewsDetailsPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailsPage({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ARTICLE IMAGE
            Container(
              width: double.infinity,
              height: 230,

              decoration: BoxDecoration(
                color: article.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),

              child: Icon(
                article.icon,
                size: 120,
                color: article.color,
              ),
            ),

            const SizedBox(height: 20),

            // CATEGORY
            Text(
              article.category.toUpperCase(),
              style: TextStyle(
                color: article.color,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // TITLE
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // AUTHOR
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 18,
                ),

                const SizedBox(width: 6),

                Text(
                  article.author,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(width: 15),

                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 15,
                ),

                const SizedBox(width: 6),

                Text(
                  article.date,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            // DESCRIPTION
            const Text(
              'About This News',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              article.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Stay connected with NewsHub for more updates '
              'and the latest news from around the world.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
