import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/whatsapp.dart';

class SendPDF {
  final String accessToken =
      'EAAMLzrSztE0BOZBCVx5nFQQfCj5ZB8x6aPa62VeX9wjUjJ3sZCrZC05jO2ZCluSZCJD6vaa9GfQZCQBrJvt37cJ1SY6n3zSeR5pQ2d1U8pnf5LVpjZBjwZBpFhpBW07FuSbbEokP4e8osTkpL2dZClfUV8GkGY5ZC4UG1uI8sZAKnJBQgJzCqvSdTrHmRVWM2MnhizoZCArmsgGKkhyMk1gKTUygZD';
  final String phoneNumberId = '372942749237947';
  static final SendPDF _instance = SendPDF._();
  static WhatsApp? _whatsApp;

  SendPDF._();

  factory SendPDF() {
    return _instance;
  }

  WhatsApp get wa {
    if (_whatsApp != null) {
      return _whatsApp!;
    }
    _whatsApp = WhatsApp(accessToken, phoneNumberId);
    return _whatsApp!;
  }

  sendPDF(File file, String phoneNumber) async {
    print('SendPDF called');
    var client = wa;
    var uploadMediaFile =
        await client.uploadMediaFile(file: file, fileType: "application/pdf");
    if (uploadMediaFile.isSuccess()) {
      String? mediaID = uploadMediaFile.mediaId;
      sendPDFWithMediaId(mediaID, phoneNumber);
    } else {
      print(
          'media upload failed Status: ${uploadMediaFile.httpCode}, ErrorMessage: ${uploadMediaFile.errorMessage}, Error: ${uploadMediaFile.error}');
    }
    print('SendPDF call completed');
  }

  sendPDFWithMediaId(String? mediaId, String phoneNumber) async {
    var client = wa;
    var res = await wa.sendTemplate(
        phoneNumber: phoneNumber, template: 'hello_world', language: 'en_US');
    print('Successfully sent. Code: ${res.httpCode}, ${res.response}');
    // print('Media ID: $mediaId, phoneNumber: 91$phoneNumber');
    // if (mediaId != null && mediaId.isNotEmpty) {
    //   var client = wa;
    //   var res = await client.sendDocumentById(phoneNumber: '91$phoneNumber', mediaId: mediaId);
    //   if(res.isSuccess()){
    //     print('Successfully sent. Code: ${res.httpCode}, ${res.response}');
    //   }else{
    //     print('media upload failed Status: ${res.httpCode}, ErrorMessage: ${res.errorMessage}, Error: ${res.error}');
    //
    //   }
    // }else{
    //   print('MediaId is null or empty');
    // }
  }

  launchWhatsappWithMobileNumber(String phoneNumber, String message) async {
    // final url = "whatsapp://send?phone=$phoneNumber&text=$message";
    final url = "whatsapp://send?phone=$phoneNumber&text=$message";
    if (await canLaunchUrl(Uri.parse(Uri.encodeFull(url)))) {
      await launchUrl(Uri.parse(Uri.encodeFull(url)));
    } else {
      throw 'Could not launch $url';
    }
  }
}
