import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syn/models/event_pool.dart';
import 'package:syn/models/player_profile.dart';
import 'package:syn/models/settings.dart';

final eventPoolServiceProvider = Provider<EventPoolService>((ref) => EventPoolService());

class EventPoolService {
  List<PooledEventTemplate>? _cache;
  // Map core drives to indicative tags. Expand freely as content grows.
  static const Map<String, List<String>> _driveTagMap = {
    'seek_knowledge': ['education', 'intellectual', 'curiosity', 'study', 'research'],
    'achieve_fame': ['fame', 'reputation', 'spotlight', 'performance'],
    'build_connections': ['social', 'romantic', 'relationship', 'community', 'family'],
    'experience_everything': ['party', 'adventure', 'travel', 'risk', 'explore'],
    'master_a_craft': ['creative', 'craft', 'art', 'skill', 'practice', 'hobby'],
    'amass_wealth': ['wealth', 'finance', 'career', 'job', 'promotion'],
    'fight_for_a_cause': ['cause', 'justice', 'politics', 'activism'],
    'seek_transcendence': ['digital', 'philosophy', 'identity', 'transcend'],
    'survive_at_all_costs': ['health', 'danger', 'crime', 'survival', 'safety'],
  };

  Future<List<PooledEventTemplate>> _loadPoolFile(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => PooledEventTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PooledEventTemplate>> _loadAll() async {
    if (_cache != null) return _cache!;
    // Manifest lists pool files to load
    final manifestRaw = await rootBundle.loadString('assets/events/manifest.json');
    final List<dynamic> files = jsonDecode(manifestRaw) as List<dynamic>;
    final List<PooledEventTemplate> all = [];
    for (final f in files) {
      final items = await _loadPoolFile('assets/events/$f');
      all.addAll(items);
    }
    _cache = all;
    return all;
  }

  bool _flagsOk(PlayerProfile p, EventGate g) {
    if (g.requiredFlags.isNotEmpty && !g.requiredFlags.every(p.flags.contains)) {
      return false;
    }
    if (g.excludedFlags.any(p.flags.contains)) {
      return false;
    }
    return true;
  }

  num _getStat(PlayerProfile p, String key) {
    final s = p.stats;
    switch (key) {
      case 'health':
        return s.health;
      case 'intelligence':
        return s.intelligence;
      case 'charisma':
        return s.charisma;
      case 'creativity':
        return s.creativity;
      case 'confidence':
        return s.confidence;
      case 'wealth':
        return s.wealth;
      case 'reputation':
        return s.reputation;
      case 'mood':
        return s.mood;
      case 'libido':
        return s.libido;
      case 'appearanceRating':
        return s.appearanceRating;
      case 'wisdom':
        return s.wisdom;
      case 'strength':
        return s.strength;
      case 'social':
        return s.social;
      case 'happiness':
        return s.happiness;
      case 'karma':
        return s.karma;
      default:
        return 0;
    }
  }

  bool _statsOk(PlayerProfile p, EventGate g) {
    if (g.minStats != null) {
      for (final e in g.minStats!.entries) {
        if (_getStat(p, e.key) < e.value) return false;
      }
    }
    if (g.maxStats != null) {
      for (final e in g.maxStats!.entries) {
        if (_getStat(p, e.key) > e.value) return false;
      }
    }
    return true;
  }

  bool _ageOk(PlayerProfile p, EventGate g) {
    if (g.minAge != null && p.age < g.minAge!) return false;
    if (g.maxAge != null && p.age > g.maxAge!) return false;
    return true;
  }

  Future<List<PooledEventTemplate>> eligibleTemplates(
    PlayerProfile profile,
    AppSettings settings,
  ) async {
    final all = await _loadAll();
    return all.where((tpl) {
      final g = tpl.gate;
      if (!_ageOk(profile, g)) return false;
      if (!_flagsOk(profile, g)) return false;
      if (!_statsOk(profile, g)) return false;
      if (g.requiresNsfw && !settings.nsfwEnabled) return false;
      // Optional: honor MemoryTemplate.ageRange if present
      if (tpl.ageRange != null && tpl.ageRange!.length == 2) {
        final minA = tpl.ageRange![0];
        final maxA = tpl.ageRange![1];
        if (profile.age < minA || profile.age > maxA) return false;
      }
      // Relationship gating
      if (g.relationshipConditions.isNotEmpty &&
          !_relationshipOk(profile, g)) return false;
      return true;
    }).toList();
  }

  bool _relationshipOk(PlayerProfile p, EventGate g) {
    for (final cond in g.relationshipConditions) {
      final found = p.relationships.any((n) {
        if (n.role != cond.role) return false;
        if (cond.stage != null && n.stage != cond.stage) return false;
        if (cond.minAffection != null && n.affection < cond.minAffection!) {
          return false;
        }
        if (cond.minTrust != null && n.trust < cond.minTrust!) {
          return false;
        }
        if (cond.minSexCompatibility != null &&
            n.sexCompatibility < cond.minSexCompatibility!) {
          return false;
        }
        return true;
      });
      if (!found) return false;
    }
    return true;
  }

  Future<PooledEventTemplate?> pickWeighted(
    PlayerProfile profile,
    AppSettings settings, {
    List<String>? preferredTags,
  }) async {
    final eligible = await eligibleTemplates(profile, settings);
    if (eligible.isEmpty) return null;
    // Apply core drive weighting
    final weighted = eligible.map((e) {
      final factor = _driveFactor(profile, e);
      // Tag bias boost
      double tagBoost = 1.0;
      if (preferredTags != null && preferredTags.isNotEmpty) {
        final matches = e.tags
            .where((t) => preferredTags.any((pt) => pt.toLowerCase() == t.toLowerCase()))
            .length;
        if (matches > 0) {
          tagBoost += (0.2 * matches).clamp(0.0, 0.8); // up to +80%
        }
      }
      final eff = (e.weight * factor * tagBoost).clamp(1, 1e9).toDouble();
      return MapEntry(e, eff);
    }).toList();
    final total = weighted.fold<double>(0, (sum, me) => sum + me.value);
    var r = Random().nextDouble() * total;
    for (final me in weighted) {
      if (r < me.value) return me.key;
      r -= me.value;
    }
    return weighted.first.key;
  }

  double _driveFactor(PlayerProfile profile, PooledEventTemplate tpl) {
    if (profile.coreDriveScores.isEmpty) return 1.0;
    double best = 1.0;
    for (final entry in _driveTagMap.entries) {
      final driveId = entry.key;
      final tags = entry.value;
      final hasTag = tpl.tags.any((t) => tags.contains(t.toLowerCase()));
      if (!hasTag) continue;
      final score = profile.coreDriveScores[driveId] ?? 0;
      final norm = (score.clamp(0, 100)) / 100.0; // 0..1
      final factor = 1.0 + norm * 0.75; // up to 1.75x
      if (factor > best) best = factor;
    }
    return best;
  }

  Future<PooledEventTemplate?> getById(String id) async {
    final all = await _loadAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
