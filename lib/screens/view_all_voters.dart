import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewAllVotersPage extends StatefulWidget {
  const ViewAllVotersPage({super.key});

  @override
  State<ViewAllVotersPage> createState() => _ViewAllVotersPageState();
}

class _ViewAllVotersPageState extends State<ViewAllVotersPage> {
  Map<String, Map<String, Map<String, Map<String, int>>>> voterData = {};
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchVoterParts();
  }

  Future<void> fetchVoterParts() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("No token found. Please login again.");
      }

      final response = await http.get(
        Uri.parse(
          'http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com/masteradmin/voter-parts',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, Map<String, Map<String, Map<String, int>>>>
        transformed = {};

        for (var part in data) {
          String state = part['state'] ?? 'Unknown';
          String district = part['district'] ?? 'Unknown';
          String assembly = part['assembly_constituency'] ?? 'Unknown';
          String partName = part['part_name'] ?? 'Unknown';
          int voters = part['voters'] ?? 0;

          transformed[state] ??= {};
          transformed[state]![district] ??= {};
          transformed[state]![district]![assembly] ??= {};
          transformed[state]![district]![assembly]![partName] = voters;
        }

        setState(() {
          voterData = transformed;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load voters: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching voters: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStates = voterData.entries
        .where((e) => e.key.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voters - States'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search State...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredStates.length,
                    itemBuilder: (context, index) {
                      final stateEntry = filteredStates[index];
                      final stateName = stateEntry.key;
                      final totalVoters = stateEntry.value.values
                          .map(
                            (district) => district.values
                                .map(
                                  (assembly) => assembly.values.fold<int>(
                                    0,
                                    (a, b) => a + b,
                                  ),
                                )
                                .fold<int>(0, (a, b) => a + b),
                          )
                          .fold<int>(0, (a, b) => a + b);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(stateName),
                          trailing: Text(
                            '$totalVoters voters',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DistrictsPage(
                                stateName: stateName,
                                districts: stateEntry.value,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ----------------- Districts Page -----------------
class DistrictsPage extends StatelessWidget {
  final String stateName;
  final Map<String, Map<String, Map<String, int>>> districts;
  const DistrictsPage({
    super.key,
    required this.stateName,
    required this.districts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$stateName - Districts'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: districts.entries.map((districtEntry) {
          final totalVoters = districtEntry.value.values
              .map((assembly) => assembly.values.fold<int>(0, (a, b) => a + b))
              .fold<int>(0, (a, b) => a + b);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(districtEntry.key),
              trailing: Text(
                '$totalVoters voters',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssemblyPage(
                    districtName: districtEntry.key,
                    assemblies: districtEntry.value,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ----------------- Assembly Page -----------------
class AssemblyPage extends StatelessWidget {
  final String districtName;
  final Map<String, Map<String, int>> assemblies;
  const AssemblyPage({
    super.key,
    required this.districtName,
    required this.assemblies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$districtName - Assembly Constituencies'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: assemblies.entries.map((assemblyEntry) {
          final totalVoters = assemblyEntry.value.values.fold<int>(
            0,
            (a, b) => a + b,
          );

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(assemblyEntry.key),
              trailing: Text(
                '$totalVoters voters',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PartPage(
                    assemblyName: assemblyEntry.key,
                    parts: assemblyEntry.value,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ----------------- Part Page -----------------
class PartPage extends StatelessWidget {
  final String assemblyName;
  final Map<String, int> parts;
  const PartPage({super.key, required this.assemblyName, required this.parts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$assemblyName - Parts'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: parts.entries.map((partEntry) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(partEntry.key),
              trailing: Text(
                '${partEntry.value} voters',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoterListPage(partName: partEntry.key),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ----------------- Voter List Page -----------------
class VoterListPage extends StatefulWidget {
  final String partName;
  const VoterListPage({super.key, required this.partName});

  @override
  State<VoterListPage> createState() => _VoterListPageState();
}

class _VoterListPageState extends State<VoterListPage> {
  List<Map<String, dynamic>> voters = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchVoters();
  }

  Future<void> fetchVoters() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) throw Exception('No token found.');

      final response = await http.get(
        Uri.parse(
          'http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com/masteradmin/voters?part=${widget.partName}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            voters = List<Map<String, dynamic>>.from(data);
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch voters');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }

  void showVoterDetails(BuildContext context, Map<String, dynamic> voter) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Voter Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const Divider(thickness: 1),
                      _detailRow('Name', voter['name']),
                      _detailRow('Voter ID', voter['voter_id']),
                      _detailRow('Age', voter['age']),
                      _detailRow('Gender', voter['gender']),
                      _detailRow('Relation', voter['relation']),
                      _detailRow('House No', voter['house_no']),
                      _detailRow('Part Name', voter['part_name']),
                      _detailRow('Assembly', voter['assembly_constituency']),
                      _detailRow('District', voter['district']),
                      _detailRow('State', voter['state']),
                    ],
                  ),
                ),
              ),

              /// ❌ Close Button
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredVoters = voters.where((v) {
      final name = v['name']?.toString().toLowerCase() ?? '';
      final voterId = v['voter_id']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();

      return name.contains(query) || voterId.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.partName} - Voters'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by Name or Voter ID',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredVoters.length,
                    itemBuilder: (context, index) {
                      final voter = filteredVoters[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text(voter['name'] ?? 'Unknown'),
                          subtitle: Text('ID: ${voter['voter_id'] ?? '-'}'),
                          onTap: () => showVoterDetails(context, voter),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
