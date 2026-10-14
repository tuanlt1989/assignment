# Exam Prep Apps — nhà máy app luyện thi (Flutter)

Một codebase Flutter → nhiều app luyện thi chứng chỉ hành nghề trên Google Play.
Mỗi app = **1 file cấu hình** (`apps/<id>.json`) + **1 ngân hàng câu hỏi** (`content/<bank>/`) + **1 bộ nội dung cửa hàng** (`store/<id>/`).

## 5 app đầu tiên

| id | App | Ngân hàng câu hỏi | Ngôn ngữ | Giá gợi ý (trả 1 lần) |
|---|---|---|---|---|
| `nailvi` | Luyện Thi Nail Tiếng Việt | `nail` (120 câu) | Việt + Anh | $14.99 |
| `nailes` | Examen de Uñas en Español | `nail` (120 câu) | Tây Ban Nha + Anh | $12.99 |
| `cosmovi` | Thi Cosmetology Tiếng Việt | `cosmetology` (120 câu) | Việt + Anh | $14.99 |
| `cosmoes` | Examen de Cosmetología | `cosmetology` (120 câu) | Tây Ban Nha + Anh | $12.99 |
| `insurancelh` | Life & Health Insurance Exam | `insurance_lh` (120 câu) | Anh | $19.99 |

Toàn bộ câu hỏi là **câu tự biên soạn** theo các chủ đề thi đã được công bố. Không có câu nào sao chép từ đề thi thật hay sách giáo trình.

## Tính năng app

- Luyện theo chủ đề, luyện nhanh 10 câu (ưu tiên câu chưa thuộc), ôn câu sai, lưu câu khó.
- Thi thử bấm giờ có điểm đậu, xem kết quả theo từng chủ đề và xem lại bài làm.
- **Song ngữ**: câu hỏi, đáp án và giải thích hiện bằng ngôn ngữ chính, chạm một lần để xem tiếng Anh.
- Xáo thứ tự đáp án mỗi lần làm, để người học không thuộc lòng vị trí đáp án.
- Điểm "mức độ sẵn sàng", số ngày học. Giao diện đổi được giữa ngôn ngữ chính và tiếng Anh.
- **Kiếm tiền**:
  - Bản miễn phí mở khoảng 35–40% câu hỏi của mỗi chủ đề, có banner và quảng cáo xen kẽ (tối đa 1 lần sau mỗi 2 lượt làm bài).
  - **Gói mua một lần `premium_lifetime`** mở khoá toàn bộ câu hỏi và tắt quảng cáo. Có nút khôi phục giao dịch.
- Tự hỏi người dùng đánh giá app trên Play ngay sau khi họ **thi thử đậu** (tối đa 30 ngày một lần).
- Hiện form đồng ý quảng cáo của Google (UMP) ở những nơi luật yêu cầu (EU, Anh…). Chạy được không cần mạng, không cần tài khoản.

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
.github/workflows/android.yml   CI: analyze + test + build AAB/APK cho MỌI app
```

## Lệnh thường dùng

```bash
python3 tool/build_banks.py                 # sau khi sửa content/
python3 tool/factory.py                     # sau khi sửa apps/*.json (cần: pip install Pillow)
python3 tool/factory.py --release           # kiểm tra trước khi phát hành (báo lỗi nếu còn ID quảng cáo TEST / CHANGE_ME)
flutter analyze && flutter test
flutter build appbundle --release --flavor nailvi   # file AAB để đưa lên Play
flutter build apk --release --flavor nailvi         # file APK để cài thử trên máy
flutter run --flavor nailvi                         # chạy thử trên điện thoại
```

Mỗi lần push lên GitHub, CI sẽ build **AAB + APK cho tất cả app** (tab Actions → chọn lần chạy → Artifacts).
Nếu đã cài secrets của khoá ký thì file AAB tải về đưa thẳng lên Play được. Xem `docs/01-SIGNING-AND-BUILD.md`.

## Tài liệu

1. [docs/01-SIGNING-AND-BUILD.md](docs/01-SIGNING-AND-BUILD.md): khoá ký, secrets trên GitHub, build ra AAB/APK
2. [docs/02-LAUNCH-CHECKLIST.md](docs/02-LAUNCH-CHECKLIST.md): **từng bước đưa app lên Google Play**
3. [docs/03-ANDROID-GROWTH-PLAYBOOK.md](docs/03-ANDROID-GROWTH-PLAYBOOK.md): kế hoạch marketing trên Android
4. [docs/04-ADD-NEW-APP.md](docs/04-ADD-NEW-APP.md): thêm app thứ 6 đến thứ 100
5. [docs/05-CONTENT-GUIDE.md](docs/05-CONTENT-GUIDE.md): cách soạn, dịch và kiểm tra câu hỏi

## ⚠️ Phải sửa trước lần upload đầu tiên

- `applicationId` trong `apps/*.json`: hiện là `com.tuanlt.examprep.*`. **Sau khi đã upload lên Play thì không đổi được nữa.**
- `supportEmail`, `developerName`, `privacyPolicyUrl`.
- `admob.*`: hiện là **ID TEST của Google**. Đổi sang ID thật lấy từ AdMob thì quảng cáo mới ra tiền.
