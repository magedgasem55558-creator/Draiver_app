import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nqothizwtmvbvyrxoguz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xb3RoaXp3dG12YnZ5cnhvZ3V6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwMjc2ODEsImV4cCI6MjA4MjYwMzY4MX0.Hah1FyYJT-dQI0byUO7pNKB3NZqzkyICPh_0D_zdzis', // مفتاحك الكامل
  );
  runApp(const DriverTrackerApp());
}