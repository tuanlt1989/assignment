# 08 — Đưa app đầu tiên (`nailvi`) lên Google Play: làm theo từng cú bấm

Tài liệu này đi **một app cụ thể từ đầu đến cuối**: Luyện Thi Nail Tiếng Việt (`nailvi`).
Làm xong app này thì 14 app còn lại chỉ lặp lại từ bước 5 (mỗi app khoảng 30–45 phút).
`docs/02-LAUNCH-CHECKLIST.md` là bản tóm tắt; tài liệu này là bản chi tiết. Viết tháng 10/2026. Giao diện Play Console có thể đổi tên menu, nhưng thứ tự các bước giữ nguyên.

Thời gian tổng cộng (tài khoản cá nhân): khoảng **1 buổi làm** + **14 ngày chạy thử kín** + 1–7 ngày Google duyệt.

---

## Bước 1 — Tạo tài khoản Google Play Console (1 lần)

1. Mở <https://play.google.com/console/signup> bằng Gmail bạn muốn dùng lâu dài. Nên dùng Gmail riêng cho công việc, bật xác minh 2 bước.
2. Chọn loại tài khoản:
   - **Yourself (cá nhân)**: nhanh, chỉ cần CCCD/hộ chiếu. Mỗi app mới phải chạy **closed test ≥12 người × 14 ngày** trước khi lên production.
   - **An organization (tổ chức)**: cần công ty + số **D-U-N-S**, nhưng **không** phải chạy 12 người × 14 ngày. Nên chuyển sang loại này khi đã có vài app ra tiền.
3. Trả phí **$25** (một lần, dùng thẻ Visa/Master quốc tế).
4. Xác minh danh tính: chụp giấy tờ, điền địa chỉ trùng với giấy tờ. Google duyệt trong vài giờ đến vài ngày.
5. Xác minh **có điện thoại Android thật**: cài app **Google Play Console** trên điện thoại Android, đăng nhập cùng Gmail. Play Console sẽ yêu cầu bước này với tài khoản mới.
6. Xác minh số điện thoại và email liên hệ.

## Bước 2 — Hồ sơ thanh toán để nhận tiền (1 lần)

**Setup → Payments profile** (hoặc menu *Monetize* sẽ nhắc). Làm đúng theo `docs/06-IN-APP-PURCHASE.md` bước 0:
tên pháp lý, địa chỉ, tài khoản ngân hàng (tên chủ tài khoản trùng tên hồ sơ), thông tin thuế (người Việt Nam: khai W-8BEN, chọn không phải công dân Mỹ).
Chưa xong bước này thì **không tạo được sản phẩm có giá** ở bước 9.

## Bước 3 — Sửa thông tin cá nhân trong cấu hình (1 lần cho cả 15 app)

Trong **mọi** file `apps/*.json` và `games/apps/*.json`:

| Trường | Hiện tại | Đổi thành |
|---|---|---|
| `developerName` | `CHANGE_ME` | Tên hiện trên Play, ví dụ `Tuan LT Apps` |
| `supportEmail` | `CHANGE_ME@example.com` | Email hỗ trợ (hiện công khai) |
| `applicationId` | `com.tuanapps.nailvi` | Đã đặt sẵn. Sau lần upload đầu tiên thì không đổi được nữa. |

Lệnh đổi nhanh cho cả 15 file (thay giá trị của bạn):

```bash
sed -i 's/"developerName": "CHANGE_ME"/"developerName": "Tuan LT Apps"/; s/CHANGE_ME@example.com/ban@gmail.com/' apps/*.json games/apps/*.json
python3 tool/factory.py && python3 tool/factory.py --root games
git commit -am "Set developer name and support email" && git push origin main:exam-prep-apps
```

## Bước 4 — Bật trang Chính sách bảo mật (1 lần, miễn phí)

Repo `tuanlt1989/assignment` đang public, nên dùng GitHub Pages:

1. Mở <https://github.com/tuanlt1989/assignment/settings/pages>.
2. **Source**: *Deploy from a branch*. **Branch**: `exam-prep-apps`, thư mục **`/docs`** → **Save**.
3. Chờ 1–3 phút, mở thử <https://tuanlt1989.github.io/assignment/privacy/nailvi.html> trên điện thoại.

Cả 15 app đã được cấu hình sẵn URL dạng `https://tuanlt1989.github.io/assignment/privacy/<id>.html`. Trang này cũng nằm trong mục *Cài đặt* của từng app.

## Bước 5 — Lấy file AAB đã ký

1. Cài 4 secrets khoá ký vào GitHub (đã gửi bạn file `SIGNING-SECRETS.txt` + `upload-keystore.jks`):
   <https://github.com/tuanlt1989/assignment/settings/secrets/actions> → **New repository secret**, tạo đúng 4 tên:
   `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
2. Push một commit bất kỳ (hoặc vào tab **Actions → Android build → Run workflow**, chọn branch `exam-prep-apps`).
3. Chờ lần chạy có dấu ✅ → kéo xuống **Artifacts** → tải `nailvi-buildN` → giải nén, lấy `app-nailvi-release.aab`.
4. Kiểm tra log bước *Release signing* phải ghi `Signing with the upload key.` Nếu thấy cảnh báo *debug-signed* thì secrets chưa đúng, Play sẽ từ chối file.

> ⚠️ Cất **file .jks + mật khẩu** ở 2 nơi an toàn (ví dụ Google Drive riêng + USB). Mất khoá upload vẫn xin Google reset được, nhưng mất vài ngày.

## Bước 6 — Tạo app trong Play Console

1. **Home → Create app**:
   - **App name**: `Nail Exam Prep (Vietnamese)` (lấy từ `store/nailvi/metadata/android/en-US/title.txt`).
   - **Default language**: English (United States) – en-US.
   - **App or game**: App. **Free or paid**: **Free** (tiền đến từ gói mua trong app).
   - Tích 2 ô cam kết (Developer Program Policies, US export laws) → **Create app**.
2. Mở **Dashboard**, kéo xuống mục *Set up your app*. Làm lần lượt các mục dưới đây.

## Bước 7 — Khai báo nội dung app (App content)

Trả lời **đúng như sau** cho `nailvi` (và mọi app luyện thi, vì đều `"ads": false`):

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/nailvi.html` |
| App access | *All functionality in my app is available without any access restrictions* |
| Ads | **No, my app does not contain ads** |
| Content rating | Làm bảng hỏi IARC: email của bạn, category **Reference, News, or Educational**, trả lời **No** mọi câu về bạo lực, tình dục, ngôn ngữ, chất cấm, cờ bạc, tương tác người dùng, chia sẻ vị trí. Câu "mua hàng kỹ thuật số": **Yes**. Kết quả thường là **Everyone / PEGI 3**. |
| Target audience | **18 and over** (chỉ chọn nhóm này). App có hấp dẫn trẻ em không: **No**. |
| News app | No |
| Data safety | **Does your app collect or share any of the required user data types? → No.** Phần mã hoá và xoá dữ liệu sẽ tự ẩn. Lý do: tiến độ học chỉ lưu trên máy; thanh toán do Google Play xử lý. |
| Government app | No |
| Financial features | *My app doesn't provide any financial features* |
| Health | *My app does not have any health features* (kể cả `nursegulf`: app chỉ để ôn thi) |
| Advertising ID | **No** (factory đã gỡ quyền `AD_ID` khỏi mọi app không quảng cáo) |

**Với 5 game** (`games/`): giống bảng trên, chỉ khác:
- Category trong content rating: **Game → Puzzle** (Word Weave: **Word**).
- Target audience: chọn **13–15, 16–17, 18+** (không chọn dưới 13 để tránh chính sách Families). App có hấp dẫn trẻ em: **No**.

## Bước 8 — Trang cửa hàng (Store listing)

1. **Grow users → Store presence → Store settings**:
   - App category: **Education** (game: **Puzzle**).
   - Email: email hỗ trợ ở bước 3. Website: có thể để trống.
2. **Main store listing** — lấy file trong `store/nailvi/metadata/android/en-US/`:
   - App name ← `title.txt`, Short description ← `short_description.txt`, Full description ← `full_description.txt`.
   - App icon ← `images/icon.png` (512×512). Feature graphic ← `images/featureGraphic.png` (1024×500).
   - Phone screenshots ← `images/phoneScreenshots/1.png` … `4.png`.
   - **Save**.
3. **Manage translations → Add your own translations → Vietnamese – vi**: dán `title`, `short_description`, `full_description` và ảnh từ `store/nailvi/metadata/android/vi/`.
   Người dùng đặt điện thoại tiếng Việt sẽ thấy bản tiếng Việt; người đặt tiếng Anh thấy "Nail Exam Prep (Vietnamese)".

| App | Locale cần thêm bản dịch |
|---|---|
| `nailvi`, `cosmovi` | vi |
| `nailes`, `cosmoes` | es-US |
| `cscsro` | ro |
| `cscspl` | pl-PL |
| `sachkunde` | de-DE |
| 5 game | es-419, pt-BR, vi, id, de-DE, ja-JP |

## Bước 9 — Bản thử nội bộ + tạo gói mua

1. **Test and release → Testing → Internal testing → Create new release**.
   - Lần đầu Play hỏi về **Play App Signing** → để mặc định (*Google manages and protects your app signing key*). Khoá trong `.jks` của bạn trở thành *upload key*.
   - Upload `app-nailvi-release.aab`. Release name tự điền. Release notes: `Phiên bản đầu tiên`.
   - **Next → Save and publish**.
2. Tab **Testers** → **Create email list** → thêm Gmail của bạn → **Save** → copy **link tham gia** (*Join on the web*).
3. Trên điện thoại: mở link, bấm *Become a tester*, rồi cài app từ Play Store.
4. **Monetize with Play → Products → One-time products → Create one-time product**:
   - Product ID: **`premium_lifetime`** (không đổi được về sau).
   - Name: `Mở khoá toàn bộ câu hỏi`. Description: `Tất cả câu hỏi, thi thử không giới hạn, thẻ ghi nhớ. Trả một lần.`
   - Purchase option: *Buy*, giá **US $14.99** → Play tự quy đổi các nước → **Save → Activate**.
   (Chi tiết + giá gợi ý cho từng app: `docs/06-IN-APP-PURCHASE.md`.)
5. **Setup → License testing** → thêm Gmail của bạn → *License response*: `RESPOND_NORMALLY`. Từ giờ bạn mua thử không mất tiền.

## Bước 10 — Tự kiểm tra trên điện thoại (15 phút)

- [ ] Mở app lần đầu: hiện màn hình chọn **ngày thi → số câu mỗi ngày → kế hoạch + nhắc học** rồi màn hình mở khoá.
- [ ] Trang chủ có chuỗi ngày học, mục tiêu hôm nay, đếm ngược ngày thi và 6 ô: thi thử, 10 câu nhanh, thẻ ghi nhớ, chủ đề yếu nhất, câu sai, câu đã lưu.
- [ ] Chạm câu hỏi tiếng Việt → hiện bản tiếng Anh.
- [ ] Bật nhắc học, đặt giờ sau 2 phút, tắt app → có thông báo.
- [ ] Màn hình mở khoá hiện **giá thật** (không phải "Cửa hàng tạm thời không khả dụng").
- [ ] Mua thử → mọi câu được mở, thi thử đủ 50 câu.
- [ ] Gỡ app, cài lại → **Khôi phục giao dịch** → lại là bản đầy đủ.

## Bước 11 — Chạy thử kín 12 người × 14 ngày (chỉ tài khoản cá nhân)

1. **Testing → Closed testing → Create track** (hoặc dùng track *Alpha* có sẵn) → **Create new release** → **Add from library** chọn AAB đã upload → **Save and publish**.
2. **Countries/regions**: chọn United States + Vietnam (để người quen ở Việt Nam cũng cài được).
3. **Testers**: tạo **Google Group** (<https://groups.google.com>, ví dụ `nail-testers@googlegroups.com`) rồi dán email nhóm vào. Ai tham gia nhóm là thành tester — tiện dùng chung cho **cả 15 app**.
4. Gửi link tham gia cho **ít nhất 15 người** (dư ra phòng người bỏ ngang): bạn bè, người làm nail, nhóm Facebook "Thợ Nail Việt tại Mỹ"… Nhờ họ **giữ app cài trên máy 14 ngày** và mở vài lần.
5. Thu góp ý: tester có thể gửi phản hồi riêng ngay trên trang Play của app. Ghi lại để trả lời câu hỏi ở bước 12.
6. **Mẹo tiết kiệm thời gian**: upload AAB và mở closed test cho **cả 15 app cùng ngày**, dùng chung một Google Group.

## Bước 12 — Xin lên Production và phát hành

1. Sau 14 ngày, Dashboard hiện nút **Apply for production**. Trả lời bảng hỏi:
   - Cách tuyển tester, số người, họ đã dùng tính năng nào.
   - App dành cho ai (người Việt thi bằng nail ở Mỹ), giá trị (song ngữ, thi thử, giải thích).
   - Bạn đã sửa gì sau phản hồi. Viết thật, cụ thể, tiếng Anh đơn giản.
2. Được duyệt (thường 1–7 ngày) → **Production → Countries/regions**: thêm **United States** (`nailes`/`cosmoes` thêm Puerto Rico; các app khác theo trường `markets` trong `apps/<id>.json`).
3. **Create new release** → *Add from library* chọn AAB mới nhất → Release notes → **Next → Save → Send for review**.
4. **Staged rollout**: bắt đầu **20%**, sau 2 ngày không có crash (xem *Quality → Android vitals*) thì tăng **100%**.

## Bước 13 — Tuần đầu sau khi lên Store

- [ ] Nhờ 5–10 tester đầu tiên **đánh giá thật** (Play cấm mua/đổi quà lấy đánh giá).
- [ ] Đăng bài giới thiệu trong các nhóm Facebook/Zalo thợ nail (xem `docs/03-ANDROID-GROWTH-PLAYBOOK.md`).
- [ ] *Grow users → Store listing experiments*: thử 2 icon hoặc 2 ảnh đầu tiên.
- [ ] Theo dõi *Monetize → Financial reports* và tỷ lệ chuyển đổi trang cửa hàng. Mục tiêu: ≥25% người xem trang cài app, ≥3% người cài mua gói.
- [ ] Trả lời mọi đánh giá trong 24–48 giờ.
- [ ] Lặp lại từ **bước 5** cho app tiếp theo.

---

### Lỗi hay gặp

| Thông báo | Cách xử lý |
|---|---|
| *You uploaded an APK or Android App Bundle that was signed in debug mode* | Secrets khoá ký chưa đúng (bước 5). |
| *Version code 1 has already been used* | Tải AAB của lần chạy CI mới hơn (CI tự tăng versionCode). |
| *Your app currently has no in-app products* / không tạo được sản phẩm | Phải upload AAB lên một track trước, và hoàn tất payments profile. |
| App báo "Cửa hàng tạm thời không khả dụng" | Cài app **từ link tester trên Play**, không cài APK tay; Gmail trên máy phải là tester. |
| *Policy: misleading claims* | Không viết "đề thi thật", "official", "guaranteed pass" trong mô tả. Nội dung mẫu đã tránh các từ này. |
| *Target API level* | Flutter 3.47 build với targetSdk 36, đạt yêu cầu năm 2026. Năm sau chỉ cần nâng Flutter. |
