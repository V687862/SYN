// lib/providers/memory_log_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memory_event.dart';

// Notifier class
class MemoryLogNotifier extends StateNotifier<List<MemoryEvent>> {
  MemoryLogNotifier() : super([]); // Initial state is an empty list

  void addMemory(MemoryEvent event) {
    state = [...state, event]; // Add new event to the list
  }

  void clearLog() {
    state = [];
  }

  // You could add other methods here, e.g.,
  // List<MemoryEvent> getMemoriesByAge(int age) => state.where((m) => m.age == age).toList();
  // List<MemoryEvent> getMemoriesByTag(String tag) => state.where((m) => m.tags.contains(tag)).toList();
}

// Global Provider
final memoryLogProvider = StateNotifierProvider<MemoryLogNotifier, List<MemoryEvent>>((ref) {
  return MemoryLogNotifier();
});