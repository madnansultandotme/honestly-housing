import '/flutter_flow/flutter_flow_util.dart';
import 'builder_selection_item_detail_widget.dart'
    show BuilderSelectionItemDetailWidget;
import 'package:flutter/material.dart';

class BuilderSelectionItemDetailModel
    extends FlutterFlowModel<BuilderSelectionItemDetailWidget> {
  FocusNode? nameFocusNode;
  TextEditingController? nameController;

  FocusNode? brandFocusNode;
  TextEditingController? brandController;

  FocusNode? allowanceFocusNode;
  TextEditingController? allowanceController;

  FocusNode? actualCostFocusNode;
  TextEditingController? actualCostController;

  FocusNode? notesFocusNode;
  TextEditingController? notesController;

  FocusNode? linkFocusNode;
  TextEditingController? linkController;

  FocusNode? roomFocusNode;
  TextEditingController? roomController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameController?.dispose();

    brandFocusNode?.dispose();
    brandController?.dispose();

    allowanceFocusNode?.dispose();
    allowanceController?.dispose();

    actualCostFocusNode?.dispose();
    actualCostController?.dispose();

    notesFocusNode?.dispose();
    notesController?.dispose();

    linkFocusNode?.dispose();
    linkController?.dispose();

    roomFocusNode?.dispose();
    roomController?.dispose();
  }
}
