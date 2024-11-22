import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:amazonclone/models/cart_item.dart';
import 'package:amazonclone/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  Future<void> fetchCartItems() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final snapshot = await _firestore
            .collection('carts')
            .doc(userId)
            .collection('items')
            .get();

        _cartItems = snapshot.docs.map((doc) {
          final data = doc.data();
          final product = Product.fromMap(data['product'], doc.id);
          final quantity = data['quantity'] ?? 1;
          return CartItem(product: product, quantity: quantity);
        }).toList();
        notifyListeners();
      } catch (e) {
        print("Error fetching cart items: $e");
      }
    }
  }
  Future<void> addToCart(Product product) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final cartRef = _firestore.collection('carts').doc(userId).collection('items');
        final cartItemRef = cartRef.doc(product.id);
        final doc = await cartItemRef.get();
        if (doc.exists) {
      
          final currentQuantity = doc['quantity'] ?? 0;
          await cartItemRef.update({
            'quantity': currentQuantity + 1,
          });
        } else {
          await cartItemRef.set({
            'product': product.toMap(),
            'quantity': 1,
          });
        }
        await fetchCartItems(); 
      } catch (e) {
        print("Error adding to cart: $e");
      }
    }
  }
  Future<void> removeFromCart(CartItem cartItem) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await _firestore
            .collection('carts')
            .doc(userId)
            .collection('items')
            .doc(cartItem.product.id)
            .delete();
        await fetchCartItems(); 
      } catch (e) {
        print("Error removing from cart: $e");
      }
    }
  }
  Future<void> updateQuantity(CartItem cartItem, int quantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {if (quantity < 1) {
        print("Quantity cannot be less than 1. Skipping update.");
        return;
      }
        await _firestore
            .collection('carts')
            .doc(userId)
            .collection('items')
            .doc(cartItem.product.id)
            .update({'quantity': quantity});
        await fetchCartItems(); 
      } catch (e) {
        print("Error updating quantity: $e");
      }
    }
  }
}
