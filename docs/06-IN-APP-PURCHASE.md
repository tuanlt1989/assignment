# 06 — Cấu hình mua trong app (Google Play Billing) từng bước

Mỗi app bán **1 gói mua một lần** với mã `premium_lifetime`. Gói này mở khoá toàn bộ câu hỏi và cho thi thử không giới hạn; với app có bật quảng cáo thì còn tắt quảng cáo.
Code đã làm sẵn mọi thứ: hiển thị giá theo tiền địa phương, mua, khôi phục khi cài lại, xử lý thanh toán đang chờ, thử lại khi chưa tải được giá. Phần **bạn phải làm là cấu hình trong Play Console**.

> App dùng thư viện `in_app_purchase_android` 0.5.x, bên trong là **Play Billing Library 8**. Đây là phiên bản dùng mô hình "one-time product" mới của Google (có 2025), nên không cần bật chế độ tương thích ngược.

---

## Bước 0 — Hồ sơ thanh toán (payments profile): làm 1 lần

1. Vào Play Console, chọn **Setup → Payments profile** (hoặc làm theo lời nhắc ở phần *Monetize*). Liên kết hoặc tạo **payments profile**.
2. Điền đầy đủ:
   - Tên pháp lý, địa chỉ.
   - **Tài khoản ngân hàng nhận tiền**: tên chủ tài khoản phải khớp với payments profile.
   - **Thông tin thuế**: với người không ở Mỹ, Google thường yêu cầu tờ khai W-8BEN.
3. Google sẽ gửi một khoản tiền nhỏ vào tài khoản ngân hàng để xác minh. Bạn nhập đúng số tiền đó vào Play Console.
4. Kiểm tra danh sách nước được phép bán ứng dụng (*supported locations for merchants*) trong trang trợ giúp Play Console. **Chưa xong payments profile thì không tạo được sản phẩm có giá.**

## Bước 1 — Upload AAB lên kênh Internal testing

Play Console chỉ cho tạo sản phẩm sau khi app đã có một bản build chứa quyền `com.android.vending.BILLING`. Plugin đã tự thêm quyền này.

1. Lấy file AAB đã ký: tải từ GitHub Actions hoặc build trên máy, xem `docs/01`.
2. Vào **Testing → Internal testing → Create new release**, upload AAB, bấm **Save → Review → Start rollout**.
3. Ở tab **Testers**, thêm email Gmail của bạn và copy **link opt-in**. Mở link đó trên điện thoại, bấm *Accept*, rồi cài app **từ Play Store**.

> ⚠️ Mua trong app **chỉ chạy khi app được cài từ Play** (qua link tester). Nếu cài APK bằng tay, app sẽ báo "Cửa hàng tạm thời không khả dụng". Đó là hành vi bình thường.

## Bước 2 — Tạo sản phẩm `premium_lifetime`

1. Vào **Monetize with Play → Products → One-time products → Create one-time product**.
2. Điền thông tin:
   - **Product ID**: `premium_lifetime`. Phải trùng chính xác với `premiumProductId` trong `apps/<id>.json`. **Sau khi tạo thì không đổi được, và cũng không dùng lại được nếu đã xoá.**
   - **Name**: tên hiển thị ở màn hình thanh toán của Google, ví dụ:
     - nailvi: "Mở khoá toàn bộ câu hỏi"
     - sachkunde: "Alle Fragen freischalten"
     - cscsro: "Deblochează toate întrebările"
     - các app tiếng Anh: "Unlock all questions"
   - **Description**: một câu ngắn, ví dụ "All questions and unlimited mock exams. One-time payment."
   - **Tax / compliance category** (nếu được hỏi): Digital content / app features.
3. **Purchase options → Add purchase option**:
   - ID ví dụ `lifetime`, loại **Buy** (mua đứt).
   - Nếu Play Console hỏi "**Backwards compatible**" thì có thể bật cho chắc. App dùng PBL 8 nên không bắt buộc.
4. **Prices → Set prices**:
   - Nhập giá gốc bằng USD (bảng gợi ý bên dưới), Play tự quy đổi sang các nước.
   - Sau đó **sửa tay giá ở các thị trường chính** để có số đẹp và hợp sức mua, ví dụ ₹499, ₱249, €14,99, £7,99.
5. Bấm **Save**, sau đó **Activate**. Purchase option phải ở trạng thái **Active**: ở trạng thái Draft thì app không nhìn thấy sản phẩm.
6. Chờ khoảng 15 phút đến vài giờ để sản phẩm có hiệu lực.

### Bảng giá gợi ý

| App | Giá gốc | Giá chỉnh tay ở thị trường chính |
|---|---|---|
| nailvi, cosmovi | $14.99 | US $14.99 |
| nailes, cosmoes | $12.99 | US $12.99 |
| insurancelh | $19.99 | US $19.99 |
| **nursegulf** | $14.99 | Ấn Độ ₹499–799 · Philippines ₱599 · UAE AED 49.99 · Saudi SAR 49.99 |
| **cscsro / cscspl** | $9.99 | Anh £7.99 |
| **sachkunde** | $14.99 | Đức €14,99 (lệ phí thi ở IHK khoảng €150–240) |
| **civilserviceph** | $4.99 | Philippines ₱199–249 |

Mẹo: sau 2–4 tuần có số liệu thật, dùng **Monetize → Price experiments** để thử A/B giá, ví dụ €9,99 so với €14,99.

## Bước 3 — Mua thử miễn phí (license testing)

1. Vào trang **Settings → License testing** ở cấp tài khoản developer (không phải trong từng app). Thêm email Gmail đang đăng nhập trên điện thoại test và đặt License response là **RESPOND_NORMALLY**.
2. Mở app (cài từ link Internal testing), vào **Mở khoá** và bấm nút mua. Màn hình thanh toán sẽ có các thẻ test như "Test card, always approves".
3. Kiểm tra:
   - [ ] Màn hình Mở khoá hiện giá đúng tiền địa phương.
   - [ ] Mua xong, app báo "Đã mở khoá toàn bộ" và các ổ khoá ở từng chủ đề biến mất.
   - [ ] Thử thẻ "**Slow test card**" để thấy thông báo thanh toán đang chờ. App tự mở khoá khi thanh toán xong.
   - [ ] Gỡ app, cài lại, mở app: quyền mua được **tự khôi phục**. Nếu không, vào Cài đặt và bấm **Khôi phục giao dịch**.
4. Muốn mua thử lại thì vào **Order management**, chọn đơn test rồi **Refund** và tick **Remove entitlement**.

## Bước 4 — Phát hành

- Làm tiếp closed testing nếu dùng tài khoản cá nhân, rồi lên Production theo `docs/02`.
- Ở **Production → Countries/regions**, chọn đúng thị trường của từng app. Danh sách gợi ý nằm trong trường `markets` của `apps/<id>.json`.
- **Promo codes** (Monetize → Promo codes): tặng mã cho trường dạy nghề, KOL hoặc nhóm cộng đồng. Đây là kênh kéo người dùng rất hiệu quả.

---

## Sửa lỗi thường gặp

| Hiện tượng | Nguyên nhân và cách sửa |
|---|---|
| App báo "Cửa hàng tạm thời không khả dụng" | App không được cài từ Play, hoặc tài khoản trên máy chưa opt-in làm tester. Cài lại bằng link Internal testing. |
| Không hiện giá, nút mua bị mờ | Sản phẩm chưa Active, Product ID sai (phải là `premium_lifetime`), sản phẩm mới tạo (chờ vài giờ), hoặc chưa có payments profile. Bấm **Thử lại** trên màn hình Mở khoá. |
| "This version of the application is not configured for billing" | `applicationId` hoặc versionCode trên máy khác với bản đã upload, hoặc app được ký bằng khoá debug. Cài đúng bản từ Play. |
| "Item not available for purchase" | Quốc gia của tài khoản Google không nằm trong danh sách được phát hành, hoặc sản phẩm chưa có giá cho nước đó. |
| Mua xong nhưng chưa mở khoá | Thanh toán đang chờ (pending). Đợi xong rồi mở lại app, hoặc bấm Khôi phục giao dịch. |
| Bị hoàn tiền sau 3 ngày | Code đã tự gọi `completePurchase` (acknowledge). Nếu vẫn bị hoàn, kiểm tra lại xem bản đang chạy có đúng code mới nhất không. |

## (Tuỳ chọn) Nâng cấp sau này

- **Xác minh giao dịch phía server** bằng Google Play Developer API để chống crack. Chỉ cần làm khi doanh thu đã lớn.
- **Thêm gói thuê bao** (ví dụ 1 tháng $4.99) bên cạnh gói trọn đời. Muốn vậy phải thêm logic kiểm tra gói còn hạn, nên tạm thời chưa làm.
