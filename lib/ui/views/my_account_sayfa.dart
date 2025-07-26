import 'package:event_tickets/l10n/app_localizations.dart';
import 'package:event_tickets/ui/cubits/locale_cubit.dart';
import 'package:event_tickets/ui/cubits/my_account_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final formKey = GlobalKey<FormState>();
  var tfEmail = TextEditingController();
  var tfFirstName = TextEditingController();
  var tfLastName = TextEditingController();
  var tfDTarihi = TextEditingController();
  var country;
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
  void initState() {
    super.initState();
    context.read<MyAccountCubit>().loadUserInfo().then((_) {
      final userData = context.read<MyAccountCubit>().state;
      if (userData != null) {
        setState(() {
          tfEmail.text = userData["email"];
          tfFirstName.text = userData["ad"];
          tfLastName.text = userData["soyad"];
          tfDTarihi.text = userData["dtarih"];
          country = userData["country"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang!.events, style: TextStyle(color: Colors.white),),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocBuilder<MyAccountCubit, Map<String, dynamic>?>(
            builder: (context, userData) {
              if (userData == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15.r),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(lang.my_account, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),),
                            DropdownButton<Locale>(
                              value: Localizations.localeOf(context),
                              onChanged: (Locale? newLocale) {
                                if (newLocale != null) {
                                  context.read<LocaleCubit>().changeLocale(newLocale);
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: Locale('en'),
                                  child: Text("English"),
                                ),
                                DropdownMenuItem(
                                  value: Locale('tr'),
                                  child: Text("Türkçe"),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h,),
                        textFieldOlustur(context, tfFirstName, lang.first_name, lang.enter_your_first_name),
                        SizedBox(height: 10.h,),
                        textFieldOlustur(context, tfLastName, lang.last_name, lang.enter_your_last_name),
                        SizedBox(height: 10.h,),
                        textFieldOlustur(context, tfDTarihi, lang.date_of_birth, lang.enter_your_date_of_birth),
                        SizedBox(height: 10.h,),
                        textFieldOlustur(context, tfEmail, lang.email_address, lang.enter_your_email_address, enable: false),
                        SizedBox(height: 10.h,),

                        DropdownButtonFormField<String>(
                          value: country,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none
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
                              country = value;
                            });
                          },
                        ),

                        SizedBox(height: 20.h,),
                        Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: (){
                                    if (formKey.currentState!.validate()) {
                                      context.read<MyAccountCubit>().updateUserInfo(
                                          email: tfEmail.text,
                                          ad: tfFirstName.text,
                                          soyad: tfLastName.text,
                                          dtarih: tfDTarihi.text,
                                          country: country
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(lang.save),
                                            content: Text(lang.your_information_has_been_updated_successfully_),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(lang.ok),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }, child: Text(lang.save, style: TextStyle(fontSize: 18.sp),)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}

Widget textFieldOlustur(BuildContext context, TextEditingController controller, String labelText, String hintText,{bool enable = true}) {
  var lang = AppLocalizations.of(context);
  return TextFormField(
    controller: controller,
    cursorColor: Colors.black,
    enabled: enable,
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
      labelText: labelText,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
    ),
  );
}
