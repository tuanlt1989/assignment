# Exam Prep Apps — nhà máy app luyện thi (Flutter)

Một codebase Flutter → nhiều app luyện thi chứng chỉ hành nghề trên Google Play.
Mỗi app = **1 file cấu hình** (`apps/<id>.json`) + **1 ngân hàng câu hỏi** (`content/<bank>/`) + **1 bộ nội dung cửa hàng** (`store/<id>/`).

## 15 app: 10 app luyện thi + 5 game giải đố

5 game giải đố ngách (gần như chưa có đối thủ trên Android) nằm trong project riêng [`games/`](games/README.md): Domino Dots, Patch Grid, Word Weave, Putt Puzzle, Meow Queens.


**Đợt 1 — thị trường Mỹ** (nghề làm đẹp, bảo hiểm):

| id | App | Ngân hàng câu hỏi | Ngôn ngữ | Giá gợi ý (trả 1 lần) |
|---|---|---|---|---|
| `nailvi` | Luyện Thi Nail Tiếng Việt | `nail` (250 câu) | Việt + Anh | $14.99 |
| `nailes` | Examen de Uñas en Español | `nail` (250 câu) | Tây Ban Nha + Anh | $12.99 |
| `cosmovi` | Thi Cosmetology Tiếng Việt | `cosmetology` (250 câu) | Việt + Anh | $14.99 |
| `cosmoes` | Examen de Cosmetología | `cosmetology` (250 câu) | Tây Ban Nha + Anh | $12.99 |
| `insurancelh` | Life & Health Insurance Exam | `insurance_lh` (250 câu) | Anh | $19.99 |

**Đợt 2 — thị trường quốc tế, nơi đa số dùng Android** (lao động và người đi làm việc ở nước ngoài, những người sẵn sàng trả tiền để thi đậu):

| id | App | Thị trường | Ngân hàng câu hỏi | Ngôn ngữ | Giá gợi ý |
|---|---|---|---|---|---|
| `nursegulf` | Gulf Nursing Exam Prep (DHA/DOH/MOHAP/SCFHS/QCHP) | Điều dưỡng Ấn Độ, Philippines… đi làm ở Trung Đông | `nursing_gulf` (250 câu) | Anh | $14.99 (₹499, ₱599) |
| `cscsro` | Test CSCS în Română | Thợ xây Romania tại Anh | `cscs` (250 câu) | Romania + Anh | £7.99 |
| `cscspl` | Test CSCS po polsku | Thợ xây Ba Lan tại Anh | `cscs` (250 câu) | Ba Lan + Anh | £7.99 |
| `sachkunde` | Sachkunde §34a Prüfung | Nhân viên bảo vệ ở Đức (nhiều người nhập cư) | `sachkunde34a` (250 câu) | Đức + Anh | €14.99 |
| `civilserviceph` | Civil Service Exam Reviewer PH | Philippines, khoảng 240 nghìn người thi mỗi đợt, tỷ lệ đậu khoảng 14% | `cse_ph` (250 câu) | Anh | ₱249 |

**Hiện cả 15 app đều đặt `"ads": false`: không quảng cáo, chỉ bán gói một lần.** Muốn bật quảng cáo, xem `docs/07-ADMOB.md`.

Toàn bộ câu hỏi là **câu tự biên soạn** theo các chủ đề thi đã được công bố. Không có câu nào sao chép từ đề thi thật hay sách giáo trình.

## Tính năng app

- **Lần mở đầu tiên**: hỏi ngày thi → số câu mỗi ngày (10/20/30/50) → lập kế hoạch + bật nhắc học hằng ngày → màn hình mở khoá.
- **Trang chủ**: chuỗi ngày học (streak), tiến độ mục tiêu hôm nay, đếm ngược ngày thi, điểm "mức độ sẵn sàng".
- 6 chế độ học: **thi thử** bấm giờ có điểm đậu, **10 câu nhanh** (ưu tiên câu chưa thuộc), **thẻ ghi nhớ** (lật thẻ, đánh dấu đã thuộc/chưa thuộc), **chủ đề yếu nhất** (tự chọn chủ đề điểm thấp nhất), **câu sai**, **câu đã lưu**. Ngoài ra luyện theo từng chủ đề.
- Kết quả thi thử theo từng chủ đề và xem lại bài làm.
- **Nhắc học** hằng ngày bằng thông báo, chọn giờ trong Cài đặt; đổi ngày thi, mục tiêu mỗi ngày bất cứ lúc nào.
- **Song ngữ**: câu hỏi, đáp án và giải thích hiện bằng ngôn ngữ chính, chạm một lần để xem tiếng Anh.
- Xáo thứ tự đáp án mỗi lần làm, để người học không thuộc lòng vị trí đáp án.
- **Kiếm tiền (ưu tiên bán gói)**:
  - Bản miễn phí mở khoảng 30–40% câu hỏi mỗi chủ đề, thi thử ngắn, thẻ ghi nhớ giới hạn.
  - Màn hình mở khoá có **bảng so sánh Miễn phí / Đầy đủ** (số câu, độ dài thi thử, thẻ ghi nhớ) và số câu đang bị khoá; gợi ý mở khoá sau mỗi 2 lượt học và cuối mỗi bộ thẻ.
  - **Gói mua một lần `premium_lifetime`**: mở toàn bộ. Có khôi phục giao dịch, thanh toán đang chờ, thử lại khi chưa tải được giá.
  - Quảng cáo AdMob là tuỳ chọn, bật riêng cho từng app.
- Tự hỏi người dùng đánh giá app trên Play ngay sau khi họ **thi thử đậu** (tối đa 30 ngày một lần).
- Chạy được không cần mạng, không cần tài khoản.

## Cấu trúc

```
apps/<id>.json            cấu hình từng app (applicationId, màu, ngôn ngữ, đề thi, AdMob, giá…)
content/<bank>/           ngân hàng câu hỏi dạng text, dễ sửa: meta.json, en.txt (bản gốc), vi.txt, es.txt
store/<id>/metadata/android/<locale>/   nội dung Play Store (định dạng fastlane): tiêu đề, mô tả, icon, feature graphic, ảnh màn hình
lib/                      code Flutter dùng chung cho mọi app
tool/build_banks.py       content/*.txt  -> assets/banks/*.json (có kiểm tra lỗi)
tool/factory.py           apps/*.json    -> flavor Android, icon, tên app, ảnh cửa hàng, chính sách bảo mật
tool/screenshots/ + tool/frame_screenshots.py   chụp và đóng khung ảnh màn hình cửa hàng
docs/                     hướng dẫn phát hành, marketing, thêm app, soạn câu hỏi; docs/privacy/*.html
.github/workflows/android.yml   CI: analyze + test + build AAB/APK cho MỌI app (cả games/)
games/                    project Flutter riêng cho 5 game giải đố
```

## Lệnh thường dùng

```bash
python3 tool/build_banks.py                 # sau khi sửa content/
python3 tool/factory.py                     # sau khi sửa apps/*.json (cần: pip install Pillow)
python3 tool/play_publish.py --app nailvi --listing --dry-run   # kiểm tra nội dung trước khi upload lên Play
python3 tool/factory.py --release           # kiểm tra trước khi phát hành (báo lỗi nếu còn ID quảng cáo TEST / CHANGE_ME)
flutter analyze && flutter test
flutter build appbundle --release --flavor nailvi   # file AAB để đưa lên Play
flutter build apk --release --flavor nailvi         # file APK để cài thử trên máy
flutter run --flavor nailvi                         # chạy thử trên điện thoại
```

Mỗi lần push lên GitHub, CI sẽ build **AAB + APK cho tất cả app** (tab Actions → chọn lần chạy → Artifacts).
Nếu đã cài secrets của khoá ký thì file AAB tải về đưa thẳng lên Play được. Xem `docs/01-SIGNING-AND-BUILD.md`.

## Tài liệu

0. [docs/STORE-GUIDE.md](docs/STORE-GUIDE.md): **tất cả trong 1 file**: hướng dẫn upload từng app (15 app) + mọi tài liệu
1. [docs/01-SIGNING-AND-BUILD.md](docs/01-SIGNING-AND-BUILD.md): khoá ký, secrets trên GitHub, build ra AAB/APK
2. [docs/02-LAUNCH-CHECKLIST.md](docs/02-LAUNCH-CHECKLIST.md): **từng bước đưa app lên Google Play**
3. [docs/03-ANDROID-GROWTH-PLAYBOOK.md](docs/03-ANDROID-GROWTH-PLAYBOOK.md): kế hoạch marketing trên Android
4. [docs/04-ADD-NEW-APP.md](docs/04-ADD-NEW-APP.md): thêm app thứ 6 đến thứ 100
5. [docs/05-CONTENT-GUIDE.md](docs/05-CONTENT-GUIDE.md): cách soạn, dịch và kiểm tra câu hỏi
6. [docs/06-IN-APP-PURCHASE.md](docs/06-IN-APP-PURCHASE.md): **cấu hình mua trong app từng bước**, bảng giá và cách sửa lỗi
7. [docs/07-ADMOB.md](docs/07-ADMOB.md): lỗi đăng ký AdMob và cách bật quảng cáo (không bắt buộc)
8. [docs/08-PUBLISH-FIRST-APP.md](docs/08-PUBLISH-FIRST-APP.md): **đưa app đầu tiên (`nailvi`) lên Google Play, từng cú bấm**
9. [games/README.md](games/README.md): 5 game giải đố
10. [docs/09-AUTO-PUBLISH.md](docs/09-AUTO-PUBLISH.md): **tự động upload lên Google Play bằng 1 nút** (API chính thức + GitHub Actions)

## ⚠️ Phải sửa trước lần upload đầu tiên

- `applicationId` trong `apps/*.json` và `games/apps/*.json`: đã đặt là `com.tuanapps.<id>` (ví dụ `com.tuanapps.nailvi`). **Sau khi đã upload lên Play thì không đổi được nữa.**
- `supportEmail`, `developerName`. Bật GitHub Pages để có trang chính sách bảo mật (docs/08 bước 4).
- Gói mua trong app `premium_lifetime`: tạo theo `docs/06-IN-APP-PURCHASE.md`.
