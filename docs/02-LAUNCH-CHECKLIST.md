# 02 — Checklist đưa app lên Google Play

Làm lần lượt từ trên xuống. Phần B–D làm một lần cho cả nhà máy; phần E–H làm cho **từng app**.
Chính sách của Google Play thay đổi thường xuyên, nên luôn đọc lại thông báo trong Play Console. Tài liệu này viết vào tháng 10/2026.

---

## A. Chọn loại tài khoản Play Console (quan trọng)

| | Tài khoản **Cá nhân** | Tài khoản **Tổ chức** |
|---|---|---|
| Phí | $25 một lần | $25 một lần |
| Giấy tờ | CMND/hộ chiếu | Công ty (LLC…) + **số D-U-N-S** (miễn phí, chờ vài ngày đến vài tuần) |
| **Thử nghiệm kín bắt buộc** | Tài khoản tạo sau 11/2023 phải chạy **closed testing với ≥12 tester liên tục 14 ngày** cho **mỗi app** trước khi được lên production | **Không bắt buộc** |
| Tên hiển thị | Tên thật của bạn | Tên công ty, trông chuyên nghiệp hơn |

👉 Nếu định làm 100 app, nên **mở LLC và lấy số D-U-N-S** để bỏ được bước 12 tester × 14 ngày cho mỗi app.
Nếu dùng tài khoản cá nhân: chạy closed test **cho cả 5 app cùng lúc** với cùng một nhóm tester (12 người trở lên), ví dụ người quen, học viên trường nail hoặc thành viên các nhóm Facebook.

Không tạo nhiều tài khoản developer để lách luật. Google có thể khoá toàn bộ các tài khoản liên quan.

## B. Sửa cấu hình (một lần, trước lần upload đầu tiên)

Trong mỗi file `apps/*.json`:

- [ ] `applicationId`: đổi `com.tuanlt.examprep` thành tên miền hoặc thương hiệu của bạn, ví dụ `com.tenban.nailvi`. **Sau khi upload thì không đổi được nữa.**
- [ ] `developerName`, `supportEmail`: email này hiện công khai trên Play.
- [ ] `privacyPolicyUrl`: xem mục C.
- [ ] Chạy `python3 tool/factory.py`, commit rồi push.

## C. Đưa trang Chính sách bảo mật lên mạng

`tool/factory.py` đã tạo sẵn `docs/privacy/<id>.html`. Chọn một trong các cách sau để đưa lên mạng:
- **GitHub Pages**: repo phải public (hoặc dùng gói GitHub Pro). Vào Settings → Pages, chọn thư mục `/docs`. URL sẽ là `https://<user>.github.io/<repo>/privacy/<id>.html`.
- **Cloudflare Pages / Netlify**: miễn phí, kéo thả thư mục `docs/privacy` là xong.
- **Google Sites**: dán nội dung trang vào.

Kiểm tra URL mở được trên điện thoại, rồi cập nhật `privacyPolicyUrl` trong `apps/*.json`.

## D. Khoá ký và build

Làm theo `docs/01-SIGNING-AND-BUILD.md`. Kết quả là có AAB đã ký cho từng app.

---

## E. Tạo app trong Play Console (làm cho từng app)

1. **Create app**:
   - Tên app: lấy từ `store/<id>/metadata/android/<locale>/title.txt`.
   - Ngôn ngữ mặc định: English (United States).
   - Loại: App. Hình thức: **Free** (vì có mua trong app).
2. **Dashboard → Set up your app**, trả lời từng mục:
   - **App access**: All functionality is available without special access.
   - **Ads**: **Yes, my app contains ads**.
   - **Content rating**: chọn danh mục Reference/Education. Không có bạo lực hay nội dung người lớn, thường ra mức **Everyone**.
   - **Target audience**: chọn **18 and over**. App dành cho người đi thi chứng chỉ; chọn nhóm dưới 13 tuổi sẽ bị áp chính sách Families rất chặt.
   - **News app**: No. **Government app**: No. **Financial features**: No. **Health**: chọn mục không thuộc nhóm nào. Với app bảo hiểm cũng chọn No vì app chỉ dạy học, không bán bảo hiểm.
   - **Advertising ID**: Yes, dùng cho mục đích Advertising/Analytics (thư viện Google Mobile Ads tự thêm quyền `AD_ID`).
   - **Data safety**, trả lời theo những gì AdMob thu thập:
     - Có thu thập dữ liệu: **Yes**. Dữ liệu được mã hoá khi truyền: **Yes**. Có cách xoá dữ liệu: dữ liệu học chỉ nằm trên máy, người dùng xoá bằng "Xoá tiến độ" hoặc gỡ app.
     - Loại dữ liệu (do AdMob): **Device or other IDs**, **App interactions**, **Diagnostics**, **Approximate location** (suy ra từ IP).
     - Mục đích: Advertising or marketing, Analytics, Fraud prevention/security. Dữ liệu được chia sẻ (shared) với Google AdMob.
     - Đối chiếu thêm hướng dẫn chính thức của Google về khai báo Data safety cho AdMob.
   - **Privacy policy**: dán URL ở mục C.
3. **Store settings**: Category **Education**, email liên hệ, website (nếu có).
4. **Main store listing**:
   - Dán title, short description, full description từ `store/<id>/metadata/android/en-US/`.
   - Upload `images/icon.png` (512×512), `images/featureGraphic.png` (1024×500) và `images/phoneScreenshots/1-4.png`.
   - **Thêm bản dịch**: Vietnamese (`vi`) cho app `*vi`, Spanish – United States (`es-US`) cho app `*es`. Lấy file trong thư mục locale tương ứng.

   Mẹo: có thể upload toàn bộ nội dung cửa hàng bằng lệnh `fastlane supply --metadata_path store/<id>/metadata/android --package_name <applicationId> --skip_upload_aab` (cần service account JSON của Play Console).

## F. Upload bản đầu tiên & thử nghiệm

1. **Testing → Internal testing → Create release**:
   - Upload AAB.
   - Đặt release notes, ví dụ "First release".
   - Thêm email của bạn vào danh sách tester.
2. Cài app từ link internal testing và kiểm tra:
   - Mở app, làm bài, thi thử.
   - Banner quảng cáo TEST hiện lên.
   - Nút mua hiện giá. Mục này chỉ chạy sau khi đã tạo sản phẩm ở mục G.
3. **Tài khoản cá nhân:**
   - Tạo **Closed testing**, thêm ≥12 tester (Google Group hoặc danh sách email), gửi link opt-in.
   - Chờ đủ **14 ngày liên tục**, sau đó bấm **Apply for production** và trả lời các câu hỏi về quá trình test.
4. **Production → Create release**:
   - Chọn quốc gia: **United States** là chính. App tiếng Tây Ban Nha thêm Puerto Rico; app bảo hiểm chỉ chọn United States.
   - Bật rollout. Thời gian duyệt từ vài giờ đến vài ngày.

## G. Tạo sản phẩm mua trong app

Play chỉ cho tạo sản phẩm sau khi đã upload ít nhất một AAB có quyền BILLING. Thư viện `in_app_purchase` đã tự thêm quyền này.

1. **Monetize → Products → In-app products → Create product**:
   - Product ID: **`premium_lifetime`**. ID phải trùng chính xác với `premiumProductId` trong `apps/<id>.json`.
   - Tên: "Unlock all questions". Viết mô tả ngắn.
   - Giá: xem bảng giá gợi ý trong README. Play tự quy đổi sang các nước khác.
   - Bấm **Activate**.
2. **Setup → License testing**: thêm email của bạn để mua thử miễn phí.
3. Mở app (bản cài từ Play) → Mở khoá → mua thử. Kiểm tra quảng cáo biến mất và toàn bộ câu hỏi được mở. Gỡ app, cài lại, bấm "Khôi phục giao dịch" để kiểm tra khôi phục.

## H. Bật quảng cáo thật (AdMob)

1. Tạo tài khoản tại admob.google.com và điền thông tin thanh toán và thuế (W-8BEN nếu bạn không phải người Mỹ).
2. **Apps → Add app** → chọn Android → liên kết với app trên Play (sau khi app đã được duyệt).
3. Tạo 2 ad unit cho mỗi app: **Banner** và **Interstitial**.
4. Chép App ID (`ca-app-pub-xxx~yyy`) và 2 ad unit ID (`ca-app-pub-xxx/zzz`) vào `apps/<id>.json` → `admob`.
5. Chạy `python3 tool/factory.py --release`. Lệnh phải báo `ok` cho mọi app.
6. Commit, push, tải AAB mới (CI tự tăng versionCode) và upload lên Production.
7. **app-ads.txt**: AdMob yêu cầu đặt file `app-ads.txt` ở **website ghi trong mục Store settings** của Play, ví dụ `https://tenmien.com/app-ads.txt`. Nội dung lấy trong AdMob → Apps → app-ads.txt.
8. **Privacy & messaging** trong AdMob: tạo **GDPR message** (bắt buộc nếu phát hành ở EU/Anh) và **US states message**. App đã gắn sẵn UMP SDK nên form tự hiện khi cần.

⚠️ **Không bao giờ bấm vào quảng cáo thật trên app của chính mình.** Khi tự test, chỉ dùng ID TEST hoặc thêm máy của bạn làm test device trong AdMob.

## I. Sau khi phát hành

- [ ] Trả lời mọi đánh giá trong vòng 24–48 giờ, đặc biệt các đánh giá 1–3 sao.
- [ ] Xem **Statistics**: tỷ lệ chuyển đổi trang cửa hàng (store listing conversion), số lượt cài, tỷ lệ gỡ app.
- [ ] Mỗi lần cập nhật câu hỏi: sửa `content/`, chạy `build_banks.py`, push, upload AAB mới.
- [ ] Đọc `docs/03-ANDROID-GROWTH-PLAYBOOK.md`.
