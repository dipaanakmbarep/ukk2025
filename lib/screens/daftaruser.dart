import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaftarUserPage extends StatefulWidget {
  const DaftarUserPage({super.key});

  @override
  DaftarUserPageState createState() => DaftarUserPageState();
}

class DaftarUserPageState extends State<DaftarUserPage> {
  final supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> _userList = [];

  @override
  void initState() {
    super.initState();
    _fetchUserList();
  }

  Future<void> _fetchUserList() async {
    try {
      final response = await supabaseClient.from('users').select('id, username, email, password');
      if (response.isNotEmpty) {
        setState(() {
          _userList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat daftar user: $error'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _showEditPopup(Map<String, dynamic> user) {
    TextEditingController usernameController = TextEditingController(text: user['username']);
    TextEditingController emailController = TextEditingController(text: user['email']);
    TextEditingController passwordController = TextEditingController(text: user['password']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue[900], // Warna popup biru tua
          title: const Text('Edit User', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Username', labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await supabaseClient.from('users').update({
                    'username': usernameController.text,
                    'email': emailController.text,
                    'password': passwordController.text,
                  }).eq('id', user['id']);

                  Navigator.pop(context);
                  _fetchUserList(); // Refresh data setelah update

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('User berhasil diperbarui!'),
                    backgroundColor: Colors.green,
                  ));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Gagal mengupdate user: $error'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int id) async {
    try {
      await supabaseClient.from('users').delete().eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User berhasil dihapus!'),
          backgroundColor: Colors.green,
        ));
        _fetchUserList();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menghapus user: $error'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        backgroundColor: Colors.blue[900], // Warna navbar biru tua
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white, // Background putih
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 30.0, // Menambah ruang antar kolom
                    dataRowHeight: 60.0, // Memperbesar tinggi baris
                    columns: const [
                      DataColumn(label: Text('Nomor', style: TextStyle(color: Colors.black))),
                      DataColumn(label: Text('Username', style: TextStyle(color: Colors.black))),
                      DataColumn(label: Text('Email', style: TextStyle(color: Colors.black))),
                      DataColumn(label: Text('Password', style: TextStyle(color: Colors.black))),
                      DataColumn(label: Text('Aksi', style: TextStyle(color: Colors.black))),
                    ],
                    rows: _userList.asMap().entries.map((entry) {
                      int index = entry.key + 1; // Auto-increment nomor
                      Map<String, dynamic> user = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text(index.toString(), style: const TextStyle(color: Colors.black))),
                          DataCell(Text(user['username'], style: const TextStyle(color: Colors.black))),
                          DataCell(Text(user['email'], style: const TextStyle(color: Colors.black))),
                          DataCell(Text(user['password'], style: const TextStyle(color: Colors.black))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditPopup(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteUser(user['id']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
