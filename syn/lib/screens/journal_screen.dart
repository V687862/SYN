import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/syn_kit.dart';
import '../models/memory_event.dart';
import '../providers/player_state_provider.dart';
import '../providers/app_screen_provider.dart';
import '../providers/action_log_provider.dart';
import '../models/action_log_entry.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  static const Color _accent = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerProfile = ref.watch(playerStateProvider);
    final actionLog = ref.watch(actionLogProvider);

    final memories = List<MemoryEvent>.from(playerProfile.memories)
      ..sort((a, b) => a.age.compareTo(b.age));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('JOURNAL', style: TextStyle(letterSpacing: 4)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(appScreenProvider.notifier).pop(),
        ),
      ),
      body: memories.isEmpty
          ? const _EmptyState()
          : Stack(
              children: [
                // vertical ghost timeline line
                Positioned.fill(
                  left: 36,
                  child: IgnorePointer(
                    child: CustomPaint(painter: _TimelinePainter()),
                  ),
                ),
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  itemCount: memories.length,
                  itemBuilder: (context, i) {
                    final m = memories[i];
                    ActionLogEntry? entry;
                    try {
                      entry = actionLog.firstWhere((e) => e.eventId == m.id);
                    } catch (_) {}
                    return _ExpandableMemoryItem(
                      memory: m,
                      actionEntry: entry,
                      isFirst: i == 0,
                      isLast: i == memories.length - 1,
                    );
                  },
                ),
              ],
            ),
    );
  }
}

/* -------------------- Empty State -------------------- */
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(.12), width: 1),
        ),
        child: Text(
          'No significant memories yet.',
          style: TextStyle(color: Colors.white.withOpacity(.7), letterSpacing: .5),
        ),
      ),
    );
  }
}

/* -------------------- Timeline Painter -------------------- */
class _TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withOpacity(.08)
      ..strokeWidth = 1;
    // vertical line near left side
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), line);
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) => false;
}

/* -------------------- Memory Item -------------------- */
class _ExpandableMemoryItem extends StatefulWidget {
  final MemoryEvent memory;
  final ActionLogEntry? actionEntry;
  final bool isFirst;
  final bool isLast;
  const _ExpandableMemoryItem({
    required this.memory,
    this.actionEntry,
    required this.isFirst,
    required this.isLast,
  });

  @override
  State<_ExpandableMemoryItem> createState() => _ExpandableMemoryItemState();
}

class _ExpandableMemoryItemState extends State<_ExpandableMemoryItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00E5FF);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // timeline node
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withOpacity(.8), width: 1),
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // ghost panel
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(_open ? .20 : .12),
                  width: 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _open = !_open),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header row
                      Row(
                        children: [
                          Text(
                            'Age ${widget.memory.age}',
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: 1.2,
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.memory.summary,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: _open ? .5 : 0.0,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(Icons.expand_more, color: Colors.white70, size: 20),
                          ),
                        ],
                      ),

                      // body
                      AnimatedCrossFade(
                        firstChild: const SizedBox(height: 0),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _MemoryDetails(memory: widget.memory, actionEntry: widget.actionEntry),
                        ),
                        crossFadeState:
                            _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 180),
                        sizeCurve: Curves.easeOut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------- Details -------------------- */
class _MemoryDetails extends StatelessWidget {
  final MemoryEvent memory;
  final ActionLogEntry? actionEntry;
  const _MemoryDetails({required this.memory, this.actionEntry});

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0x22FFFFFF);
    const accent = Color(0xFF00E5FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          memory.description,
          style: TextStyle(color: Colors.white.withOpacity(.85), height: 1.45),
        ),
        if (actionEntry != null) ...[
          const SizedBox(height: 12),
          const ThinDivider(),
          const SizedBox(height: 8),
          Text('Your Choice:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(.75),
              )),
          const SizedBox(height: 4),
          Text('“${actionEntry!.choiceText}”',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: accent,
              )),
          if ((actionEntry!.outcomeDescription ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Outcome:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(.75),
                )),
            const SizedBox(height: 4),
            Text(
              actionEntry!.outcomeDescription!,
              style: TextStyle(color: Colors.white.withOpacity(.85), height: 1.45),
            ),
          ],
        ],
      ],
    );
  }
}
