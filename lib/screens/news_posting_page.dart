import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class NewsPostingPage extends StatefulWidget {
  const NewsPostingPage({Key? key}) : super(key: key);

  @override
  State<NewsPostingPage> createState() => _NewsPostingPageState();
}

class _NewsPostingPageState extends State<NewsPostingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  NewsPost? _editingPost;
  bool _isEditing = false;

  List<String> tags = ['Election', 'Breaking News'];
  String selectedCategory = 'Election News';
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;
  bool enableScheduling = false;

  final List<String> categories = [
    'Election News',
    'Breaking News',
    'Updates',
    'Announcements',
    'Alerts'
  ];

  List<NewsPost> publishedNews = [
    NewsPost(
      id: '1',
      title: 'Election Results Announced',
      content: 'Final results for the parliamentary elections have been announced...',
      images: [
        'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500'
      ],
      category: 'Election News',
      likes: 1250,
      comments: 89,
      shares: 340,
      views: 5420,
      publishedDate: DateTime.now().subtract(Duration(hours: 2)),
      author: 'Admin',
      tags: ['Election', 'Results'],
    ),
    NewsPost(
      id: '2',
      title: 'Voting Booth Guidelines Updated',
      content: 'New safety guidelines for voting booths have been released...',
      images: [
        'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500'
      ],
      category: 'Updates',
      likes: 890,
      comments: 56,
      shares: 210,
      views: 3250,
      publishedDate: DateTime.now().subtract(Duration(hours: 5)),
      author: 'Admin',
      tags: ['Guidelines', 'Updates'],
    ),
  ];

  List<NewsPost> draftNews = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _loadPostForEditing(NewsPost post, {required bool fromDraft}) {
    setState(() {
      _isEditing = true;
      _editingPost = post;

      _titleController.text = post.title;
      _contentController.text = post.content;
      selectedCategory = post.category;
      tags = List.from(post.tags);

      selectedImages.clear();
      if (post.localImages != null) {
        selectedImages.addAll(post.localImages!);
      }

      if (fromDraft) {
        draftNews.remove(post);
      } else {
        publishedNews.remove(post);
      }
    });

    // 🔄 Switch to Create News tab
    _tabController.animateTo(0);
  }

  void _confirmDeleteDraft(NewsPost draft) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Draft'),
        content: const Text('Are you sure you want to delete this draft?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                draftNews.remove(draft);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0066CC), Color(0xFF0052A3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 7, right: 20),
                child:
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'News Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Create and manage daily news posts',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFF0066CC),
              labelColor: Color(0xFF0066CC),
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.create), text: 'Create News'),
                Tab(icon: Icon(Icons.schedule), text: 'Drafts'),
                Tab(icon: Icon(Icons.publish), text: 'Published'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Create News Tab
                _buildCreateNewsTab(isDesktop),
                // Drafts Tab
                _buildDraftsTab(isDesktop),
                // Published Tab
                _buildPublishedTab(isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewsTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: isDesktop
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildNewsFormContent(),
          ),
          SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildNewsPreview(),
          ),
        ],
      )
          : _buildNewsFormContent(),
    );
  }

  Widget _buildNewsFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        _buildSectionTitle('News Title'),
        TextField(
          controller: _titleController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Enter news title...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
        SizedBox(height: 24),

        // Category Selection
        _buildSectionTitle('Category'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            underline: SizedBox.shrink(),
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue ?? selectedCategory;
              });
            },
          ),
        ),
        SizedBox(height: 24),

        // Content Field
        _buildSectionTitle('News Content'),
        TextField(
          controller: _contentController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Write detailed news content...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
        SizedBox(height: 24),

        // Image Upload
        _buildSectionTitle('Images (Multiple)'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Drag & drop images or click to upload',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0066CC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Select Images'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        // Selected Images Preview
        if (selectedImages.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: selectedImages.map((image) {
              return Stack(
                children: [
                  FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: MemoryImage(snapshot.data!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImages.remove(image);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        SizedBox(height: 24),

        // Tags Field
        _buildSectionTitle('Tags/Hashtags'),
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: 'Add tags (press Enter to add)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
            ),
            contentPadding: EdgeInsets.all(16),
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_tagController.text.isNotEmpty) {
                  setState(() {
                    tags.add(_tagController.text);
                    _tagController.clear();
                  });
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                tags.add(value);
                _tagController.clear();
              });
            }
          },
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0066CC), Color(0xFF0052A3)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tags.remove(tag);
                      });
                    },
                    child: Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24),

        // Scheduling Section
        _buildSectionTitle('Schedule Publishing'),
        SwitchListTile(
          title: Text('Schedule for later'),
          subtitle: Text('Automatically publish at specified time'),
          value: enableScheduling,
          onChanged: (value) {
            setState(() {
              enableScheduling = value;
            });
          },
          tileColor: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        SizedBox(height: 12),
        if (enableScheduling) ...[
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text('Date'),
                  subtitle: Text(
                    scheduledDate != null
                        ? DateFormat('dd/MM/yyyy').format(scheduledDate!)
                        : 'Select date',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() {
                        scheduledDate = date;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text('Time'),
                  subtitle: Text(
                    scheduledTime != null
                        ? scheduledTime!.format(context)
                        : 'Select time',
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        scheduledTime = time;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
        ],

        // Publish Buttons
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _saveDraft();
                },
                icon: Icon(Icons.save),
                label: Text('Save Draft'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0066CC), Color(0xFF0052A3)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _publishNews();
                  },
                  icon: Icon(Icons.publish),
                  label: Text('Publish Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shadowColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewsPreview() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0066CC),
            ),
          ),
          SizedBox(height: 16),

          if (selectedImages.isNotEmpty)
            FutureBuilder<Uint8List>(
              future: selectedImages[0].readAsBytes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: MemoryImage(snapshot.data!),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),

          SizedBox(height: 12),
          Text(
            _titleController.text.isEmpty ? 'Your title here' : _titleController.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text(
            _contentController.text.isEmpty
                ? 'Your content preview will appear here...'
                : _contentController.text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Chip(
                label: Text(
                  selectedCategory,
                  style: TextStyle(fontSize: 10),
                ),
                backgroundColor: Color(0xFF0066CC).withOpacity(0.1),
                labelStyle: TextStyle(color: Color(0xFF0066CC)),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),
          Text(
            'Engagement Metrics',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricSmall('Views', '0'),
              _buildMetricSmall('Likes', '0'),
              _buildMetricSmall('Comments', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSmall(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0066CC),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDraftsTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved Drafts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (draftNews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No drafts available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isDesktop ? 0.9 : 1.2,
              ),
              itemCount: draftNews.length,
              itemBuilder: (context, index) {
                return _buildDraftCard(draftNews[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDraftCard(NewsPost draft) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: SizedBox(
        height: 300, // ✅ FIXED CARD HEIGHT (important)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Container(
              height: 140,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: _buildPublishedImage(draft),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    draft.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // DATE
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a')
                        .format(draft.publishedDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // ✅ PUSH EVERYTHING UP
            const Spacer(),

            // ✅ BUTTONS STICK TO BOTTOM
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child:
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _loadPostForEditing(draft, fromDraft: true);
                      },
                      child: const Text('Edit'),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDeleteDraft(draft);
                    },
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.publish, color: Colors.white),
                      label: const Text('Publish', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                      ),
                      onPressed: () {
                        setState(() {
                          draftNews.remove(draft);
                          publishedNews.insert(0, draft);
                        });
                        _tabController.animateTo(2);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishedTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Published News',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: publishedNews.length,
            itemBuilder: (context, index) {
              return _buildPublishedNewsCard(publishedNews[index], isDesktop);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPublishedNewsCard(NewsPost news, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isDesktop
          ? Row(
        children: [
          // IMAGE (LEFT SIDE – DESKTOP)
          Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildPublishedImage(news),
          ),

          // CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildNewsCardContent(news),
            ),
          ),
        ],
      )
          : Column(
        children: [
          // IMAGE (TOP – MOBILE)
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildPublishedImage(news),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildNewsCardContent(news),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCardContent(NewsPost news) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              label: Text(news.category),
              backgroundColor: Color(0xFF0066CC).withOpacity(0.1),
              labelStyle: TextStyle(color: Color(0xFF0066CC), fontSize: 11),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _loadPostForEditing(news, fromDraft: false);
                } else if (value == 'delete') {
                  _confirmDeletePublished(news);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          news.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),
        Text(
          news.content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(news.publishedDate),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 12),
        Divider(),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildEngagementMetric(Icons.visibility, '${news.views}', 'Views'),
            _buildEngagementMetric(Icons.favorite, '${news.likes}', 'Likes'),
            _buildEngagementMetric(Icons.comment, '${news.comments}', 'Comments'),
            _buildEngagementMetric(Icons.share, '${news.shares}', 'Shares'),
          ],
        ),
      ],
    );
  }

  void _confirmDeletePublished(NewsPost news) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete News'),
        content: const Text('Are you sure you want to delete this published news?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                publishedNews.remove(news);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  Widget _buildEngagementMetric(IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF0066CC), size: 16),
        SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF0066CC),
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _saveDraft() {
    // ❌ Prevent empty draft
    if (_titleController.text.isEmpty &&
        _contentController.text.isEmpty &&
        selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to save as draft'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // ✏️ EDIT MODE (from draft OR published)
      if (_isEditing && _editingPost != null) {
        draftNews.insert(
          0,
          NewsPost(
            id: _editingPost!.id, // ✅ keep same ID
            title: _titleController.text.isEmpty
                ? 'Untitled Draft'
                : _titleController.text,
            content: _contentController.text,
            images: null,
            localImages: List.from(selectedImages),
            category: selectedCategory,
            likes: _editingPost!.likes,
            comments: _editingPost!.comments,
            shares: _editingPost!.shares,
            views: _editingPost!.views,
            publishedDate: DateTime.now(),
            author: _editingPost!.author,
            tags: List.from(tags),
          ),
        );

        // ✅ reset edit state
        _isEditing = false;
        _editingPost = null;
      }

      // ➕ NEW DRAFT
      else {
        draftNews.insert(
          0,
          NewsPost(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text.isEmpty
                ? 'Untitled Draft'
                : _titleController.text,
            content: _contentController.text,
            images: null,
            localImages: List.from(selectedImages),
            category: selectedCategory,
            likes: 0,
            comments: 0,
            shares: 0,
            views: 0,
            publishedDate: DateTime.now(),
            author: 'Admin',
            tags: List.from(tags),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: Colors.green,
      ),
    );

    _clearForm();

    // ✅ SWITCH TO DRAFT TAB
    _tabController.animateTo(1);
  }

  void _publishNews() {
    // ❌ Validation
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter news title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish News?'),
        content: Text(
          _isEditing
              ? 'Are you sure you want to update and publish this news?'
              : 'Are you sure you want to publish this news?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          // ✅ PUBLISH BUTTON
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066CC), Color(0xFF0052A3)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  // ✏️ EDIT MODE → UPDATE EXISTING POST
                  if (_isEditing && _editingPost != null) {
                    publishedNews.insert(
                      0,
                      NewsPost(
                        id: _editingPost!.id, // keep same ID
                        title: _titleController.text,
                        content: _contentController.text,
                        images: null,
                        localImages: List.from(selectedImages),
                        category: selectedCategory,
                        likes: _editingPost!.likes,
                        comments: _editingPost!.comments,
                        shares: _editingPost!.shares,
                        views: _editingPost!.views,
                        publishedDate: DateTime.now(),
                        author: _editingPost!.author,
                        tags: List.from(tags),
                      ),
                    );

                    // reset edit state
                    _isEditing = false;
                    _editingPost = null;
                  }

                  // ➕ NEW PUBLISH
                  else {
                    publishedNews.insert(
                      0,
                      NewsPost(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _titleController.text,
                        content: _contentController.text,
                        images: null,
                        localImages: List.from(selectedImages),
                        category: selectedCategory,
                        likes: 0,
                        comments: 0,
                        shares: 0,
                        views: 0,
                        publishedDate: DateTime.now(),
                        author: 'Admin',
                        tags: List.from(tags),
                      ),
                    );
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('News published successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                _clearForm();

                // ✅ SWITCH TO "PUBLISHED" TAB
                _tabController.animateTo(2);
              },
              child: const Text(
                'Publish',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          selectedImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images')),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _tagController.clear();
    setState(() {
      selectedImages.clear();
      tags.clear();
      scheduledDate = null;
      scheduledTime = null;
      enableScheduling = false;
    });
  }
}

class NewsPost {
  final String id;
  final String title;
  final String content;
  final List<XFile>? localImages;
  final List<String>? images;
  final String category;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final DateTime publishedDate;
  final String author;
  final List<String> tags;

  NewsPost({
    required this.id,
    required this.title,
    required this.content,
    this.images,
    this.localImages,
    required this.category,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
    required this.publishedDate,
    required this.author,
    required this.tags,
  });
}

Widget _buildPublishedImage(NewsPost news) {
  // 🔹 LOCAL IMAGE (newly published)
  if (news.localImages != null && news.localImages!.isNotEmpty) {
    return FutureBuilder<Uint8List>(
      future: news.localImages!.first.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  // 🔹 NETWORK IMAGE (old/dummy published)
  if (news.images != null && news.images!.isNotEmpty) {
    return Image.network(
      news.images!.first,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
        );
      },
    );
  }

  // 🔹 FALLBACK
  return const Center(
    child: Icon(Icons.image, size: 40, color: Colors.grey),
  );
}

