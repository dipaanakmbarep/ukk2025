import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _loginMessage;
  Color? _loginMessageColor;
  Color _usernameFieldColor = Colors.white;
  Color _passwordFieldColor = Colors.white;

  void _onChanged() {
    setState(() {
      _usernameFieldColor = Colors.white;
      _passwordFieldColor = Colors.white;
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input kosong
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _loginMessage = 'Data belum diisi';
        _loginMessageColor = Colors.red;
        _usernameFieldColor = username.isEmpty ? Colors.red : Colors.white;
        _passwordFieldColor = password.isEmpty ? Colors.red : Colors.white;
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        throw Exception('Username atau password salah');
      }

      final user = response;

      if (password == user['password']) {
        // Notifikasi login berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Berhasil! Selamat datang, $username'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        setState(() {
          _loginMessage = 'Login Berhasil';
          _loginMessageColor = Colors.green;
        });

        // Redirect ke HomePage setelah SnackBar muncul sebentar
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(username: username, email: user['email'])),
          );
        });
      } else {
        throw Exception('Username atau password salah');
      }
    } catch (e) {
      setState(() {
        _passwordController.clear();
        _loginMessage = e.toString().replaceFirst('Exception: ', '');
        _loginMessageColor = Colors.red;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: _usernameFieldColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _usernameFieldColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _usernameFieldColor),
                  ),
                ),
                style: TextStyle(color: _usernameFieldColor),
                onChanged: (_) => _onChanged(),
                onSubmitted: (_) => _login(), // Memulai login saat tombol enter ditekan
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: _passwordFieldColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _passwordFieldColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _passwordFieldColor),
                  ),
                ),
                style: TextStyle(color: _passwordFieldColor),
                onChanged: (_) => _onChanged(),
                onSubmitted: (_) => _login(), // Memulai login saat tombol enter ditekan
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                      ),
                    ),
              const SizedBox(height: 20),
              if (_loginMessage != null)
                Text(
                  _loginMessage!,
                  style: TextStyle(color: _loginMessageColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
