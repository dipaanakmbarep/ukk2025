import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  PelangganPageState createState() => PelangganPageState();
}

class PelangganPageState extends State<PelangganPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Controller untuk form tambah pelanggan
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
      await supabase.from('pelanggan').insert({
        'nama': namaController.text,
        'alamat': alamatController.text,
        'nomortelepon': nomorTeleponController.text,
      });
      fetchPelanggan();
      clearForm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelanggan berhasil ditambahkan!')),
      );
    }
  }

  Future<void> deletePelanggan(int pelangganId) async {
    await supabase.from('pelanggan').delete().eq('pelangganid', pelangganId);
    fetchPelanggan();
  }

  void showEditDialog(Map<String, dynamic> pelanggan) {
    TextEditingController editNamaController = TextEditingController(text: pelanggan['nama']);
    TextEditingController editAlamatController = TextEditingController(text: pelanggan['alamat']);
    TextEditingController editNomorTeleponController = TextEditingController(text: pelanggan['nomortelepon']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Pelanggan'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: editNamaController,
                    decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                    validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: editAlamatController,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                    validator: (value) => value!.isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: editNomorTeleponController,
                    decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Nomor telepon wajib diisi';
                      if (value.length > 14) return 'Maksimal 14 digit';
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Harus angka';
                      return null;
                    },
                    onFieldSubmitted: (_) => saveEdit(editNamaController, editAlamatController, editNomorTeleponController, pelanggan['pelangganid']),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.purple)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
              ),
              onPressed: () => saveEdit(editNamaController, editAlamatController, editNomorTeleponController, pelanggan['pelangganid']),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveEdit(TextEditingController nama, TextEditingController alamat, TextEditingController nomorTelepon, int pelangganId) async {
    if (_formKey.currentState!.validate()) {
      await supabase.from('pelanggan').update({
        'nama': nama.text,
        'alamat': alamat.text,
        'nomortelepon': nomorTelepon.text,
      }).eq('pelangganid', pelangganId);
      
      fetchPelanggan();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diperbarui!')),
      );
    }
  }

  void clearForm() {
    namaController.clear();
    alamatController.clear();
    nomorTeleponController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelanggan'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Form Tambah Pelanggan
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
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Harus angka';
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
              // List Pelanggan
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pelangganList.length,
                itemBuilder: (context, index) {
                  final pelanggan = pelangganList[index];
                  return ListTile(
                    title: Text(pelanggan['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pelanggan['alamat']}\n${pelanggan['nomortelepon']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => showEditDialog(pelanggan)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => deletePelanggan(pelanggan['pelangganid'])),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Tombol Keluar
              ElevatedButton.icon(
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Kembali'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
