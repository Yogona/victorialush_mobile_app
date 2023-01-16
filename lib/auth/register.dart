import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../packages/validators.dart';
import '../shared/constraints.dart';
import '../widgets/loading.dart';
import '../widgets/toast.dart';

class Register extends StatefulWidget {
  Register({Key? key, required this.toggleAuth, required this.swapAuth}) : super(key: key);

  final Function toggleAuth;
  final Function swapAuth;

  final formKey = GlobalKey<FormState>();
  final dobController = TextEditingController();

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin{
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..animateTo(1.0);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  //We set it to false so that initially it does not show calendar until it is clicked
  bool showCal = false;
  bool _isLoading = false;
  String _pwd = "";

  void toggleCal(){
    setState(() {
      showCal = !showCal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading)?const Loading(msg: "We're creating your account."):
    FadeTransition(
        opacity: _animation,
      child: Form(
        key: widget.formKey,
        child: ListView(
          cacheExtent: 500.0,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()
          ),
          children: [
            const SizedBox(height: vGap,),

            const Center(
              child: Text(
                "Register Account",
                style: TextStyle(
                    fontSize: 30
                ),
              ),
            ),

            const SizedBox(height: vGap,),

            //First name
            TextFormField(
              decoration: const InputDecoration(
                hintText: "John Doe",
                label: Text(
                    "Names"
                  // )
                ),
              ),
              keyboardType: TextInputType.text,
              //inputFormatters: nameFilter,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              //validator: firstNameValidator,
              onSaved: (val){},
            ),
            const SizedBox(height: vGap,),

            TextFormField(
              decoration: const InputDecoration(
                  hintText: "255799283712",
                  label: Text(
                      "Phone Numbers"
                  )
              ),
              keyboardType: TextInputType.phone,
              validator: phoneValidator,
              onSaved: (val){},
            ),
            const SizedBox(height: vGap,),

            TextFormField(
              decoration: const InputDecoration(
                  hintText: "user@domain.extension",
                  label: Text(
                      "Email Address"
                  )
              ),
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
              onSaved: (val){},
            ),
            const SizedBox(height: vGap,),

            TextFormField(
              decoration: const InputDecoration(
                  hintText: "DoeDon",
                  label: Text(
                      "Username"
                  )
              ),
              keyboardType: TextInputType.streetAddress,
              validator: addressValidator,
              onSaved: (val){},
            ),
            const SizedBox(height: vGap,),

            TextFormField(
              decoration: const InputDecoration(
                  hintText: "Alpha numerics, 6 characters long.",
                  label: Text(
                      "Enter password"
                  )
              ),
              keyboardType: TextInputType.text,
              obscureText: true,
              validator: passwordValidator,
              onChanged: (val){_pwd = val;},
            ),
            const SizedBox(height: vGap,),

            TextFormField(
              decoration: const InputDecoration(
                  hintText: "Enter a matching password.",
                  label: Text(
                      "Confirm password"
                  )
              ),
              keyboardType: TextInputType.emailAddress,
              obscureText: true,
              validator: (val){
                if(val != _pwd){
                  return "Passwords do not match.";
                }

                return null;
              },
            ),

            TextButton(
              child: const Text("Terms and policies of use."),

              onPressed: (){
                //widget.swapAuth();
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text("I have an account already!"),

                  onPressed: (){
                    widget.swapAuth();
                  },
                ),

                ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0))
                  ),
                  child: const Text("Sign up"),

                  onPressed: () async
                  {
                    if(widget.formKey.currentState!.validate())
                    {
                      bool isConnected = await InternetConnectionChecker().hasConnection;

                      if(isConnected)
                      {
                        setState(() {
                          _isLoading = !_isLoading;
                        });

                        widget.formKey.currentState!.save();

                        // Map<String, dynamic> data = {
                        //   "first_name":User.getFirstName(),
                        //   "last_name":User.getLastName(),
                        //   "dob":User.getDOB(),
                        //   "gender":User.getGender(),
                        //   "address":User.getGender(),
                        //   "phone":User.getPhone(),
                        //   "email":User.getEmail(),
                        //   "password":_pwd
                        // };

                        // Response response = await HttpRequests.post(uri: "/sign-up", data: data, headers: headers);
                        //
                        // setState(() {
                        //   _isLoading = !_isLoading;
                        // });
                        //
                        // data = json.decode(response.body);
                        //
                        // if(response.statusCode == 201)
                        // {
                        //   Files fileWriter = Files();
                        //   String token = data["data"];
                        //   fileWriter.writeFile("token.dat", token);
                        //   headers["Authorization"] = "Bearer $token";
                        //   User.setRoleId(2);
                        //   widget.toggleAuth();
                        // }
                      }else{
                        Toast.showToast(msg: "No internet connection.",);
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: vGap,),
          ],
        ),
      ),
    );
  }
}
