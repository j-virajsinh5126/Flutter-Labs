import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class ProductCatalogueScreen extends StatefulWidget {
  const ProductCatalogueScreen({super.key});
  @override State<ProductCatalogueScreen> createState() => _ProductCatalogueScreenState();
}

class _ProductCatalogueScreenState extends State<ProductCatalogueScreen> {
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) context.read<ProductProvider>().loadProducts(); }); }

  @override Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Discover products'), actions: [IconButton(tooltip: 'Refresh', onPressed: () => context.read<ProductProvider>().loadProducts(forceRefresh: true), icon: const Icon(Icons.refresh))]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 10), child: Row(children: [Expanded(child: TextField(onChanged: context.read<ProductProvider>().setQuery, decoration: const InputDecoration(hintText: 'Search products...', prefixIcon: Icon(Icons.search)))), const SizedBox(width: 8), IconButton.filledTonal(onPressed: () => _showFilters(context), icon: const Icon(Icons.tune), tooltip: 'Filters') ])),
        SizedBox(height: 46, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: provider.categories.length, separatorBuilder: (_,__) => const SizedBox(width: 8), itemBuilder: (context,index) { final category=provider.categories[index]; final selected=provider.selectedCategory==category; return ChoiceChip(label: Text(_pretty(category)), selected: selected, onSelected: (_) => context.read<ProductProvider>().setCategory(category)); })),
        if (provider.isOfflineData) Container(width: double.infinity, margin: const EdgeInsets.fromLTRB(16,8,16,0), padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.amber.shade100,borderRadius: BorderRadius.circular(10)), child: const Text('Offline mode · Showing your saved product catalogue', style: TextStyle(fontSize: 12))),
        Expanded(child: _buildBody(provider)),
      ]),
    );
  }

  Widget _buildBody(ProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) return const Center(child: CircularProgressIndicator());
    if (provider.error != null && provider.products.isEmpty) return _MessageState(icon: Icons.wifi_off, title: 'Could not load products', message: provider.error!, action: 'Try again', onPressed: () => context.read<ProductProvider>().loadProducts(forceRefresh: true));
    final products=provider.filteredProducts;
    if (products.isEmpty) return _MessageState(icon: Icons.search_off, title: 'No products found', message: 'Try changing your search or filters.', action: 'Clear filters', onPressed: () => context.read<ProductProvider>().resetFilters());
    return RefreshIndicator(onRefresh: () => context.read<ProductProvider>().loadProducts(forceRefresh: true), child: GridView.builder(padding: const EdgeInsets.all(16), physics: const AlwaysScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .64), itemCount: products.length, itemBuilder: (context,index) => _ProductCard(product: products[index])));
  }

  Future<void> _showFilters(BuildContext context) async {
    final p=context.read<ProductProvider>(); double min=p.minPrice, max=p.maxPrice, rating=p.minimumRating; ProductSort sort=p.sort;
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheetContext) => StatefulBuilder(builder: (context,setSheetState) => Padding(padding: EdgeInsets.fromLTRB(20,8,20,20+MediaQuery.of(context).viewInsets.bottom), child: Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,children: [
      const Text('Advanced filters',style: TextStyle(fontSize:20,fontWeight:FontWeight.bold)), const SizedBox(height:16),
      Text('Maximum price: \$${max.toStringAsFixed(0)}'), Slider(value:max.clamp(50,1000),min:50,max:1000,divisions:19,label:'\$${max.toStringAsFixed(0)}',onChanged:(v)=>setSheetState(()=>max=v)),
      const Text('Minimum rating'), Wrap(spacing:8,children:[0.0,3.0,4.0].map((v)=>ChoiceChip(label:Text(v==0?'Any': '$v+ stars'),selected:rating==v,onSelected:(_)=>setSheetState(()=>rating=v))).toList()),
      const SizedBox(height:12), const Text('Sort by'), DropdownButtonFormField<ProductSort>(value:sort, items:const [DropdownMenuItem(value:ProductSort.recommended,child:Text('Recommended')),DropdownMenuItem(value:ProductSort.priceLowHigh,child:Text('Price: low to high')),DropdownMenuItem(value:ProductSort.priceHighLow,child:Text('Price: high to low')),DropdownMenuItem(value:ProductSort.rating,child:Text('Top rated'))],onChanged:(v)=>setSheetState(()=>sort=v??ProductSort.recommended)),
      const SizedBox(height:18), Row(children:[Expanded(child:OutlinedButton(onPressed:(){p.resetFilters(); Navigator.pop(context);},child:const Text('Reset'))),const SizedBox(width:10),Expanded(child:FilledButton(onPressed:(){p.setFilters(minPrice:min,maxPrice:max,minimumRating:rating,sort:sort);Navigator.pop(context);},child:const Text('Apply filters')))]),
    ]))));
  }
  String _pretty(String value) => value=='All' ? value : value.split(' ').map((s)=>s.isEmpty?s:'${s[0].toUpperCase()}${s.substring(1)}').join(' ');
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product}); final Product product;
  @override Widget build(BuildContext context) => InkWell(borderRadius:BorderRadius.circular(18),onTap:()=>context.push('/product/${product.id}',extra:product),child:Card(clipBehavior:Clip.antiAlias,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Padding(padding:const EdgeInsets.all(12),child:Center(child:Image.network(product.image,fit:BoxFit.contain,errorBuilder:(_,__,___)=>const Icon(Icons.image_not_supported_outlined,size:48))))),Padding(padding:const EdgeInsets.fromLTRB(12,0,12,12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(product.title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w600)),const SizedBox(height:6),Row(children:[const Icon(Icons.star_rounded,color:Colors.amber,size:16),Text(' ${product.rating.toStringAsFixed(1)} (${product.ratingCount})',style:Theme.of(context).textTheme.bodySmall)]),const SizedBox(height:6),Text('\$${product.price.toStringAsFixed(2)}',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold,color:Theme.of(context).colorScheme.primary))]))])));
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon,required this.title,required this.message,required this.action,required this.onPressed}); final IconData icon; final String title,message,action; final VoidCallback onPressed;
  @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:56,color:Theme.of(context).colorScheme.primary),const SizedBox(height:12),Text(title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),const SizedBox(height:6),Text(message,textAlign:TextAlign.center),const SizedBox(height:16),FilledButton(onPressed:onPressed,child:Text(action))])));
}
