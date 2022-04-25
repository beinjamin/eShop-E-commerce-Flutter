import 'package:eshop/Helper/String.dart';

class FaqsModel {
  String? id, question,answer,status;

  FaqsModel(
      {this.id, this.question, this.answer, this.status});

  factory FaqsModel.fromJson(Map<String, dynamic> json) {

    return FaqsModel(
        id: json[ID],
        question: json[QUESTION],
        answer: json[ANSWER],
        status: json[STATUS]);
  }
}
