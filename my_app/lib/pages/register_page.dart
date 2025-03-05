import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phone = '';
  String companyName = '';
  String role = 'Owner'; // Default selection
  bool isLoading = false;

  // Function to register user and store data in the correct table
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords do not match!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Supabase Auth - Register User
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("Registration failed!");
      }

      // Choose the correct table based on role
      final table = role == "Owner" ? "owners" : "sponsors";

      await _supabase.from(table).insert({
        'username': username,
        'email': email,
        'password': password, // Note: Hash password in production
        'phone': phone,
        'company_name': companyName,
      });

      /*final stable = "users";

      await _supabase.from(stable).insert({
        'username': username,
        'email': email,
        'password': password, // Note: Hash password in production
        'mobile': phone,
        //'company_name': companyName,
        'usertype': table,
      });*/

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration Successful!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login page after success
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Register as:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text("Owner"),
                      leading: Radio(
                        value: "Owner",
                        groupValue: role,
                        onChanged: (value) {
                          setState(() => role = value.toString());
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text("Bidder"),
                      leading: Radio(
                        value: "Bidder",
                        groupValue: role,
                        onChanged: (value) {
                          setState(() => role = value.toString());
                        },
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Username"),
                validator:
                    (value) => value!.isEmpty ? "Enter a username" : null,
                onChanged: (value) => username = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        !value!.contains("@") ? "Enter a valid email" : null,
                onChanged: (value) => email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value!.length < 10
                            ? "Enter a valid phone number"
                            : null,
                onChanged: (value) => phone = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Company Name"),
                validator:
                    (value) => value!.isEmpty ? "Enter company name" : null,
                onChanged: (value) => companyName = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator:
                    (value) =>
                        value!.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                onChanged: (value) => password = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
                validator:
                    (value) =>
                        value!.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                onChanged: (value) => confirmPassword = value,
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _registerUser,
                    child: Text("Register"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
