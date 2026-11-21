# Mock Draft GM (bản nháp, Godot 4.3)

Giả lập NFL-style draft cho thị trường Mỹ. Đội, cầu thủ, trường đều **hư cấu** (tránh vấn đề bản quyền NFL/NFLPA).

## Vòng chơi
1. Chọn 1 trong 32 đội và số vòng (1/3/7).
2. Phòng draft: AI các đội chọn theo điểm scout x giá trị vị trí + nhu cầu đội. "Sim to my pick" để tua.
3. Đến lượt bạn: lọc theo vị trí, xem thẻ cầu thủ (grade, chiều cao, cân nặng, 40 yard, nhận xét scout), bấm DRAFT.
4. Kết thúc: điểm draft A+ đến F, xếp hạng trong 32 đội, **lộ diện chỉ số thật** (OVR/POT) với nhãn STEAL / SOLID / BUST RISK.

## Cấu trúc
- `scripts/draft.gd`: dữ liệu, sinh cầu thủ, AI, chấm điểm (autoload `Draft`).
- `scripts/main.gd`: 3 màn hình, UI dựng bằng code.
- `scripts/ui.gd`: nút/khung dùng chung.

## Ý tưởng kiếm tiền (chưa làm)
- Bản miễn phí: 1–3 vòng. Premium (một lần 9,99–19,99$ hoặc subscription mùa draft): 7 vòng, trade pick, chỉnh nhu cầu đội, nhiều mùa (franchise mode).
- Gói "Scouting Pro": xem chỉ số thật trước khi chọn.
- Chia sẻ thẻ kết quả lên mạng xã hội (kênh lan truyền miễn phí).

## Build
Mở thư mục bằng Godot 4.3, hoặc headless: `godot --headless --path . --export-debug Android build/mock-draft-gm-debug.apk` (cần Android SDK + export templates).
