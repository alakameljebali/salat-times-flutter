import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const PrayerTimesApp());
}

class PrayerTimesApp extends StatelessWidget {
  const PrayerTimesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Directionality(
      textDirection: TextDirection.rtl, // Set the text direction to RTL
      child: MaterialApp(
        title: 'أوقات الصلاة',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
            bodyMedium: GoogleFonts.readexPro(textStyle: textTheme.bodyMedium),
          ),
        ),
        home: const PrayerTimesWidget(), // Set your PrayerTimesWidget as the home screen.
      ),
    );
  }
}

class PrayerTimesWidget extends StatefulWidget {
  const PrayerTimesWidget({super.key});

  @override
  _PrayerTimesWidgetState createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  String fajr = "";
  String dhuhr = "";
  String asr = "";
  String maghrib = "";
  String isha = "";

  final String apiUrl =
      "https://api.aladhan.com/v1/calendarByCity?city=Bizerte&country=Tunisia&method=3";

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
  }

  Future<void> fetchPrayerTimes() async {
    try {
      final currentDayOfMonth = getCurrentDayOfMonth();
      final response = await http.get(Uri.parse(apiUrl));
      final data = json.decode(response.body);
      final prayerTimes = data['data'][currentDayOfMonth]['timings'];

      setState(() {
        fajr = prayerTimes['Fajr'].replaceAll(" (CET)", "");
        dhuhr = prayerTimes['Dhuhr'].replaceAll(" (CET)", "");
        asr = prayerTimes['Asr'].replaceAll(" (CET)", "");
        maghrib = prayerTimes['Maghrib'].replaceAll(" (CET)", "");
        isha = prayerTimes['Isha'].replaceAll(" (CET)", "");
      });
    } catch (error) {
      debugPrint("Error fetching data: $error");
    }
  }

  int getCurrentDayOfMonth() {
    final today = DateTime.now();
    return today.day - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("أوقات الصلاة"), // Prayer Times in Arabic
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PrayerCard("العصر", asr),
                PrayerCard("الظهر", dhuhr),
                PrayerCard("الصبح", fajr),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PrayerCard("العشاء", isha),
                PrayerCard("المغرب", maghrib),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerCard extends StatelessWidget {
  final String title;
  final String time;

  const PrayerCard(this.title, this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 56.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12.0),
              Center(
                child: Text(
                  time,
                  style: const TextStyle(fontSize: 45.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
