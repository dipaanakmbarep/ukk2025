import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({Key? key}) : super(key: key);

  @override
  _TambahProdukPageState createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController produkIdController = TextEditingController();
  final TextEditingController namaProdukController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();

  Future<void> tambahProduk() async {
    final String produkId = produkIdController.text.trim();
    final String namaProduk = namaProdukController.text.trim();
    final int? harga = int.tryParse(hargaController.text.trim());
    final int? stok = int.tryParse(stokController.text.trim());

    if (produkId.isEmpty || namaProduk.isEmpty || harga == null || stok == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi dengan benar!')),
      );
      return;
    }

    if (harga <= 0 || stok < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga harus lebih dari 0 dan stok tidak boleh negatif!')),
      );
      return;
    }

    try {
      final List existingProduct = await supabase
          .from('produk')
          .select('produkid')
          .eq('produkid', produkId);

      if (existingProduct.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk ID sudah terdaftar, gunakan ID lain!')),
        );
        return;
      }

      await supabase.from('produk').insert({
        'produkid': produkId,
        'namaproduk': namaProduk,
        'harga': harga,
        'stok': stok,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );

      produkIdController.clear();
      namaProdukController.clear();
      hargaController.clear();
      stokController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan produk: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      appBar: AppBar(
        title: const Text('Input Produk'),
        backgroundColor: Colors.blue.shade900, // AppBar biru 900
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: produkIdController,
              decoration: const InputDecoration(labelText: 'Produk ID'),
            ),
            TextField(
              controller: namaProdukController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: stokController,
              decoration: const InputDecoration(labelText: 'Stok'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900, // Tombol biru 900
                foregroundColor: Colors.white, // Teks putih
              ),
              onPressed: tambahProduk,
              child: const Text('Simpan Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
