import 'package:flutter/material.dart';
import 'topics_screen.dart';

class CountrySelectScreen extends StatefulWidget {
  static const routeName = '/country-select';

  const CountrySelectScreen({super.key});

  @override
  State<CountrySelectScreen> createState() => _CountrySelectScreenState();
}

class _CountrySelectScreenState extends State<CountrySelectScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<Country> _countries = [
    Country(name: 'Afghanistan', flag: '🇦🇫'),
    Country(name: 'Albania', flag: '🇦🇱'),
    Country(name: 'Algeria', flag: '🇩🇿'),
    Country(name: 'Andorra', flag: '🇦🇩'),
    Country(name: 'Angola', flag: '🇦🇴'),
    Country(name: 'Argentina', flag: '🇦🇷'),
    Country(name: 'Armenia', flag: '🇦🇲'),
    Country(name: 'Australia', flag: '🇦🇺'),
    Country(name: 'Austria', flag: '🇦🇹'),
    Country(name: 'Azerbaijan', flag: '🇦🇿'),
    Country(name: 'Iceland', flag: '🇮🇸'),
    Country(name: 'India', flag: '🇮🇳'),
    Country(name: 'Indonesia', flag: '🇮🇩'),
    Country(name: 'Iran', flag: '🇮🇷'),
    Country(name: 'Iraq', flag: '🇮🇶'),
    Country(name: 'Ireland', flag: '🇮🇪'),
    Country(name: 'Israel', flag: '🇮🇱'),
    Country(name: 'Italy', flag: '🇮🇹'),
  ];

  List<Country> get _filteredCountries => _countries
      .where((country) =>
          country.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select your Country',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF246BFD)),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected =
                    country.name.toLowerCase() == _searchQuery.toLowerCase();
                return InkWell(
                  onTap: () {
                    setState(() {
                      _searchController.text = country.name;
                      _searchQuery = country.name;
                    });
                  },
                  child: Container(
                    color: isSelected ? const Color(0xFF246BFD) : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          country.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          country.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_searchQuery.isNotEmpty) {
                    Navigator.pushReplacementNamed(context, TopicsScreen.routeName);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF246BFD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Country {
  final String name;
  final String flag;

  Country({required this.name, required this.flag});
}