import 'package:flutter/material.dart';

void main() => runApp(const FadingLabApp());

class FadingLabApp extends StatefulWidget {
  const FadingLabApp({super.key});
  @override
  State<FadingLabApp> createState() => _FadingLabAppState();
}

class _FadingLabAppState extends State<FadingLabApp> {
  ThemeMode _mode = ThemeMode.light;
  void _toggleTheme() => setState(
    () => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
  );

  @override
  Widget build(BuildContext context) {
    const seed = Colors.teal;
    return MaterialApp(
      title: 'Fading Lab',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
      ),
      home: FadingHome(
        isDark: _mode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class FadingHome extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const FadingHome({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<FadingHome> createState() => _FadingHomeState();
}

class _FadingHomeState extends State<FadingHome> {
  final _page = PageController();
  Color _textColor = Colors.tealAccent;
  bool _showFrame = false;

  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _page.addListener(() {
      final idx = _page.page?.round() ?? 0;
      if (idx != _pageIndex) {
        setState(() => _pageIndex = idx);
      }
    });
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    await _page.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fading Lab'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Pick text color',
            onPressed: () async {
              final picked = await showDialog<Color>(
                context: context,
                builder: (ctx) => _ColorGridDialog(initial: _textColor),
              );
              if (picked != null) setState(() => _textColor = picked);
            },
            icon: const Icon(Icons.palette_outlined),
          ),
          IconButton(
            tooltip: widget.isDark
                ? 'Switch to Day Mode'
                : 'Switch to Night Mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),

      body: PageView(
        controller: _page,
        children: [
          _FadePlayground(
            title: 'Screen 1 · Snappy Fade',
            textColor: _textColor,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            showFrame: _showFrame,
            onToggleFrame: (v) => setState(() => _showFrame = v),
          ),
          _FadePlayground(
            title: 'Screen 2 · Dreamy Fade',
            textColor: _textColor,
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOutCubicEmphasized,
            showFrame: _showFrame,
            onToggleFrame: (v) => setState(() => _showFrame = v),
          ),
        ],
      ),

      // NEW: Back + Next floating buttons (Back goes 2 -> 1)
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab-back',
            tooltip: 'Back to Page 1',
            onPressed: _pageIndex > 0 ? () => _goTo(0) : null,
            child: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: 'fab-next',
            tooltip: 'Go to Page 2',
            onPressed: _pageIndex < 1 ? () => _goTo(1) : null,
            child: const Icon(Icons.chevron_right),
          ),
        ],
      ),

      bottomNavigationBar: _PageDots(controller: _page, color: scheme.primary),
    );
  }
}

class _FadePlayground extends StatefulWidget {
  final String title;
  final Color textColor;
  final Duration duration;
  final Curve curve;
  final bool showFrame;
  final ValueChanged<bool> onToggleFrame;

  const _FadePlayground({
    required this.title,
    required this.textColor,
    required this.duration,
    required this.curve,
    required this.showFrame,
    required this.onToggleFrame,
  });

  @override
  State<_FadePlayground> createState() => _FadePlaygroundState();
}

class _FadePlaygroundState extends State<_FadePlayground> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch.adaptive(
                value: widget.showFrame,
                onChanged: widget.onToggleFrame,
              ),
              const SizedBox(width: 6),
              const Text('Show Frame'),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _visible = !_visible), // tap-to-fade
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: _visible ? 1 : 0,
                    duration: widget.duration,
                    curve: widget.curve,
                    child: Text(
                      'Hello, Flutter!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bonus: image card with rounded corners and optional frame
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: widget.showFrame
                          ? Border.all(color: scheme.primary, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 240,
                        height: 140,
                        alignment: Alignment.center,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E1F22)
                            : const Color(0xFFF0F2F5),
                        child: const FlutterLogo(size: 96),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => setState(() => _visible = !_visible),
                    icon: Icon(_visible ? Icons.pause : Icons.play_arrow),
                    label: Text(_visible ? 'Fade Out' : 'Fade In'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PageDots extends StatefulWidget {
  final PageController controller;
  final Color color;
  const _PageDots({required this.controller, required this.color});

  @override
  State<_PageDots> createState() => _PageDotsState();
}

class _PageDotsState extends State<_PageDots> {
  double _page = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() => setState(() => _page = widget.controller.page ?? 0);

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (i) {
          final active = (_page.round() == i);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: active ? 22 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: active ? widget.color : widget.color.withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }),
      ),
    );
  }
}

/// Simple no-package color picker (grid of swatches)
class _ColorGridDialog extends StatelessWidget {
  final Color initial;
  const _ColorGridDialog({required this.initial});

  @override
  Widget build(BuildContext context) {
    final swatches = <Color>[
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.pinkAccent,
      Colors.deepOrange,
      Colors.orange,
      Colors.amber,
      Colors.yellow,
      Colors.lime,
      Colors.lightGreen,
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.lightBlue,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.deepPurple,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.tealAccent,
      Colors.cyanAccent,
      Colors.purpleAccent,
    ];
    return AlertDialog(
      title: const Text('Pick Text Color'),
      content: SizedBox(
        width: 320,
        child: GridView.count(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          children: [
            for (final c in swatches)
              _ColorCell(
                color: c,
                selected: c.value == initial.value,
                onTap: () => Navigator.of(context).pop<Color>(c),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _ColorCell extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorCell({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
        : null;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
      ),
    );
  }
}
