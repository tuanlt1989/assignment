# 07 — AdMob: xử lý lỗi đăng ký & cách bật quảng cáo (không bắt buộc)

**Hiện tại cả 10 app đều đặt `"ads": false`, tức chỉ bán gói và không cần AdMob.** Khi tắt quảng cáo:
- App không khởi động thư viện quảng cáo và không hiện form đồng ý quảng cáo (consent).
- Người dùng miễn phí thấy màn hình **Mở khoá** sau mỗi 2 lượt làm bài, thay cho quảng cáo xen kẽ.
- Công cụ `tool/factory.py` tự **gỡ quyền Advertising ID** (`AD_ID`) khỏi app và viết trang chính sách bảo mật thành "không quảng cáo, không theo dõi".
- Trong Play Console khai báo như sau:
  - **Ads: No**
  - **Advertising ID: No**
  - **Data safety: "No data collected"**, vì dữ liệu học chỉ lưu trên máy, còn thanh toán do Google Play xử lý.

Vì vậy **bạn có thể phát hành ngay mà không cần AdMob.** Khi tài khoản AdMob đã chạy được, bật lại theo mục C.

## A. Các lỗi đăng ký AdMob hay gặp và cách xử lý

| Lỗi / hiện tượng | Cách xử lý |
|---|---|
| Form đăng ký báo lỗi hoặc không cho bấm tiếp | Dùng **Gmail cá nhân** (không dùng email Google Workspace của công ty). Tắt VPN. Dùng Chrome ẩn danh. Chọn **Quốc gia: Việt Nam** và **múi giờ đúng**, vì 2 mục này **không đổi được sau khi tạo**. |
| "You already have an AdSense/AdMob account" | Mỗi người chỉ được có **1 tài khoản AdSense**, dùng chung cho AdMob. Đăng nhập đúng Gmail đã có AdSense, hoặc đóng tài khoản AdSense cũ trước. |
| Tài khoản bị từ chối hoặc vô hiệu (disapproved / disabled) | Thường do tài khoản AdSense cũ từng vi phạm, hoặc thông tin trùng với tài khoản đã bị khoá. Bạn chỉ được gửi **kháng nghị (appeal)** 1 lần, và không nên tạo tài khoản mới để lách vì sẽ bị khoá tiếp. |
| "Your account is being reviewed" / quảng cáo bị giới hạn | Tài khoản mới được xét duyệt trong vài ngày đến khoảng 2 tuần. App nên đã có trên Play và có file **app-ads.txt**, xem mục C. |
| Không thêm được app vì app chưa có trên Play | Khi thêm app, chọn "**No, the app is not listed on a supported app store**". Sau khi app lên Play thì liên kết lại. |
| Lỗi xác minh địa chỉ (PIN) hoặc thanh toán | Google gửi mã PIN qua bưu điện khi thu nhập đạt ngưỡng xác minh. Tên người nhận tiền phải khớp với tên chủ tài khoản ngân hàng. |

👉 **Gửi mình ảnh chụp chính xác dòng báo lỗi** (bằng tiếng Anh hoặc tiếng Việt), mình sẽ chỉ cách sửa cụ thể.

## B. Phương án khác nếu AdMob vẫn không được

- **Chỉ bán gói**: cấu hình hiện tại. Với app luyện thi, doanh thu chủ yếu đến từ việc người dùng mua gói.
- Mạng quảng cáo khác (cần sửa code, chỉ làm khi thật sự cần):
  - AppLovin MAX
  - Unity LevelPlay
  - Pangle (của ByteDance), dễ duyệt cho tài khoản ở châu Á

## C. Bật quảng cáo AdMob cho một app

1. Trong AdMob, vào **Apps → Add app → Android**, rồi tạo 2 ad unit: **Banner** và **Interstitial**.
2. Sửa file `apps/<id>.json`:
   ```json
   "ads": true,
   "admob": {
     "appId": "ca-app-pub-XXXXXXXX~YYYYYYYY",
     "banner": "ca-app-pub-XXXXXXXX/1111111111",
     "interstitial": "ca-app-pub-XXXXXXXX/2222222222"
   }
   ```
3. Chạy `python3 tool/factory.py --release`. Lệnh phải báo `ok`. Sau đó commit, push và upload AAB mới.
4. Trong Play Console, đổi khai báo sang **Ads: Yes**, **Advertising ID: Yes** và cập nhật **Data safety** theo mục E của `docs/02`.
5. Đặt file **app-ads.txt** ở website ghi trong mục Store settings, rồi tạo **GDPR message** trong AdMob → Privacy & messaging.
