import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, rootBundle;
import 'package:drivers/style/barvy.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drivers/style/places_autocomplete.dart';

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
  String? selectedColor;
  String? selectedFueltype;
  final List<String> conditions = ['Nové', 'Ojeté', 'Poškozené'];
  final List<String> bodyTypes = [
    'Sedan',
    'Kombi',
    'SUV',
    'Coupé',
    'Hatchback'
  ];
  final List<String> transmissions = ['Manuální', 'Automatická'];
  final List<String> fueltype = ['Benzín', 'Diesel', 'LPG','CNG','Elektro', ];
  final List<String> drivetrains = ['Přední náhon', 'Zadní náhon', '4x4'];
  final List<XFile> _images = [];
  final List<String> colors = [
    'Černá',
    'Bílá',
    'Červená',
    'Modrá',
    'Zelená',
    'Šedá',
    'Stříbrná',
    'Žlutá',
    'Oranžová',
    'Fialová',
    'Hnědá',
    'Zlatá',
    'Béžová',
    'Tmavě modrá',
    'Tmavě zelená',
    'Grafitová',
    'Bronzová',
    'Perleťová',
    'Matná černá',
    'Chromová'
  ];
  final TextEditingController vinController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController engineCapacityController = TextEditingController();
  final TextEditingController powerController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();



  @override

  void dispose() {
    // Dispose controllers to avoid memory leaks
    vinController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    mileageController.dispose();
    engineCapacityController.dispose();
    powerController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    loadCarData();
  }

  Future<void> loadCarData() async {
    String jsonString = await rootBundle.loadString('assets/car-list.json');
    List<dynamic> rawData = json.decode(jsonString);

    // Seřadíme značky aut podle abecedy
    rawData.sort((a, b) => a['brand'].compareTo(b['brand']));

    // Uložíme seřazené značky
    carData = rawData.map((brand) {
      List<dynamic> models = brand['models'];

      // Seřadíme modely uvnitř každé značky
      models.sort((a, b) => a.compareTo(b));

      return {
        'brand': brand['brand'],
        'models': models,
      };
    }).toList();

    print("✅ Značky a modely aut byly úspěšně seřazeny!");
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
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      })

      ;
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
        ),
      ),
      resizeToAvoidBottomInset:
          true, // Umožní přizpůsobení obsahu při otevření klávesnice
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.75, // Dynamická výška
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildBasicInfoStep(),
                    _buildTechnicalInfoStep(),
                    _buildDescriptionStep(),
                    _buildPhotosAndPriceStep(),
                    _buildSummaryStep(),
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

  Widget _buildSummaryStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shrnutí inzerátu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSummaryItem('Značka', selectedBrand),
            _buildSummaryItem('Model', selectedModel),
            _buildSummaryItem('Stav vozidla', selectedCondition),
            _buildSummaryItem('Tvar karoserie', selectedBodyType),
            _buildSummaryItem('Převodovka', selectedTransmission),
            _buildSummaryItem('Náhon', selectedDrivetrain),
            _buildSummaryItem('VIN kód', vinController.text),
            _buildSummaryItem('Barva', selectedColor),
            _buildSummaryItem('Druh paliva', selectedFueltype),
            _buildSummaryItem('Rok výroby', yearController.text),
            _buildSummaryItem('Najeté km', mileageController.text),
            _buildSummaryItem('Objem motoru', engineCapacityController.text),
            _buildSummaryItem('Výkon motoru', powerController.text),
            _buildSummaryItem('Cena', priceController.text),
            _buildSummaryItem('Popis', descriptionController.text),
            const SizedBox(height: 16),
            Text('Fotografie:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: _images
                  .map((image) =>
                  Image.file(File(image.path), width: 100, height: 100))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Trochu větší mezera mezi řádky
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Lepší zarovnání
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onPrimary, // Použijeme barvu z colorScheme
            ),
          ),
          const SizedBox(width: 8), // Malá mezera mezi názvem a hodnotou
          Expanded(
            child: Text(
              value ?? 'Neuvedeno',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onPrimary, // Použijeme barvu z colorScheme
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, String unit) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffix: Text(
          unit,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7), // Styl jednotky
            fontSize: 14,
          ),
        ),
        labelStyle: TextStyle(color: colorScheme.onSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: colorScheme.secondary,
      ),
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
          Text('Základní informace',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
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
          if (selectedBrand != null) ...[
            const SizedBox(height: 16),
            _buildDropdown(
              'Model',
              selectedModel,
              (carData.firstWhere(
                          (brand) => brand['brand'] == selectedBrand)['models']
                      as List<dynamic>)
                  .cast<String>(),
              (value) {
                setState(() => selectedModel = value);
              },
            ),
          ],
          const SizedBox(height: 16),
          _buildNumberField('Rok výroby', yearController,'YYYY'),
          const SizedBox(height: 16),
          _buildNumberField('Najeté km', mileageController, 'km'),
          const SizedBox(height: 16),
          _buildDropdown('Stav vozidla', selectedCondition, conditions,
              (value) {
            setState(() => selectedCondition = value);

          }),
          const SizedBox(height: 16),
          _buildDropdown('Druh paliva', selectedFueltype, fueltype,
                  (value) {
                setState(() => selectedFueltype = value);

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
          const Text('Technické parametry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField('VIN kód', vinController),
          const SizedBox(height: 16),
          _buildDropdown('Barva', selectedColor, colors, (value) {
          setState(() => selectedColor = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Tvar karoserie', selectedBodyType, bodyTypes,
              (value) {
            setState(() => selectedBodyType = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Typ prevodovky', selectedTransmission, transmissions,
              (value) {
            setState(() => selectedTransmission = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Typ nahonu', selectedDrivetrain, drivetrains,
              (value) {
            setState(() => selectedDrivetrain = value);
          }),
          const SizedBox(height: 16),
          _buildNumberField('Objem motoru', engineCapacityController, 'cm3'),
          const SizedBox(height: 16),
          _buildNumberField('Výkon motoru', powerController, 'kw'),
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
          const Text('Popis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField('Popis inzerátu', descriptionController, maxLines: 5),
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
            children: _images
                .map((image) =>
                    Image.file(File(image.path), width: 100, height: 100))
                .toList(),
          ),
          const SizedBox(height: 16),
          _buildNumberField('Cena', priceController, 'kč'),
          GooglePlacesAutoCompleteTextFormField(googleAPIKey: 'AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY', textEditingController: cityController,
            debounceTime: 400, // Zpoždění před odesláním dotazu (lepší UX)
            countries: ["cz"], // Pouze Česká republika 🇨🇿
            minInputLength: 2, // Umožní hledání už po dvou znacích
            decoration: InputDecoration(
              labelText: 'Město',
              hintText: 'Zadejte město',
              labelStyle: TextStyle(color: colorScheme.onSecondary),
              hintStyle: TextStyle(color: colorScheme.onSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: colorScheme.secondary,
            ),
            style: TextStyle( // ✅ Styl textu, který uživatel píše
              color: colorScheme.onPrimary,
              fontSize: 16,
            ),
            overlayContainerBuilder: (child) => Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.secondary, // ✅ Stejné pozadí jako TextField
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.secondary, // ✅ Stejná barva jako TextField
                  borderRadius: BorderRadius.circular(10),
                ),
                child: child,
              ),
            ),
            predictionsStyle: TextStyle( // ✅ Barva textu v nabídce
              color: colorScheme.onPrimary,
              fontSize: 16,
            ),
            onSuggestionClicked: (Prediction prediction) {
              cityController.text = prediction.description!;
              print("✅ Vybrané město: ${cityController.text}");
            },
          ),


        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options,
      ValueChanged<String?> onChanged) {
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
            style: TextStyle(
                color: colorScheme.onPrimary), // Barva textu v dropdownu
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: colorScheme.secondary, // Nastavení pozadí menu
    );
  }

  Widget _buildTextField(String label, dynamic controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
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
