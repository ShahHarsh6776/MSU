import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addBillboard() async {
    final location = _locationController.text.trim();
    final size = double.tryParse(_sizeController.text.trim());
    final basePrice = double.tryParse(_basePriceController.text.trim());
    final companyName = _companyController.text.trim();

    if (location.isEmpty ||
        size == null ||
        basePrice == null ||
        companyName.isEmpty) {
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
        'base_price': basePrice,
        'company_name': companyName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Billboard added successfully!')),
        );
        Navigator.pop(context, true); // Return `true` to indicate success
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
              controller: _basePriceController,
              decoration: const InputDecoration(labelText: 'Base Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company Name'),
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
