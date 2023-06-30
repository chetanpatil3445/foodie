import 'package:badges/badges.dart' as badge;
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Db_helper.dart';
import 'cart_model.dart';
import '../Screens/cart_provider.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  DBHelper? dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    final cart  = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        centerTitle: true,
        actions: [
          Center(
            child: badge.Badge(
              badgeContent: Consumer<CartProvider>(
                builder: (context, value , child){
                  return Text(value.getCounter().toString(),style: TextStyle(color: Colors.white));
                },

              ),
              // animationDuration: Duration(milliseconds: 300),
              // animationType: BadgeAnimationType.slide,
              child: Icon(Icons.shopping_cart),
            ),
          ),
          SizedBox(width: 20.0)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            FutureBuilder(
                future:cart.getData() ,
                builder: (context , AsyncSnapshot<List<Cart>> snapshot){
                  if(snapshot.hasData){

                    if(snapshot.data!.isEmpty){
                      return Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Image(
                              image: AssetImage('asset/images/empty.png'),
                            ),
                            SizedBox(height: 20,),
                            Text('Your cart is empty 😌' ,style: Theme.of(context).textTheme.headline5),
                            SizedBox(height: 20,),
                            Text('Explore products and shop your\nfavourite items' , textAlign: TextAlign.center ,style: Theme.of(context).textTheme.subtitle2)

                          ],
                        ),
                      );
                    }else {
                      return Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index){
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            height: 100,
                                            width: 100,
                                            child: Image(
                                              image: AssetImage(snapshot.data![index].image.toString()),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(snapshot.data![index].productName.toString() ,
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                    ),
                                                    InkWell(
                                                        onTap: (){
                                                          dbHelper!.delete(snapshot.data![index].id!);
                                                          cart.removerCounter();
                                                          cart.removeTotalPrice(double.parse(snapshot.data![index].productPrice.toString()));
                                                        },
                                                        child: Icon(Icons.delete))
                                                  ],
                                                ),

                                                SizedBox(height: 5,),
                                                Text(snapshot.data![index].unitTag.toString() +" "+r"$"+ snapshot.data![index].productPrice.toString() ,
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                ),
                                                SizedBox(height: 5,),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: InkWell(
                                                    onTap: (){},
                                                    child:  Container(
                                                      height: 35,
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius: BorderRadius.circular(5)
                                                      ),
                                                      child:  Padding(
                                                        padding: const EdgeInsets.all(4.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            InkWell(
                                                                onTap: (){

                                                                  int quantity =  snapshot.data![index].quantity! ;
                                                                  int price = snapshot.data![index].initialPrice!;
                                                                  quantity--;
                                                                  int? newPrice = price * quantity ;

                                                                  if(quantity > 0){
                                                                    dbHelper!.updateQuantity(
                                                                        Cart(
                                                                            id: snapshot.data![index].id!,
                                                                            productId: snapshot.data![index].id!.toString(),
                                                                            productName: snapshot.data![index].productName!,
                                                                            initialPrice: snapshot.data![index].initialPrice!,
                                                                            productPrice: newPrice,
                                                                            quantity: quantity,
                                                                            unitTag: snapshot.data![index].unitTag.toString(),
                                                                            image: snapshot.data![index].image.toString())
                                                                    ).then((value){
                                                                      newPrice = 0 ;
                                                                      quantity = 0;
                                                                      cart.removeTotalPrice(double.parse(snapshot.data![index].initialPrice!.toString()));
                                                                    }).onError((error, stackTrace){
                                                                      print(error.toString());
                                                                    });
                                                                  }

                                                                },
                                                                child: Icon(Icons.remove , color: Colors.white,)),
                                                            Text( snapshot.data![index].quantity.toString(), style: TextStyle(color: Colors.white)),
                                                            InkWell(
                                                                onTap: (){
                                                                  int quantity =  snapshot.data![index].quantity! ;
                                                                  int price = snapshot.data![index].initialPrice!;
                                                                  quantity++;
                                                                  int? newPrice = price * quantity ;

                                                                  dbHelper!.updateQuantity(
                                                                      Cart(
                                                                          id: snapshot.data![index].id!,
                                                                          productId: snapshot.data![index].id!.toString(),
                                                                          productName: snapshot.data![index].productName!,
                                                                          initialPrice: snapshot.data![index].initialPrice!,
                                                                          productPrice: newPrice,
                                                                          quantity: quantity,
                                                                          unitTag: snapshot.data![index].unitTag.toString(),
                                                                          image: snapshot.data![index].image.toString())
                                                                  ).then((value){
                                                                    newPrice = 0 ;
                                                                    quantity = 0;
                                                                    cart.addTotalPrice(double.parse(snapshot.data![index].initialPrice!.toString()));
                                                                  }).onError((error, stackTrace){
                                                                    print(error.toString());
                                                                  });
                                                                },
                                                                child: Icon(Icons.add , color: Colors.white,)),

                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )

                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      );
                    }

                  }
                  return Text('') ;
                }),
            Container(
              height: 40,
              width: 170,
              child: Consumer<CartProvider>(builder: (context, value, child){
                return ElevatedButton(
                  onPressed: () {

                  },
                  child: Visibility(
                    visible: value.getTotalPrice().toStringAsFixed(2) == "0.00" ? false : true,
                    child: Column(
                      children: [
                       // ReusableWidget(title: 'Sub Total', value: r'$'+value.getTotalPrice().toStringAsFixed(2),),
                       // ReusableWidget(title: 'Discout 5%', value: r'$'+'20',),
                        ReusableWidget(title: 'Place Order', value: r' $'+value.getTotalPrice().toStringAsFixed(2),),

                      ],
                    ),
                  ),
                );
              }),
            )
            /*  ElevatedButton(
                        onPressed: () {
                          List<Cart> cartItems = cart.getCartItems(); // Get the cart items from CartProvider

                          // Calculate the total price of the cart items
                          double totalPrice = 0.0;
                          for (Cart item in cartItems) {
                            totalPrice += item.productPrice!;
                          }

                          // Apply a discount of 5% to the total price
                          double discount = totalPrice * 0.05;
                          double discountedPrice = totalPrice - discount;

                          // Show a dialog or navigate to the payment method screen with the calculated details
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Payment Method'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
                                    Text('Discount (5%): \$${discount.toStringAsFixed(2)}'),
                                    Text('Discounted Price: \$${discountedPrice.toStringAsFixed(2)}'),
                                    // Add any additional payment method details here
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },

                        child: Text('Place Order'),)*/
          ],
        ),
      ) ,
    );
  }
}


class ReusableWidget extends StatelessWidget {
  final String title , value ;
  const ReusableWidget({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title , style: Theme.of(context).textTheme.subtitle2,),
          Text(value.toString() , style: Theme.of(context).textTheme.subtitle2,)
        ],
      ),
    );
  }
}
