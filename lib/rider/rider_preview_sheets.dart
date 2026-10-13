import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

Future<String?> editSavedAddress(
  BuildContext context,
  String label,
  String? initialValue,
) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (_) => PointerInterceptor(
    child: _AddressSheet(label: label, initialValue: initialValue),
  ),
);

class _AddressSheet extends StatefulWidget {
  const _AddressSheet({required this.label, this.initialValue});
  final String label;
  final String? initialValue;
  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  final _form = GlobalKey<FormState>();
  late final _address = TextEditingController(text: widget.initialValue);
  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      24,
      26,
      24,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.label} address',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Save a shortcut for this preview session.',
                style: TextStyle(color: Color(0xFF8B91A6)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('saved-address'),
                controller: _address,
                autofocus: true,
                maxLines: 2,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'House, street and area',
                ),
                validator: (value) => (value?.trim().length ?? 0) < 3
                    ? 'Enter an address.'
                    : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    Navigator.pop(context, _address.text.trim());
                  }
                },
                child: const Text('Save address'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String? validateSchedule(DateTime selected, DateTime now) =>
    selected.isAfter(now) ? null : 'Choose a future date and time.';

Future<DateTime?> chooseSchedule(
  BuildContext context,
  DateTime? initialValue,
) => showModalBottomSheet<DateTime>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (_) =>
      PointerInterceptor(child: _ScheduleSheet(initialValue: initialValue)),
);

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({this.initialValue});
  final DateTime? initialValue;
  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  late DateTime _selected =
      widget.initialValue != null &&
          widget.initialValue!.isAfter(DateTime.now())
      ? widget.initialValue!
      : DateTime.now().add(const Duration(hours: 1));
  String? _error;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.event_available_rounded,
              color: hiGoPurple,
              size: 34,
            ),
            const SizedBox(height: 12),
            const Text(
              'Plan your next ride',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a time for your preview. No ride will be scheduled with a driver.',
              style: TextStyle(color: Color(0xFF8B91A6)),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today_outlined,
                color: hiGoPurple,
              ),
              title: Text(
                MaterialLocalizations.of(context).formatMediumDate(_selected),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  builder: (_, child) => PointerInterceptor(child: child!),
                  initialDate: _selected,
                  firstDate: DateTime(now.year, now.month, now.day),
                  lastDate: DateTime(now.year + 1, now.month, now.day),
                );
                if (date != null && mounted) {
                  setState(() {
                    _selected = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _selected.hour,
                      _selected.minute,
                    );
                    _error = null;
                  });
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, color: hiGoPurple),
              title: Text(
                MaterialLocalizations.of(
                  context,
                ).formatTimeOfDay(TimeOfDay.fromDateTime(_selected)),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  builder: (_, child) => PointerInterceptor(child: child!),
                  initialTime: TimeOfDay.fromDateTime(_selected),
                );
                if (time != null && mounted) {
                  setState(() {
                    _selected = DateTime(
                      _selected.year,
                      _selected.month,
                      _selected.day,
                      time.hour,
                      time.minute,
                    );
                    _error = null;
                  });
                }
              },
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final error = validateSchedule(_selected, DateTime.now());
                if (error == null) {
                  Navigator.pop(context, _selected);
                } else {
                  setState(() => _error = error);
                }
              },
              child: const Text('Save schedule'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    ),
  );
}

void showRiderNotifications(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (context) => PointerInterceptor(
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: hiGoPurple,
              size: 42,
            ),
            const SizedBox(height: 16),
            const Text(
              'You’re all caught up',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ride updates and offers will appear here.\nThis is a local UI preview.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8B91A6)),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    ),
  ),
);
