# 03 — Kế hoạch "đánh mạnh" thị trường Android

Mục tiêu thực tế cho giai đoạn đầu: **mỗi app 5–20 USD/ngày** sau 2–3 tháng.
Mỗi app có hai nguồn thu: người dùng miễn phí xem quảng cáo, và một phần nhỏ người dùng (khoảng 2–5%) trả tiền một lần.
Các con số dưới đây là **ước tính để lên kế hoạch**, không phải cam kết. Hãy đo số liệu thật rồi điều chỉnh.

## 0. Phép tính cần nhớ

```
Doanh thu/ngày ≈ lượt cài/ngày × tỷ lệ mua × giá × 0,85 (Google thu 15%)  +  doanh thu quảng cáo
Ví dụ app nailvi: 30 lượt cài/ngày × 4% × $14.99 × 0,85 ≈ $15/ngày (chưa tính quảng cáo)
```

Cần khoảng **20–40 lượt cài mỗi ngày cho mỗi app**. Đó là mục tiêu của mọi việc bên dưới.

## 1. Tối ưu trang cửa hàng (ASO) — miễn phí, làm trước tiên

- **Tiêu đề và mô tả ngắn chứa đúng từ khoá người dùng gõ.** Nội dung trong `store/` đã viết sẵn theo hướng này: "nail exam", "Vietnamese", "manicurist", "state board", "examen de uñas", "cosmetología"…
- **Dịch trang cửa hàng** sang ngôn ngữ người dùng: `vi` cho app tiếng Việt, `es-US` cho app tiếng Tây Ban Nha. Người dùng có điện thoại để tiếng Việt sẽ thấy trang tiếng Việt.
- **Store listing experiments** (Play Console → Grow → Store listing experiments): luôn chạy 1 thử nghiệm A/B, mỗi lần chỉ thử 1 yếu tố. Thứ tự nên thử: icon → ảnh màn hình đầu tiên → mô tả ngắn.
- **Custom store listings**: tạo trang riêng cho từng nhóm người dùng, ví dụ người dùng ở Texas hoặc từ một chiến dịch quảng cáo.
- **Đánh giá trung bình ≥ 4.5 sao** có ảnh hưởng lớn đến thứ hạng trên Play:
  - App đã tự hỏi người dùng đánh giá ngay sau khi họ thi thử đậu.
  - Trả lời mọi review, sửa lỗi người dùng báo rồi nhắn lại cho họ biết.
- Cập nhật app đều đặn (2–4 tuần một lần, thêm câu hỏi mới). Play ưu tiên các app được cập nhật thường xuyên.

## 2. Cộng đồng — nguồn người dùng miễn phí tốt nhất cho ngách này

### App tiếng Việt (nail / cosmetology)
- **Nhóm Facebook** của thợ nail và học viên nail người Việt tại Mỹ: đăng **mỗi ngày 1 câu hỏi kèm giải thích** dưới dạng ảnh, cuối bài để link app. Đăng nội dung có giá trị, đừng spam.
- **Trường nail và trường thẩm mỹ** của người Việt ở California, Texas, Georgia, Florida, Virginia…:
  - Tặng **mã khuyến mại (promo code)** của Play. Mỗi app được tạo tối đa 500 mã mỗi quý cho sản phẩm mua trong app.
  - Đề nghị chia hoa hồng nếu trường giới thiệu học viên.
- **TikTok / YouTube Shorts / Reels**: video 15–30 giây dạng "Câu này 70% thí sinh làm sai", quay màn hình app có phụ đề tiếng Việt.
- Đăng bài trên các trang báo và diễn đàn cộng đồng người Việt tại Mỹ.

### App tiếng Tây Ban Nha
- Cách làm tương tự: nhóm Facebook "manicuristas", "cosmetología", trường beauty school có học viên nói tiếng Tây Ban Nha, video ngắn trên TikTok bằng tiếng Tây Ban Nha.

### App bảo hiểm
- Reddit r/Insurance, các nhóm "new insurance agents".
- Các công ty bảo hiểm tuyển nhiều agent mới (IMO/agency) thường cần tài liệu ôn thi cho người mới.

## 3. Quảng cáo trả phí (làm sau khi tỷ lệ chuyển đổi đã tốt)

- Chỉ chạy khi trang cửa hàng có **tỷ lệ chuyển đổi trên 25%** và app có **≥ 4.3 sao**.
- **Google Ads → App campaign (App promotion)**:
  - Ngân sách thử 10–20 USD/ngày/app trong 2 tuần.
  - Nhắm Mỹ, ngôn ngữ vi hoặc es.
  - Ban đầu tối ưu theo lượt cài. Khi đã có dữ liệu mua hàng thì chuyển sang tối ưu theo hành động trong app; muốn vậy cần thêm Firebase Analytics, xem mục 6.
- So sánh chi phí mỗi lượt cài (CPI) với doanh thu trên mỗi lượt cài: chỉ tăng ngân sách khi **CPI < doanh thu/lượt cài**.

## 4. Giá & khuyến mãi

- Giá gợi ý ghi trong README. Thí sinh vừa trả $100–300 phí thi, nên mức $12.99–19.99 trả một lần dễ được chấp nhận.
- Thử giá bằng **Price experiments** trong Play Console, ví dụ $14.99 so với $19.99.
- Chạy **giảm giá theo mùa**: tháng 1 (đầu năm học mới), mùa hè.

## 5. Chỉ số theo dõi hằng tuần

| Chỉ số | Ở đâu xem | Mục tiêu |
|---|---|---|
| Tỷ lệ chuyển đổi trang cửa hàng | Play Console → Store performance | > 25% |
| Đánh giá trung bình | Ratings | ≥ 4.5 |
| Tỷ lệ người dùng mua | Doanh thu ÷ lượt cài | 2–5% |
| eCPM quảng cáo | AdMob | Mỹ: banner $0.3–1, interstitial $3–10 |
| Tỷ lệ gỡ app trong ngày đầu | Statistics | < 30% |

## 6. Lộ trình sản phẩm (theo thứ tự ưu tiên)

1. **Mở rộng ngân hàng câu hỏi lên 300–500 câu mỗi bộ.** Đối thủ quảng cáo "900 câu", nên số lượng câu là điều người dùng so sánh đầu tiên. Cách làm ở `docs/05-CONTENT-GUIDE.md`.
2. **Thêm phần luật riêng từng bang** (state law), ví dụ luật California hoặc Texas cho nail. Có thể bán thành gói riêng hoặc tách thành app riêng.
3. Thêm Firebase Analytics để chạy quảng cáo tối ưu theo lượt mua.
4. **Quảng cáo có thưởng (rewarded ad)**: "Xem 1 quảng cáo để mở khoá 24 giờ", giúp tăng doanh thu từ người dùng miễn phí.
5. Thêm chế độ flashcard và đọc câu hỏi thành tiếng.

## 7. Nhân rộng nhà máy (sau khi 5 app đầu có số liệu)

Chỉ nhân rộng **ngách nào đã có doanh thu**. Các hướng dễ làm nhất:
- **Thêm ngôn ngữ cho bộ nail và cosmetology**: tiếng Hàn (`ko`), tiếng Trung (`zh`). Nhiều bang cho thi bằng các thứ tiếng này. Mỗi ngôn ngữ chỉ cần thêm file `ko.txt`, không phải viết code.
- **Thêm loại bằng mới**: Esthetician (chăm sóc da), Barber (cắt tóc nam). Mỗi loại bằng là một ngân hàng câu hỏi mới, dịch sang 3–4 thứ tiếng thì ra 3–4 app.
- **Bảo hiểm**: thêm Property & Casualty, sau đó làm phần luật riêng cho từng bang (50 bang × 2 loại bằng).
- **Bất động sản** (real estate): thị trường lớn nhưng cạnh tranh mạnh, cần chất lượng nội dung cao.

⚠️ **Chính sách spam của Google Play**: không đăng hàng loạt app gần như giống hệt nhau. Mỗi app phải có nội dung thật sự khác (ngân hàng câu hỏi khác, ngôn ngữ khác, kỳ thi khác), có icon, ảnh màn hình và mô tả riêng. Nhà máy này được thiết kế để mỗi app khác nhau ở **nội dung**, không chỉ đổi màu và đổi tên.

## 8. Kênh tiếp cận cho 5 app thị trường quốc tế

| App | Người dùng | Kênh tiếp cận hiệu quả |
|---|---|---|
| `nursegulf` | Điều dưỡng Ấn Độ (Kerala), Philippines, Pakistan, Ai Cập… chuẩn bị đi làm ở vùng Vịnh | Nhóm Facebook và Telegram như "DHA exam nurses", "Prometric reviewer"; trung tâm tuyển dụng điều dưỡng; YouTube Shorts dạng "1 câu Prometric mỗi ngày". Ở Ấn Độ và Philippines nên đặt giá theo sức mua địa phương (₹499, ₱599). |
| `cscsro` / `cscspl` | Thợ xây Romania và Ba Lan mới sang Anh | Nhóm Facebook "Români în UK – construcții", "Polacy w UK – praca budowa"; agency giới thiệu việc làm; TikTok bằng tiếng Romania/Ba Lan. Điểm bán hàng: được nghe đọc đề bằng tiếng mẹ đẻ khi thi (voiceover theo yêu cầu) nhưng phải hiểu thuật ngữ tiếng Anh trên công trường. |
| `sachkunde` | Người học bảo vệ ở Đức, nhiều người nhập cư (Ả Rập, Thổ Nhĩ Kỳ, Ukraina) | Nhóm Facebook "Sachkunde 34a", trung tâm đào tạo bảo vệ, Jobcenter/kurs. Có thể dịch thêm sang tiếng Ả Rập, Thổ Nhĩ Kỳ, Ukraina (chỉ cần thêm file `ar.txt`/`tr.txt`/`uk.txt`) để nhân thành nhiều app. |
| `civilserviceph` | Khoảng 240 nghìn người thi mỗi đợt, 2 đợt/năm, tỷ lệ đậu khoảng 14% | Nhóm Facebook "Civil Service Exam Reviewer" (rất đông thành viên), TikTok giải đề, chia sẻ trong group của các trường. Giá thấp (₱199–249) để bán được số lượng lớn. |

Thứ tự ưu tiên chạy quảng cáo trả phí (khi app đã có ≥ 4.3 sao):
1. `sachkunde` (Đức trả tiền cao)
2. `cscsro` / `cscspl` (Anh)
3. `nursegulf`
4. `civilserviceph`: chủ yếu chỉ nên làm kênh miễn phí, vì chi phí quảng cáo ở Philippines rẻ nhưng giá bán cũng thấp.
