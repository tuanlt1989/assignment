# Cozy Merge (khung dự án Godot 4.3)

Game idle/merge cozy cho Android. Đây là **khung** để thử vòng chơi, chưa có art, âm thanh hay SDK thật.

## Đã có
- Bàn ghép 5x6: bấm "Thêm vật phẩm" (10 vàng), chạm 2 ô cùng cấp để ghép (tối đa cấp 10).
- Idle: vàng/giây = tổng (cấp²) các vật phẩm; thu nhập offline tối đa 4 giờ.
- Lưu local (`user://save.json`), tự lưu khi ghép/thoát/tạm dừng.
- `Monetization` autoload: **stub** cho quảng cáo rewarded và IAP (starter 4,99$, 9,99$, 19,99$, 49,99$, remove ads). Hiện cấp thưởng giả lập.

## Đợt polish 1
- 10 loài cá vẽ bằng code (`scripts/item_view.gd`): bơi nhấp nhô, vẫy đuôi, chớp mắt; cấp 5+ có sao, cấp 8+ có vương miện và hào quang.
- Ghép: nảy, hạt nổ, chữ bay, rung máy; loài mới hiện banner. Chạm ô trống để di chuyển cá.
- Ô cùng cấp được viền vàng khi chọn; để yên 4 giây sẽ gợi ý một cặp ghép.
- HUD vàng đếm số mượt, bong bóng nền, nút 3D, popup thu nhập offline (x2 qua quảng cáo), cửa hàng.
- Âm thanh: thả file `.ogg` vào `audio/` (xem `audio/README.txt`), chưa có file thì game vẫn chạy.
- Rung máy trên Android cần bật quyền **VIBRATE** trong Export preset.

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
