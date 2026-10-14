# 05 — Soạn, dịch & kiểm duyệt câu hỏi

Chất lượng câu hỏi quyết định số sao đánh giá, mà số sao quyết định thứ hạng trên Play. Đây là phần đáng đầu tư nhất.

## Định dạng file

```
[n121] infection              <- id + chủ đề (chủ đề chỉ ghi trong en.txt)
Which agency registers ...?   <- câu hỏi (có thể viết nhiều dòng)
- OSHA                        <- đáp án sai
* EPA                         <- đáp án đúng (bắt buộc trong en.txt)
- FDA
- CDC
> Giải thích ngắn: vì sao đúng, mẹo ghi nhớ.
```

- `en.txt` là **bản gốc**: chủ đề và đáp án đúng chỉ lấy từ file này.
- `vi.txt`, `es.txt`… phải có **cùng id, cùng số đáp án và cùng thứ tự đáp án**. Có thể đánh dấu `*` để `build_banks.py` kiểm tra chéo với bản gốc.
- App **tự xáo thứ tự đáp án** mỗi lần hiển thị, nên không cần lo đáp án đúng bị dồn vào một vị trí.
- Tránh đáp án kiểu "Tất cả các ý trên" hoặc "A và B", vì khi xáo thứ tự sẽ sai nghĩa.
- Id phải tăng dần và **không bao giờ dùng lại id đã xoá**, vì tiến độ học của người dùng lưu theo id.

## Quy tắc nội dung (bắt buộc)

1. **Không sao chép** câu hỏi từ đề thi thật, sách Milady/Pivot Point, sách luyện thi hay app của người khác. Tất cả đều có bản quyền. Hãy tự viết câu hỏi dựa trên **kiến thức chung** và **đề cương thi công khai** (candidate handbook, content outline của PSI/NIC/Pearson VUE/Prometric).
2. Mỗi câu chỉ có **một đáp án đúng rõ ràng**. Các đáp án sai phải hợp lý nhưng sai rõ ràng.
3. Với số liệu khác nhau giữa các bang (thời gian ngâm, giờ học, thời gian free look…), viết "thường là", "theo nhãn sản phẩm" hoặc "theo luật tiểu bang". Phần luật riêng của từng bang nên tách thành bộ câu hỏi riêng.
4. Giải thích ngắn gọn (1–3 câu) và nêu được **lý do** đáp án đúng.
5. Bản dịch tiếng Việt hoặc Tây Ban Nha: ghi kèm **thuật ngữ tiếng Anh trong ngoặc** ở những chỗ quan trọng, ví dụ "Mầm móng (matrix)". Người thi cần biết cả hai.

## Quy trình mở rộng lên 300–500 câu mỗi bộ

1. Lấy đề cương (content outline) chính thức của kỳ thi để biết tỷ lệ phần trăm từng chủ đề, rồi chia số câu theo đúng tỷ lệ đó.
2. Soạn bản nháp tiếng Anh, theo từng lô 20 câu cho mỗi chủ đề. Có thể dùng AI hỗ trợ viết nháp, **nhưng phải có người có chuyên môn duyệt lại từng câu**, ví dụ thợ nail hoặc giáo viên đã có bằng.
3. `python3 tool/build_banks.py` kiểm tra định dạng.
4. Dịch sang các ngôn ngữ khác. Nhờ người bản ngữ trong nghề đọc lại khoảng 10% số câu dịch, chọn ngẫu nhiên.
5. Tăng `version` trong `meta.json`, rồi build và phát hành bản cập nhật. Trong release notes ghi rõ "Thêm 100 câu mới".

## Xử lý khi người dùng báo câu sai

- Sửa ngay trong `en.txt` và các bản dịch, **giữ nguyên id**.
- Trả lời review của người đó: "Cảm ơn bạn, đã sửa trong bản x.y".
