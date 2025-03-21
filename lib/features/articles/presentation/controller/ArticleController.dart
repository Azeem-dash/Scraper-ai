import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mistralai_client_dart/mistralai_client_dart.dart';
import 'package:get/get.dart';

class ArticleController extends GetxController {
  final dio = Dio();
  final TextEditingController queryController = TextEditingController();
  RxString response = ''.obs;
  RxList markdownList = [].obs;
  RxList websiteList = [].obs;
  var summaryMap = {}.obs;
  var summaryResponse = ''.obs;
  RxBool isChatWindowOpen = false.obs;
  RxBool isSummaryWindowOpen = false.obs;
  RxBool isGenerating = false.obs;
  RxBool isLoading = true.obs;

  final client = MistralAIClient(apiKey: 'aMMDwxogZkfE5IbI4rRiTNRHrWnnIpDQ');
  final PageController pageController = PageController(initialPage: 0);
  StreamController<String> streamController = StreamController<String>.broadcast();

  // Move to the next page
  void nextPage() {
    if (pageController.page!.toInt() < markdownList.length - 1) {
      summaryResponse.value = '';
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Move to the previous page
  void previousPage() {
    if (pageController.page!.toInt() > 0) {
      summaryResponse.value = '';
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Send query to AI
  Future<void> sendQuery() async {
    final String query = queryController.text;
    if (query.isEmpty) return;

    isGenerating.value = true;

    try {
      final request = ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [
          UserMessage(content: UserMessageContent.string(
              'Query: $query\n\n\n'
                  'Give answer from this Article ${markdownList[pageController.page!.toInt()]}\n\n'
                  'Note: The data is written in md format you have to give response in simple text only'
          )),
        ],
      );

      final stream = client.chatStream(request: request);

      await for (final completionChunk in stream) {
        final chatMessage = completionChunk.choices[0].delta.content;
        if (chatMessage != null) {
          response.value += chatMessage;
          streamController.sink.add(response.value);
        }
      }
    } catch (e) {
      response.value = 'Failed to get response: $e';
    } finally {
      isGenerating.value = false;
    }
  }

  // Future<void> generateSummary() async {
  //   final String query = queryController.text;
  //   if (query.isEmpty) return;
  //
  //   isGenerating.value = true;
  //
  //   try {
  //     final request = ChatCompletionRequest(
  //       model: 'mistral-small-latest',
  //       messages: [
  //         UserMessage(content: UserMessageContent.string(
  //             'Generate Summary for this Article ${markdownList[pageController.page!.toInt()]}\n\n'
  //                 'Note: The data is written in md format you have to give response in simple text only'
  //         )),
  //       ],
  //     );
  //
  //     final stream = client.chatStream(request: request);
  //
  //     await for (final completionChunk in stream) {
  //       final chatMessage = completionChunk.choices[0].delta.content;
  //       if (chatMessage != null) {
  //         response.value += chatMessage;
  //         streamController.sink.add(response.value);
  //       }
  //     }
  //   } catch (e) {
  //     response.value = 'Failed to get response: $e';
  //   } finally {
  //     isGenerating.value = false;
  //   }
  // }

  // Generate Summary to AI
  Future<void> generateSummary(int index) async {
    isGenerating.value = true;

    try {
      final request = ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [
          UserMessage(content: UserMessageContent.string(
                  'Generate Summary for this Article ${markdownList[pageController.page!.toInt()]}\n\n'
                  'Note: The data is written in md format you have to give response in simple text only'
          )),
        ],
      );

      final chatCompletion = await client.chatComplete(request: request);
      final chatMessage = chatCompletion.choices?[0].message;
      print(chatMessage?.content);
      print('chatMessage?.content.runtimeType');
      print(chatMessage?.content.runtimeType);

      if (chatMessage != null) {
        summaryMap['ArticleSummary $index'] = chatMessage.content.toString();
        summaryResponse.value = chatMessage.content.toString();

      }

    } catch (e) {
      response.value = 'Failed to get response: $e';
    } finally {
      isGenerating.value = false;
    }
  }

  // Fetch articles
  Future<void> getArticles(int index) async {
    try {
      isLoading.value = true;
      final response = await dio.post(
        'http://127.0.0.1:8000/scraping/fetch',
        data: {'index': index}, // Passing the index as a query parameter
      );

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          markdownList.value = response.data['scraped_data'];
        } else {
          markdownList.value = [response.data['message']];
        }
      } else {
        markdownList.value = ['Error: ${response.statusCode}'];
      }
    } catch (e) {
      response.value = 'Failed to get response: $e';
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> getWebsites() async {
    try {
      isLoading.value = true;
      final response = await dio.get('http://127.0.0.1:8000/scraping/get_websites');

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          websiteList.addAll(response.data['websites']);
          websiteList.addAll(response.data['websites']);
          websiteList.addAll(response.data['websites']);
        }
      } else {
        websiteList.value = ['Error: ${response.statusCode}'];
      }
    } catch (e) {
      response.value = 'Failed to get response: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getWebsites();
  }

  @override
  void onClose() {
    streamController.close();
    pageController.dispose();
    super.onClose();
  }
}
