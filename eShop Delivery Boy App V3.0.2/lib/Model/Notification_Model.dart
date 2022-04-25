import 'package:deliveryboy/Helper/String.dart';
import 'package:intl/intl.dart';

class Notification_Model {
  String? id, title, desc, img, type_id, date;

  Notification_Model(
      {this.id, this.title, this.desc, this.img, this.type_id, this.date});

  factory Notification_Model.fromJson(Map<String, dynamic> json) {
    String date = json[DATE_SEND];

    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return Notification_Model(
        id: json[ID],
        title: json[TITLE],
        desc: json[MESSAGE],
        img: json[IMAGE],
        type_id: json[TYPE_ID],
        date: date);
  }
}
