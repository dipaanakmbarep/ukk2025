import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await supabase.from('users').select();
    setState(() {
      userList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> addUser() async {
    if (_formKey.currentState!.validate()) {
      await supabase.from('users').insert({
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      });
      fetchUsers();
      clearForm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil ditambahkan!')),
      );
    }
  }

  Future<void> deleteUser(int userId) async {
    await supabase.from('users').delete().eq('id', userId);
    fetchUsers();
  }

  void showEditDialog(Map<String, dynamic> user) {
    TextEditingController editUsernameController = TextEditingController(text: user['username']);
    TextEditingController editEmailController = TextEditingController(text: user['email']);
    TextEditingController editPasswordController = TextEditingController(text: user['password']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: editUsernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) => value!.isEmpty ? 'Username wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: editEmailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email wajib diisi';
                      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(value)) {
                        return 'Gunakan email Gmail yang valid';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: editPasswordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Password wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => saveEdit(editUsernameController, editEmailController, editPasswordController, user['id']),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveEdit(TextEditingController username, TextEditingController email, TextEditingController password, int userId) async {
    if (_formKey.currentState!.validate()) {
      await supabase.from('users').update({
        'username': username.text,
        'email': email.text,
        'password': password.text,
      }).eq('id', userId);
      fetchUsers();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil diperbarui!')),
      );
    }
  }

  void clearForm() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
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
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) => value!.isEmpty ? 'Username wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email wajib diisi';
                      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(value)) {
                        return 'Gunakan email Gmail yang valid';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addUser,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
                    child: const Text('Tambah User', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  final user = userList[index];
                  return ListTile(
                    title: Text(user['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${user['email']}\n${user['password']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showEditDialog(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteUser(user['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
              child: const Text('Kembali', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
