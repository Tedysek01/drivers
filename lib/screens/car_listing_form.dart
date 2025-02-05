import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, rootBundle;
import 'package:drivers/style/barvy.dart';
import 'package:image_picker/image_picker.dart';

class AddListingScreen extends StatefulWidget {
  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  PageController _pageController = PageController();
  int _currentStep = 0;
  List<dynamic> carData = [];
  String? selectedBrand;
  String? selectedModel;
  String? selectedCondition;
  String? selectedBodyType;
  String? selectedTransmission;
  String? selectedDrivetrain;
  final List<String> conditions = ['Nové', 'Ojeté', 'Poškozené'];
  final List<String> bodyTypes = ['Sedan', 'Kombi', 'SUV', 'Coupé', 'Hatchback'];
  final List<String> transmissions = ['Manuální', 'Automatická'];
  final List<String> drivetrains = ['Přední náhon', 'Zadní náhon', '4x4'];
  final List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    loadCarData();
  }

  Future<void> loadCarData() async {
    String jsonString = await rootBundle.loadString('assets/car-list.json');
    setState(() {
      carData = json.decode(jsonString);
    });
  }
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _images.addAll(images);
      });
    }
  }


  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
        appBar: AppBar(
        title: Text('Přidat inzerát'),
    backgroundColor: colorScheme.surface,
    foregroundColor: colorScheme.onSurface,
    leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: _prevStep,
    ),),
      resizeToAvoidBottomInset: true, // Umožní přizpůsobení obsahu při otevření klávesnice
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75, // Dynamická výška
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildBasicInfoStep(),
                    _buildTechnicalInfoStep(),
                    _buildDescriptionStep(),
                    _buildPhotosAndPriceStep(),
                  ],
                ),
              ),
        FloatingActionButton(
          onPressed: _nextStep,
          child: Icon(Icons.arrow_forward),
        ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label) {
    return TextFormField(
      decoration: _inputDecoration(label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: colorScheme.onPrimary),
    );
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Základní informace', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDropdown(
            'Značka',
            selectedBrand,
            carData.map((brand) => brand['brand'] as String).toList(),
                (value) {
              setState(() {
                selectedBrand = value;
                selectedModel = null;
              });
            },
          ),

          if (selectedBrand != null)...[
            const SizedBox(height: 16),
            _buildDropdown(
              'Model',
              selectedModel,
              (carData.firstWhere((brand) => brand['brand'] == selectedBrand)['models'] as List<dynamic>).cast<String>(),
                  (value) {
                setState(() => selectedModel = value);
              },
            ),

          ],
          const SizedBox(height: 16),
          _buildNumberField('Rok výroby'),
          const SizedBox(height: 16),
          _buildNumberField('Najeté km'),
          const SizedBox(height: 16),
          _buildDropdown('Stav vozidla', selectedCondition, conditions, (value) {
            setState(() => selectedCondition = value);
          }),
        ],
      ),
    );
  }

  Widget _buildTechnicalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Technické parametry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField('VIN kód'),
          const SizedBox(height: 16),
          _buildTextField('Barva'),
          const SizedBox(height: 16),
          _buildDropdown('Tvar karoserie', selectedBodyType, bodyTypes, (value){
            setState(() => selectedBodyType = value);}),
          const SizedBox(height: 16),
          _buildDropdown('Typ prevodovky', selectedTransmission, transmissions, (value){
            setState(() => selectedTransmission = value);}),
          const SizedBox(height: 16),
          _buildDropdown('Typ nahonu', selectedDrivetrain, drivetrains, (value){
            setState(() => selectedDrivetrain = value);}),
          const SizedBox(height: 16),
          _buildNumberField('Objem motoru'),
          const SizedBox(height: 16),
          _buildNumberField('Výkon motoru'),
        ],
      ),
    );
  }

  Widget _buildDescriptionStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Popis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField('Popis inzerátu', maxLines: 5),
        ],
      ),
    );
  }

  Widget _buildPhotosAndPriceStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImages,
            child: const Text('Přidat fotky'),
          ),
          Wrap(
            spacing: 8.0,
            children: _images.map((image) => Image.file(File(image.path), width: 100, height: 100)).toList(),
          ),
          const SizedBox(height: 16),
          _buildNumberField('Cena'),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: colorScheme.secondary, // Nastavení pozadí dropdownu
      ),
      value: value,
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(
            option,
            style: TextStyle(color: colorScheme.onPrimary), // Barva textu v dropdownu
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: colorScheme.secondary, // Nastavení pozadí menu
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return TextFormField(
      decoration: _inputDecoration(label),
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onPrimary),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: colorScheme.secondary,
    );
  }

  void _submitForm() {
    print('Inzerát odeslán!');
  }
}

