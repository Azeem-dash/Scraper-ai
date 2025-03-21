
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_scrapping_project/features/articles/presentation/pages/ArticlePage.dart';

import '../controller/ArticleController.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArticleController());
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: screenSize.height * .2,
                width: screenSize.width,
                padding: EdgeInsets.only(top: 35, left: screenSize.width *0.035, right: screenSize.width *0.035, bottom: 8),
                decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(100),
                        bottomLeft: Radius.circular(100),
                    )
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Welcome to Articles App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 50)),

                      SizedBox(
                        height: screenSize.height * 0.01,
                      ),

                      Container(
                        height: screenSize.height * 0.01,
                        width: screenSize.width * 0.4,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: screenSize.height * 0.02,
                      ),

                      Container(
                        height: screenSize.height * 0.01,
                        width: screenSize.width * 0.45,
                        color: Colors.white,
                      ),

                      SizedBox(
                        height: screenSize.height * 0.01,
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: screenSize.height * .8,
                width: screenSize.width,
                padding: EdgeInsets.all(screenSize.width * 0.025),
                decoration: const BoxDecoration(
                ),
                child: controller.isLoading.value ?
                SizedBox(
                    height: 20,
                    width: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    )
                )
                : Center(
                  child: Wrap(
                    spacing: screenSize.width * 0.03,
                    runSpacing: screenSize.height * 0.03,
                    children: controller.websiteList.map((website){
                      int index = controller.websiteList.indexOf(website);
                      String websiteName = website.toString().split('.')[1];

                      return Container(
                        height: screenSize.height * 0.21,
                        width: screenSize.width *0.21,
                        padding: EdgeInsets.only(
                          right: 7, bottom: 7,
                          // left: 1, top: 1
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Get.theme.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(2, 4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],

                        ),

                        child: Container(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          padding: EdgeInsets.only(left: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(websiteName, style: TextStyle(color: Get.theme.primaryColor, fontSize: (screenSize.height * .2) * 0.18, fontWeight: FontWeight.bold),),
                                        Text(website.toString().split('/')[2], style: TextStyle(color: Get.theme.primaryColor, fontSize: (screenSize.height * .2) * 0.095, fontWeight: FontWeight.w500),),
                                      ],
                                    )
                                  ]
                              ),

                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      backgroundColor: Get.theme.primaryColor
                                  ),
                                  onPressed: ()=> Get.to(()=> ArticlePage(articleIndex: index, website: websiteName,)),
                                  child: Icon(Icons.arrow_forward, size: 30, color: Colors.white)
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
