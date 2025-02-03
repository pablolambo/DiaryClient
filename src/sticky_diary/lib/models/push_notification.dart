class PushNotification {
  PushNotification({
    required this.title,
    this.body,
    required this.dataTitle,
    this.dataBody,
  });

  String title;
  String? body;
  String dataTitle;
  String? dataBody;
}