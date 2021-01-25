class MemoryData{
  int memoryId;
  String memoryTitle;
  String imagePath;
  int publicFlag;
  int goodNum;
  String categoryName;
  List<String> withPeople;
  String memoryAddress;
  DateTime notificationDate;
  double memoryLatitude;
  double memoryLongitude;
  List<String> videos;
  List<String> pictures;
  String userName;
  String userProfile;
  DateTime scheduledDate;

  MemoryData(
      this.memoryId,
      this.memoryTitle,
      this.imagePath,
      this.publicFlag,
      this.goodNum,
      this.categoryName,
      this.withPeople,
      this.memoryAddress,
      this.notificationDate,
      this.memoryLatitude,
      this.memoryLongitude,
      this.videos,
      this.pictures,
      this.userName,
      this.userProfile,
      this.scheduledDate
  );

}