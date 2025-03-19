import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dio = Dio();
  final TextEditingController _queryController = TextEditingController();
  String _response = '';

  var markdownList = [];
  bool _isChatWindowOpen = false;
  bool _isGenerating = false;
  bool _isLoading = true;


  final PageController _pageController = PageController(initialPage: 0);

  // Move to the next page
  void nextPage() {
    if (_pageController.page!.toInt() < markdownList.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Move to the previous page
  void previousPage() {
    if (_pageController.page!.toInt() > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    _getArticles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(
          'Articles Screen',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 6,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        child: Icon(
          Icons.chat_outlined,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            _isChatWindowOpen = !_isChatWindowOpen; // Toggle chat window visibility
          });
        },
      ),
      body: Stack(
        children: [
          _isLoading ? Center(child: CircularProgressIndicator()) : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: PageView.builder(
              controller: _pageController,
              itemCount: markdownList.length,
              itemBuilder: (context, index) {
                var htmlContent = md.markdownToHtml('# Article ${markdownList[index]}');
                return SingleChildScrollView(
                    child: HtmlWidget(htmlContent)
                );
              },
            ),
          ),
          // Navigation buttons in the middle of the screen
          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.blue.shade700,
                      ),
                      onPressed: previousPage,
                      child: Icon(Icons.arrow_back, size: 30, color: Colors.white)
                  ),

                  // Next button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.blue.shade700
                      ),
                      onPressed: nextPage,
                      child: Icon(Icons.arrow_forward, size: 30, color: Colors.white)
                  ),
                ],
              ),
            ),
          ),
          _isChatWindowOpen ? Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.height * 0.5,
                  child: _buildChatWindow()
              ),
            ),
          ) : SizedBox.shrink(),
        ],
      ),
    );
  }

  // Build the chat window (small window on the screen)
  Widget _buildChatWindow() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChatWindowOpen = false;
        });
      },
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _isGenerating ? 'Generating...' : _response.isEmpty ? 'Write Query to get Response...' : _response,
                    style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Query input section
            TextField(
              controller: _queryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Ask your query...',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                if(_isGenerating == false) {
                  _sendQuery();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
              ),
              child: Text('Ask', style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _sendQuery() async {
    final String query = _queryController.text;

    if (query.isEmpty) return;

    try {
      setState(() {
        _isGenerating = true;
        print('Generating...');
      });

      final response = await dio.post(
        'http://127.0.0.1:8000/chat', // FastAPI server URL
        data: {
          'query': 'Query: $query\n\n\n'
              'Give answer from this Article ${markdownList[_pageController.page!.toInt()]}\n\n'
              'Note: The data is written in md format you have to give response in simple text only'
        },  // Sending query in the body
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        _response = response.data['response'];
      } else {
        _response = 'Error: ${response.statusCode}';
      }
      print(_response);
    } catch (e) {
      print('Failed to get response: $e');
      _response = 'Failed to get response: $e';
    } finally {
      _isGenerating = false;
      setState(() {});
    }
  }

  Future<void> _getArticles() async {

    try {
      final response = await dio.get(
        'http://127.0.0.1:8000/scraping/fetch', // FastAPI server URL
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          markdownList = response.data['scraped_data'];
        }
        else {
          markdownList = [response.data['message']];
        }
      } else {
        markdownList = ['Error: ${response.statusCode}'];
      }
    } catch (e) {
      print('Failed to get response: $e');
      _response = 'Failed to get response: $e';
    } 
    finally {
      _isLoading = false;
      setState(() {});
    }
  }
}
