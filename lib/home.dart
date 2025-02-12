import 'package:flutter/material.dart';
import 'screens/user.dart';
import 'screens/tambahproduk.dart';
import 'screens/produk.dart';
import 'screens/keranjang.dart'; // Import benar
import 'login.dart';
import 'screens/pelanggan.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String email;

  const HomePage({super.key, required this.username, required this.email});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      BerandaTab(username: widget.username),
       ProdukPage(),
       KeranjangPage(), // Perbaikan: Menggunakan KeranjangPage() dari keranjang.dart
      const RiwayatTab(),
    ];
  }

  String _getTabTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Produk';
      case 2:
        return 'Keranjang';
      case 3:
        return 'Riwayat';
      default:
        return '';
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTabTitle(), style: const TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(153),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[900]),
              accountName: Text(widget.username, style: const TextStyle(color: Colors.white)),
              accountEmail: Text(widget.email, style: const TextStyle(color: Colors.white)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 40.0, color: Colors.blue[900]),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Beranda', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.white),
              title: const Text('User', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box, color: Colors.white),
              title: const Text('Produk', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahProdukPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.white),
              title: const Text('Pelanggan', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PelangganPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.white),
              title: const Text('Keranjang', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  KeranjangPage()));
              },
            ),
            const Divider(color: Colors.white),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class BerandaTab extends StatelessWidget {
  final String username;

  const BerandaTab({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat datang, $username',
              style: const TextStyle(fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RiwayatTab extends StatelessWidget {
  const RiwayatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text('Riwayat Transaksi', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }
}
