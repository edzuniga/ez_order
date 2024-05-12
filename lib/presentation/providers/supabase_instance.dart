import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'supabase_instance.g.dart';

@Riverpod(keepAlive: true)
SupabaseClient supabaseInstance(Ref ref) {
  final instance = Supabase.instance.client;
  return instance;
}
