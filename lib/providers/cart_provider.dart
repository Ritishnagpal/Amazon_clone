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

  // Fetch cart items from Firebase based on userId
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

  // Add a product to the cart in Firebase
  Future<void> addToCart(Product product) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final cartRef = _firestore.collection('carts').doc(userId).collection('items');
        final cartItemRef = cartRef.doc(product.id);

        // Check if product already exists in cart
        final doc = await cartItemRef.get();
        if (doc.exists) {
          // Update quantity if product already exists in cart
          final currentQuantity = doc['quantity'] ?? 0;
          await cartItemRef.update({
            'quantity': currentQuantity + 1,
          });
        } else {
          // Add new product to cart
          await cartItemRef.set({
            'product': product.toMap(),
            'quantity': 1,
          });
        }
        await fetchCartItems(); // Refresh cart after adding
      } catch (e) {
        print("Error adding to cart: $e");
      }
    }
  }

  // Remove an item from the cart in Firebase
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
        await fetchCartItems(); // Refresh cart after removal
      } catch (e) {
        print("Error removing from cart: $e");
      }
    }
  }

  // Update quantity of a cart item in Firebase
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
        await fetchCartItems(); // Refresh cart after update
      } catch (e) {
        print("Error updating quantity: $e");
      }
    }
  }
}
