import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  @override Widget build(BuildContext context) {
    final saved=context.watch<WishlistProvider>();
    final products=context.watch<ProductProvider>().products.where((p)=>saved.productIds.contains(p.id)).toList();
    return Scaffold(appBar:AppBar(title:const Text('My wishlist')),body:products.isEmpty
      ? const Center(child:Padding(padding:EdgeInsets.all(30),child:Column(mainAxisSize:MainAxisSize.min,children:[
          Icon(Icons.favorite_border,size:64),SizedBox(height:14),Text('Your wishlist is empty',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),
          SizedBox(height:8),Text('Tap the heart on a product to save it for later.',textAlign:TextAlign.center)
        ])))
      : ListView.separated(padding:const EdgeInsets.all(16),itemCount:products.length,separatorBuilder:(_,__)=>const SizedBox(height:10),itemBuilder:(context,i){
        final p=products[i];
        return Card(child:ListTile(
          leading:SizedBox(width:54,height:60,child:Image.network(p.image,fit:BoxFit.contain,errorBuilder:(_,__,___)=>const Icon(Icons.image_not_supported))),
          title:Text(p.title,maxLines:2,overflow:TextOverflow.ellipsis),
          subtitle:Text('\$${p.price.toStringAsFixed(2)}'),
          onTap:()=>context.push('/product/${p.id}',extra:p),
          trailing:PopupMenuButton<String>(onSelected:(v)async{
            if(v=='remove'){await saved.remove(p);}
            if(v=='cart'){await context.read<CartProvider>().add(p);if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Added to cart')));}
          },itemBuilder:(_)=>const [
            PopupMenuItem(value:'cart',child:Text('Add to cart')),
            PopupMenuItem(value:'remove',child:Text('Remove from wishlist'))
          ])
        ));
      })
    );
  }
}
