import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddBillboardPage extends StatefulWidget {
  final String ownerId;

  const AddBillboardPage({super.key, required this.ownerId});

  @override
  State<AddBillboardPage> createState() => _AddBillboardPageState();
}

class _AddBillboardPageState extends State<AddBillboardPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _manualPriceController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  bool _availability = true; // Default availability is true
  bool _isLoading = false;
  double? _aiPredictedPrice; // AI-generated price

  Future<void> _fetchAiPredictedPrice() async {
    final location = _locationController.text.trim();
    final size = double.tryParse(_sizeController.text.trim());
    final ownerName = _ownerController.text.trim();

    if (location.isEmpty || size == null || ownerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter location, size, and owner name first!'),
        ),
      );
      return;
    }

    try {
      var url = Uri.parse("http://127.0.0.1:8000/predict_price/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "location": location,
          "size": size,
          "owner_name": ownerName,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _aiPredictedPrice = jsonDecode(response.body)["ai_predicted_price"];
        });
      } else {
        throw "Failed to fetch AI price";
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("AI Pricing Error: $e")));
    }
  }

  Future<void> _addBillboard() async {
    final location = _locationController.text.trim();
    final size = double.tryParse(_sizeController.text.trim());
    final manualPrice = double.tryParse(_manualPriceController.text.trim());
    final ownerName = _ownerController.text.trim();

    if (location.isEmpty ||
        size == null ||
        manualPrice == null ||
        ownerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.from('billboards').insert({
        'owner_id': widget.ownerId,
        'location': location,
        'size': size,
        'manual_price': manualPrice,
        'ai_predicted_price':
            _aiPredictedPrice ?? manualPrice, // Use AI price if available
        'owner_name': ownerName,
        'availability': _availability,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Billboard added successfully!')),
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Billboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _sizeController,
              decoration: const InputDecoration(labelText: 'Size (sq ft)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _manualPriceController,
              decoration: const InputDecoration(labelText: 'Manual Price (\$)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ownerController,
              decoration: const InputDecoration(labelText: 'Owner Name'),
            ),
            SwitchListTile(
              title: const Text('Available for Bidding'),
              value: _availability,
              onChanged: (bool value) {
                setState(() {
                  _availability = value;
                });
              },
            ),
            const SizedBox(height: 10),

            _aiPredictedPrice != null
                ? Text(
                  "AI Predicted Price: \$$_aiPredictedPrice",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
                : Container(),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchAiPredictedPrice,
              child: const Text('Get AI-Predicted Price'),
            ),
            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _addBillboard,
                  child: const Text('Add Billboard'),
                ),
          ],
        ),
      ),
    );
  }
}
