# Puzzle Games — 5 game giải đố ngách, ăn theo trend (Flutter)

Project Flutter riêng (`games/`), cùng kiểu "nhà máy" với app luyện thi: mỗi game = 1 file `apps/<id>.json` + 1 bộ nội dung cửa hàng `store/<id>/`.
Mọi câu đố được **sinh tự động, đã kiểm chứng giải được** (logic: đúng **1 lời giải duy nhất**; golf: bộ giải tìm được đường về par), nên số câu đố là vô hạn.

## Cách chọn game: trend mới + gần như chưa có đối thủ trên Android

Tiêu chí:
1. Cơ chế đang viral trong khoảng tháng 3–10/2026.
2. Trên Google Play **chưa có hoặc chỉ có rất ít bản tương tự**.
3. Có chiều sâu để người chơi ở lại **30 phút mỗi lượt**.

Bốn game cũ (mũi tên, xếp khối 8×8, bus jam, pixel) đã bỏ vì mỗi thể loại có hàng trăm bản clone. Code vẫn còn trong lịch sử git, commit `90627a8`.

| id | Game | Ăn theo | Mức cạnh tranh trên Play |
|---|---|---|---|
| `dominodots` | **Domino Dots** – đặt domino cho mỗi vùng màu thoả điều kiện (tổng, bằng nhau, khác nhau, lớn hơn, nhỏ hơn) | *Pips* của NYT Games ([Tom's Guide](https://www.tomsguide.com/gaming/nyts-new-game-pips-is-already-addictive-heres-how-to-play)), có nhiều bản web "unlimited" | Rất thấp: bản tương tự duy nhất tìm được (*dotio*) là app trả phí với khoảng 50 lượt cài ([AppPricingLab](https://apppricinglab.com/app/google_play/com.leoncross.dotio)) |
| `patchgrid` | **Patch Grid** – chia lưới thành hình chữ nhật; gợi ý số (diện tích) và hình (vuông, ngang, dọc) | *Patches* của LinkedIn, ra mắt 19/3/2026 ([PocketGamer.biz](https://www.pocketgamer.biz/linkedin-launches-new-logic-puzzle-game-patches), [LinkedIn](https://news.linkedin.com/2026/LinkedIn-Announces-Patches-A-New-Thinking-Oriented-Game-Inspired-by-Zip/LinkedIn-Announces-Patches-A-New-Thinking-Oriented-Game-Inspired-by-Zip)) | Thấp: chỉ vài app Shikaku cũ, không app nào có huy hiệu hình dạng kiểu Patches |
| `wordweave` | **Word Weave** – lưới chữ được chia hết thành các từ ẩn, chỉ biết độ dài từ | *Wend* của LinkedIn, ra mắt 6/2026 ([PocketGamer.biz](https://www.pocketgamer.biz/linkedin-launches-wend-as-first-new-word-game-in-two-years/)) | Không tìm thấy bản nào trên Android |
| `puttpuzzle` | **Putt Puzzle** – mỗi ngày một lỗ golf mini (cát, nước, băng, dốc, nam châm) | *putt.day*, "Wordle phiên bản minigolf", ra mắt 13/5/2026 ([Dexerto](https://www.dexerto.com/gaming/this-addictive-browser-game-is-the-minigolf-version-of-wordle-3407294/)) | Chỉ là game trình duyệt; trên Android chỉ có 1 bản APK thử nghiệm trên itch.io |
| `meowqueens` | **Meow Queens** – mỗi hàng, cột, vùng màu một con mèo; mèo không chạm nhau | *Meowdoku*: hơn 43 triệu lượt tải, **đứng đầu lượt tải tại Nhật** tháng 8 và 9/2026 ([Sensor Tower JP](https://sensortower.com/ja/blog/top-10-japan-mobile-games-by-revenue-and-downloads-in-september-2026-JP), [MobileGamer.biz](https://mobilegamer.biz/data-digest-meowdoku-and-learnings-sudden-rise-honor-of-kings-disney-emoji-blitz-netflix-playground-more/)) | Trung bình: có nhiều bản Queens. Riêng Meowdoku kiếm tiền gần như 100% bằng quảng cáo ([baijing](https://www.baijing.cn/article/56287)), nên mình khác biệt bằng **không quảng cáo** + **tiếng Nhật** |

Tên và đồ hoạ là của riêng mình, **không dùng** tên Pips, Patches, Wend, putt.day, Meowdoku, NYT hay LinkedIn. Cơ chế chơi không được bảo hộ bản quyền, nhưng tên và hình ảnh thương hiệu thì có.

## Tính năng chung (đủ chơi 30 phút mỗi lượt)

- **4 độ khó**: Dễ, Vừa, Khó, Chuyên gia. Mỗi mức có câu đố đánh số, không giới hạn (#1, #2…), và mọi người chơi cùng một câu ở cùng số.
- **Câu đố hằng ngày**: dễ đầu tuần, khó nhất cuối tuần, có chuỗi ngày chơi 🔥 và **kho 60 ngày** để chơi lại.
- **1–3 sao** mỗi câu: trừ sao khi sai hoặc dùng gợi ý; golf thì tính theo par.
- **8 giao diện màu** mở bằng sao, có 2 giao diện nền tối. **12 huy hiệu** (giải 1/25/100/500 câu, chuỗi 3/7/30 ngày, giải không gợi ý…).
- **Thống kê**: số câu đã giải, sao, chuỗi ngày, tổng thời gian chơi, kỷ lục thời gian theo từng mức.
- Bấm giờ, gợi ý, chơi lại miễn phí, hướng dẫn "Cách chơi" hiện ở lần chơi đầu tiên.
- **7 ngôn ngữ**: Anh, Tây Ban Nha, Bồ Đào Nha, Việt, Indonesia, Đức, **Nhật**. Word Weave có từ điển tiếng Anh, Tây Ban Nha, Bồ Đào Nha và Đức.
- Không quảng cáo, chạy offline, không cần tài khoản.

## Kiếm tiền: mua một lần `premium_lifetime` (gợi ý $2.99)

| | Miễn phí | Không giới hạn |
|---|---|---|
| Dễ & Vừa | không giới hạn | không giới hạn |
| Khó | 3 câu/ngày | ∞ |
| Chuyên gia | 1 câu/ngày | ∞ |
| Gợi ý | 3, mỗi ngày +1 | ∞ |
| Kho câu đố hằng ngày | chỉ hôm nay | 60 ngày |
| Giao diện | mở bằng sao | tất cả |

Người chơi mới được chơi thoải mái ở mức Dễ/Vừa để "nghiện" trước. Khi lên Khó/Chuyên gia, muốn chơi tiếp hoặc chơi lại các ngày cũ thì phải mua.
Cấu hình trên Play giống app luyện thi, xem `../docs/06-IN-APP-PURCHASE.md`.

## Thị trường

Phát hành toàn cầu. Nội dung cửa hàng có sẵn 7 ngôn ngữ (`en-US, es-419, pt-BR, vi, id, de-DE, ja-JP`).
Ưu tiên Mỹ, Nhật (Meowdoku đang đứng đầu, người chơi Nhật quen mua game giải đố), Đức, Brazil, Mỹ Latin.

## Lệnh

```bash
cd games
flutter pub get && flutter analyze && flutter test   # test kiểm chứng câu đố có lời giải duy nhất / về được par
flutter run --flavor patchgrid
flutter build appbundle --release --flavor dominodots
cd .. && python3 tool/factory.py --root games        # sau khi sửa games/apps/*.json
```

Ảnh cửa hàng: chạy `flutter build web --release --no-web-resources-cdn`, phục vụ thư mục `build/web`, rồi chạy
`ROOT=games SCENES=home,play,play2,stats node tool/screenshots/shoot.js` và `python3 tool/frame_screenshots.py --root games --scenes home,play,play2,stats`.

CI build AAB + APK cho cả 5 game. Hướng dẫn đưa lên Play: `../docs/08-PUBLISH-FIRST-APP.md`. Khai báo cho game: content rating chọn **Game → Puzzle** (Word Weave chọn **Word**), target audience 13+.

## Thêm game mới

1. Viết `lib/games/<ten>.dart`, theo hợp đồng `GameSession` trong `lib/games/session.dart`:
   - Sinh câu đố tất định từ (difficulty, level, seed).
   - Gọi `onWin` khi giải xong và `addMistake` mỗi lần sai.
   - Lắng nghe `hint` để hiện gợi ý.
   Sau đó đăng ký game trong `buildGame`.
2. Thêm luật chơi vào `_rules` trong `lib/i18n.dart` (đủ 7 ngôn ngữ), icon vào `GameBadge` và glyph trong `tool/graphics.py`.
3. Tạo `apps/<id>.json`, viết short description, rồi chạy `python3 tool/factory.py --root games`.
4. Viết test chứng minh câu đố luôn giải được và nhanh (dưới 300 ms).
