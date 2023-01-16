import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../packages/http_requests.dart';
import '../../shared/colors.dart';
import '../../shared/constraints.dart';
import '../../shared/decorations.dart';
import '../../widgets/loading.dart';
import '../../widgets/toast.dart';

class MyReplies extends StatefulWidget {
  const MyReplies({Key? key}) : super(key: key);

  @override
  State<MyReplies> createState() => _MyRepliesState();
}

class _MyRepliesState extends State<MyReplies> {
  StreamController<List> replies = StreamController<List>.broadcast();
  Map<String, dynamic> data = {};
  Map<String,dynamic> _resData = {};
  bool _isLoading = false;
  int currentPage = 1;
  dynamic prevPage = "";
  dynamic nextPage = "";

  Future<void> _getUsers(String uri) async {
    Response response = await HttpRequests.get(uri: uri);
    //print(response.body);
    if(response.statusCode == 200){
      _resData = json.decode(response.body);

      prevPage = _resData["data"]["prev_page_url"];
      if(prevPage != null) prevPage = prevPage.split("v1")[1];

      nextPage = _resData["data"]["next_page_url"];
      if(nextPage != null) nextPage = nextPage.split("v1")[1];

      currentPage = _resData["data"]["current_page"];
      replies.add(_resData["data"]["data"]);
    }
  }

  @override
  void initState(){
    super.initState();
    _getUsers("/auto-replies/list");
  }

  @override
  Widget build(BuildContext context) {
    //_getUsers();
    final height            = MediaQuery.of(context).size.height;
    // final width             = MediaQuery.of(context).size.width;

    final searchHeight          = height*.08;
    final myRepliesListHeight   = height*.58;
    final paginationHeight      = height*.07;

    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0
      ),
      children: [
        SizedBox(
          height: searchHeight,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                        Icons.search
                    ),
                    hintText: "Search does not work"
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: myRepliesListHeight,
          child: (_isLoading)?const Loading(msg: "We're getting your replies...",):StreamBuilder<List>(
            stream: replies.stream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if(snapshot.hasData){
                int len = snapshot.requireData.length;

                if(len == 0){
                  return const Center(
                    child: Text(
                      "You didn't create any replies.",
                      style: TextStyle(
                          fontSize: h3
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: len,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    dynamic reply = snapshot.requireData[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200.0)
                      ),
                      child:  Container(
                        padding: const EdgeInsets.all(0),
                        decoration: containerDecorations,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200.0)
                          ),
                          title: Text(
                              "Scheduled Time: ${reply["scheduled_time"]}"
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reply["reply"]),
                            ],
                          ),

                          leading: Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Image.network(
                              "https://previews.123rf.com/images/krisdog/krisdog2105/krisdog210500013/168332646-happy-smiling-cartoon-emoji-emoticon-face-icon.jpg",
                              loadingBuilder:(context, child, progress){
                                if(progress == null) return child;

                                return const Text("Retrieving...");
                              },
                            ),
                          ),

                          trailing: IconButton(
                              color: minorColor,
                              onPressed: (){
                                showDialog(
                                    context: context,
                                    builder: (context){
                                      return AlertDialog(
                                        title: const Text(
                                            "Delete?"
                                        ),
                                        content: const Text("This reply will be deleted!"),
                                        actions: [
                                          TextButton(
                                              onPressed: (){
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel")
                                          ),
                                          TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                setState((){
                                                  _isLoading =!_isLoading;
                                                });

                                                Response response = await HttpRequests.delete(uri: '/auto-replies/delete/${reply['id']}');
                                                _resData = json.decode(response.body);
                                                Toast.showToast(msg: _resData['message']);

                                                _getUsers("/auto-replies/list");
                                                setState((){
                                                  _isLoading =!_isLoading;
                                                });
                                              },
                                              child: const Text("Continue")
                                          )
                                        ],
                                      );
                                    }
                                );
                              },
                              icon: const Icon(
                                Icons.remove_circle,
                              )
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              else if(snapshot.connectionState.name == "waiting"){
                return const Center(
                  child: Text(
                    "Retrieving your custom replies.",
                    style: TextStyle(
                        fontSize: h3
                    ),
                  ),
                );
              }

              return const Center(
                child: Text(
                  "You didn't create any replies.",
                  style: TextStyle(
                      fontSize: h3
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: paginationHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                enableFeedback: (prevPage != null),
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  if(prevPage != null){
                    // setState(() {
                    //   _isLoading = true;
                    // });
                    await _getUsers(prevPage);
                    // setState(() {
                    //   _isLoading = false;
                    // });
                  }
                },
              ),

              TextButton(
                child:  const Text("..."),
                onPressed: (){

                },
              ),
              TextButton(
                child:  Text("$currentPage"),
                onPressed: (){

                },
              ),
              TextButton(
                child:  const Text("..."),
                onPressed: (){

                },
              ),

              IconButton(
                enableFeedback: (nextPage != null),
                icon: const Icon(Icons.arrow_forward),
                onPressed: () async{
                  // setState(() {
                  //  _isLoading = true;
                  // });
                  await _getUsers(nextPage);
                  // setState(() {
                  //   _isLoading = false;
                  // });
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}