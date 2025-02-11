import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({Key? key}) : super(key: key);

  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController nomorTeleponController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> pelangganList = [];

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    final response = await supabase.from('pelanggan').select();
    setState(() {
      pelangganList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> addPelanggan() async {
    if (_formKey.currentState!.validate()) {
      final existing = pelangganList.where((p) => p['nama'] == namaController.text).toList();
      if (existing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama pelanggan sudah ada!')),
        );
        return;
      }

      final response = await supabase.from('pelanggan').insert({
        'nama': namaController.text,
        'alamat': alamatController.text,
        'nomortelepon': nomorTeleponController.text,
      }).select();

      if (response.isNotEmpty) {
        fetchPelanggan();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pelanggan berhasil ditambahkan!')),
        );
        namaController.clear();
        alamatController.clear();
        nomorTeleponController.clear();
      }
    }
  }

  void showEditDialog(Map<String, dynamic> pelanggan) {
    namaController.text = pelanggan['nama'];
    alamatController.text = pelanggan['alamat'];
    nomorTeleponController.text = pelanggan['nomortelepon'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Pelanggan'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                  validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                TextFormField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  validator: (value) => value!.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                TextFormField(
                  controller: nomorTeleponController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Nomor telepon wajib diisi';
                    if (value.length > 14) return 'Maksimal 14 digit';
                    if (!RegExp(r'^[0-9]+').hasMatch(value)) return 'Harus angka';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await supabase.from('pelanggan').update({
                    'nama': namaController.text,
                    'alamat': alamatController.text,
                    'nomortelepon': nomorTeleponController.text,
                  }).eq('pelangganid', pelanggan['pelangganid']);
                  fetchPelanggan();
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      appBar: AppBar(
        title: const Text('Pelanggan'),
        backgroundColor: Colors.blue.shade900, // AppBar biru 900
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: alamatController,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                    validator: (value) => value!.isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: nomorTeleponController,
                    decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Nomor telepon wajib diisi';
                      if (value.length > 14) return 'Maksimal 14 digit';
                      if (!RegExp(r'^[0-9]+').hasMatch(value)) return 'Harus angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: addPelanggan,
                    child: const Text('Tambah Pelanggan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: pelangganList.length,
                itemBuilder: (context, index) {
                  final pelanggan = pelangganList[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200, // Warna lebih terang agar terlihat di background putih
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(pelanggan['nama']),
                      subtitle: Text(
                        '${pelanggan['alamat']}\n${pelanggan['nomortelepon']}', // Menampilkan alamat dan nomor telepon
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showEditDialog(pelanggan),
                      ),
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
