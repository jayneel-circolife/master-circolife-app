class UserDetails {
  String? uId;
  String? fullname;
  String? mobile;
  String? email;
  String? userid;
  String? longitude;
  String? latitude;
  String? city;
  bool? iskycdone;
  bool? orderStatus;
  String? profileimage;

  UserDetails(
      {this.uId,
      this.fullname,
      this.mobile,
      this.email,
      this.userid,
      this.longitude,
      this.latitude,
      this.city,
      this.iskycdone,
      this.orderStatus,
      this.profileimage,
      //required UserDetails userDetails
      });

  UserDetails.fromJson(Map<String, dynamic> json) {
    uId = json['_id'];
    fullname = json['Fullname'];
    mobile = json['mobile'];
    email = json['email'];
    userid = json['userid'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    city = json['city'];
    iskycdone = json['kycStatus'];
    orderStatus = json['orderStatus'];
    profileimage = json['profileimage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = uId;
    data['Fullname'] = fullname;
    data['mobile'] = mobile;
    data['email'] = email;
    data['userid'] = userid;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['city'] = city;
    data['kycStatus'] = iskycdone;
    data['orderStatus'] = orderStatus;
    data['profileimage'] = profileimage;
    return data;
  }
}
