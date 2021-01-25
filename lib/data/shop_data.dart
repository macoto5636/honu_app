//お店のデータ
class ShopData{
  int shopId;
  String shopName;
  String categoryName;
  DateTime openTime;
  DateTime closeTime;
  String holiday;
  String shopTel;
  String address;
  double latitude;
  double longitude;
  String image;
  String detail;

  ShopData(this.shopId,this.shopName,this.categoryName,this.openTime,this.closeTime,this.holiday,this.shopTel,this.address,this.latitude,this.longitude,this.image,this.detail);
}