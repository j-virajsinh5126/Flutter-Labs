import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override Widget build(BuildContext context) {
    final cart=context.watch<CartProvider>();
    final products=context.watch<ProductProvider>().products;
    final items=products.where((p)=>cart.quantities.containsKey(p.id)).toList();
    final subtotal=cart.subtotal(items);
    final delivery=items.isEmpty || subtotal>=50 ? 0.0 : 4.99;
    return Scaffold(
      appBar:AppBar(title:const Text('Shopping cart'),actions:[
        if(!cart.isEmpty) IconButton(icon:const Icon(Icons.delete_outline),tooltip:'Clear cart',onPressed:()=>_clear(context))
      ]),
      body:cart.isEmpty
        ? const _EmptyCart()
        : items.isEmpty ? const Center(child:CircularProgressIndicator())
        : ListView(padding:const EdgeInsets.all(16),children:[
          ...items.map((p){
            final qty=cart.quantityFor(p);
            return Card(margin:const EdgeInsets.only(bottom:12),child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
              SizedBox(width:72,height:80,child:Image.network(p.image,fit:BoxFit.contain,errorBuilder:(_,__,___)=>const Icon(Icons.image_not_supported))),
              const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(p.title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w600)),
                const SizedBox(height:5),Text('\$${p.price.toStringAsFixed(2)}',style:const TextStyle(fontWeight:FontWeight.bold)),
                Row(children:[
                  IconButton(visualDensity:VisualDensity.compact,onPressed:()=>cart.setQuantity(p,qty-1),icon:const Icon(Icons.remove_circle_outline)),
                  Text('$qty'),IconButton(visualDensity:VisualDensity.compact,onPressed:()=>cart.setQuantity(p,qty+1),icon:const Icon(Icons.add_circle_outline)),
                  const Spacer(),IconButton(onPressed:()=>cart.remove(p),icon:const Icon(Icons.delete_outline,color:Colors.red))
                ])
              ]))
            ])));
          }),
          Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
            _row('Subtotal',subtotal),_row('Delivery',delivery),const Divider(height:24),
            _row('Total',subtotal+delivery,bold:true),const SizedBox(height:14),
            SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Checkout will be added in Batch 5.'))),icon:const Icon(Icons.lock_outline),label:const Text('Continue to checkout')))
          ])))
        ])
    );
  }
  Future<void> _clear(BuildContext context) async {
    final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Clear cart?'),content:const Text('Remove all items from your cart?'),actions:[
      TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),
      FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Clear'))
    ]));
    if(yes==true && context.mounted) await context.read<CartProvider>().clear();
  }
}
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisSize:MainAxisSize.min,children:[
    Icon(Icons.shopping_cart_outlined,size:64,color:Theme.of(context).colorScheme.primary),
    const SizedBox(height:14),const Text('Your cart is empty',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),const Text('Explore the catalogue and add products you love.',textAlign:TextAlign.center)
  ])));
}
Widget _row(String label,double value,{bool bold=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(children:[
  Text(label,style:TextStyle(fontWeight:bold?FontWeight.bold:FontWeight.normal)),const Spacer(),
  Text('\$${value.toStringAsFixed(2)}',style:TextStyle(fontWeight:bold?FontWeight.bold:FontWeight.normal,fontSize:bold?18:14))
]));
