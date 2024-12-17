class NotificationController {
  int notificationCount = 0; // Biến lưu số thông báo

  /// Hàm tăng số thông báo
  void incrementNotification() {
    notificationCount++;
  }

  /// Hàm lấy số lượng thông báo hiện tại
  int getNotificationCount() {
    return notificationCount;
  }
}
