import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_provider.dart';
import '../providers/auth_provider.dart';

class ReportItemScreen extends StatefulWidget {
  final bool isLost;

  const ReportItemScreen({
    super.key,
    required this.isLost,
  });

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemNameController =
      TextEditingController();

  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _colorController =
      TextEditingController();

  final TextEditingController _brandController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String? _selectedCategory;
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Electronics',
    'Books',
    'Documents',
    'Accessories',
    'Clothing',
    'Keys',
    'Bags',
    'Other',
  ];

  @override
  void dispose() {
    _itemNameController.dispose();
    _locationController.dispose();
    _colorController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitReport() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the date.'),
        ),
      );
      return;
    }

    // Get providers
    final itemProvider = Provider.of<ItemProvider>(
      context,
      listen: false,
    );

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // Add item
    await itemProvider.addItem(
      name: _itemNameController.text.trim(),
      category: _selectedCategory!,
      location: _locationController.text.trim(),
      date: _selectedDate!,
      color: _colorController.text.trim(),
      brand: _brandController.text.trim(),
      description: _descriptionController.text.trim(),
      isLost: widget.isLost,
      ownerEmail: authProvider.email,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isLost
              ? 'Lost item reported successfully!'
              : 'Found item reported successfully!',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isLost ? 'Report Lost Item' : 'Report Found Item',
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 100 : 20,
            vertical: 25,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    widget.isLost
                        ? 'Tell us about the lost item'
                        : 'Tell us about the found item',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.isLost
                        ? 'Provide details so other students can help you find it.'
                        : 'Provide details so the owner can identify it.',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Item Name
                  TextFormField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'Example: Black iPhone 15',
                      prefixIcon: Icon(
                        Icons.inventory_2_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the item name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Category
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(
                        Icons.category_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Example: Library, Block A',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the location';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(
                          Icons.calendar_today_outlined,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Select date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Color + Brand
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: _buildColorField(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBrandField(),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildColorField(),
                        const SizedBox(height: 18),
                        _buildBrandField(),
                      ],
                    ),

                  const SizedBox(height: 18),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText:
                          'Add any additional details that can help identify the item...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 75),
                        child: Icon(
                          Icons.description_outlined,
                        ),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }

                      if (value.trim().length < 10) {
                        return 'Description should be at least 10 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _submitReport,
                      icon: const Icon(
                        Icons.check_circle_outline,
                      ),
                      label: Text(
                        widget.isLost
                            ? 'Report Lost Item'
                            : 'Report Found Item',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Color field
  Widget _buildColorField() {
    return TextFormField(
      controller: _colorController,
      decoration: const InputDecoration(
        labelText: 'Color',
        hintText: 'Example: Black',
        prefixIcon: Icon(
          Icons.palette_outlined,
        ),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the color';
        }

        return null;
      },
    );
  }

  // Brand field
  Widget _buildBrandField() {
    return TextFormField(
      controller: _brandController,
      decoration: const InputDecoration(
        labelText: 'Brand',
        hintText: 'Example: Apple',
        prefixIcon: Icon(
          Icons.sell_outlined,
        ),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the brand';
        }

        return null;
      },
    );
  }
}