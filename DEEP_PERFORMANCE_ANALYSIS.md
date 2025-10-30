# Deep Performance Analysis - Renja List & Drawer

## 🔴 CRITICAL ISSUES FOUND

### 1. **List Item Widget Tree Complexity** ⭐⭐⭐ CRITICAL
**Location**: `lib/modules/renja/renja_list_page.dart` lines 142-370

**Problem**: Each list item is a MASSIVE widget tree:
```
Card (elevation: 2)
  └─ InkWell
      └─ Padding
          └─ Column
              ├─ Row (Header with status badge)
              │   ├─ Expanded
              │   │   └─ Column
              │   │       ├─ Text (title)
              │   │       └─ Text (date/time)
              │   └─ Builder (status badge)
              │       └─ Container (complex decoration)
              │           └─ Text
              ├─ Row (Info chips)
              │   ├─ _buildInfoChip (instansi)
              │   └─ _buildInfoChip (hijriah)
              ├─ Conditional Row (sasaran)
              │   └─ Text
              └─ Row (Action buttons)
                  ├─ IconButton (warning)
                  ├─ TextButton.icon (edit)
                  └─ TextButton.icon (delete)
```

**Impact**: 
- Each item rebuilds entire tree on every scroll frame
- 3+ TextButtons per item = expensive
- Builder widget for status badge = extra rebuild
- Complex decorations calculated every frame

**Why it's slow**:
- ListView.builder calls itemBuilder for EVERY visible item on EVERY frame
- Each item has 15+ nested widgets
- Status badge uses Builder (forces rebuild)
- TextButtons are expensive widgets

---

### 2. **Helper Functions Called in Build** ⭐⭐⭐ CRITICAL
**Location**: Lines 180, 288

```dart
// Called EVERY frame for EVERY item
'${_getDayName(r.date)} ${_formatDate(r.date)} • ${r.time}'
if (_isDatePassed(r.date) && r.isTergelar == null)
```

**Problem**:
- `_getDayName()` - parses date string, does weekday calculation
- `_formatDate()` - parses date string again, formats month
- `_isDatePassed()` - parses date string again, compares with DateTime.now()
- **Each item calls these 3 times per frame!**

**Impact**: 
- 3 DateTime.parse() calls per item per frame
- String parsing is expensive
- Repeated calculations for same data

---

### 3. **Status Badge Builder Widget** ⭐⭐ HIGH
**Location**: Lines 189-247

```dart
if (r.isTergelar != null)
  Builder(
    builder: (_) {
      final isComplete = r.isTergelar == true;
      final statusText = isComplete ? 'Tergelar' : 'Tidak - ${r.reasonTidakTergelar ?? 'No reason'}';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: (isComplete ? const Color(0xFF93DA49) : Colors.red).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isComplete ? const Color(0xFF93DA49) : Colors.red).withValues(alpha: 0.5),
          ),
        ),
        child: Text(statusText, ...),
      );
    },
  ),
```

**Problem**:
- Builder widget forces rebuild even when data unchanged
- Complex BoxDecoration with conditional colors
- `.withValues(alpha: 0.15)` creates new Color object every frame
- String concatenation for statusText every frame

---

### 4. **Drawer Rebuilding on Open/Close** ⭐⭐ HIGH
**Location**: `lib/shared/widgets/app_drawer.dart`

**Problem**:
- Drawer is NOT const in RenjaListPage line 60
- `const AppDrawer(selectedItem: DrawerItem.renja)` - looks const but...
- Every time drawer opens, entire ListView rebuilds
- 5 ListTile widgets rebuild

**Why**:
- Drawer is part of Scaffold
- Scaffold rebuilds when drawer state changes
- AppDrawer children are not properly memoized

---

### 5. **Expensive Decorations** ⭐⭐ HIGH
**Location**: Multiple places

```dart
// Called EVERY frame for EVERY item
decoration: BoxDecoration(
  color: const Color(0xFF135193).withValues(alpha: 0.08),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: const Color(0xFF135193).withValues(alpha: 0.2)),
),
```

**Problem**:
- `.withValues(alpha: 0.08)` creates NEW Color object every frame
- `BorderRadius.circular(8)` creates NEW BorderRadius every frame
- `Border.all()` creates NEW Border every frame
- This happens for EVERY info chip (2 per item)

---

### 6. **TextButton Widgets** ⭐⭐ HIGH
**Location**: Lines 304-370

```dart
TextButton.icon(icon: const Icon(...), label: const Text('Edit'), onPressed: ...)
TextButton.icon(icon: const Icon(...), label: const Text('Delete'), onPressed: ...)
```

**Problem**:
- TextButton is expensive widget
- 2-3 per item
- onPressed callbacks create closures
- Rebuilds on every frame

---

## 📊 Performance Impact Summary

| Issue | Frequency | Impact | Severity |
|-------|-----------|--------|----------|
| Helper functions | 3x per item per frame | DateTime parsing | 🔴 CRITICAL |
| Widget tree depth | Every frame | 15+ nested widgets | 🔴 CRITICAL |
| Builder widget | Every frame | Forces rebuild | 🟠 HIGH |
| Color.withValues() | 2x per item per frame | Object allocation | 🟠 HIGH |
| TextButtons | 2-3 per item | Expensive widgets | 🟠 HIGH |
| Drawer rebuild | On open/close | Full tree rebuild | 🟠 HIGH |

---

## 🎯 Root Cause

**The app was fast with simple text items because**:
- Simple Text widgets don't trigger expensive operations
- No DateTime parsing
- No complex decorations
- No Builder widgets
- Minimal nesting

**Now it's slow because**:
- Complex card-based design with many nested widgets
- Expensive calculations in build method
- No memoization of computed values
- No widget extraction for reusable parts
- Drawer not properly optimized

---

## ✅ Solutions (Next Steps)

1. **Extract list item to separate widget** - Memoize with const constructor
2. **Cache computed values** - Pre-calculate dates, colors, status text
3. **Use const decorations** - Define as static const
4. **Replace TextButtons with simpler widgets** - Use IconButton instead
5. **Optimize drawer** - Ensure proper const constructors
6. **Use RepaintBoundary** - Already done but needs verification
7. **Consider lazy loading** - Load item details on demand


