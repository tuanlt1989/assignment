# 09 — Tự động đưa app lên Google Play (bấm 1 nút)

Sau khi cài đặt một lần, mỗi lần muốn cập nhật app bạn chỉ cần vào **GitHub → Actions → Publish to Google Play → Run workflow**, hoặc nhắn Claude "up nailvi lên internal". Workflow sẽ tự:

1. Build file AAB đã ký cho từng app bạn chọn (một app, nhiều app, hoặc `all` cho cả 15).
2. Upload lên kênh bạn chọn: internal, closed (`alpha`), open (`beta`) hoặc production.
3. Upload trang cửa hàng: tiêu đề, mô tả, icon, feature graphic và ảnh màn hình cho mọi ngôn ngữ trong `store/<id>/`.
4. Tạo hoặc cập nhật gói `premium_lifetime` kèm giá USD gợi ý; Play tự quy đổi sang tiền các nước. Phần này tuỳ chọn.

Workflow dùng **API chính thức của Google** (Google Play Developer API) qua một *service account*. Nó **không đăng nhập bằng mật khẩu Gmail của bạn**. Dùng bot đăng nhập web Play Console bằng mật khẩu sẽ gặp 2 vấn đề: Google chặn đăng nhập tự động và xác minh 2 bước, và có rủi ro bị khoá tài khoản developer. Service account thì an toàn hơn: chỉ được quyền bạn cấp, và bạn thu hồi lúc nào cũng được.

## Những việc Google bắt buộc làm tay (một lần cho mỗi app)

API không làm được các việc sau:
- Tạo tài khoản developer, xác minh danh tính, hồ sơ thanh toán (`docs/08` bước 1–2).
- **Tạo app** trong Play Console (`docs/08` bước 6).
- **Upload bản AAB đầu tiên bằng tay** lên Internal testing. Lấy file từ artifact của CI.
- Khai báo **App content**: chính sách bảo mật, quảng cáo, phân loại độ tuổi, đối tượng, an toàn dữ liệu (`docs/08` bước 7).
- Chạy thử kín 12 người × 14 ngày rồi xin lên production (nếu là tài khoản cá nhân).

Từ lần thứ 2 trở đi, mọi việc upload đều làm bằng workflow.

---

## Cài đặt một lần (khoảng 15 phút)

### Bước 1 — Tạo service account trên Google Cloud

1. Mở <https://console.cloud.google.com/>, đăng nhập bằng Gmail dùng cho Play Console. Tạo project mới, ví dụ `play-publisher`.
2. Vào **APIs & Services → Library**, tìm **Google Play Android Developer API** và bấm **Enable**.
3. Vào **IAM & Admin → Service Accounts → Create service account**:
   - Tên: `github-publisher`. Bấm **Create and continue**, bỏ qua bước cấp role, rồi **Done**.
4. Bấm vào service account vừa tạo → tab **Keys** → **Add key → Create new key → JSON**. Một file `.json` sẽ được tải về.
   - ⚠️ File này giống mật khẩu: **không gửi cho ai và không commit lên git**.
5. Chép **email** của service account, có dạng `github-publisher@play-publisher.iam.gserviceaccount.com`.

### Bước 2 — Cấp quyền trong Play Console

1. Vào Play Console → **Users and permissions → Invite new users**.
2. Dán email của service account.
3. Cấp quyền: cách đơn giản nhất là tab **Account permissions → Admin (all permissions)**. Nếu muốn ít quyền hơn, tick tối thiểu:
   - **Release apps to testing tracks** và **Release to production, exclude devices, and use Play App Signing**
   - **Manage store presence** (trang cửa hàng)
   - **Manage store presence** của phần sản phẩm trong app / **Manage orders and subscriptions** (tên menu có thể khác theo thời điểm)
4. Bấm **Invite user**. Service account không cần chấp nhận lời mời.
5. Nếu Play Console còn trang **Setup → API access**, hãy liên kết project Google Cloud ở bước 1 tại đó. Tài khoản mới thường không cần bước này.

> Quyền có thể mất vài phút đến vài giờ mới có hiệu lực. Nếu lần chạy đầu báo `permission`, đợi một lúc rồi chạy lại.

### Bước 3 — Thêm secret vào GitHub

1. Mở <https://github.com/tuanlt1989/assignment/settings/secrets/actions> → **New repository secret**.
2. Name: `PLAY_SERVICE_ACCOUNT_JSON`. Value: dán **toàn bộ nội dung** file `.json` ở bước 1.
3. Kiểm tra đã có đủ 4 secret khoá ký từ `docs/01`: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Workflow sẽ dừng nếu thiếu, vì Play từ chối bản ký debug.

### Bước 4 — Làm phần bắt buộc bằng tay cho từng app

Làm theo `docs/08` các bước 6–7 và upload AAB đầu tiên ở bước 9: tải artifact `nailvi-buildN` trong tab **Actions → Android build**.

---

## Dùng hằng ngày

**Actions → Publish to Google Play → Run workflow**, rồi điền:

| Ô | Ý nghĩa | Gợi ý |
|---|---|---|
| apps | `nailvi` / `nailvi,cosmovi` / `all` | |
| track | `internal`, `alpha` (closed test), `beta` (open), `production` | thử trước ở `internal` |
| status | `draft`: bạn tự vào Play Console bấm *Roll out*. `completed`: phát hành luôn | để `draft` cho đến khi quen |
| bundle | build và upload bản mới | ✓ |
| listing | upload chữ và ảnh cửa hàng | ✓ khi đã sửa `store/` |
| product | tạo hoặc cập nhật `premium_lifetime` | ✓ một lần đầu, sau đó chỉ bật khi đổi giá |
| notes | ghi chú phiên bản (tiếng Anh) | |

- Với app chưa từng phát hành, Google chỉ nhận bản `draft`. Script tự chuyển sang `draft` nếu gặp trường hợp này.
- `versionCode` tự tăng theo thời gian (số phút kể từ 1/1/2026). Bản build sau luôn có versionCode lớn hơn bản trước, kể cả khi build từ workflow `Android build`.

### Chạy trên máy của bạn (không bắt buộc)

```bash
pip install google-api-python-client google-auth
export PLAY_SERVICE_ACCOUNT_JSON="$(cat ~/Downloads/play-publisher-xxxx.json)"
python3 tool/play_publish.py --app nailvi --listing --dry-run        # chỉ kiểm tra, không gửi gì
python3 tool/play_publish.py --app nailvi --aab path/to/app.aab --track internal
python3 tool/play_publish.py --app nailvi --product                   # tạo gói premium_lifetime
```

## Lỗi hay gặp

| Lỗi | Cách xử lý |
|---|---|
| `Package not found` | App chưa được tạo trong Play Console, hoặc chưa upload tay bản đầu tiên (bước 4). |
| `The caller does not have permission` | Service account chưa được mời, hoặc chưa được cấp quyền cho app này (bước 2). Đợi vài phút rồi chạy lại. |
| `Only releases with status draft may be created on draft app` | Script tự xử lý: release được lưu ở dạng draft. |
| `APK specifies a version code that has already been used` | Chạy lại workflow; versionCode mới sẽ lớn hơn. |
| Lỗi khi tạo product | Hồ sơ thanh toán chưa xong, hoặc API sản phẩm của Google thay đổi. Tạo `premium_lifetime` bằng tay theo `docs/06`; phần bundle và listing vẫn chạy bình thường. |
