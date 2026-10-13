import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

Country initialCountry(Locale locale) =>
    CountryService().findByCode(locale.countryCode) ?? Country.parse('US');

class CountryPhoneField extends StatelessWidget {
  const CountryPhoneField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    this.errorText,
  });
  final TextEditingController controller;
  final Country country;
  final ValueChanged<Country> onCountryChanged;
  final String? errorText;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText == null ? const Color(0xFFD9DCE5) : colors.error,
            ),
          ),
          child: Row(
            children: [
              Semantics(
                label:
                    'Country: ${country.name}, calling code +${country.phoneCode}',
                button: true,
                child: InkWell(
                  key: const Key('country-selector'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    showCountryPicker(
                      context: context,
                      useSafeArea: true,
                      showPhoneCode: true,
                      customFlagBuilder: (country) => Text(
                        country.flagEmoji,
                        style: const TextStyle(
                          fontFamily: 'NotoEmoji',
                          fontSize: 24,
                        ),
                      ),
                      header: const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Text(
                          'Choose your country',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      countryListTheme: CountryListThemeData(
                        bottomSheetHeight:
                            MediaQuery.sizeOf(context).height * .78,
                        bottomSheetWidth: 480,
                        backgroundColor: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        inputDecoration: const InputDecoration(
                          labelText: 'Search countries',
                          hintText: 'Name, country code, or dial code',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      onSelect: onCountryChanged,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.flagEmoji,
                          style: const TextStyle(
                            fontFamily: 'NotoEmoji',
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '+${country.phoneCode}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 17),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 26, color: const Color(0xFFD9DCE5)),
              Expanded(
                child: TextField(
                  key: const Key('phone-number'),
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  decoration: const InputDecoration(
                    hintText: 'Enter phone number',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
