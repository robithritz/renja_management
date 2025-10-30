# Quick Fix Reference - Code Examples

## Fix #1: Add Computed Properties to Renja Model

**File**: `lib/data/models/renja.dart`

```dart
class Renja {
  // ... existing fields ...

  // Computed properties (cached by Dart)
  String get dayName {
    try {
      final date = DateTime.parse(this.date);
      const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      return days[date.weekday % 7];
    } catch (_) {
      return '';
    }
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(this.date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '';
    }
  }

  bool get isDatePassed {
    try {
      final date = DateTime.parse(this.date);
      return date.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String get statusText {
    if (isTergelar == null) return '';
    if (isTergelar == true) return 'Tergelar';
    return 'Tidak - ${reasonTidakTergelar ?? 'No reason'}';
  }
}
```

**Usage in list**:
```dart
// Before (SLOW - 3 function calls per item per frame)
'${_getDayName(r.date)} ${_formatDate(r.date)} • ${r.time}'

// After (FAST - cached property access)
'${r.dayName} ${r.formattedDate} • ${r.time}'
```

---

## Fix #2: Define Static Const Decorations

**File**: `lib/modules/renja/renja_list_page.dart` (at top level)

```dart
// Pre-computed colors with alpha
const Color _infoChipBgColor = Color(0x14135193); // 0xFF135193 @ 0.08 alpha
const Color _infoChipBorderColor = Color(0x33135193); // 0xFF135193 @ 0.2 alpha

const BoxDecoration _infoChipDecoration = BoxDecoration(
  color: _infoChipBgColor,
  borderRadius: BorderRadius.all(Radius.circular(8)),
  border: Border(
    top: BorderSide(color: _infoChipBorderColor),
    bottom: BorderSide(color: _infoChipBorderColor),
    left: BorderSide(color: _infoChipBorderColor),
    right: BorderSide(color: _infoChipBorderColor),
  ),
);

const Color _statusGreenBg = Color(0x2693DA49); // 0xFF93DA49 @ 0.15 alpha
const Color _statusGreenBorder = Color(0x7F93DA49); // 0xFF93DA49 @ 0.5 alpha
const Color _statusRedBg = Color(0x26FF0000); // Colors.red @ 0.15 alpha
const Color _statusRedBorder = Color(0x7FFF0000); // Colors.red @ 0.5 alpha
```

**Usage**:
```dart
// Before (SLOW - creates new objects every frame)
decoration: BoxDecoration(
  color: const Color(0xFF135193).withValues(alpha: 0.08),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: const Color(0xFF135193).withValues(alpha: 0.2)),
),

// After (FAST - uses pre-computed const)
decoration: _infoChipDecoration,
```

---

## Fix #3: Replace TextButtons with IconButtons

**File**: `lib/modules/renja/renja_list_page.dart` (lines 284-370)

```dart
// Before (SLOW - TextButton.icon is expensive)
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    if (_isDatePassed(r.date) && r.isTergelar == null)
      IconButton(...),
    const SizedBox(width: 8),
    TextButton.icon(
      icon: const Icon(Icons.edit, size: 18),
      label: const Text('Edit'),
      onPressed: () async { ... },
    ),
    const SizedBox(width: 8),
    TextButton.icon(
      icon: const Icon(Icons.delete, size: 18),
      label: const Text('Delete'),
      onPressed: () async { ... },
    ),
  ],
)

// After (FAST - IconButton is simpler)
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    if (r.isDatePassed && r.isTergelar == null)
      IconButton(
        icon: const Icon(Icons.warning_amber, color: Color(0xFFFFA500), size: 24),
        tooltip: 'Mark status',
        onPressed: () async { ... },
      ),
    IconButton(
      icon: const Icon(Icons.edit, size: 18),
      tooltip: 'Edit',
      onPressed: () async { ... },
    ),
    IconButton(
      icon: const Icon(Icons.delete, size: 18),
      tooltip: 'Delete',
      onPressed: () async { ... },
    ),
  ],
)
```

---

## Fix #4: Extract List Item Widget

**File**: `lib/modules/renja/renja_list_page.dart` (new widget)

```dart
class _RenjaListItem extends StatelessWidget {
  final Renja renja;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onWarning;

  const _RenjaListItem({
    required this.renja,
    required this.onEdit,
    required this.onDelete,
    this.onWarning,
  });

  @override
  Widget build(BuildContext context) {
    // Move all item UI here from lines 142-370
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            renja.kegiatanDesc,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${renja.dayName} ${renja.formattedDate} • ${renja.time}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (renja.isTergelar != null)
                      _StatusBadge(renja: renja),
                  ],
                ),
                // ... rest of item UI
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Renja renja;
  const _StatusBadge({required this.renja});

  @override
  Widget build(BuildContext context) {
    final isComplete = renja.isTergelar == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isComplete ? _statusGreenBg : _statusRedBg),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isComplete ? _statusGreenBorder : _statusRedBorder),
        ),
      ),
      child: Text(
        renja.statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isComplete ? const Color(0xFF2D5A1A) : Colors.red.shade800,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
```

**Usage in ListView**:
```dart
ListView.builder(
  itemCount: filtered.length + (c.hasMorePages ? 1 : 0),
  itemBuilder: (context, i) {
    if (i == filtered.length) {
      return _LoadMoreButton(onPressed: () => c.loadMore());
    }
    final r = filtered[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _RenjaListItem(
        renja: r,
        onEdit: () async { ... },
        onDelete: () async { ... },
        onWarning: () async { ... },
      ),
    );
  },
)
```

---

## Implementation Checklist

- [ ] Add computed properties to Renja model
- [ ] Define static const decorations
- [ ] Replace TextButtons with IconButtons
- [ ] Extract _RenjaListItem widget
- [ ] Extract _StatusBadge widget
- [ ] Update ListView.builder to use new widgets
- [ ] Remove old helper functions (_getDayName, _formatDate, _isDatePassed)
- [ ] Test list scrolling
- [ ] Test drawer open/close
- [ ] Profile with Flutter DevTools


