# 04 — Thêm app mới (app thứ 6 đến thứ 100)

Thêm một app **không cần viết code**. Các bước:

## 1. Ngân hàng câu hỏi

- **Dùng lại ngân hàng có sẵn, chỉ thêm ngôn ngữ** (ví dụ nail tiếng Hàn): tạo `content/nail/ko.txt` với cùng id và cùng thứ tự đáp án như `en.txt`, rồi thêm tên tiếng Hàn của các chủ đề vào `content/nail/meta.json`.
- **Ngân hàng mới** (ví dụ `esthetics`): tạo thư mục `content/esthetics/` gồm `meta.json` (danh sách chủ đề) và `en.txt`, sau đó thêm file các ngôn ngữ khác. Định dạng xem `docs/05-CONTENT-GUIDE.md`.

```bash
python3 tool/build_banks.py      # phải chạy không lỗi
```

## 2. File cấu hình app

Copy một file có sẵn, ví dụ `cp apps/nailvi.json apps/nailko.json`, rồi sửa:

| Trường | Ý nghĩa |
|---|---|
| `id` | trùng tên file, chỉ gồm chữ thường và số (đây cũng là tên flavor của Gradle) |
| `applicationId` | package name trên Play, **không đổi được sau khi upload** |
| `launcherName` | tên ngắn hiện dưới icon trên điện thoại (≤ 12–15 ký tự) |
| `title` | tên app hiển thị trong app, theo từng ngôn ngữ giao diện |
| `bank`, `locales` | ngân hàng câu hỏi; ngôn ngữ đầu là ngôn ngữ chính, ngôn ngữ thứ hai là ngôn ngữ hỗ trợ khi bấm "Xem English" |
| `color`, `icon` | màu chủ đạo; chữ trên icon (`label`), huy hiệu ngôn ngữ (`badge`), hình vẽ (`glyph`: `nail` / `comb` / `shield`) |
| `exam` | số câu, số phút, % điểm đậu của bài thi thử |
| `freeRatio` | tỷ lệ câu miễn phí trong mỗi chủ đề (0.35–0.4 là hợp lý) |
| `admob`, `premiumProductId`, `privacyPolicyUrl`, `supportEmail`, `developerName` | xem `02-LAUNCH-CHECKLIST.md` |
| `tagline`, `screenshotCaptions` | dòng chữ trên feature graphic và chú thích trên ảnh màn hình, theo từng ngôn ngữ |

## 3. Nội dung cửa hàng

Tạo `store/<id>/metadata/android/en-US/` (và `vi/`, `es-US/`, `ko-KR/`… nếu có) với 3 file:
- `title.txt` (≤ 30 ký tự)
- `short_description.txt` (≤ 80 ký tự)
- `full_description.txt` (≤ 4000 ký tự)

## 4. Sinh tài nguyên & ảnh

```bash
python3 tool/factory.py                       # flavor, icon, feature graphic, privacy policy
flutter build web --release --no-web-resources-cdn --dart-define=NO_ADS=true
(cd build/web && python3 -m http.server 8765) &
(cd tool/screenshots && npm install && node shoot.js)
python3 tool/frame_screenshots.py             # ảnh màn hình 1080×1920 có chú thích
flutter test
```

## 5. Build & phát hành

Commit rồi push. CI tự nhận app mới (mỗi file `apps/*.json` là một job build).
Sau đó làm theo `02-LAUNCH-CHECKLIST.md` từ mục E.

## Thứ tự nên làm tiếp (gợi ý)

1. `nailko`, `nailzh`: nail tiếng Hàn và tiếng Trung (chỉ cần dịch)
2. `cosmoko`, `cosmozh`
3. `esthvi`, `esthes`: ngân hàng Esthetician mới
4. `barbervi`, `barberes`
5. `insurancepc`: bảo hiểm Property & Casualty
