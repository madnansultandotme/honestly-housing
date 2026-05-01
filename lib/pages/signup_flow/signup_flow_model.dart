import '/flutter_flow/flutter_flow_util.dart';
import 'signup_flow_widget.dart' show SignupFlowWidget;
import 'package:flutter/material.dart';

class SignupFlowModel extends FlutterFlowModel<SignupFlowWidget> {
  FocusNode? nameFocusNode;
  TextEditingController? nameController;

  FocusNode? emailFocusNode;
  TextEditingController? emailController;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordController;

  FocusNode? confirmPasswordFocusNode;
  TextEditingController? confirmPasswordController;

  FocusNode? orgNameFocusNode;
  TextEditingController? orgNameController;

  FocusNode? phoneFocusNode;
  TextEditingController? phoneController;

  FocusNode? cityFocusNode;
  TextEditingController? cityController;

  FocusNode? budgetFocusNode;
  TextEditingController? budgetController;

  FocusNode? timelineFocusNode;
  TextEditingController? timelineController;

  FocusNode? styleFocusNode;
  TextEditingController? styleController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameController?.dispose();

    emailFocusNode?.dispose();
    emailController?.dispose();

    passwordFocusNode?.dispose();
    passwordController?.dispose();

    confirmPasswordFocusNode?.dispose();
    confirmPasswordController?.dispose();

    orgNameFocusNode?.dispose();
    orgNameController?.dispose();

    phoneFocusNode?.dispose();
    phoneController?.dispose();

    cityFocusNode?.dispose();
    cityController?.dispose();

    budgetFocusNode?.dispose();
    budgetController?.dispose();

    timelineFocusNode?.dispose();
    timelineController?.dispose();

    styleFocusNode?.dispose();
    styleController?.dispose();
  }
}
