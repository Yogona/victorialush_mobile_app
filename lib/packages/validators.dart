import 'package:flutter/services.dart';

const passwordRegex = "\\0\\Z\\t\\n\\b\\r\\\$\\%\\_";
const emailRegex = "^[a-z][a-z0-9.-]+@[a-z0-9]+([-]{0,1}[a-z0-9])+([.][a-z0-9]+([-]{0,1}[a-z0-9])+)*[.][a-z]{2,}\$";
const phoneReg = "^(0)[1-9][0-9]{8}\$";
const nameRegex = "^[A-Z][a-z]{2,}\$";

var emailFilter = [FilteringTextInputFormatter(RegExp(r"[\w@.-]"), allow: true),];
var passwordFilter = [FilteringTextInputFormatter(RegExp(r"[\\0\\Z\\t\\n\\b\\r\\\\$\\%\\_]"), allow: false)];
var nameFilter = [FilteringTextInputFormatter(RegExp("[A-Za-z]"), allow: true)];
var positiveNumbersFilter = [FilteringTextInputFormatter(RegExp(r"[\d.]"), allow: true)];

var passwordValidator = (val){
  if(val!.isEmpty){
    return "Password is required.";
  }

  return null;
};

var phoneValidator = (val){
  if(val!.isEmpty){
    return "Phone numbers are required.";
  }
  else if(!RegExp(phoneReg).hasMatch(val)){
    return "Please enter valid phone numbers.";
  }

  return null;
};

var emailValidator = (val){
  if(val!.isEmpty){
    return "Email address is required.";
  }
  else if(!val.contains('@')){
    return "Email must have '@'.";
  }
  else if(!val.contains('.')){
    return "Email must have '.'.";
  }
  else if(!RegExp(emailRegex).hasMatch(val)){
    return "Invalid email address.";
  }

  return null;
};

var addressValidator = (val){
  if(val!.isEmpty){
    return "Address is required.";
  }

  return null;
};

var genderValidator = (val){
  if(val!.isEmpty){
    return "Gender is required.";
  }

  return null;
};

var dateOfBirthValidator = (val){
  if(val!.isEmpty){
    return "Date of birth is required.";
  }

  return null;
};

var lastNameValidator = (val){
  if(val!.isEmpty){
    return "Last name is required.";
  }
  else if(val.length < 3){
    return "Name must be at least 3 chars.";
  }
  else if(!RegExp(nameRegex).hasMatch(val)){
    return "Please enter a valid name.";
  }

  return null;
};

var firstNameValidator = (val){
  if(val!.isEmpty){
    return "First name is required.";
  }
  else if(val.length < 3){
    return "Name must be at least 3 chars.";
  }
  else if(!RegExp(nameRegex).hasMatch(val)){
    return "Please enter a valid name.";
  }

  return null;
};

var buildNumberValidator = (val){
  if(val!.isEmpty){
    return "Enter valid input.";
  }
  return null;
};