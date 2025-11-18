import 'package:flutter/material.dart';
import '../models/store_model.dart';
import '../services/store_services.dart';
import 'detailpage.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StoreServices _service = StoreServices();
  final ScrollController _scrollCtrl = ScrollController();

  bool _isGrid = true;
  bool _loading = false;
  String? _error;
  List<StoreModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadTopAnime();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTopAnime() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchProducts();
      setState(() => _items = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadTopAnime();
  }

  void _openDetail(StoreModel store) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailPage(store: store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('E commerce'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Cart',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () {
              setState(() => _isGrid = !_isGrid);
            },
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: _isGrid ? 'Switch to list' : 'Switch to grid',
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_loading && _items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_error != null && _items.isEmpty) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text('Terjadi kesalahan: $_error')),
                  ],
                ),
              );
            }

            final items = _items;

            if (items.isEmpty) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('Tidak ada data')),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: _isGrid ? _buildGrid(items) : _buildList(items),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid(List<StoreModel> items) {
    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length + (_loading ? 1 : 0),
      itemBuilder: (context, idx) {
        if (idx >= items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final anime = items[idx];
        return GestureDetector(
          onTap: () => _openDetail(anime),
          child: Card(
            color: Colors.white,
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: anime.imageUrl.isNotEmpty
                      ? Image.network(
                          anime.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                        )
                      : const Center(child: Icon(Icons.image)),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Color(0xFFE91E63)),
                          const SizedBox(width: 6),
                          Text(
                            anime.score.toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<StoreModel> items) {
    return ListView.separated(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(8),
      itemCount: items.length + (_loading ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        if (idx >= items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final anime = items[idx];
        return ListTile(
          onTap: () => _openDetail(anime),
          leading: SizedBox(
            width: 56,
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: anime.imageUrl.isNotEmpty
                  ? Image.network(
                      anime.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image)),
                    )
                  : const Center(child: Icon(Icons.image)),
            ),
          ),
          title: Text(
            anime.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              const Icon(Icons.star, size: 14, color: Color(0xFFE91E63)),
              const SizedBox(width: 6),
              Text(anime.score.toString()),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
 