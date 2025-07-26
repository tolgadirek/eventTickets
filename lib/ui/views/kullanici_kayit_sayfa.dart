import 'package:event_tickets/l10n/app_localizations.dart';
import 'package:event_tickets/ui/cubits/kullanici_kayit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class KullaniciKayitSayfa extends StatefulWidget {
  const KullaniciKayitSayfa({super.key});

  @override
  State<KullaniciKayitSayfa> createState() => _KullaniciKayitSayfaState();
}

class _KullaniciKayitSayfaState extends State<KullaniciKayitSayfa> {
  final formKey = GlobalKey<FormState>();
  var tfEmail = TextEditingController();
  var tfAd = TextEditingController();
  var tfSoyad = TextEditingController();
  var tfDTarihi = TextEditingController();
  var tfParola = TextEditingController();

  String? selectedCountryCode;
  final Map<String, String> supportedCountries = {
    'TR': 'Turkiye', 'US': 'United States', 'CA': 'Canada',
    'IE': 'Ireland', 'GB': 'United Kingdom', 'AU': 'Australia',
    'NZ': 'New Zealand', 'MX': 'Mexico', 'AE': 'UAE', 'AT': 'Austria',
    'BE': 'Belgium', 'DE': 'Germany', 'DK': 'Denmark', 'ES': 'Spain',
    'FI': 'Finland', 'NL': 'Netherlands', 'NO': 'Norway', 'PL': 'Poland',
    'SE': 'Sweden', 'CH': 'Switzerland', 'CZ': 'Czech Republic',
    'IT': 'Italy', 'FR': 'France', 'ZA': 'South Africa',
    'BR': 'Brazil', 'CL': 'Chile', 'PE': 'Peru'
  };

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        appBar: AppBar(backgroundColor: Colors.blueAccent,iconTheme: const IconThemeData(color: Colors.white),),
        body: BlocConsumer<KullaniciKayitCubit, KullaniciKayitState>(
          listener: (context, state) {
            if (state is KullaniciKayitSuccess) {
              context.go('/login');
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lang!.registration_process_completed)));
            } else if (state is KullaniciKayitFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error),
              ));
            }
          },
          builder: (context, state){
            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0.r),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Text(lang!.sign_up, style: TextStyle(color: Colors.white, fontSize: 40.sp, fontWeight: FontWeight.bold),),
                        SizedBox(height: 30.h,),
                        textFieldOlustur(context, tfAd, lang.enter_your_first_name),
                        SizedBox(height: 10.h,),
                        textFieldOlustur(context, tfSoyad, lang.enter_your_last_name),
                        SizedBox(height: 10.h,),
                        textFieldOlustur(context, tfDTarihi, lang.enter_your_date_of_birth),
                        SizedBox(height: 10.h,),
                        textFieldOlustur(context, tfEmail, lang.enter_your_email_address),
                        SizedBox(height: 10.h,),
                        textFieldOlustur(context, tfParola, lang.enter_your_password, isPassword: true),
                        SizedBox(height: 10.h,),

                        DropdownButtonFormField<String>(
                          value: selectedCountryCode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.r),
                              borderSide: BorderSide.none,
                            ),
                            labelText: lang.country,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          items: supportedCountries.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key.toString(),
                              child: Text(entry.value,),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return lang.please_select_a_country;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedCountryCode = value;
                            });
                          },
                        ),

                        SizedBox(height: 30.h,),
                        Padding(
                          padding: EdgeInsets.only(right: 40.w, left: 40.w),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: (){
                                  if (formKey.currentState!.validate()) {
                                    context.read<KullaniciKayitCubit>().kayitOl(
                                      tfEmail.text.trim(),
                                      tfParola.text.trim(),
                                      tfAd.text.trim(),
                                      tfSoyad.text.trim(),
                                      tfDTarihi.text.trim(),
                                      selectedCountryCode!,
                                    );
                                  }
                                }, child: Text(lang.sign_up, style: TextStyle(fontSize: 20.sp),)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget textFieldOlustur(BuildContext context, TextEditingController controller, String hintText, {bool isPassword = false}) {
  var lang = AppLocalizations.of(context);
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    cursorColor: Colors.black,
    style: const TextStyle(color: Colors.black),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return lang!.this_field_is_required;
      }
      return null;
    },
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
