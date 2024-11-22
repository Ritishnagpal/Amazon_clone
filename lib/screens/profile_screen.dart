import 'package:amazonclone/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;
  String? _name;
  bool _isNameEditing = false;
  bool _isEmailEditing = false;
  bool _isUpdating = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _fetchUserDetails() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception("No user is logged in!");

      final uid = user.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData != null) {
        setState(() {
          _email = userData['email'];
          _name = userData['name'];
          _nameController.text = _name ?? '';
          _emailController.text = _email ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    }
  }
  Future<void> _updateUserDetails() async {
    setState(() {
      _isUpdating = true;
    });
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception("No user is logged in!");

      final uid = user.uid;
      final updatedName = _nameController.text.trim();
      final updatedEmail = _emailController.text.trim();

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your email before updating it.')),
        );
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': updatedName,
        'email': updatedEmail,
      });

      if (user.email != updatedEmail) {
        await user.updateEmail(updatedEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated, please verify it.')),
        );
      }

      setState(() {
        _name = updatedName;
        _email = updatedEmail;
        _isNameEditing = false;
        _isEmailEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Profile'),
          backgroundColor: Colors.orange,
          centerTitle: true,
          actions: [

          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _isNameEditing
                    ? TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                )
                    : Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(_name ?? 'Name'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isNameEditing = true;
                          _isEmailEditing = false;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isEmailEditing
                    ? TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                )
                    : Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(_email ?? 'Email'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isEmailEditing = true;
                          _isNameEditing = false;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isNameEditing || _isEmailEditing)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _isUpdating ? null : _updateUserDetails,
                    child: _isUpdating
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      'Update Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

