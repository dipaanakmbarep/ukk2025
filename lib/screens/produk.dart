import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
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
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Produk ID')),
                      DataColumn(label: Text('Nama Produk')),
                      DataColumn(label: Text('Harga')),
                      DataColumn(label: Text('Stok')),
                    ],
                    rows: produkList.map((produk) {
                      return DataRow(cells: [
                        DataCell(Text(produk['produkid'].toString())),
                        DataCell(Text(produk['namaproduk'])),
                        DataCell(Text('Rp${produk['harga']}')),
                        DataCell(Text(produk['stok'].toString())),
                      ]);
                    }).toList(),
                  ),
                ),
    );
  }
}
