// lib/main.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // for Clipboard
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:lottie/lottie.dart';
import 'package:showcaseview/showcaseview.dart';
import 'theme.dart';
import 'screens/settings_screen.dart';
import 'screens/help_screen.dart';

// IMPORTANT: Ensure firebase is configured (google-services.json / GoogleService-Info.plist).
// Initialize Firebase before runApp.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // requires platform config files
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner + Firestore + Login',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => HomeScreen(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
        '/scanner': (_) => const ScannerScreen(),
        '/result': (_) => const ResultScreen(),
        '/employees': (_) => const EmployeesScreen(),
        '/product_search': (_) => const ProductSearchScreen(),
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/settings': (_) => SettingsScreen(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
        '/help': (_) => const HelpScreen(),
      },
    );
  }
}

/// Home screen with scanner & employees list entry points
class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  void _openProductSearch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Product Search...')));
    debugPrint('Home: Opening Product Search via MaterialPageRoute');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductSearchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner Home'),
        backgroundColor: scheme.primary,
        actions: [
          IconButton(
            tooltip: 'Employees',
            icon: const Icon(Icons.history),
            onPressed: () {
              debugPrint('Home: Employees button pressed');
              Navigator.pushNamed(context, '/employees');
            },
          ),
          IconButton(
            tooltip: 'Product Search',
            icon: const Icon(Icons.search),
            onPressed: () => _openProductSearch(context),
          ),
          // NEW: Login quick access
          IconButton(
            tooltip: 'Login',
            icon: const Icon(Icons.person),
            onPressed: () {
              debugPrint('Home: Login button pressed');
              Navigator.pushNamed(context, '/login');
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help),
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.qr_code_scanner, size: 96, color: Colors.teal),
            const SizedBox(height: 16),
            const Text('Welcome to the Barcode Scanner',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Tap the button below to open the scanner and capture a barcode/QR code. '
              'After scanning you may save the value as an employee record to Firestore.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('Open Scanner'),
              onPressed: () {
                debugPrint('Home: Open Scanner pressed');
                Navigator.pushNamed(context, '/scanner');
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Open Employees (Firestore)'),
              onPressed: () {
                debugPrint('Home: Open Employees pressed');
                Navigator.pushNamed(context, '/employees');
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Product Search (Firestore)'),
              onPressed: () => _openProductSearch(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ---------- SCANNER SCREEN (improved) ----------
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with TickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanning = true;
  String? _last;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _borderAnimation = Tween<double>(begin: 2.0, end: 6.0).animate(_animationController);
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_scanning) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue ?? barcodes.first.displayValue;
    if (code == null) return;

    if (code == _last) return;
    _last = code;

    setState(() => _scanning = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scanned: $code')));

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushNamed(context, '/result', arguments: code).then((_) {
        setState(() {
          _scanning = true;
          _last = null;
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _controls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          tooltip: 'Switch camera',
          icon: const Icon(Icons.cameraswitch),
          onPressed: () async {
            try {
              await _controller.switchCamera();
            } catch (_) {}
            setState(() {});
          },
        ),
        IconButton(
          tooltip: 'Pause/Resume',
          icon: Icon(_scanning ? Icons.pause : Icons.play_arrow),
          onPressed: () => setState(() => _scanning = !_scanning),
        ),
        IconButton(
          tooltip: 'Clear last',
          icon: const Icon(Icons.clear),
          onPressed: () => setState(() {
            _last = null;
            _scanning = true;
          }),
        ),
        IconButton(
          tooltip: 'Toggle torch',
          icon: const Icon(Icons.flash_on),
          onPressed: () async {
            try {
              await _controller.toggleTorch();
              setState(() {});
            } catch (_) {}
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  fit: BoxFit.cover,
                  onDetect: (capture) {
                    if (_scanning) _onDetect(capture);
                  },
                ),
                Center(
                  child: AnimatedBuilder(
                    animation: _borderAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 280,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: _borderAnimation.value),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Align the barcode within the frame',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _controls(),
                  const SizedBox(height: 8),
                  const Text('Last scanned:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(_last ?? 'No scan yet'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Hint:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Point the camera at a barcode / QR code. After scanning you will be taken to the result screen.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- RESULT SCREEN (unchanged) ----------
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _empidController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  bool _saving = false;

  final CollectionReference employees = FirebaseFirestore.instance.collection('employees');

  Future<void> _addEmployee(String scannedValue) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await employees.add({
        'name': _nameController.text.trim(),
        'empid': int.tryParse(_empidController.text.trim()) ?? 0,
        'salary': int.tryParse(_salaryController.text.trim()) ?? 0,
        'scanned': scannedValue,
        'created_at': FieldValue.serverTimestamp(),
      });
      _nameController.clear();
      _empidController.clear();
      _salaryController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Saved Successfully')));
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error saving employee: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _empidController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final String scanned = (args is String) ? args : '—';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Result'),
        backgroundColor: scheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text('Scanned value:', style: TextStyle(fontSize: 16, color: scheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SelectableText(scanned, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy to clipboard'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: scanned));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
              },
            ),
            const SizedBox(height: 16),
            const Text('Save scanned value as Employee', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _empidController,
                  decoration: const InputDecoration(labelText: 'Employee ID'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter emp id' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(labelText: 'Salary'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter salary' : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save to Firestore'),
                  onPressed: _saving ? null : () => _addEmployee(scanned),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Scanner'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- EMPLOYEES SCREEN (unchanged) ----------
class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference employees = FirebaseFirestore.instance.collection('employees');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Employees'), backgroundColor: scheme.primary),
      body: StreamBuilder<QuerySnapshot>(
        stream: employees.orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final records = snapshot.data!.docs;
          if (records.isEmpty) return const Center(child: Text('No Employees Found'));

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final doc = records[index];
              final name = doc['name'] ?? '';
              final empid = doc['empid']?.toString() ?? '';
              final salary = doc['salary']?.toString() ?? '';
              final scanned = doc['scanned'] ?? '';
              Timestamp? ts = doc['created_at'] as Timestamp?;
              final createdAt = ts != null ? ts.toDate().toLocal().toString() : '';

              return ListTile(
                title: Text(name),
                subtitle: Text('EMPID: $empid  SALARY: $salary\nScanned: $scanned'),
                trailing: Text(createdAt, style: const TextStyle(fontSize: 11)),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------- PRODUCT SEARCH (unchanged) ----------
class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final CollectionReference products = FirebaseFirestore.instance.collection('products');

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _foundProduct;
  String? _foundDocId; // store doc id so we can update

  Future<void> _searchProduct() async {
    final query = _searchController.text.trim();
    debugPrint('ProductSearch: _searchProduct called with "$query"');
    if (query.isEmpty) {
      setState(() {
        _error = 'Enter a product name';
        _foundProduct = null;
        _foundDocId = null;
        _quantityController.clear();
        _priceController.clear();
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _foundProduct = null;
      _foundDocId = null;
      _quantityController.clear();
      _priceController.clear();
    });

    try {
      final snapshot = await products.get();
      DocumentSnapshot? match;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final name = data?['name']?.toString() ?? '';
        if (name.toLowerCase() == query.toLowerCase()) {
          match = doc;
          break;
        }
      }

      if (match != null) {
        final data = (match.data() as Map<String, dynamic>);
        final q = (data['quantity'] is num) ? data['quantity'].toString() : (data['quantity']?.toString() ?? '0');
        final p = (data['price'] is num) ? data['price'].toString() : (data['price']?.toString() ?? '0');

        setState(() {
          _foundDocId = match!.id;
          _foundProduct = {
            'name': data['name']?.toString() ?? '',
            'quantity': num.tryParse(q) ?? 0,
            'price': double.tryParse(p) ?? 0.0,
          };
          _error = null;
          _quantityController.text = _foundProduct!['quantity'].toString();
          _priceController.text = _foundProduct!['price'].toString();
        });
      } else {
        setState(() {
          _error = 'Product not found';
          _foundProduct = null;
          _foundDocId = null;
        });
      }
    } catch (e, st) {
      debugPrint('ProductSearch: error while searching: $e\n$st');
      setState(() {
        _error = 'Error searching: $e';
        _foundProduct = null;
        _foundDocId = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateProduct() async {
    if (_foundDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No product selected to update')));
      return;
    }

    final qtyText = _quantityController.text.trim();
    final priceText = _priceController.text.trim();

    if (qtyText.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter both quantity and price')));
      return;
    }

    final int? qty = int.tryParse(qtyText);
    final double? price = double.tryParse(priceText);

    if (qty == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid numeric values')));
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await products.doc(_foundDocId).update({
        'quantity': qty,
        'price': price,
      });

      setState(() {
        _foundProduct = {
          'name': _foundProduct?['name'] ?? '',
          'quantity': qty,
          'price': price,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated successfully')));
    } catch (e, st) {
      debugPrint('ProductSearch: error while updating: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Widget _resultCard() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _foundProduct == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text(_error!, style: const TextStyle(fontSize: 16))),
      );
    }
    if (_foundProduct == null) {
      return const SizedBox.shrink();
    }

    final name = _foundProduct!['name']?.toString() ?? '';
    final quantity = (_foundProduct!['quantity'] ?? 0).toString();
    final price = (_foundProduct!['price'] ?? 0).toString();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Quantity: $quantity'),
          const SizedBox(height: 4),
          Text('Price: ₹$price'),
          const SizedBox(height: 8),
          if ((num.tryParse(quantity) ?? 0) < 5)
            const Text('Low Stock!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Search & Update'), backgroundColor: scheme.primary),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter a product name to search (case-insensitive). Do NOT add new products from the app; update only existing products.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchProduct(),
                decoration: const InputDecoration(
                  labelText: 'Product name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Mobile Charger',
                ),
                autofocus: false,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                      onPressed: _loading ? null : _searchProduct,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      debugPrint('ProductSearch: Clear pressed');
                      _searchController.clear();
                      _quantityController.clear();
                      _priceController.clear();
                      setState(() {
                        _foundProduct = null;
                        _foundDocId = null;
                        _error = null;
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _resultCard(),
              const SizedBox(height: 16),
              const Text('Update Quantity & Price:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'New Quantity', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'New Price', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.update),
                      label: const Text('Update'),
                      onPressed: (_loading || _foundDocId == null) ? null : _updateProduct,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      _quantityController.text = _foundProduct?['quantity']?.toString() ?? '';
                      _priceController.text = _foundProduct?['price']?.toString() ?? '';
                    },
                    child: const Text('Reset Values'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Note: Only existing products will be updated.'),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- NEW: LOGIN SCREEN ----------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtl = TextEditingController();
  final TextEditingController _pwdCtl = TextEditingController();
  bool _loading = false;

  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtl.text.trim();
    final password = _pwdCtl.text; // note: plain text comparison for this exercise

    setState(() {
      _loading = true;
    });

    try {
      // Query Firestore for a user document with matching email
      final query = await users.where('email', isEqualTo: email).get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password')));
        return;
      }

      // take first match
      final doc = query.docs.first;
      final data = doc.data() as Map<String, dynamic>?;

      final storedPwd = (data?['password'] ?? '').toString();
      final name = (data?['name'] ?? '').toString();

      if (storedPwd == password) {
        // success -> navigate to dashboard with user name
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful')));
        Navigator.pushReplacementNamed(context, '/dashboard', arguments: {'name': name, 'email': email});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password')));
      }
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwdCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('User Login'), backgroundColor: scheme.primary),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              const Icon(Icons.lock_outline, size: 72, color: Colors.teal),
              const SizedBox(height: 12),
              const Text('Login with email and password', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter email';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwdCtl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _loading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.login),
                        label: Text(_loading ? 'Logging in...' : 'Login'),
                        onPressed: _loading ? null : _performLogin,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        // Quick navigation back to Home
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Home'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Note: For this exercise, users are stored in Firestore collection "users".'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- NEW: DASHBOARD ----------
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final name = args?['name']?.toString() ?? 'User';
    final email = args?['email']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Return to Home (or Login) on logout
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome, $name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (email.isNotEmpty) Text(email, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
