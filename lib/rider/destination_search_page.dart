import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/auth_shell.dart';
import 'destination_panel.dart';
import 'rider_demo_data.dart';

class DestinationSearchPage extends StatefulWidget {
  const DestinationSearchPage({super.key});
  @override
  State<DestinationSearchPage> createState() => _DestinationSearchPageState();
}

class _DestinationSearchPageState extends State<DestinationSearchPage> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final results = demoPlaces
        .where(
          (place) => '${place.name} ${place.address}'.toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Where to?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: MobileFrame(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.circle, color: hiGoPurple, size: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'From F-8, Islamabad',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                key: const Key('place-query'),
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search destination',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              if (MediaQuery.viewInsetsOf(context).bottom == 0) ...[
                const SizedBox(height: 20),
                const Text(
                  'Suggested places',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Preview search uses sample Islamabad places.',
                  style: TextStyle(color: Color(0xFF8B91A6), fontSize: 11),
                ),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 8),
              Expanded(
                child: results.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching places',
                          style: TextStyle(color: Color(0xFF8B91A6)),
                        ),
                      )
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: results.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: Color(0xFFF0F1F6)),
                        itemBuilder: (context, index) => PlaceTile(
                          place: results[index],
                          onTap: () => Navigator.pop(context, results[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
