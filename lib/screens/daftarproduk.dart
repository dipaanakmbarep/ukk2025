import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaftarProdukPage extends StatefulWidget {
  const DaftarProdukPage({Key? key}) : super(key: key);

  @override
  _DaftarProdukPageState createState() => _DaftarProdukPageState();
}

class _DaftarProdukPageState extends State<DaftarProdukPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> produkList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    setState(() => isLoading = true);
    final response = await supabase.from('produk').select();
    setState(() {
      produkList = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Produk')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : produkList.isEmpty
              ? const Center(child: Text('Belum ada produk', style: TextStyle(fontStyle: FontStyle.italic)))
              : ListView.builder(
                  itemCount: produkList.length,
                  itemBuilder: (context, index) {
                    final produk = produkList[index];
                    return ListTile(
                      title: Text(produk['namaproduk']),
                      subtitle: Text('Harga: Rp${produk['harga']} - Stok: ${produk['stok']}'),
                    );
                  },
                ),
    );
  }
}
