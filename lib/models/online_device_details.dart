class OnlineDeviceDetails {
  String? did;
  String? userid;
  String? deviceid;
  String? deviceName;
  String? deviceType;
  bool? isShared;
  bool? isadmin;
  String? receiversid;
  String? sendersName;
  String? receiversName;
  String? receiversNumber;
  String? receiversImage;
  String? sendersImage;
  bool? isSelfCleanOn;
  bool isOnline = false;

  OnlineDeviceDetails(
      {this.did,
        this.userid,
        this.deviceid,
        this.deviceName,
        this.deviceType,
        this.isShared,
        this.isadmin,
        this.receiversName,
        this.receiversid,
        this.sendersName,
        this.receiversNumber,
        this.receiversImage,
        this.sendersImage,
        this.isSelfCleanOn,
        this.isOnline = false,
        required OnlineDeviceDetails addressDetails});

  OnlineDeviceDetails.fromJson(Map<String, dynamic> json) {
    did = json['_id'];
    userid = json['userid'];
    deviceName = json['deviceName'];
    deviceType = json['deviceType'];
    deviceid = json['deviceid'];
    isShared = json['isShared'];
    isadmin = json['isadmin'];
    receiversName = json['receiversName'];
    receiversid = json['receiversid'];
    sendersName = json['sendersName'];
    receiversNumber = json['receiversNumber'];
    receiversImage = json['receiversImage'];
    sendersImage = json['sendersImage'];
    isSelfCleanOn = json['isSelfCleanOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = did;
    data['userid'] = userid;
    data['deviceName'] = deviceName;
    data['deviceType'] = deviceType;
    data['deviceid'] = deviceid;
    data['isShared'] = isShared;
    data['isadmin'] = isadmin;
    data['receiversName'] = receiversName;
    data['receiversid'] = receiversid;
    data['sendersName'] = sendersName;
    data['receiversNumber'] = receiversNumber;
    data['receiversImage'] = receiversImage;
    data['sendersImage'] = sendersImage;
    data['isSelfCleanOn'] = isSelfCleanOn;
    return data;
  }
}
