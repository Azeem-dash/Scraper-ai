import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dio = Dio();
  final TextEditingController _queryController = TextEditingController();
  String _response = '';

  bool _isChatWindowOpen = false;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(
          'Chat Screen',
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Chat!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5, // Placeholder for recent chats
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          onTap: (){
                            print('hehehe');
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.person, color: Colors.blue.shade700),
                          ),
                          title: Text('Chat ${index + 1}'),
                          subtitle: Text('This is a placeholder for chat message preview'),
                          trailing: Icon(Icons.chevron_right, color: Colors.blue.shade700),
                        ),
                      );
                    },
                  ),
                ),
              ],
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

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _response.isEmpty ? 'Response...' : _response,
                    style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                  ),
                ),
              ),
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
      _isGenerating = true;
      final response = await dio.post(
        'http://127.0.0.1:8000/chat', // FastAPI server URL
        data: {'query': query},  // Sending query in the body
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        setState(() {
          _response = response.data['response'];  // Extract the response data
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';  // If something goes wrong
        });
      }
    } catch (e) {
      print('Failed to get response: $e');
      setState(() {
        _response = 'Failed to get response: $e';
      });
    } finally {
      _isGenerating = false;
    }
  }
}
