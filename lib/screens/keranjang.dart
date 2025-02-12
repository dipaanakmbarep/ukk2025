import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class KeranjangPage extends StatefulWidget {
  @override
  _KeranjangPageState createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> keranjang = [];
  double totalHarga = 0.0;

  @override
  void initState() {
    super.initState();
    _loadKeranjang();
  }

  Future<void> _loadKeranjang() async {
    final response = await supabase.from('keranjang').select();
    setState(() {
      keranjang = response;
      totalHarga = _hitungTotalHarga();
    });
  }

  double _hitungTotalHarga() {
    return keranjang.fold(0, (sum, item) => sum + (item['harga'] * item['jumlah']));
  }

  Future<void> _updateStokDanCheckout() async {
    final pelangganId = 1; // Gantilah dengan ID pelanggan yang sesuai
    final tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Buat ID Penjualan unik (7 digit)
    final idPenjualan = DateTime.now().millisecondsSinceEpoch.toString().substring(5, 12);

    // Simpan data transaksi ke tabel penjualan
    final response = await supabase.from('penjualan').insert({
      'id_penjualan': idPenjualan,
      'tanggal': tanggal,
      'total_harga': totalHarga,
      'pelangganid': pelangganId,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (response.error == null) {
      // Kurangi stok produk
      for (var item in keranjang) {
        await supabase.from('produk').update({
          'stok': item['stok'] - item['jumlah']
        }).match({'produkid': item['produkid']});
      }

      // Kosongkan keranjang setelah checkout
      await supabase.from('keranjang').delete().neq('id', 0);

      setState(() {
        keranjang.clear();
        totalHarga = 0.0;
      });

      _tampilkanStruk(idPenjualan, tanggal);
    }
  }

  void _tampilkanStruk(String idPenjualan, String tanggal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Struk Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo.png', height: 50), // Pastikan logo ada di folder assets
              Text('ID Penjualan: $idPenjualan'),
              Text('Tanggal: $tanggal'),
              Text('Total: Rp${totalHarga.toStringAsFixed(0)}'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Konfirmasi'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Tambahkan logika cetak struk di sini
                    },
                    child: Text('Cetak Struk'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _hapusItem(int id) async {
    await supabase.from('keranjang').delete().match({'id': id});
    _loadKeranjang();
  }

  Future<void> _ubahJumlah(int id, int jumlah) async {
    if (jumlah > 0) {
      await supabase.from('keranjang').update({'jumlah': jumlah}).match({'id': id});
    } else {
      await _hapusItem(id);
    }
    _loadKeranjang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keranjang Belanja')),
      body: keranjang.isEmpty
          ? Center(child: Text('Keranjang kosong'))
          : ListView.builder(
              itemCount: keranjang.length,
              itemBuilder: (context, index) {
                final item = keranjang[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item['namaproduk']),
                    subtitle: Text('Rp${item['harga']} x ${item['jumlah']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _ubahJumlah(item['id'], item['jumlah'] - 1),
                        ),
                        Text('${item['jumlah']}'),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () => _ubahJumlah(item['id'], item['jumlah'] + 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Harga:', style: TextStyle(fontSize: 18, color: Colors.blue)),
                Text('Rp${totalHarga.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        keranjang.clear();
                        totalHarga = 0.0;
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Batalkan Pembayaran', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: keranjang.isEmpty ? null : _updateStokDanCheckout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Lanjutkan Pembayaran', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
