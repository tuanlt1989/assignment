# Cozy Merge (khung dự án Godot 4.3)

Game idle/merge cozy cho Android. Đây là **khung** để thử vòng chơi, chưa có art, âm thanh hay SDK thật.

## Đã có
- Bàn ghép 5x6: bấm "Thêm vật phẩm" (10 vàng), chạm 2 ô cùng cấp để ghép (tối đa cấp 10).
- Idle: vàng/giây = tổng (cấp²) các vật phẩm; thu nhập offline tối đa 4 giờ.
- Lưu local (`user://save.json`), tự lưu khi ghép/thoát/tạm dừng.
- `Monetization` autoload: **stub** cho quảng cáo rewarded và IAP (starter 4,99$, 9,99$, 19,99$, 49,99$, remove ads). Hiện cấp thưởng giả lập.

## Chạy thử
Mở thư mục `game/` bằng Godot 4.3+ rồi bấm Play (F5).

## Xuất .aab để thử upload Play Console
1. Godot: *Project → Install Android Build Template*, cài Android SDK + JDK 17, đặt đường dẫn trong *Editor Settings → Export → Android*.
2. Tạo keystore (giữ kỹ, đừng commit):
   `keytool -genkey -v -keystore release.keystore -alias key -keyalg RSA -keysize 2048 -validity 10000`
3. *Project → Export → Add → Android*: bật **Use Gradle Build**, **Export AAB**, đặt `package/unique_name` (ví dụ `com.tenban.cozymerge`) và keystore.
4. Export ra `.aab` rồi upload vào *Testing → Internal testing* để kiểm tra luồng upload.

## Việc tiếp theo
- Thay stub bằng Google Play Billing (plugin GodotGooglePlayBilling) và AdMob/AppLovin.
- Art/mascot, hiệu ứng ghép, âm thanh.
- Starter pack giới hạn lần đầu, season pass, sự kiện theo mùa.
- Đo analytics: giữ chân D1/D7/D30, tỷ lệ trả tiền, ARPPU.
