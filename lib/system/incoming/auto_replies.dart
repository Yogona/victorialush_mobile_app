import 'package:flutter/material.dart';

import '../../widgets/loading.dart';
import 'create_reply.dart';
import 'my_replies.dart';

class AutoReplies extends StatefulWidget {
  AutoReplies({Key? key}) : super(key: key);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final personalDetailsKey  = GlobalKey<FormState>();
  final phoneKey            = GlobalKey<FormState>();
  final emailKey            = GlobalKey<FormState>();

  @override
  State<AutoReplies> createState() => _AutoRepliesState();
}

class _AutoRepliesState extends State<AutoReplies> {
  //We set it to false so that initially it does not show calendar until it is clicked
  bool showCal = false;
  bool _isLoading = false;
  Map<String, dynamic> data = {};
  Map<String, dynamic> resData = {};

  void toggleCal(){
    setState(() {
      showCal = !showCal;
    });
  }


  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return (_isLoading)?const Loading(msg: 'Creating a reply...',):
    Builder(
      builder: (context){
        return ListView(
          children: [
            DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Column(
                children: [
                  const TabBar(
                    padding: EdgeInsets.all(0.0),
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(
                        child: Text(
                            "My Replies"
                        ),
                      ),
                      Tab(
                        child: Text(
                            "Create Reply"
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: height*.75,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: TabBarView(
                      children: [
                        const MyReplies(),
                        CreateReply(),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
