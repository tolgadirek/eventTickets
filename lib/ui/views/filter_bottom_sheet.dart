import 'package:event_tickets/l10n/app_localizations.dart';
import 'package:event_tickets/ui/cubits/anasayfa_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    var lang = AppLocalizations.of(context);

    String? selectedCity;
    String? selectedCategory;
    DateTime? selectedDate;
    var tfGun = TextEditingController();

    var cubit = context.read<AnasayfaCubit>();
    selectedCity = cubit.currentCity;
    selectedCategory = cubit.currentSegment;
    selectedDate = cubit.currentDate;
    if(selectedDate != null) {
      tfGun.text = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
    }

    var events = (cubit.state is EventLoaded) ? (cubit.state as EventLoaded).events : [];

    var cities = events.map((event) => event.city)
        .where((e) => e != null).toSet().cast<String>().toList();

    var categories = events.map((event) => event.segment)
        .where((event) => event != null).toSet().cast<String>().toList();

    return Padding(
      padding: EdgeInsets.all(15.0.r),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(lang!.filter, style: TextStyle(fontWeight: FontWeight.bold),),
            DropdownButtonFormField(
                value: selectedCity,
                decoration: InputDecoration(labelText: lang.city),
                items: cities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) => selectedCity = value
            ),
            DropdownButtonFormField(
                value: selectedCategory,
                decoration: InputDecoration(labelText: lang.category),
                items: categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => selectedCategory = value
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 200.w,
                  child: TextField(
                    controller: tfGun,
                    decoration: InputDecoration(hintText: lang.date,), enabled: false,
                  ),
                ),
                ElevatedButton(onPressed: () async {
                  var picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 7)),
                      lastDate: DateTime(2035));
                  if (picked != null) {
                    selectedDate = picked;
                    tfGun.text = "${picked.year}/${picked.month}/${picked.day}";
                  }
                }, child: Text(lang.choose_date)),
              ],
            ),
            SizedBox(height: 10.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: (){
                  setState(() {
                    selectedCity = null;
                    selectedCategory = null;
                    selectedDate = null;
                  });
                  Navigator.pop(context);
                  cubit.applyFilters(); // sıfırlama
                }, child: Text(lang.clean)),
                TextButton(onPressed: (){
                  Navigator.pop(context);
                  cubit.applyFilters(
                    city: selectedCity,
                    segment: selectedCategory,
                    date: selectedDate,
                  );
                }, child: Text(lang.apply)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

