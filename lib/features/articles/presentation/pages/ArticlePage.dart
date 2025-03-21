import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;

import '../controller/ArticleController.dart';

class ArticlePage extends StatefulWidget {
  final int articleIndex;
  final String website;
  const ArticlePage({super.key, required this.articleIndex, required this.website});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final ArticleController controller = Get.find<ArticleController>();

  @override
  void initState() {
    controller.getArticles(widget.articleIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.primaryColor,
        toolbarHeight: screenSize.height * 0.07,
        title: Text(
          '${widget.website} Articles',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 6,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        child: Icon(
          Icons.chat_outlined,
          color: Colors.white,
        ),
        onPressed: () {
          controller.isChatWindowOpen.value = !controller.isChatWindowOpen.value;
        },
      ),
      body: Stack(
        children: [
          Obx(() => controller.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 10),
            child: PageView.builder(
              controller: controller.pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.markdownList.length,
              itemBuilder: (context, index) {
                var htmlContent = md.markdownToHtml('# Article ${controller.markdownList[index]}');
                return SingleChildScrollView(
                    child: SelectableRegion(
                        selectionControls: materialTextSelectionControls,
                        child: HtmlWidget(htmlContent)
                    )
                );
              },
            ),
          ),
          ),
          // Navigation buttons in the middle of the screen
          Positioned(
              top: 10,
              right: 10,
              child: Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: Get.theme.primaryColor,
                      padding: EdgeInsets.all(20)
                    ),
                    onPressed: () {
                      controller.isChatWindowOpen.value = false;
                      controller.isSummaryWindowOpen.value = !controller.isSummaryWindowOpen.value;
                      if(controller.isSummaryWindowOpen.value){
                        controller.generateSummary(widget.articleIndex);

                        if (controller.summaryMap['ArticleSummary ${widget.articleIndex}'] != null) {

                        }
                      }

                      // controller.summaryMap['ArticleSummary ${widget.articleIndex}'] != null ;
                    },
                    child: Icon(Icons.article_outlined, size: 25, color: Colors.white)
                ),
              ),
          ),

          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Get.theme.primaryColor,
                      ),
                      onPressed: controller.previousPage,
                      child: Icon(Icons.arrow_back, size: 30, color: Colors.white)
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Get.theme.primaryColor
                      ),
                      onPressed: controller.nextPage,
                      child: Icon(Icons.arrow_forward, size: 30, color: Colors.white)
                  ),
                ],
              ),
            ),
          ),
          Obx(() => controller.isChatWindowOpen.value ? Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.height * 0.6,
                  child: _buildChatWindow(controller)
              ),
            ),
          ) : SizedBox.shrink()),

          Obx(() => controller.isSummaryWindowOpen.value ? Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.height * 0.6,
                  child: _buildSummaryWindow(controller)
              ),
            ),
          ) : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildChatWindow(ArticleController controller) {
    controller.queryController.text = '';

    return Container(
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
                  child: StreamBuilder<String>(
                    stream: controller.streamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          controller.isGenerating.value ? 'Generating...' : 'Write query to get response...',
                          style: TextStyle(fontSize: 16, color: Get.theme.primaryColor),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        );
                      } else if (snapshot.hasData) {
                        return Text(
                          snapshot.data ?? 'No data available',
                          style: TextStyle(fontSize: 16, color: Get.theme.primaryColor),
                        );
                      } else {
                        return Text(
                          'No data available',
                          style: TextStyle(fontSize: 16, color: Get.theme.primaryColor),
                        );
                      }
                    },
                  )
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: controller.queryController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Ask your query...',
              border: OutlineInputBorder(),
            ),
            maxLines: 1,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: controller.isGenerating.value ? null : () => controller.sendQuery(),
            style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
            ),
            child: Text('Ask AI', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSummaryWindow(ArticleController controller) {
    return Container(
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
                  child:  Text(
                    controller.summaryResponse.isNotEmpty ? controller.summaryResponse.value : ' Generating Summary of this Article...',
                    style: TextStyle(fontSize: 16, color: Get.theme.primaryColor),
                  )
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
