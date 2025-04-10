class RegisterResponse {
  String? sId;
  String? userid;
  String? fullname;
  String? mobile;
  String? email;
  String? longitude;
  String? latitude;
  String? area;
  String? flat;
  String? address;
  String? state;
  String? city;
  String? pincode;
  bool? kycStatus;
  bool? orderStatus;
  String? onBoardingDate;
  List<DeviceResponse>? devices;
  String? refferid;
  String? customerId;
  String? role;
  int? iV;

  RegisterResponse(
      {this.sId,
        this.userid,
        this.fullname,
        this.mobile,
        this.email,
        this.longitude,
        this.latitude,
        this.area,
        this.flat,
        this.address,
        this.state,
        this.city,
        this.pincode,
        this.kycStatus,
        this.orderStatus,
        this.onBoardingDate,
        this.devices,
        this.refferid,
        this.customerId,
        this.role,
        this.iV});

  RegisterResponse.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userid = json['userid'];
    fullname = json['Fullname'];
    mobile = json['mobile'];
    email = json['email'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    area = json['area'];
    flat = json['flat'];
    address = json['address'];
    state = json['state'];
    city = json['city'];
    pincode = json['pincode'];
    kycStatus = json['kycStatus'];
    orderStatus = json['orderStatus'];
    onBoardingDate = json['onBoardingDate'];
    if (json['devices'] != null) {
      devices = <DeviceResponse>[];
      json['devices'].forEach((v) {
        devices!.add(new DeviceResponse.fromJson(v));
      });
    }
    refferid = json['refferid'];
    customerId = json['customer_id'];
    role = json['role'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userid'] = this.userid;
    data['Fullname'] = this.fullname;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['area'] = this.area;
    data['flat'] = this.flat;
    data['address'] = this.address;
    data['state'] = this.state;
    data['city'] = this.city;
    data['pincode'] = this.pincode;
    data['kycStatus'] = this.kycStatus;
    data['orderStatus'] = this.orderStatus;
    data['onBoardingDate'] = this.onBoardingDate;
    if (this.devices != null) {
      data['devices'] = this.devices!.map((v) => v.toJson()).toList();
    }
    data['refferid'] = this.refferid;
    data['customer_id'] = this.customerId;
    data['role'] = this.role;
    data['__v'] = this.iV;
    return data;
  }
}
class DeviceResponse {
  String? sId;
  String? userid;
  String? fullname;
  String? mobile;
  String? email;
  String? longitude;
  String? latitude;
  String? area;
  String? flat;
  String? address;
  String? state;
  String? city;
  String? pincode;
  String? status;
  String? orderingDate;
  String? appointmentDate;
  String? model;
  int? planYear;
  String? paymentId;
  int? paymentAmount;
  bool? isKycNeede;
  int? iV;

  DeviceResponse(
      {this.sId,
        this.userid,
        this.fullname,
        this.mobile,
        this.email,
        this.longitude,
        this.latitude,
        this.area,
        this.flat,
        this.address,
        this.state,
        this.city,
        this.pincode,
        this.status,
        this.orderingDate,
        this.appointmentDate,
        this.model,
        this.planYear,
        this.paymentId,
        this.paymentAmount,
        this.isKycNeede,
        this.iV});

  DeviceResponse.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userid = json['userid'];
    fullname = json['Fullname'];
    mobile = json['mobile'];
    email = json['email'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    area = json['area'];
    flat = json['flat'];
    address = json['address'];
    state = json['state'];
    city = json['city'];
    pincode = json['pincode'];
    status = json['Status'];
    orderingDate = json['orderingDate'];
    appointmentDate = json['appointmentDate'];
    model = json['model'];
    planYear = json['plan_year'];
    paymentId = json['paymentId'];
    paymentAmount = json['payment_amount'];
    isKycNeede = json['is_kyc_neede'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userid'] = userid;
    data['Fullname'] = fullname;
    data['mobile'] = mobile;
    data['email'] = email;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['area'] = area;
    data['flat'] = flat;
    data['address'] = address;
    data['state'] = state;
    data['city'] = city;
    data['pincode'] = pincode;
    data['Status'] = status;
    data['orderingDate'] = orderingDate;
    data['appointmentDate'] = appointmentDate;
    data['model'] = model;
    data['plan_year'] = planYear;
    data['paymentId'] = paymentId;
    data['payment_amount'] = paymentAmount;
    data['is_kyc_neede'] = isKycNeede;
    data['__v'] = iV;
    return data;
  }
}