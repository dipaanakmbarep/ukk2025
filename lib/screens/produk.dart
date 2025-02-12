import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukPage extends StatefulWidget {
  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _loadProduk() async {
    try {
      final response = await supabase.from('produk').select();
      print(response); // Debug: cek apakah data terambil
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Future<void> _tambahKeKeranjang(String nama, double harga) async {
    try {
      await supabase.from('keranjang').insert({
        'namaproduk': nama,
        'harga': harga,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$nama ditambahkan ke keranjang')),
      );
    } catch (e) {
      print("Error saat menambahkan ke keranjang: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produk')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadProduk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan, coba lagi.'));
          }

          final produk = snapshot.data ?? [];
          final makanan = produk.where((item) => item['kategori'] == 'Makanan').toList();
          final minuman = produk.where((item) => item['kategori'] == 'Minuman').toList();

          if (produk.isEmpty) {
            return Center(child: Text('Tidak ada produk tersedia.'));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text("Makanan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...makanan.map((item) => Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(item['namaproduk']),
                      subtitle: Text('Rp${item['harga']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.shopping_cart, color: Colors.blue),
                        onPressed: () => _tambahKeKeranjang(item['namaproduk'], item['harga']),
                      ),
                    ),
                  )),

              SizedBox(height: 16),

              Text("Minuman", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...minuman.map((item) => Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(item['namaproduk']),
                      subtitle: Text('Rp${item['harga']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.shopping_cart, color: Colors.blue),
                        onPressed: () => _tambahKeKeranjang(item['namaproduk'], item['harga']),
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
