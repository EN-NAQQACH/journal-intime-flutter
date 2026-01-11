import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/entry_provider.dart';
import '../providers/mood_provider.dart';
import '../models/journal_entry.dart';
import 'add_entry_page.dart';
import 'entry_details_page.dart';
import 'calendrier_page.dart';
import 'gallery_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  String _selectedMoodFilter = 'all';
  bool _isSearching = false;
  final ScrollController _scrollController = ScrollController();
  bool _showFabText = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection.toString().contains(
      'forward',
    )) {
      if (!_showFabText) setState(() => _showFabText = true);
    } else {
      if (_showFabText) setState(() => _showFabText = false);
    }
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await entryProvider.loadEntries(authProvider.currentUser!.id!);
      await moodProvider.loadMoodStats(authProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      const CalendrierPage(),
      const GalleryPage(),
      const StatsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 ? _buildFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEntryPage()),
        );
        if (result == true) _loadData();
      },
      icon: const Icon(Icons.add),
      label: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _showFabText ? const Text('Ajouter') : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Calendrier',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Galerie',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Réglages',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildAppBar(),
        _buildSearchBar(),
        _buildMoodFilter(),
        _buildEntriesList(),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      title: Row(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Journal Intime',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _isSearching = !_isSearching),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEntryPage()),
            );
            if (result == true) _loadData();
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearching) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Rechercher par titre, contenu ou date...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _loadData();
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onChanged: (value) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final entryProvider = Provider.of<EntryProvider>(
              context,
              listen: false,
            );
            if (value.isNotEmpty) {
              entryProvider.searchEntries(authProvider.currentUser!.id!, value);
            } else {
              _loadData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMoodFilter() {
    final moodProvider = Provider.of<MoodProvider>(context);
    final moods = ['all', 'happy', 'content', 'neutral', 'sad', 'angry'];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: moods.length,
          itemBuilder: (context, index) {
            final mood = moods[index];
            final isSelected = _selectedMoodFilter == mood;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  children: [
                    if (mood != 'all')
                      Text(
                        moodProvider.getMoodEmoji(mood),
                        style: const TextStyle(fontSize: 18),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      mood == 'all' ? 'Tous' : moodProvider.getMoodLabel(mood),
                    ),
                  ],
                ),
                onSelected: (selected) {
                  setState(() => _selectedMoodFilter = mood);
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final entryProvider = Provider.of<EntryProvider>(
                    context,
                    listen: false,
                  );

                  if (mood == 'all') {
                    entryProvider.loadEntries(authProvider.currentUser!.id!);
                  } else {
                    entryProvider.filterByMood(
                      authProvider.currentUser!.id!,
                      mood,
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEntriesList() {
    return Consumer<EntryProvider>(
      builder: (context, entryProvider, child) {
        if (entryProvider.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (entryProvider.entries.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune entrée',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commencez à écrire votre journal',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildEntryCard(entryProvider.entries[index]),
              childCount: entryProvider.entries.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);

    return FutureBuilder(
      future: entryProvider.getPhotosForEntry(entry.id!),
      builder: (context, snapshot) {
        final photos = snapshot.data ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _handleEntryTap(entry),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (entry.password != null &&
                                entry.password!.isNotEmpty)
                              Icon(
                                Icons.lock_outline,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              moodProvider.getMoodEmoji(entry.mood),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              moodProvider.getMoodLabel(entry.mood),
                              style: TextStyle(
                                fontSize: 12,
                                color: moodProvider.getMoodColor(entry.mood),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (photos.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(photos.first.imagePath),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        // errorBuilder: (context, error, stackTrace) => Container(
                        //   width: 80,
                        //   height: 80,
                        //   color: Colors.grey.shade200,
                        //   child: const Icon(Icons.image_not_supported),
                        // ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEntryTap(JournalEntry entry) async {
    // Check if entry has password
    if (entry.password != null && entry.password!.isNotEmpty) {
      // Show password dialog
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PasswordDialog(correctPassword: entry.password!),
      );

      // If password is incorrect, don't navigate
      if (result != true) return;
    }

    // Navigate to details page
    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EntryDetailsPage(entry: entry)),
      );
      if (result == true) _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _PasswordDialog extends StatefulWidget {
  final String correctPassword;

  const _PasswordDialog({required this.correctPassword});

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Entrée protégée',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Cette entrée est protégée par un mot de passe',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            obscureText: _obscurePassword,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.key),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onSubmitted: (_) => _verifyPassword(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _verifyPassword,
          icon: const Icon(Icons.lock_open, size: 20),
          label: const Text('Déverrouiller'),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

      ],
    );
  }

  void _verifyPassword() {
    if (_controller.text == widget.correctPassword) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = 'Mot de passe incorrect');
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
