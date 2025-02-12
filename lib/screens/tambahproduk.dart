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
  String? kategori;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> productList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await supabase.from('produk').select();
    setState(() {
      productList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> tambahProduk() async {
    if (_formKey.currentState!.validate()) {
      final String produkId = produkIdController.text.trim();
      final String namaProduk = namaProdukController.text.trim();
      final int harga = int.parse(hargaController.text.trim());
      final int stok = int.parse(stokController.text.trim());

      try {
        await supabase.from('produk').insert({
          'produkid': produkId,
          'namaproduk': namaProduk,
          'harga': harga,
          'stok': stok,
          'kategori': kategori,
        });

        fetchProducts();
        clearForm();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan produk: $error')),
        );
      }
    }
  }

  Future<void> updateProduk(int index, String namaProduk, int harga, int stok, String kategori) async {
    final produk = productList[index];
    try {
      await supabase.from('produk').update({
        'namaproduk': namaProduk,
        'harga': harga,
        'stok': stok,
        'kategori': kategori,
      }).eq('produkid', produk['produkid']);

      fetchProducts();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $error')),
      );
    }
  }

  Future<void> deleteProduk(int index) async {
    final produk = productList[index];
    try {
      await supabase.from('produk').delete().eq('produkid', produk['produkid']);
      fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $error')),
      );
    }
  }

  void showEditDialog(int index) {
    final produk = productList[index];
    final TextEditingController editNamaController = TextEditingController(text: produk['namaproduk']);
    final TextEditingController editHargaController = TextEditingController(text: produk['harga'].toString());
    final TextEditingController editStokController = TextEditingController(text: produk['stok'].toString());
    String? editKategori = produk['kategori'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: editNamaController, decoration: const InputDecoration(labelText: 'Nama Produk')),
              TextField(controller: editHargaController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
              TextField(controller: editStokController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
                value: editKategori,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: ['Makanan', 'Minuman'].map((kategori) {
                  return DropdownMenuItem(value: kategori, child: Text(kategori));
                }).toList(),
                onChanged: (value) => editKategori = value,
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                updateProduk(
                  index,
                  editNamaController.text.trim(),
                  int.parse(editHargaController.text.trim()),
                  int.parse(editStokController.text.trim()),
                  editKategori!,
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void clearForm() {
    produkIdController.clear();
    namaProdukController.clear();
    hargaController.clear();
    stokController.clear();
    setState(() => kategori = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Produk', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: produkIdController, decoration: const InputDecoration(labelText: 'Produk ID'), validator: (value) => value!.isEmpty ? 'Wajib diisi' : null),
                  TextFormField(controller: namaProdukController, decoration: const InputDecoration(labelText: 'Nama Produk'), validator: (value) => value!.isEmpty ? 'Wajib diisi' : null),
                  TextFormField(controller: hargaController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Wajib diisi' : null),
                  TextFormField(controller: stokController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Wajib diisi' : null),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    value: kategori,
                    items: ['Makanan', 'Minuman'].map((kategori) {
                      return DropdownMenuItem(value: kategori, child: Text(kategori));
                    }).toList(),
                    onChanged: (value) => setState(() => kategori = value),
                    validator: (value) => value == null ? 'Pilih kategori' : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: tambahProduk,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
                    child: const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final product = productList[index];
                  return ListTile(
                    title: Text(product['namaproduk']),
                    subtitle: Text('Kategori: ${product['kategori']} - Harga: ${product['harga']} - Stok: ${product['stok']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => showEditDialog(index)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteProduk(index)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
