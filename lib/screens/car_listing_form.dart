import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, Uint8List, rootBundle;
import 'package:drivers/style/barvy.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drivers/style/places_autocomplete.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

class AddListingScreen extends StatefulWidget {
  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  PageController _pageController = PageController();
  int _currentStep = 0;
  List<dynamic> carData = [];
  Map<String, dynamic> equipmentData = {};
  String? selectedBrand;
  String? selectedModel;
  String? selectedCondition;
  String? selectedBodyType;
  String? selectedTransmission;
  String? selectedDrivetrain;
  String? selectedColor;
  String? selectedFueltype;
  String? selectedVatDeduction;
  String? selectedServiceBook;
  String? selectedTuning;
  String? selectedZtp;
  String? selectedMonth;
  String? selectedYear;
  String? selectedFirstRegistrationYear;
  String? selectedFirstRegistrationMonth;
  Map<String, List<String>> selectedEquipment = {};

  final List<String> conditions = ['Nové', 'Ojeté', 'Poškozené'];
  final List<String> bodyTypes = ['Sedan', 'Kombi', 'SUV', 'Coupé', 'Hatchback'];
  final List<String> transmissions = ['Manuální', 'Automatická'];
  final List<String> fueltype = ['Benzín', 'Diesel', 'LPG', 'CNG', 'Elektro'];
  final List<String> drivetrains = ['Přední náhon', 'Zadní náhon', '4x4'];
  final List<String> months = List.generate(12, (index) => (index + 1).toString());
  final List<String> years = List.generate(50, (index) => (DateTime.now().year - index).toString());
  final List<XFile> _images = [];
  final List<String> colors = [
    'Černá', 'Bílá', 'Červená', 'Modrá', 'Zelená', 'Šedá', 'Stříbrná', 'Žlutá', 'Oranžová', 'Fialová', 'Hnědá', 'Zlatá', 'Béžová', 'Tmavě modrá', 'Tmavě zelená', 'Grafitová', 'Bronzová', 'Perleťová', 'Matná černá', 'Chromová'
  ];

  final TextEditingController vinController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController engineCapacityController = TextEditingController();
  final TextEditingController powerController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    vinController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    mileageController.dispose();
    engineCapacityController.dispose();
    powerController.dispose();
    priceController.dispose();
    cityController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadCarData();
    loadEquipmentData();
  }

  Future<void> loadCarData() async {
    String jsonString = await rootBundle.loadString('assets/car-list.json');
    List<dynamic> rawData = json.decode(jsonString);
    rawData.sort((a, b) => a['brand'].compareTo(b['brand']));

    if (!mounted) return;

    setState(() {
      carData = rawData.map((brand) {
        List<dynamic> models = brand['models'];
        models.sort((a, b) => a.compareTo(b));
        return {
          'brand': brand['brand'],
          'models': models,
        };
      }).toList();
    });
  }

  Future<void> loadEquipmentData() async {
    String jsonString = await rootBundle.loadString('assets/equipment.json');
    Map<String, dynamic> rawData = json.decode(jsonString);

    if (!mounted) return;

    setState(() {
      equipmentData = rawData['equipment'];
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
    if (_currentStep < 6) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (!mounted) return;

    if (_currentStep == 0) {
      if (mounted) {
        Navigator.pop(context);
      }
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

  Future<List<String>> _uploadImagesToStorage(String userId) async {
    if (!mounted) return [];

    List<String> uploadedUrls = [];
    List<XFile> imagesToUpload = _images.take(20).toList();

    for (XFile image in imagesToUpload) {
      try {
        final File file = File(image.path);
        final List<int> compressedBytes = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          quality: 80,
        ) ?? file.readAsBytesSync();

        String filePath = 'marketplace/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
        UploadTask uploadTask = storageRef.putData(Uint8List.fromList(compressedBytes));
        TaskSnapshot snapshot = await uploadTask;

        if (!mounted) return [];

        String imageUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(imageUrl);
        print("✅ Obrázek nahrán: $imageUrl");

        if (mounted) {
          setState(() {});
        }

      } catch (e) {
        print("❌ Chyba při nahrávání obrázku: $e");
      }
    }

    return uploadedUrls;
  }

  Future<void> _submitListing() async {
    if (!mounted) return;

    print("Validace spuštěna...");
print("selectedBrand: $selectedBrand");
print("selectedModel: $selectedModel");
print("selectedCondition: $selectedCondition");
print("selectedBodyType: $selectedBodyType");
print("selectedTransmission: $selectedTransmission");
print("selectedDrivetrain: $selectedDrivetrain");
print("selectedColor: $selectedColor");
print("selectedFueltype: $selectedFueltype");
print("Rok výroby: ${yearController.text}");
print("Město: ${cityController.text}");
print("Počet fotek: ${_images.length}");


    if (selectedBrand == null ||
        selectedModel == null ||
        selectedCondition == null ||
        selectedBodyType == null ||
        selectedTransmission == null ||
        selectedDrivetrain == null ||
        selectedColor == null ||
        selectedFueltype == null ||
        yearController.text.isEmpty ||
        mileageController.text.isEmpty ||
        engineCapacityController.text.isEmpty ||
        powerController.text.isEmpty ||
        priceController.text.isEmpty ||
        cityController.text.isEmpty ||
        _images.isEmpty) {
      _showErrorSnackbar("Vyplňte všechna povinná pole a přidejte alespoň 1 fotku.");
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ Chyba: Uživatel není přihlášen!");
        return;
      }

      List<String> imageUrls = await _uploadImagesToStorage(user.uid);
      if (!mounted) return;

      await FirebaseFirestore.instance.collection('marketplace').add({
        'userId': user.uid,
        'brand': selectedBrand,
        'model': selectedModel,
        'condition': selectedCondition,
        'bodyType': selectedBodyType,
        'transmission': selectedTransmission,
        'drivetrain': selectedDrivetrain,
        'color': selectedColor,
        'fuelType': selectedFueltype,
        'year': yearController.text,
        'mileage': mileageController.text,
        'engineCapacity': engineCapacityController.text,
        'power': powerController.text,
        'price': priceController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
        'city': cityController.text,
        'images': imageUrls,
        'vatDeduction': selectedVatDeduction,
        'serviceBook': selectedServiceBook,
        'tuning': selectedTuning,
        'ztpModifications': selectedZtp,
        'firstRegistrationYear': selectedFirstRegistrationYear,
        'firstRegistrationMonth': selectedFirstRegistrationMonth,
        'equipment': selectedEquipment,
        'phone': phoneController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Inzerát úspěšně přidán uživatelem: ${user.uid}");

      if (mounted) {
        _showSuccessDialog();
      }

    } catch (e) {
      print("❌ Chyba při přidávání inzerátu: $e");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: colorScheme.surface,
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.orange, size: 60),
              SizedBox(height: 12),
              Text("Inzerát přidán!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
            ],
          ),
          content: Text(
            "Tvůj inzerát byl úspěšně přidán na Marketplace.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text("Zavřít", style: TextStyle(fontSize: 16, color: colorScheme.primary)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetForm();
                  },
                  child: Text("Přidat další", style: TextStyle(fontSize: 16, color: colorScheme.primary)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  void _resetForm() {
    setState(() {
      selectedBrand = null;
      selectedModel = null;
      selectedCondition = null;
      selectedBodyType = null;
      selectedTransmission = null;
      selectedDrivetrain = null;
      selectedColor = null;
      selectedFueltype = null;
      selectedVatDeduction = null;
      selectedServiceBook = null;
      selectedTuning = null;
      selectedZtp = null;
      selectedFirstRegistrationYear = null;
      selectedFirstRegistrationMonth = null;
      selectedEquipment.clear();
      _images.clear();
      vinController.clear();
      descriptionController.clear();
      yearController.clear();
      mileageController.clear();
      engineCapacityController.clear();
      powerController.clear();
      priceController.clear();
      cityController.clear();
      phoneController.clear();
      _currentStep = 0;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildBasicInfoStep(),
                    _buildMandatoryInfoStep(),
                    _buildOptionalInfoStep(),
                    _buildEquipmentStep(),
                    _buildPhotosAndPriceStep(),
                    _buildContactStep(),
                    _buildSummaryStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        child: ElevatedButton(
          onPressed: () {
            if (_currentStep == 6) {
              _submitListing();
            } else {
              _nextStep();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _currentStep == 6 ? 'Odeslat inzerát' : 'Pokračovat',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
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
          _buildDropdown('Měsíc první registrace', selectedFirstRegistrationMonth, months,
              (value) {
            setState(() => selectedFirstRegistrationMonth = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Rok první registrace', selectedFirstRegistrationYear, years,
              (value) {
            setState(() => selectedFirstRegistrationYear = value);
          }),
        ],
      ),
    );
  }

  Widget _buildMandatoryInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Povinné informace',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
          const SizedBox(height: 16),
          _buildDropdown('Barva', selectedColor, colors, (value) {
            setState(() => selectedColor = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Tvar karoserie', selectedBodyType, bodyTypes, (value) {
            setState(() => selectedBodyType = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Typ převodovky', selectedTransmission, transmissions, (value) {
            setState(() => selectedTransmission = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Druh paliva', selectedFueltype, fueltype, (value) {
            setState(() => selectedFueltype = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Typ náhonu', selectedDrivetrain, drivetrains, (value) {
            setState(() => selectedDrivetrain = value);
          }),
          const SizedBox(height: 16),
          _buildNumberField('Objem motoru', engineCapacityController, 'cm3'),
          const SizedBox(height: 16),
          _buildNumberField('Výkon motoru', powerController, 'kW'),
        ],
      ),
    );
  }

  Widget _buildOptionalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nepovinné informace',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
          const SizedBox(height: 16),
          _buildTextField('VIN kód', vinController),
          const SizedBox(height: 16),
          _buildDropdown('Odpočet DPH', selectedVatDeduction, ['Ano', 'Ne'], (value) {
            setState(() => selectedVatDeduction = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Servisní knížka', selectedServiceBook, ['Ano', 'Ne'], (value) {
            setState(() => selectedServiceBook = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Tuning', selectedTuning, ['Ano', 'Ne'], (value) {
            setState(() => selectedTuning = value);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Úpravy ZTP', selectedZtp, ['Ano', 'Ne'], (value) {
            setState(() => selectedZtp = value);
          }),
        ],
      ),
    );
  }

  Widget _buildEquipmentStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Výbava',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
            const SizedBox(height: 16),
            if (equipmentData.isNotEmpty)
              ...equipmentData.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)), 
                    ...entry.value.map((item) {
                      return CheckboxListTile(
                        title: Text(item, style: TextStyle(color: colorScheme.onPrimary),),
                        value: selectedEquipment[entry.key]?.contains(item) ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedEquipment[entry.key] = [...selectedEquipment[entry.key] ?? [], item];
                            } else {
                              selectedEquipment[entry.key]?.remove(item);
                            }
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosAndPriceStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fotky a cena',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.add_a_photo, size: 24, color: Colors.white),
              label: Text(
                'Přidat fotky',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildImageGrid(),
          const SizedBox(height: 16),
          _buildNumberField('Cena', priceController, 'kč'),
          const SizedBox(height: 16),
          _buildTextField('Popis', descriptionController, maxLines: 5),
        ],
      ),
    );
  }

  Widget _buildContactStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kontakt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
          const SizedBox(height: 16),
          _buildTextField('Telefonní číslo', phoneController),
          const SizedBox(height: 16),
          GooglePlacesAutoCompleteTextFormField(
            googleAPIKey: 'AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY',
            textEditingController: cityController,
            debounceTime: 400,
            countries: ["cz"],
            minInputLength: 2,
            decoration: InputDecoration(
              labelText: 'Město',
              hintText: 'Zadejte město',
              labelStyle: TextStyle(color: colorScheme.onSecondary),
              hintStyle: TextStyle(color: colorScheme.onSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: colorScheme.secondary,
            ),
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 16,
            ),
            overlayContainerBuilder: (child) => Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.secondary,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: child,
              ),
            ),
            predictionsStyle: TextStyle(
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
            if (selectedVatDeduction != null) _buildSummaryItem('Odpočet DPH', selectedVatDeduction),
            if (selectedServiceBook != null) _buildSummaryItem('Servisní knížka', selectedServiceBook),
            if (selectedTuning != null) _buildSummaryItem('Tuning', selectedTuning),
            if (selectedZtp != null) _buildSummaryItem('Úpravy ZTP', selectedZtp),
            if (selectedFirstRegistrationYear != null) _buildSummaryItem('Rok první registrace', selectedFirstRegistrationYear),
            if (selectedFirstRegistrationMonth != null) _buildSummaryItem('Měsíc první registrace', selectedFirstRegistrationMonth),
            if (selectedEquipment.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Výbava:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ...selectedEquipment.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                    ...entry.value.map((item) {
                      return Text('- $item', style: TextStyle(color: colorScheme.onPrimary,));
                    }).toList(),
                  ],
                );
              }).toList(),
            ],
            const SizedBox(height: 16),
            Text('Fotografie:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            _buildImageGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      height: 220,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_images[index].path),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _images.removeAt(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'Neuvedeno',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onPrimary,
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
            color: colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: colorScheme.secondary,
      ),
      value: value,
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(
            option,
            style: TextStyle(
                color: colorScheme.onPrimary),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: colorScheme.secondary,
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
}