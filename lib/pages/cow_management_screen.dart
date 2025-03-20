import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cow_model.dart';
import 'cow_form_page.dart';
// import '../pages/scanner_page.dart';
import 'scanner.dart'; // Adjust the import path as needed

class CowManagementScreen extends StatefulWidget {
  const CowManagementScreen({super.key});

  @override
  _CowManagementScreenState createState() => _CowManagementScreenState();
}

class _CowManagementScreenState extends State<CowManagementScreen> {
  late Box<Cow> cowBox;

  @override
  void initState() {
    super.initState();
    cowBox = Hive.box<Cow>('cows');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.green[800]!, Colors.green[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            'Cow Management',
            style: GoogleFonts.lobster(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.green[300],
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: cowBox.listenable(),
        builder: (context, Box<Cow> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No cows found. Add your first cow!',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final cow = box.getAt(index);
                return _buildCowCard(cow!, index);
              },
            ),
          );
        },
      ),
      floatingActionButton: _buildActionButtonRow(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildActionButtonRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAddCowButton(),
          const SizedBox(width: 16),
          _buildScanQRButton(),
        ],
      ),
    );
  }

  Widget _buildAddCowButton() {
    return Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 120),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CowFormPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Cow'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanQRButton() {
    return Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 120),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScannerPage(
                    onCowScanned: (cow) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CowFormPage(
                            cow: cow,
                            index: cowBox.values.toList().indexOf(cow),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.qr_code),
            label: const Text('Scan QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCowCard(Cow cow, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.co2, color: Colors.green[700]),
        ),
        title: Text(
          cow.name,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Breed: ${cow.breed}'),
            Text('Age: ${cow.age}'),
            Text('Weight: ${cow.weight}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmationDialog(index);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          icon: Icon(Icons.more_vert),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CowFormPage(cow: cow, index: index),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this cow?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cowBox.deleteAt(index);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}