# Hướng dẫn đưa 15 app lên Google Play (tổng hợp)

> File được tạo tự động bởi `python3 tool/store_guide.py` từ `apps/*.json`, `store/` và `docs/`. Sửa nguồn rồi chạy lại lệnh, đừng sửa tay file này.

**Mục lục:** Phần A (làm chung) · Phần B (từng app) · Phụ lục (tài liệu 01–09, README).

Phần B:
1. [Civil Service Exam Reviewer (civilserviceph)](#1-civil-service-exam-reviewer-civilserviceph)
2. [Cosmetology Exam in Spanish (cosmoes)](#2-cosmetology-exam-in-spanish-cosmoes)
3. [Cosmetology Exam Vietnamese (cosmovi)](#3-cosmetology-exam-vietnamese-cosmovi)
4. [CSCS Test in Polish (cscspl)](#4-cscs-test-in-polish-cscspl)
5. [CSCS Test in Romanian (cscsro)](#5-cscs-test-in-romanian-cscsro)
6. [Life & Health Insurance Exam (insurancelh)](#6-life--health-insurance-exam-insurancelh)
7. [Nail Tech Exam in Spanish (nailes)](#7-nail-tech-exam-in-spanish-nailes)
8. [Nail Exam Prep - Vietnamese (nailvi)](#8-nail-exam-prep---vietnamese-nailvi)
9. [Gulf Nursing Exam Prep (nursegulf)](#9-gulf-nursing-exam-prep-nursegulf)
10. [Security Exam §34a Germany (sachkunde)](#10-security-exam-34a-germany-sachkunde)
11. [Domino Dots: Logic Puzzle (dominodots)](#11-domino-dots-logic-puzzle-dominodots)
12. [Meow Queens: Cat Logic Puzzle (meowqueens)](#12-meow-queens-cat-logic-puzzle-meowqueens)
13. [Patch Grid: Rectangle Logic (patchgrid)](#13-patch-grid-rectangle-logic-patchgrid)
14. [Putt Puzzle: Daily Mini Golf (puttpuzzle)](#14-putt-puzzle-daily-mini-golf-puttpuzzle)
15. [Word Weave: Hidden Words (wordweave)](#15-word-weave-hidden-words-wordweave)

## Phần A — Làm chung cho cả 15 app

### A0. Tình trạng

| Việc | Trạng thái |
|---|---|
| Code 15 app, câu hỏi 250 câu/app, 5 game | ✅ |
| Icon, feature graphic, ảnh màn hình, nội dung store mọi ngôn ngữ | ✅ trong `store/` và `games/store/` |
| Email hỗ trợ `tuanlt1989@gmail.com`, tên nhà phát triển `Tuan Apps` | ✅ (đổi trong `apps/*.json` nếu muốn khác, rồi chạy `python3 tool/factory.py`) |
| 4 secrets khoá ký trên GitHub | ✅ bạn đã thêm |
| AAB đã ký cho 15 app | ✅ tự build mỗi lần push: [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) |
| Trang chính sách bảo mật (GitHub Pages) | ⬜ bật 1 lần ở mục A2 |
| `PLAY_SERVICE_ACCOUNT_JSON` (upload tự động) | ⬜ không bắt buộc, mục A5 |

### A1. Danh sách app

| # | id | Tên (en) | Mã app (không đổi được sau khi upload) |
|---|---|---|---|
| 1 | `civilserviceph` | Civil Service Exam Reviewer PH | `com.tuanapps.civilserviceph` |
| 2 | `cosmoes` | Cosmetology Exam (Spanish) | `com.tuanapps.cosmoes` |
| 3 | `cosmovi` | Cosmetology Exam Prep (Vietnamese) | `com.tuanapps.cosmovi` |
| 4 | `cscspl` | CSCS Test in Polish | `com.tuanapps.cscspl` |
| 5 | `cscsro` | CSCS Test in Romanian | `com.tuanapps.cscsro` |
| 6 | `insurancelh` | Life & Health Insurance Exam Prep | `com.tuanapps.insurancelh` |
| 7 | `nailes` | Nail Tech Exam (Spanish) | `com.tuanapps.nailes` |
| 8 | `nailvi` | Nail Exam Prep (Vietnamese) | `com.tuanapps.nailvi` |
| 9 | `nursegulf` | Gulf Nursing Exam Prep | `com.tuanapps.nursegulf` |
| 10 | `sachkunde` | Security Exam §34a (Germany) | `com.tuanapps.sachkunde` |
| 11 | `dominodots` | Domino Dots: Logic Puzzle | `com.tuanapps.dominodots` |
| 12 | `meowqueens` | Meow Queens: Cat Logic Puzzle | `com.tuanapps.meowqueens` |
| 13 | `patchgrid` | Patch Grid: Rectangle Logic | `com.tuanapps.patchgrid` |
| 14 | `puttpuzzle` | Putt Puzzle: Daily Mini Golf | `com.tuanapps.puttpuzzle` |
| 15 | `wordweave` | Word Weave: Hidden Words | `com.tuanapps.wordweave` |

### A2. Bật trang chính sách bảo mật (1 lần)
1. <https://github.com/tuanlt1989/assignment/settings/pages> → **Source**: *Deploy from a branch* → **Branch** `exam-prep-apps`, thư mục **`/docs`** → **Save**.
2. Sau 1–3 phút mở thử <https://tuanlt1989.github.io/assignment/privacy/nailvi.html>. Cả 15 trang có dạng `…/privacy/<id>.html`.

### A3. Thứ tự đưa 1 app lên
1. **Create app** → tên (mục "App name" của app) → **English (United States) – en-US** → App/Game theo bảng → **Free** → Create.
2. **App content**: điền theo bảng 📋 của app.
3. **Store settings** + **Main store listing**: dán chữ ✍️, upload ảnh 🖼. **Manage translations → Add your own translations**: thêm các ngôn ngữ còn lại.
4. **Testing → Internal testing → Create new release**: để mặc định Play App Signing, upload `app-<id>-release.aab`, release notes → **Save and publish**. Thêm Gmail của bạn vào Testers.
5. Tạo sản phẩm 🛒 (mục A4) → **Setup → License testing** thêm Gmail → cài từ link tester → mua thử.
6. **Closed testing** ≥12 tester × 14 ngày (tài khoản cá nhân); dùng chung 1 Google Group cho cả 15 app → **Apply for production**.
7. **Production** → chọn quốc gia theo bảng → **Create new release** → *Add from library* → rollout 20% → 100%.

> Mẹo: làm bước 1–5 cho cả 15 app trong cùng 1–2 ngày, để 15 app chạy closed test song song.

### A4. Tạo one-time product `premium_lifetime` (từng bước, giống nhau cho mọi app)
**Bước 0: điều kiện:** đã upload ít nhất 1 file `.aab` (Internal testing là đủ); Payments profile không bị hold.

**Bước 1:** Play Console → chọn app → **Monetize with Play → Products → One-time products** → **Create one-time product**.

**Bước 2:** điền Product ID, Name, Description theo bảng 🛒 của app. Ngôn ngữ mặc định **en-US** → **Save**.

**Bước 3:** **Add purchase option** → ID `buy` · Type **Buy** (giữ *Backwards compatible*).

**Bước 4:** giá theo bảng của app → **Update exchange rates** → sửa tay các nước được ghi → Availability.

**Bước 5:** **Activate** purchase option → **Activate** sản phẩm. Sau 5–30 phút nút mua trong app hiện giá.

**Bước 6:** **Settings → License testing** → thêm Gmail → cài app **từ link Internal testing** (không cài APK tay) → mua thử ("Test card, always approves").

Chi tiết và cách sửa lỗi: Phụ lục, mục 06.

### A5. Từ lần cập nhật thứ 2: bấm 1 nút
1. Tạo service account và thêm secret `PLAY_SERVICE_ACCOUNT_JSON` (Phụ lục, mục 09).
2. [Actions → Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) → **Run workflow** → `apps` = `nailvi` (hoặc `nailvi,cosmovi` hoặc `all`), `track` = internal/production. Workflow tự build, ký, upload AAB + toàn bộ trang store.
3. Hoặc nhắn Claude: *"up nailvi lên internal"*.

### A6. Release notes chung khi cập nhật
```
<en-US>
• More practice questions and clearer explanations
• Bug fixes and performance improvements
</en-US>
```

---

## Phần B — Từng app

## 1. Civil Service Exam Reviewer (civilserviceph)

| | |
|---|---|
| Mã app | `com.tuanapps.civilserviceph` |
| Loại | App → **Education** |
| Thị trường | 🇵🇭 Philippines |
| Ngôn ngữ store | `en-US` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/civilserviceph.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Khoảng 240 nghìn người thi Civil Service Exam mỗi đợt, tỷ lệ đậu chỉ khoảng 14%; Philippines dùng Android là chủ yếu.

**Kiếm tiền:** miễn phí khoảng 35% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 60 câu/70 phút (đậu 80%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`civilserviceph-buildN`** → giải nén → **`app-civilserviceph-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = civilserviceph` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **₱249** (Philippines) → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/civilserviceph/metadata/android/en-US/images/icon.png` · `store/civilserviceph/metadata/android/en-US/images/featureGraphic.png` · `store/civilserviceph/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (27/30)
```
Civil Service Exam Reviewer
```
Short description (79/80)
```
CSE Professional & Subprofessional reviewer: practice tests, answers explained.
```
Full description
```
Pass the Civil Service Exam (CSE-PPT) for Professional and Subprofessional levels with focused practice and clear explanations.

Only a small share of examinees pass each exam. Smart, regular practice on every subtest makes the difference.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Original practice items for every part of the exam: verbal ability (vocabulary, grammar, analogies), reading comprehension, numerical ability (percent, ratio, word problems, series), analytical ability (logic, coding, patterns) and general information (Philippine Constitution, RA 6713, government, environment and human rights)
• Step-by-step explanations for every item
• Timed mock exams with an 80% passing target
• Practice by subtest, Quick 10, review your mistakes, save hard items
• Readiness score that tracks your progress
• No ads. Works offline. No account needed

FREE AND PREMIUM
Practise part of every subtest for free. Unlock every item and unlimited mock exams with one small one-time payment. No subscription.

IMPORTANT
This is an independent reviewer. It is not affiliated with or endorsed by the Civil Service Commission or any government agency. All items are original practice questions. Check the official CSC announcement for exam dates, coverage and requirements.
```

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/civilserviceph.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của Civil Service Commission (CSC); mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.

### 🚀 Tăng lượt tải

1. Nhóm Facebook "Civil Service Exam Reviewer" (rất đông thành viên), TikTok PH.
2. Đăng trước mỗi kỳ thi (tháng 3 và tháng 8 hằng năm) 4–6 tuần.

---

## 2. Cosmetology Exam in Spanish (cosmoes)

| | |
|---|---|
| Mã app | `com.tuanapps.cosmoes` |
| Loại | App → **Education** |
| Thị trường | 🇺🇸 Mỹ, 🇵🇷 Puerto Rico |
| Ngôn ngữ store | `en-US`, `es-US` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/cosmoes.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Cosmetology bằng tiếng Tây Ban Nha: thị trường lớn ở TX, FL, CA, NY và Puerto Rico.

**Kiếm tiền:** miễn phí khoảng 40% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 50 câu/50 phút (đậu 75%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`cosmoes-buildN`** → giải nén → **`app-cosmoes-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = cosmoes` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $12.99** → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/cosmoes/metadata/android/en-US/images/icon.png` · `store/cosmoes/metadata/android/en-US/images/featureGraphic.png` · `store/cosmoes/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`
(Ảnh riêng cho `es-US` nằm trong thư mục cùng tên.)

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (27/30)
```
Cosmetology Exam in Spanish
```
Short description (77/80)
```
Cosmetology state board written exam practice in Spanish with English toggle.
```
Full description
```
Study for your cosmetology state board written exam in Spanish, with English one tap away.

Original practice questions written in clear Spanish, each with an instant English version so you also learn the English salon terms.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Practice questions on the main exam topics: infection control and safety, hair and scalp science, haircoloring, perms, relaxers and chemistry, haircutting and styling, and skin care, makeup, hair removal and electricity
• Bilingual Spanish and English questions and explanations
• Timed mock exams with a passing score
• An explanation for every answer
• Practice by topic, Quick 10, review mistakes, save questions
• Readiness score, no ads, works offline, no account needed

FREE AND PREMIUM
Practice part of every topic for free. Unlock all questions and unlimited full mock exams with a single one-time purchase. No subscription.

IMPORTANT
This is an independent study tool, not affiliated with or endorsed by any state board, PSI, Pearson VUE, NIC or other exam provider. All questions are original practice items. Check your state's candidate handbook for the exact format and languages.
```

<details><summary>Spanish (United States) – es-US: bấm để mở</summary>

**Spanish (United States) – es-US**

App name (22/30)
```
Examen de Cosmetología
```
Short description (77/80)
```
Practica el examen escrito de cosmetología del estado en español, con inglés.
```
Full description
```
Prepárate para el examen escrito de cosmetología de la junta estatal en español, con inglés a un toque.

Preguntas de práctica originales escritas en un español claro, cada una con su versión en inglés para que aprendas también los términos del salón.

QUÉ INCLUYE
• 250 preguntas de práctica originales con explicaciones claras
• Plan de estudio personal: fija tu fecha de examen y meta diaria, con recordatorio diario
• Tarjetas de memoria, repaso de tu tema más débil y racha diaria
• Preguntas sobre los temas principales: control de infecciones y seguridad, ciencia del cabello y cuero cabelludo, coloración, permanentes, alisadores y química, corte y peinado, y cuidado de la piel, maquillaje, depilación y electricidad
• Preguntas y explicaciones bilingües español–inglés
• Exámenes de práctica cronometrados con puntaje para aprobar
• Explicación de cada respuesta
• Practica por tema, Rápido 10, repasa errores y guarda preguntas
• Puntaje de preparación, sin anuncios, funciona sin internet y sin cuenta

GRATIS Y PREMIUM
Practica parte de cada tema gratis. Desbloquea todas las preguntas y exámenes ilimitados con un solo pago único. Sin suscripción.

IMPORTANTE
Herramienta de estudio independiente. No está afiliada ni respaldada por ninguna junta estatal, PSI, Pearson VUE, NIC u otro proveedor de exámenes. Todas las preguntas son originales. Consulta el manual del candidato de tu estado.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/cosmoes.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của NIC, PSI, Pearson VUE, state board; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.

### 🚀 Tăng lượt tải

1. Nhóm Facebook "Cosmetología en USA", trường beauty khu Latino.

---

## 3. Cosmetology Exam Vietnamese (cosmovi)

| | |
|---|---|
| Mã app | `com.tuanapps.cosmovi` |
| Loại | App → **Education** |
| Thị trường | 🇺🇸 Mỹ |
| Ngôn ngữ store | `en-US`, `vi` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/cosmovi.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Giống app Nail: kỳ thi Cosmetology có bản tiếng Việt ở nhiều bang, nhưng tài liệu ôn tiếng Việt rất hiếm.

**Kiếm tiền:** miễn phí khoảng 40% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 50 câu/50 phút (đậu 75%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`cosmovi-buildN`** → giải nén → **`app-cosmovi-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = cosmovi` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $14.99** → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/cosmovi/metadata/android/en-US/images/icon.png` · `store/cosmovi/metadata/android/en-US/images/featureGraphic.png` · `store/cosmovi/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`
(Ảnh riêng cho `vi` nằm trong thư mục cùng tên.)

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (27/30)
```
Cosmetology Exam Vietnamese
```
Short description (80/80)
```
Cosmetology state board written exam practice in Vietnamese with English toggle.
```
Full description
```
Study for your cosmetology state board written exam in Vietnamese, with English one tap away.

Original practice questions written in natural Vietnamese, each with an instant English version so you also learn the English salon terms.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Practice questions on the main cosmetology exam topics: infection control and safety, hair and scalp science, haircoloring, perms, relaxers and chemistry, haircutting and styling, and skin care, makeup, hair removal and electricity
• Bilingual Vietnamese and English questions and explanations
• Timed mock exams with a passing score
• An explanation for every answer
• Practice by topic, Quick 10, review mistakes, save hard questions
• Readiness score, no ads, works offline, no account needed

FREE AND PREMIUM
Practice part of every topic for free. Unlock every question and unlimited full mock exams with one one-time purchase. No subscription.

IMPORTANT
This is an independent study tool, not affiliated with or endorsed by any state board, PSI, Pearson VUE, NIC or other exam provider. All questions are original practice items. Check your state board's candidate handbook for the exact exam format and language options.
```

<details><summary>Vietnamese – vi: bấm để mở</summary>

**Vietnamese – vi**

App name (26/30)
```
Thi Cosmetology Tiếng Việt
```
Short description (71/80)
```
Ôn thi bằng Cosmetology bằng tiếng Việt, có tiếng Anh. Thi thử bấm giờ.
```
Full description
```
Ôn thi viết bằng Cosmetology của State Board bằng tiếng Việt, xem tiếng Anh chỉ với một chạm.

Bộ câu hỏi luyện tập tự biên soạn, viết bằng tiếng Việt dễ hiểu, mỗi câu đều có bản tiếng Anh để bạn học luôn thuật ngữ trong tiệm.

CÓ GÌ TRONG APP
• 250 câu hỏi luyện tập tự biên soạn, có giải thích rõ ràng
• Kế hoạch học riêng: chọn ngày thi, số câu mỗi ngày, có nhắc học hằng ngày
• Thẻ ghi nhớ, ôn chủ đề yếu nhất, chuỗi ngày học liên tục
• Câu hỏi theo các chủ đề chính của đề thi Cosmetology: kiểm soát nhiễm khuẩn & an toàn, cấu tạo tóc & da đầu, nhuộm tóc, uốn – duỗi & hoá học, cắt & tạo kiểu tóc, chăm sóc da – trang điểm – tẩy lông & điện
• Song ngữ Việt – Anh cho câu hỏi và giải thích
• Thi thử bấm giờ, có điểm đậu
• Giải thích cho từng câu
• Luyện theo chủ đề, luyện nhanh 10 câu, ôn câu sai, lưu câu khó
• Điểm sẵn sàng, không quảng cáo, dùng không cần mạng, không cần tài khoản

MIỄN PHÍ VÀ BẢN ĐẦY ĐỦ
Mỗi chủ đề đều có câu hỏi miễn phí. Mở khoá toàn bộ câu hỏi và thi thử không giới hạn chỉ với một lần mua. Không thu phí hằng tháng.

LƯU Ý
Đây là công cụ ôn tập độc lập, không liên kết hay được bảo trợ bởi bất kỳ State Board, PSI, Pearson VUE, NIC hay đơn vị tổ chức thi nào. Toàn bộ câu hỏi do chúng tôi tự biên soạn. Hãy kiểm tra cẩm nang thí sinh của State Board nơi bạn thi.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/cosmovi.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của NIC, PSI, Pearson VUE, state board; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.

### 🚀 Tăng lượt tải

1. Nhóm Facebook thợ tóc/thẩm mỹ người Việt ở Mỹ, trường beauty của người Việt.
2. Bán chéo với app Nail (cùng người dùng).

---

## 4. CSCS Test in Polish (cscspl)

| | |
|---|---|
| Mã app | `com.tuanapps.cscspl` |
| Loại | App → **Education** |
| Thị trường | 🇬🇧 Anh |
| Ngôn ngữ store | `en-US`, `pl-PL` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/cscspl.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Thợ xây Ba Lan là nhóm lao động nước ngoài lớn trong ngành xây dựng ở Anh; cần thẻ CSCS để vào công trường.

**Kiếm tiền:** miễn phí khoảng 30% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 50 câu/45 phút (đậu 90%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`cscspl-buildN`** → giải nén → **`app-cscspl-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = cscspl` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **£7.99** (Anh) → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/cscspl/metadata/android/en-US/images/icon.png` · `store/cscspl/metadata/android/en-US/images/featureGraphic.png` · `store/cscspl/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`
(Ảnh riêng cho `pl-PL` nằm trong thư mục cùng tên.)

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (19/30)
```
CSCS Test in Polish
```
Short description (66/80)
```
CSCS HS&E Operatives test practice in Polish, with English on tap.
```
Full description
```
Practise for the CITB Health, Safety and Environment (HS&E) test for Operatives, the test you need for a CSCS card, in Polish with the English version one tap away.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Original questions on the main test topics: legal duties and site rules, health and welfare, PPE, electricity, fire and work at height, plant, lifting, excavations and confined spaces, and environment and good practice
• Polish + English for every question and explanation
• Timed mock tests with a 90% pass target
• Explanations for every answer
• Practice by topic, Quick 10, review mistakes, save questions
• No ads. Works offline. No account needed

FREE AND PREMIUM
Practise part of every topic for free. Unlock every question and unlimited mock tests with one one-time purchase. No subscription.

IMPORTANT
This is an independent study tool. It is not affiliated with or endorsed by CITB, CSCS or Pearson VUE. All questions are original practice items.
```

<details><summary>Polish – pl-PL: bấm để mở</summary>

**Polish – pl-PL**

App name (19/30)
```
Test CSCS po polsku
```
Short description (79/80)
```
Przygotowanie do testu CSCS (HS&E Operatives) po polsku, z angielskim pod ręką.
```
Full description
```
Przygotuj się do testu CITB Health, Safety and Environment (HS&E) dla Operatives, potrzebnego do karty CSCS i pracy na brytyjskich budowach.

Autorskie pytania napisane prostym polskim. Jednym kliknięciem zobaczysz to samo pytanie po angielsku, więc nauczysz się też słownictwa używanego na budowie.

CO ZAWIERA
• 250 autorskich pytań ćwiczeniowych z jasnymi wyjaśnieniami
• Osobisty plan nauki: data egzaminu, cel dzienny i codzienne przypomnienie
• Fiszki, powtórka najsłabszego działu i seria dni nauki
• Pytania z głównych tematów testu: obowiązki prawne i zasady na budowie, zdrowie i warunki socjalne (pył, hałas, COSHH, azbest, ręczne przenoszenie), ŚOI, prąd, pożar i praca na wysokości, maszyny, podnoszenie, wykopy i przestrzenie zamknięte, środowisko i dobre praktyki
• Polski + angielski przy każdym pytaniu i wyjaśnieniu
• Egzaminy próbne z limitem czasu i progiem 90%
• Wyjaśnienie każdej odpowiedzi
• Ćwiczenia według tematów, Szybkie 10, powtórka błędów, zapisane pytania
• Bez reklam. Działa offline. Bez konta

ZA DARMO I PREMIUM
Część pytań z każdego tematu za darmo. Odblokuj wszystkie pytania i nielimitowane egzaminy próbne jedną płatnością. Bez subskrypcji.

WAŻNE
Niezależna aplikacja do nauki. Nie jest powiązana z CITB, CSCS ani Pearson VUE ani przez nie zatwierdzona. Wszystkie pytania są autorskie. Przed rezerwacją testu sprawdź oficjalne informacje CITB.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/cscspl.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của CITB, CSCS, Pearson VUE; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.
- "CSCS" là thương hiệu của CSCS Ltd. Nếu Google phản hồi về thương hiệu, đổi tên thành "Test HS&E pentru construcții" / "Test BHP budowa UK".

### 🚀 Tăng lượt tải

1. Nhóm Facebook "Polacy w UK", "Praca budowlana UK".
2. Diễn đàn Polish Express / MojaWyspa.

---

## 5. CSCS Test in Romanian (cscsro)

| | |
|---|---|
| Mã app | `com.tuanapps.cscsro` |
| Loại | App → **Education** |
| Thị trường | 🇬🇧 Anh |
| Ngôn ngữ store | `en-US`, `ro` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/cscsro.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Hàng trăm nghìn thợ xây Romania làm việc ở Anh phải đậu bài thi HS&E để có thẻ CSCS vào công trường; tài liệu tiếng Romania rất ít.

**Kiếm tiền:** miễn phí khoảng 30% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 50 câu/45 phút (đậu 90%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`cscsro-buildN`** → giải nén → **`app-cscsro-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = cscsro` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **£7.99** (Anh) → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/cscsro/metadata/android/en-US/images/icon.png` · `store/cscsro/metadata/android/en-US/images/featureGraphic.png` · `store/cscsro/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`
(Ảnh riêng cho `ro` nằm trong thư mục cùng tên.)

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (21/30)
```
CSCS Test in Romanian
```
Short description (68/80)
```
CSCS HS&E Operatives test practice in Romanian, with English on tap.
```
Full description
```
Practise for the CITB Health, Safety and Environment (HS&E) test for Operatives, the test you need for a CSCS card, in Romanian with the English version one tap away.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Original questions on the main test topics: legal duties and site rules, health and welfare, PPE, electricity, fire and work at height, plant, lifting, excavations and confined spaces, and environment and good practice
• Romanian + English for every question and explanation
• Timed mock tests with a 90% pass target
• Explanations for every answer
• Practice by topic, Quick 10, review mistakes, save questions
• No ads. Works offline. No account needed

FREE AND PREMIUM
Practise part of every topic for free. Unlock every question and unlimited mock tests with one one-time purchase. No subscription.

IMPORTANT
This is an independent study tool. It is not affiliated with or endorsed by CITB, CSCS or Pearson VUE. All questions are original practice items.
```

<details><summary>Romanian – ro: bấm để mở</summary>

**Romanian – ro**

App name (19/30)
```
Test CSCS în Română
```
Short description (77/80)
```
Pregătire pentru testul CSCS (HS&E Operatives) în română, cu engleza alături.
```
Full description
```
Pregătește-te pentru testul CITB Health, Safety and Environment (HS&E) pentru Operatives, ca să obții cardul CSCS și să lucrezi pe șantierele din Marea Britanie.

Întrebări originale scrise într-o română clară. Cu un singur click vezi aceeași întrebare în engleză, ca să înveți și termenii folosiți pe șantier.

CE PRIMEȘTI
• 250 de întrebări de exersare originale, cu explicații clare
• Plan de studiu personal: data examenului, obiectiv zilnic și memento zilnic
• Cartonașe, exersarea celui mai slab capitol și seria de zile de studiu
• Întrebări pe temele principale ale testului: obligații legale și reguli de șantier, sănătate și bunăstare (praf, zgomot, COSHH, azbest, manipulare manuală), EIP, electricitate, incendiu și lucru la înălțime, utilaje, ridicări, excavații și spații închise, mediu și bune practici
• Română + engleză pentru fiecare întrebare și explicație
• Teste simulate cu cronometru, cu prag de promovare 90%
• Explicație la fiecare răspuns
• Exersare pe teme, Rapid 10, greșeli de recapitulat, întrebări salvate
• Fără reclame. Merge offline. Fără cont

GRATUIT ȘI PREMIUM
Exersează gratuit o parte din fiecare temă. Deblochează toate întrebările și teste simulate nelimitate cu o singură plată. Fără abonament.

IMPORTANT
Aplicație de studiu independentă. Nu este afiliată și nu este aprobată de CITB, CSCS sau Pearson VUE. Toate întrebările sunt originale. Verifică informațiile oficiale CITB înainte de a programa testul.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/cscsro.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của CITB, CSCS, Pearson VUE; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.
- "CSCS" là thương hiệu của CSCS Ltd. Nếu Google phản hồi về thương hiệu, đổi tên thành "Test HS&E pentru construcții" / "Test BHP budowa UK".

### 🚀 Tăng lượt tải

1. Nhóm Facebook "Români în UK", "Muncă în construcții UK".
2. Đại lý tuyển thợ xây sang Anh.

---

## 6. Life & Health Insurance Exam (insurancelh)

| | |
|---|---|
| Mã app | `com.tuanapps.insurancelh` |
| Loại | App → **Education** |
| Thị trường | 🇺🇸 Mỹ |
| Ngôn ngữ store | `en-US` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/insurancelh.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Mỗi năm hàng trăm nghìn người thi chứng chỉ đại lý bảo hiểm Life & Health ở Mỹ, chịu chi cho tài liệu ôn (khoá học thường $50–$200).

**Kiếm tiền:** miễn phí khoảng 35% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 60 câu/75 phút (đậu 70%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`insurancelh-buildN`** → giải nén → **`app-insurancelh-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = insurancelh` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $19.99** → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/insurancelh/metadata/android/en-US/images/icon.png` · `store/insurancelh/metadata/android/en-US/images/featureGraphic.png` · `store/insurancelh/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (28/30)
```
Life & Health Insurance Exam
```
Short description (77/80)
```
Practice for the life and health insurance producer license exam. Mock tests.
```
Full description
```
Get ready for your life and health insurance producer (agent) license exam with clear practice questions and explanations.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Original practice questions covering the general (national) portion of most life and health exams: insurance basics and contract law, life insurance policies and riders, policy provisions, options and beneficiaries, annuities, retirement plans and taxation, health and disability insurance with the uniform provisions, and group insurance, Medicare, Medigap, long-term care and unfair trade practices
• Timed mock exams with a passing score
• A short explanation for every answer
• Practice by topic, Quick 10, review your mistakes, and save tricky questions
• Readiness score that tracks your progress
• No ads. Works offline. No account needed

FREE AND PREMIUM
Practice part of every topic for free. Unlock every question and unlimited full mock exams with one one-time purchase. No subscription.

IMPORTANT
Each state adds its own laws and rules to the exam. Use this app for the general portion and study your state-specific section from your state's official content outline. This is an independent study tool and is not affiliated with or endorsed by any state department of insurance, Pearson VUE, PSI, Prometric or any exam provider. All questions are original practice items.
```

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/insurancelh.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của Pearson VUE, PSI, Prometric, NAIC, state Department of Insurance; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.

### 🚀 Tăng lượt tải

1. Reddit r/Insurance, r/InsuranceAgent (đọc luật trước khi đăng).
2. Nhóm Facebook tuyển đại lý bảo hiểm; người tuyển dụng hay giới thiệu tài liệu ôn cho người mới.

---

## 7. Nail Tech Exam in Spanish (nailes)

| | |
|---|---|
| Mã app | `com.tuanapps.nailes` |
| Loại | App → **Education** |
| Thị trường | 🇺🇸 Mỹ, 🇵🇷 Puerto Rico |
| Ngôn ngữ store | `en-US`, `es-US` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/nailes.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Thợ nail nói tiếng Tây Ban Nha ở Mỹ được thi bằng tiếng Tây Ban Nha ở nhiều bang; app ôn thi song ngữ Tây Ban Nha–Anh còn rất ít.

**Kiếm tiền:** miễn phí khoảng 40% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 50 câu/50 phút (đậu 75%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`nailes-buildN`** → giải nén → **`app-nailes-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = nailes` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $12.99** → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/nailes/metadata/android/en-US/images/icon.png` · `store/nailes/metadata/android/en-US/images/featureGraphic.png` · `store/nailes/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`
(Ảnh riêng cho `es-US` nằm trong thư mục cùng tên.)

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (25/30)
```
Nail Tech Exam in Spanish
```
Short description (80/80)
```
Practice for the nail technician state board exam in Spanish, with English help.
```
Full description
```
Prepare for your nail technician (manicurist) state board written exam in Spanish, with the English version one tap away.

Many states offer the nail theory exam in Spanish. This app gives you original practice questions written in clear, natural Spanish, plus an instant English toggle so you also learn the English terms used in salons and by clients.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Original practice questions on the main exam topics: infection control and safety, nail and skin anatomy, nail disorders, chemistry and product safety (SDS), manicure and pedicure, and nail enhancements (acrylic, gel, tips, wraps, dip)
• Bilingual Spanish and English questions and explanations
• Timed mock exams with a passing score
• An explanation for every answer
• Practice by topic, Quick 10, review mistakes, save questions
• Readiness score, no ads, works offline, no account needed

FREE AND PREMIUM
Practice part of every topic for free. Unlock all questions and unlimited full mock exams with one one-time purchase. No subscription.

IMPORTANT
This is an independent study tool, not affiliated with or endorsed by any state board, PSI, Pearson VUE, NIC or other exam provider. All questions are original practice items. Check your state's candidate handbook for the exact exam format and languages.
```

<details><summary>Spanish (United States) – es-US: bấm để mở</summary>

**Spanish (United States) – es-US**

App name (25/30)
```
Examen de Uñas en Español
```
Short description (80/80)
```
Practica para el examen de manicurista (uñas) del estado en español, con inglés.
```
Full description
```
Prepárate para el examen escrito de técnico de uñas (manicurista) de la junta estatal en español, con la versión en inglés a un toque.

Muchos estados ofrecen el examen teórico de uñas en español. Esta app tiene preguntas de práctica originales escritas en un español claro y natural, y un botón para ver cada pregunta en inglés y aprender los términos que se usan en el salón.

QUÉ INCLUYE
• 250 preguntas de práctica originales con explicaciones claras
• Plan de estudio personal: fija tu fecha de examen y meta diaria, con recordatorio diario
• Tarjetas de memoria, repaso de tu tema más débil y racha diaria
• Preguntas de práctica originales sobre los temas principales: control de infecciones y seguridad, anatomía de uñas y piel, trastornos de las uñas, química y seguridad de productos (SDS), manicura y pedicura, y uñas artificiales (acrílico, gel, tips, envolturas, dip)
• Bilingüe: preguntas y explicaciones en español con inglés al instante
• Exámenes de práctica cronometrados con puntaje para aprobar
• Explicación de cada respuesta
• Practica por tema, Rápido 10, repasa tus errores y guarda preguntas
• Puntaje de preparación, sin anuncios, funciona sin internet y sin cuenta

GRATIS Y PREMIUM
Practica parte de cada tema gratis. Desbloquea todas las preguntas y exámenes de práctica ilimitados con un solo pago único. Sin suscripción.

IMPORTANTE
Esta es una herramienta de estudio independiente. No está afiliada ni respaldada por ninguna junta estatal, PSI, Pearson VUE, NIC u otro proveedor de exámenes. Todas las preguntas son originales. Consulta el manual del candidato de tu estado para conocer el formato y los idiomas del examen.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/nailes.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của NIC, PSI, Pearson VUE, state board; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.

### 🚀 Tăng lượt tải

1. Nhóm Facebook "Manicuristas en USA", trường thẩm mỹ khu Latino (TX, FL, CA).
2. Reels/TikTok tiếng Tây Ban Nha: "Preguntas del examen de uñas".

---

## 8. Nail Exam Prep - Vietnamese (nailvi)

| | |
|---|---|
| Mã app | `com.tuanapps.nailvi` |
| Loại | App → **Education** |
| Thị trường | 🇺🇸 Mỹ |
| Ngôn ngữ store | `en-US`, `vi` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/nailvi.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Nhiều bang ở Mỹ cho thi lý thuyết Nail bằng tiếng Việt, và phần lớn thợ nail ở Mỹ là người Việt, nhưng app ôn thi tiếng Việt chất lượng gần như không có.

**Kiếm tiền:** miễn phí khoảng 40% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 50 câu/50 phút (đậu 75%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`nailvi-buildN`** → giải nén → **`app-nailvi-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = nailvi` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $14.99** → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/nailvi/metadata/android/en-US/images/icon.png` · `store/nailvi/metadata/android/en-US/images/featureGraphic.png` · `store/nailvi/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`
(Ảnh riêng cho `vi` nằm trong thư mục cùng tên.)

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (27/30)
```
Nail Exam Prep - Vietnamese
```
Short description (73/80)
```
Nail tech license exam practice in Vietnamese & English, with mock tests.
```
Full description
```
Study for your nail technician (manicurist) state board written exam in Vietnamese, with English on tap.

Many states let you take the nail theory exam in Vietnamese, but good study material in Vietnamese is hard to find. This app gives you clear, original practice questions written in natural Vietnamese, and one tap shows the same question in English so you also learn the English terms you hear in the salon.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Original practice questions covering the main exam topics: infection control and safety, nail and skin anatomy, nail disorders and diseases, chemistry and product safety (SDS), manicure and pedicure, and nail enhancements (acrylic, gel, tips, wraps, dip)
• Bilingual: Vietnamese questions and explanations with an instant English toggle
• Timed mock exams with a passing score, just like test day
• An explanation for every answer, so you learn why
• Practice by topic, Quick 10, review your mistakes, and save hard questions
• Readiness score that shows how close you are to passing
• No ads. Works offline. No account needed

FREE AND PREMIUM
Practice part of every topic for free. Unlock every question and unlimited full mock exams with a single one-time purchase. No subscription.

WHO IT'S FOR
Nail students and manicurists preparing for the written (theory) exam in states such as California, Texas, Pennsylvania, Virginia, Tennessee, Kentucky and others that offer the exam in Vietnamese. Check your state board's candidate handbook for the exact exam format and language options.

IMPORTANT
This is an independent study tool. It is not affiliated with or endorsed by any state board, PSI, Pearson VUE, NIC or other exam provider. All questions are original practice items written to cover published exam topics.
```

<details><summary>Vietnamese – vi: bấm để mở</summary>

**Vietnamese – vi**

App name (25/30)
```
Luyện Thi Nail Tiếng Việt
```
Short description (77/80)
```
Ôn thi bằng Nail (manicurist) bằng tiếng Việt, có tiếng Anh. Thi thử bấm giờ.
```
Full description
```
Ôn thi lý thuyết bằng Nail (manicurist) bằng tiếng Việt, xem tiếng Anh chỉ với một chạm.

Nhiều tiểu bang cho thi lý thuyết Nail bằng tiếng Việt, nhưng tài liệu ôn tiếng Việt chất lượng rất hiếm. App này có bộ câu hỏi luyện tập tự biên soạn, viết bằng tiếng Việt dễ hiểu, và chạm một lần là xem được câu hỏi bằng tiếng Anh để bạn học luôn thuật ngữ dùng trong tiệm.

CÓ GÌ TRONG APP
• 250 câu hỏi luyện tập tự biên soạn, có giải thích rõ ràng
• Kế hoạch học riêng: chọn ngày thi, số câu mỗi ngày, có nhắc học hằng ngày
• Thẻ ghi nhớ, ôn chủ đề yếu nhất, chuỗi ngày học liên tục
• Câu hỏi luyện tập theo các chủ đề chính của đề thi: kiểm soát nhiễm khuẩn & an toàn, cấu tạo móng & da, bệnh về móng, hoá học & an toàn sản phẩm (SDS), manicure & pedicure, móng nhân tạo (acrylic, gel, tip, bọc móng, bột nhúng)
• Song ngữ: câu hỏi và giải thích tiếng Việt, bật tiếng Anh bất cứ lúc nào
• Thi thử bấm giờ, có điểm đậu như khi thi thật
• Giải thích cho từng câu để hiểu vì sao đúng, vì sao sai
• Luyện theo chủ đề, luyện nhanh 10 câu, ôn lại câu sai, lưu câu khó
• Điểm sẵn sàng cho biết bạn đã gần đậu chưa
• Không quảng cáo, dùng không cần mạng, không cần tài khoản

MIỄN PHÍ VÀ BẢN ĐẦY ĐỦ
Mỗi chủ đề đều có câu hỏi miễn phí. Mở khoá toàn bộ câu hỏi và thi thử không giới hạn chỉ với một lần mua. Không thu phí hằng tháng.

DÀNH CHO AI
Học viên trường nail và thợ nail chuẩn bị thi viết (lý thuyết) ở các tiểu bang cho thi bằng tiếng Việt như California, Texas, Pennsylvania, Virginia, Tennessee, Kentucky… Hãy kiểm tra cẩm nang thí sinh của State Board nơi bạn thi để biết hình thức thi và ngôn ngữ được chọn.

LƯU Ý
Đây là công cụ ôn tập độc lập, không liên kết hay được bảo trợ bởi bất kỳ State Board, PSI, Pearson VUE, NIC hay đơn vị tổ chức thi nào. Toàn bộ câu hỏi do chúng tôi tự biên soạn theo các chủ đề thi đã được công bố.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/nailvi.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của NIC, PSI, Pearson VUE, state board; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.

### 🚀 Tăng lượt tải

1. Nhóm Facebook/Zalo "Thợ Nail Việt tại Mỹ", "Học Nail", các trường nail của người Việt (xin đặt link/QR ở lớp).
2. TikTok/YouTube Shorts tiếng Việt: "3 câu hỏi thi nail hay trượt nhất".
3. Cho học viên đầu tiên mã dùng thử qua Internal testing để lấy đánh giá thật.

---

## 9. Gulf Nursing Exam Prep (nursegulf)

| | |
|---|---|
| Mã app | `com.tuanapps.nursegulf` |
| Loại | App → **Education** |
| Thị trường | 🇮🇳 Ấn Độ, 🇵🇭 Philippines, 🇦🇪 UAE, 🇸🇦 Ả Rập Xê Út, 🇶🇦 Qatar, 🇰🇼 Kuwait, 🇴🇲 Oman, 🇧🇭 Bahrain, 🇵🇰 Pakistan, 🇪🇬 Ai Cập, 🇳🇬 Nigeria, 🇰🇪 Kenya, 🇯🇴 Jordan |
| Ngôn ngữ store | `en-US` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/nursegulf.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Điều dưỡng Ấn Độ, Philippines, Pakistan… muốn làm việc ở vùng Vịnh phải thi Prometric (DHA/DOH/MOHAP/SCFHS/QCHP); họ chịu chi vì lương ở Vịnh cao gấp nhiều lần.

**Kiếm tiền:** miễn phí khoảng 30% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 60 câu/72 phút (đậu 60%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`nursegulf-buildN`** → giải nén → **`app-nursegulf-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = nursegulf` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $14.99** → Update exchange rates → **sửa tay: Ấn Độ ₹499, Philippines ₱599, Pakistan Rs 1,499** → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/nursegulf/metadata/android/en-US/images/icon.png` · `store/nursegulf/metadata/android/en-US/images/featureGraphic.png` · `store/nursegulf/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (22/30)
```
Gulf Nursing Exam Prep
```
Short description (80/80)
```
DHA, DOH, MOHAP, SCFHS & QCHP nursing exam practice with rationales & mock tests
```
Full description
```
Prepare for your registered nurse licensing exam for the Gulf: Dubai (DHA), Abu Dhabi (DOH), UAE (MOHAP), Saudi Arabia (SCFHS), Qatar (QCHP) and similar Prometric computer-based exams.

Practice with clear, original multiple-choice questions written in the style of these exams, each with a short rationale so you understand the "why", not just the answer.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Practice questions across the core nursing areas: fundamentals and patient safety, medical-surgical nursing, pharmacology and dosage calculations, maternal and child health, and emergency, critical care and mental health
• Dosage and IV rate calculations with worked answers
• Timed mock exams with a passing target
• A rationale for every answer
• Practice by topic, Quick 10, review your mistakes and save hard questions
• Readiness score that tracks your progress
• No ads. Works offline. No account needed

FREE AND PREMIUM
Try part of every topic for free. Unlock every question and unlimited full mock exams with one one-time purchase. No subscription.

WHO IT'S FOR
Nurses from India, the Philippines, Pakistan, Egypt, Nigeria, Kenya, Jordan and elsewhere preparing to work in the UAE, Saudi Arabia, Qatar, Kuwait, Oman or Bahrain.

IMPORTANT
This is an independent study tool. It is not affiliated with or endorsed by DHA, DOH, MOHAP, SCFHS, QCHP, Prometric or any licensing authority. All questions are original practice items. Always check the official candidate guide of your licensing authority for the current exam format and eligibility rules.
```

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/nursegulf.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của DHA, DOH, MOHAP, SCFHS, QCHP, Prometric; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.

### 🚀 Tăng lượt tải

1. Nhóm Facebook/Telegram "Gulf nurses", "DHA exam preparation", các trung tâm tuyển dụng điều dưỡng ở Kerala, Manila.
2. YouTube Shorts tiếng Anh: "5 DHA questions most nurses get wrong".

---

## 10. Security Exam §34a Germany (sachkunde)

| | |
|---|---|
| Mã app | `com.tuanapps.sachkunde` |
| Loại | App → **Education** |
| Thị trường | 🇩🇪 Đức |
| Ngôn ngữ store | `en-US`, `de-DE` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/sachkunde.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Nhân viên bảo vệ ở Đức (rất nhiều người nhập cư) bắt buộc đậu Sachkundeprüfung §34a của IHK; tỷ lệ trượt cao, khoá học offline đắt.

**Kiếm tiền:** miễn phí khoảng 30% câu mỗi chủ đề + thi thử ngắn; `premium_lifetime` mở 250 câu, thi thử đầy đủ 72 câu/120 phút (đậu 50%), thẻ ghi nhớ không giới hạn.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`sachkunde-buildN`** → giải nén → **`app-sachkunde-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = sachkunde` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• 250 original practice questions with explanations
• Timed mock exams with pass mark
• Study plan, daily reminder, flashcards and weakest-topic drill
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlock all questions` |
| **Description** | `All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **€14.99** (Đức) → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`store/sachkunde/metadata/android/en-US/images/icon.png` · `store/sachkunde/metadata/android/en-US/images/featureGraphic.png` · `store/sachkunde/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`
(Ảnh riêng cho `de-DE` nằm trong thư mục cùng tên.)

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (26/30)
```
Security Exam §34a Germany
```
Short description (79/80)
```
Practice for the German §34a security guard exam (IHK), in German with English.
```
Full description
```
Prepare for the German security guard competence exam (Sachkundeprüfung § 34a GewO) at the IHK, needed for door staff, public-area patrols, store detectives and more.

The questions are in German, like the real exam, with an English translation one tap away – ideal if German is not your first language.

WHAT YOU GET
• 250 original practice questions with clear explanations
• Personal study plan: set your exam date and daily goal, get a daily reminder
• Flashcards, a weakest-topic drill and a daily streak to keep you on track
• Original practice questions on trade law and data protection, civil law (self-defence, necessity, self-help), criminal law and procedure (§ 32 StGB, § 127 StPO), weapons law, accident prevention and first aid, dealing with people and security technology
• Timed mock exams
• An explanation for every answer
• Practice by topic, Quick 10, review mistakes, save questions
• No ads. Works offline. No account needed

FREE AND PREMIUM
Practise part of every topic for free. Unlock every question and unlimited mock exams with a single one-time purchase. No subscription.

IMPORTANT
This is an independent study tool, not affiliated with any IHK, the DIHK or any public authority. All questions are original practice items.
```

<details><summary>German – de-DE: bấm để mở</summary>

**German – de-DE**

App name (22/30)
```
Sachkunde §34a Prüfung
```
Short description (78/80)
```
Sachkundeprüfung §34a GewO üben: Prüfungsfragen, Erklärungen und Probeprüfung.
```
Full description
```
Bereite dich gezielt auf die Sachkundeprüfung nach § 34a GewO bei der IHK vor – für Türsteher, Kontrollgänge im öffentlichen Raum, Ladendetektive und weitere Bewachungstätigkeiten.

Eigene Übungsfragen zu allen Prüfungsgebieten, jeweils mit kurzer Erklärung und Paragrafen, damit du verstehst, warum eine Antwort richtig ist. Auf Wunsch zeigt die App jede Frage zusätzlich auf Englisch – ideal, wenn Deutsch nicht deine Muttersprache ist.

DAS BEKOMMST DU
• 250 eigene Übungsfragen mit verständlichen Erklärungen
• Persönlicher Lernplan: Prüfungstermin und Tagesziel festlegen, tägliche Erinnerung
• Karteikarten, Training des schwächsten Themas und Lern-Serie
• Übungsfragen zu: Gewerberecht, Bewachungsverordnung und Datenschutz, Bürgerliches Recht (Notwehr, Notstand, Selbsthilfe, Besitzwehr), Straf- und Strafverfahrensrecht (§ 32 StGB, § 127 StPO), Waffenrecht, Unfallverhütung (DGUV Vorschrift 23) und Erste Hilfe, Umgang mit Menschen und Sicherheitstechnik
• Probeprüfung mit Zeitlimit wie in der schriftlichen Prüfung
• Erklärung zu jeder Antwort
• Üben nach Thema, Schnell 10, Fehler wiederholen, Fragen merken
• Deutsch mit zuschaltbarem Englisch
• Keine Werbung. Funktioniert offline. Kein Konto nötig

KOSTENLOS UND PREMIUM
Teste einen Teil jedes Themas kostenlos. Schalte alle Fragen und unbegrenzte Probeprüfungen mit einer Einmalzahlung frei. Kein Abo.

HINWEIS
Unabhängiges Lernwerkzeug. Keine Verbindung zu IHKs, dem DIHK oder Behörden. Alle Fragen sind eigene Übungsfragen; die echte Prüfung kann Fragen mit mehreren richtigen Antworten enthalten. Informiere dich bei deiner IHK über Ablauf und Termine.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/sachkunde.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3 |
| Target audience | **18 and over**. Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Education** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng logo hay chữ "official" của IHK, DIHK; mô tả đã ghi rõ "not affiliated with or endorsed by".
- Không viết "đề thi thật", "guaranteed pass", "100% pass" (Google từ chối vì quảng cáo sai sự thật).
- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo.

### 🚀 Tăng lượt tải

1. Nhóm Facebook "Sicherheitsdienst Jobs", "Sachkundeprüfung 34a Lerngruppe".
2. Các công ty bảo vệ tuyển người mới (họ cần nhân viên đậu nhanh).

---

## 11. Domino Dots: Logic Puzzle (dominodots)

| | |
|---|---|
| Mã app | `com.tuanapps.dominodots` |
| Loại | Game → **Puzzle** |
| Thị trường | **Tất cả quốc gia** |
| Ngôn ngữ store | `en-US`, `de-DE`, `es-419`, `id`, `ja-JP`, `pt-BR`, `vi` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/dominodots.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Ăn theo *Pips* của NYT Games (domino logic). Trên Android gần như chưa có app tương tự: bản duy nhất tìm thấy là app trả phí khoảng 50 lượt cài.

**Kiếm tiền:** miễn phí Dễ + Vừa không giới hạn; Khó 3 câu/ngày, Chuyên gia 1 câu/ngày, 3 gợi ý + 1/ngày. `premium_lifetime` mở mọi mức, gợi ý không giới hạn, kho 60 ngày, mọi giao diện.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`dominodots-buildN`** → giải nén → **`app-dominodots-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = dominodots` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• Unlimited puzzles in 4 levels: Easy to Expert
• Daily puzzle with streaks
• Stars, themes and trophies – no ads
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlimited: all levels & hints` |
| **Description** | `Unlimited Hard & Expert puzzles, unlimited hints, the daily archive and every theme. One-time purchase.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $2.99** → Update exchange rates → sửa tay: Nhật ¥450, Ấn Độ ₹149, Brazil R$ 11,90 → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`games/store/dominodots/metadata/android/en-US/images/icon.png` · `games/store/dominodots/metadata/android/en-US/images/featureGraphic.png` · `games/store/dominodots/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (25/30)
```
Domino Dots: Logic Puzzle
```
Short description (74/80)
```
Place dominoes so every colored area matches its rule. Daily logic puzzle.
```
Full description
```
Place dominoes so every colored area matches its rule. Daily logic puzzle.

HOW TO PLAY
Place every domino from the tray on two neighbouring cells. Each colored region must match its label: Σ = total pips, = all the same, ≠ all different, < or > total below or above the number.

FEATURES
• Unlimited puzzles in 4 levels: Easy, Medium, Hard and Expert
• Every puzzle has exactly one solution – pure logic, no guessing
• A new daily puzzle, streaks and a 60-day archive
• Earn 1–3 stars, unlock 8 color themes, collect 12 trophies
• Timer, best times and detailed stats
• Hints when you're stuck
• No ads. Works offline. No account needed.

GO UNLIMITED
One small one-time purchase: unlimited Hard & Expert puzzles, unlimited hints, the full daily archive and every theme. No subscription.
```

<details><summary>German – de-DE: bấm để mở</summary>

**German – de-DE**

App name (25/30)
```
Domino Dots: Domino-Logik
```
Short description (73/80)
```
Lege Dominos so, dass jede Farbzone ihre Regel erfüllt. Tägliches Rätsel.
```
Full description
```
Lege Dominos so, dass jede Farbzone ihre Regel erfüllt. Tägliches Rätsel.

SO WIRD GESPIELT
Lege jeden Dominostein auf zwei benachbarte Felder. Jede farbige Zone muss ihr Etikett erfüllen: Σ = Augensumme, = alle gleich, ≠ alle verschieden, < oder > Summe kleiner oder größer als die Zahl.

FUNKTIONEN
• Unbegrenzt Rätsel in 4 Stufen: Leicht, Mittel, Schwer, Experte
• Jedes Rätsel hat genau eine Lösung – reine Logik, kein Raten
• Neues Tagesrätsel, Serien und ein 60-Tage-Archiv
• 1–3 Sterne verdienen, 8 Farbdesigns und 12 Trophäen freischalten
• Timer, Bestzeiten und Statistik
• Tipps, wenn du feststeckst
• Keine Werbung. Offline spielbar. Kein Konto nötig.

UNBEGRENZT FREISCHALTEN
Ein kleiner Einmalkauf: unbegrenzt schwere und Experten-Rätsel, unbegrenzt Tipps, das komplette Archiv und alle Designs. Kein Abo.
```

</details>

<details><summary>Spanish (Latin America) – es-419: bấm để mở</summary>

**Spanish (Latin America) – es-419**

App name (26/30)
```
Domino Dots: Lógica Dominó
```
Short description (73/80)
```
Coloca dominós para cumplir la regla de cada zona de color. Puzle diario.
```
Full description
```
Coloca dominós para cumplir la regla de cada zona de color. Puzle diario.

CÓMO JUGAR
Coloca cada ficha de dominó en dos casillas vecinas. Cada región de color debe cumplir su etiqueta: Σ = suma de puntos, = todos iguales, ≠ todos distintos, < o > suma menor o mayor que el número.

CARACTERÍSTICAS
• Puzles ilimitados en 4 niveles: Fácil, Medio, Difícil y Experto
• Cada puzle tiene una sola solución: lógica pura, sin adivinar
• Puzle diario nuevo, rachas y archivo de 60 días
• Gana de 1 a 3 estrellas, desbloquea 8 temas y 12 trofeos
• Cronómetro, mejores tiempos y estadísticas
• Pistas cuando te atascas
• Sin anuncios. Funciona sin internet. Sin cuenta.

PÁSATE A ILIMITADO
Un único pago pequeño: puzles difíciles y expertos ilimitados, pistas ilimitadas, archivo diario completo y todos los temas. Sin suscripción.
```

</details>

<details><summary>Indonesian – id: bấm để mở</summary>

**Indonesian – id**

App name (26/30)
```
Domino Dots: Logika Domino
```
Short description (72/80)
```
Letakkan domino agar tiap area warna sesuai aturannya. Teka-teki harian.
```
Full description
```
Letakkan domino agar tiap area warna sesuai aturannya. Teka-teki harian.

CARA BERMAIN
Letakkan setiap kartu domino di dua kotak yang bersebelahan. Setiap area berwarna harus sesuai labelnya: Σ = jumlah titik, = semua sama, ≠ semua berbeda, < atau > jumlah kurang atau lebih dari angkanya.

FITUR
• Teka-teki tanpa batas di 4 level: Mudah, Sedang, Sulit, Ahli
• Setiap teka-teki punya tepat satu solusi – murni logika
• Teka-teki harian baru, beruntun, dan arsip 60 hari
• Raih 1–3 bintang, buka 8 tema warna, kumpulkan 12 trofi
• Timer, waktu terbaik, dan statistik
• Petunjuk saat kamu buntu
• Tanpa iklan. Bisa offline. Tanpa akun.

BUKA TANPA BATAS
Sekali bayar: teka-teki Sulit & Ahli tanpa batas, petunjuk tanpa batas, arsip harian lengkap, dan semua tema. Tanpa langganan.
```

</details>

<details><summary>Japanese – ja-JP: bấm để mở</summary>

**Japanese – ja-JP**

App name (21/30)
```
Domino Dots: ドミノ論理パズル
```
Short description (31/80)
```
色エリアの条件を満たすようにドミノを置こう。毎日の論理パズル。
```
Full description
```
色エリアの条件を満たすようにドミノを置こう。毎日の論理パズル。

遊び方
すべてのドミノを隣り合う2マスに置きましょう。各色エリアはラベルを満たす必要があります：Σ＝目の合計、＝すべて同じ、≠すべて違う、<・>は合計がその数より小さい・大きい。

特徴
• かんたん・ふつう・むずかしい・エキスパートの4段階、パズルは無制限
• どのパズルも答えはひとつ。運ではなく論理で解ける
• 毎日の新作パズル、連続記録、60日分のアーカイブ
• ★1〜3で評価、8つのカラーテーマと12個のトロフィー
• タイマー、ベストタイム、詳しい記録
• 行きづまったらヒント
• 広告なし。オフラインOK。アカウント不要。

無制限パック
一度の購入で、むずかしい・エキスパートが無制限、ヒント無制限、過去のパズル全部、すべてのテーマが使えます。サブスクではありません。
```

</details>

<details><summary>Portuguese (Brazil) – pt-BR: bấm để mở</summary>

**Portuguese (Brazil) – pt-BR**

App name (29/30)
```
Domino Dots: Lógica de Dominó
```
Short description (75/80)
```
Coloque dominós para cumprir a regra de cada área colorida. Desafio diário.
```
Full description
```
Coloque dominós para cumprir a regra de cada área colorida. Desafio diário.

COMO JOGAR
Coloque cada peça de dominó em duas casas vizinhas. Cada região colorida deve cumprir sua etiqueta: Σ = soma dos pontos, = todos iguais, ≠ todos diferentes, < ou > soma menor ou maior que o número.

RECURSOS
• Desafios ilimitados em 4 níveis: Fácil, Médio, Difícil e Especialista
• Cada desafio tem uma única solução – lógica pura, sem chute
• Desafio diário novo, sequências e arquivo de 60 dias
• Ganhe de 1 a 3 estrelas, desbloqueie 8 temas e 12 troféus
• Cronômetro, melhores tempos e estatísticas
• Dicas quando você travar
• Sem anúncios. Funciona offline. Sem cadastro.

DESBLOQUEIE O ILIMITADO
Um pagamento único: desafios difíceis e de especialista ilimitados, dicas ilimitadas, arquivo diário completo e todos os temas. Sem assinatura.
```

</details>

<details><summary>Vietnamese – vi: bấm để mở</summary>

**Vietnamese – vi**

App name (27/30)
```
Domino Dots: Giải Đố Domino
```
Short description (70/80)
```
Đặt domino sao cho mỗi vùng màu đúng điều kiện. Câu đố logic mỗi ngày.
```
Full description
```
Đặt domino sao cho mỗi vùng màu đúng điều kiện. Câu đố logic mỗi ngày.

CÁCH CHƠI
Đặt mọi quân domino vào hai ô kề nhau. Mỗi vùng màu phải đúng nhãn của nó: Σ = tổng số chấm, = tất cả bằng nhau, ≠ tất cả khác nhau, < hoặc > tổng nhỏ hơn hoặc lớn hơn số đó.

TÍNH NĂNG
• Câu đố không giới hạn ở 4 mức: Dễ, Vừa, Khó, Chuyên gia
• Mỗi câu đố chỉ có đúng một lời giải – thuần logic, không phải đoán
• Câu đố mới mỗi ngày, chuỗi ngày chơi và kho 60 ngày
• Nhận 1–3 sao, mở 8 giao diện màu, sưu tầm 12 huy hiệu
• Bấm giờ, kỷ lục và thống kê chi tiết
• Gợi ý khi bí
• Không quảng cáo. Chơi không cần mạng. Không cần tài khoản.

MỞ KHOÁ KHÔNG GIỚI HẠN
Trả một lần: câu Khó và Chuyên gia không giới hạn, gợi ý không giới hạn, toàn bộ kho câu đố hằng ngày và mọi giao diện. Không thuê bao.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/dominodots.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Game** → Puzzle/Word; mọi mục bạo lực, cờ bạc, người lớn, tương tác người dùng: **No**; mua hàng kỹ thuật số: **Yes** |
| Target audience | **13–15, 16–17, 18+** (không chọn dưới 13). Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Puzzle** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng chữ "Pips", "NYT", "New York Times" trong tên, icon, mô tả, ảnh.
- Cơ chế chơi không được bảo hộ bản quyền; tên, logo, hình ảnh thương hiệu thì có. Tên, icon và đồ hoạ của app là của riêng mình.
- Không thêm tính năng cược hay giải thưởng tiền thật.

### 🚀 Tăng lượt tải

1. Reddit r/NYTPips, r/puzzles, r/dominoes: "I made an unlimited domino logic puzzle (no ads)".
2. Người chơi Pips chỉ có 3 câu/ngày → nhấn mạnh "unlimited puzzles" trong mô tả.

---

## 12. Meow Queens: Cat Logic Puzzle (meowqueens)

| | |
|---|---|
| Mã app | `com.tuanapps.meowqueens` |
| Loại | Game → **Puzzle** |
| Thị trường | **Tất cả quốc gia** |
| Ngôn ngữ store | `en-US`, `de-DE`, `es-419`, `id`, `ja-JP`, `pt-BR`, `vi` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/meowqueens.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** *Meowdoku* hơn 43 triệu lượt tải, đứng đầu lượt tải tại Nhật tháng 8–9/2026, nhưng kiếm tiền gần như 100% bằng quảng cáo. Khác biệt: không quảng cáo + tiếng Nhật.

**Kiếm tiền:** miễn phí Dễ + Vừa không giới hạn; Khó 3 câu/ngày, Chuyên gia 1 câu/ngày, 3 gợi ý + 1/ngày. `premium_lifetime` mở mọi mức, gợi ý không giới hạn, kho 60 ngày, mọi giao diện.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`meowqueens-buildN`** → giải nén → **`app-meowqueens-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = meowqueens` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• Unlimited puzzles in 4 levels: Easy to Expert
• Daily puzzle with streaks
• Stars, themes and trophies – no ads
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlimited: all levels & hints` |
| **Description** | `Unlimited Hard & Expert puzzles, unlimited hints, the daily archive and every theme. One-time purchase.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $2.99** → Update exchange rates → sửa tay: **Nhật ¥450** → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`games/store/meowqueens/metadata/android/en-US/images/icon.png` · `games/store/meowqueens/metadata/android/en-US/images/featureGraphic.png` · `games/store/meowqueens/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (29/30)
```
Meow Queens: Cat Logic Puzzle
```
Short description (72/80)
```
Place one cat per row, column and color. Cats can't touch! Daily puzzle.
```
Full description
```
Place one cat per row, column and color. Cats can't touch! Daily puzzle.

HOW TO PLAY
Place one cat in every row, every column and every colored area. Cats can never touch each other, not even diagonally. Tap once to mark X, tap again to place a cat. A wrong cat costs a heart.

FEATURES
• Unlimited puzzles in 4 levels: Easy, Medium, Hard and Expert
• Every puzzle has exactly one solution – pure logic, no guessing
• A new daily puzzle, streaks and a 60-day archive
• Earn 1–3 stars, unlock 8 color themes, collect 12 trophies
• Timer, best times and detailed stats
• Hints when you're stuck
• No ads. Works offline. No account needed.

GO UNLIMITED
One small one-time purchase: unlimited Hard & Expert puzzles, unlimited hints, the full daily archive and every theme. No subscription.
```

<details><summary>German – de-DE: bấm để mở</summary>

**German – de-DE**

App name (26/30)
```
Meow Queens: Katzen-Rätsel
```
Short description (65/80)
```
Eine Katze pro Zeile, Spalte und Farbe. Katzen berühren sich nie!
```
Full description
```
Eine Katze pro Zeile, Spalte und Farbe. Katzen berühren sich nie!

SO WIRD GESPIELT
Setze in jede Zeile, jede Spalte und jeden Farbbereich genau eine Katze. Katzen dürfen sich nie berühren, auch nicht diagonal. Einmal tippen markiert X, nochmal tippen setzt eine Katze. Eine falsche Katze kostet ein Herz.

FUNKTIONEN
• Unbegrenzt Rätsel in 4 Stufen: Leicht, Mittel, Schwer, Experte
• Jedes Rätsel hat genau eine Lösung – reine Logik, kein Raten
• Neues Tagesrätsel, Serien und ein 60-Tage-Archiv
• 1–3 Sterne verdienen, 8 Farbdesigns und 12 Trophäen freischalten
• Timer, Bestzeiten und Statistik
• Tipps, wenn du feststeckst
• Keine Werbung. Offline spielbar. Kein Konto nötig.

UNBEGRENZT FREISCHALTEN
Ein kleiner Einmalkauf: unbegrenzt schwere und Experten-Rätsel, unbegrenzt Tipps, das komplette Archiv und alle Designs. Kein Abo.
```

</details>

<details><summary>Spanish (Latin America) – es-419: bấm để mở</summary>

**Spanish (Latin America) – es-419**

App name (28/30)
```
Meow Queens: Lógica de Gatos
```
Short description (71/80)
```
Un gato por fila, columna y color. ¡Los gatos no se tocan! Reto diario.
```
Full description
```
Un gato por fila, columna y color. ¡Los gatos no se tocan! Reto diario.

CÓMO JUGAR
Coloca un gato en cada fila, cada columna y cada zona de color. Los gatos nunca pueden tocarse, ni en diagonal. Toca una vez para marcar X y otra vez para poner un gato. Un gato incorrecto cuesta un corazón.

CARACTERÍSTICAS
• Puzles ilimitados en 4 niveles: Fácil, Medio, Difícil y Experto
• Cada puzle tiene una sola solución: lógica pura, sin adivinar
• Puzle diario nuevo, rachas y archivo de 60 días
• Gana de 1 a 3 estrellas, desbloquea 8 temas y 12 trofeos
• Cronómetro, mejores tiempos y estadísticas
• Pistas cuando te atascas
• Sin anuncios. Funciona sin internet. Sin cuenta.

PÁSATE A ILIMITADO
Un único pago pequeño: puzles difíciles y expertos ilimitados, pistas ilimitadas, archivo diario completo y todos los temas. Sin suscripción.
```

</details>

<details><summary>Indonesian – id: bấm để mở</summary>

**Indonesian – id**

App name (26/30)
```
Meow Queens: Logika Kucing
```
Short description (70/80)
```
Satu kucing per baris, kolom, dan warna. Kucing tak boleh bersentuhan!
```
Full description
```
Satu kucing per baris, kolom, dan warna. Kucing tak boleh bersentuhan!

CARA BERMAIN
Letakkan satu kucing di setiap baris, kolom, dan area warna. Kucing tidak boleh bersentuhan, termasuk diagonal. Ketuk sekali untuk tanda X, ketuk lagi untuk meletakkan kucing. Kucing yang salah mengurangi satu hati.

FITUR
• Teka-teki tanpa batas di 4 level: Mudah, Sedang, Sulit, Ahli
• Setiap teka-teki punya tepat satu solusi – murni logika
• Teka-teki harian baru, beruntun, dan arsip 60 hari
• Raih 1–3 bintang, buka 8 tema warna, kumpulkan 12 trofi
• Timer, waktu terbaik, dan statistik
• Petunjuk saat kamu buntu
• Tanpa iklan. Bisa offline. Tanpa akun.

BUKA TANPA BATAS
Sekali bayar: teka-teki Sulit & Ahli tanpa batas, petunjuk tanpa batas, arsip harian lengkap, dan semua tema. Tanpa langganan.
```

</details>

<details><summary>Japanese – ja-JP: bấm để mở</summary>

**Japanese – ja-JP**

App name (20/30)
```
Meow Queens: ネコ論理パズル
```
Short description (34/80)
```
各行・列・色にネコを1匹ずつ。ネコ同士はとなり合えない！毎日パズル。
```
Full description
```
各行・列・色にネコを1匹ずつ。ネコ同士はとなり合えない！毎日パズル。

遊び方
すべての行・列・色のエリアに、ネコを1匹ずつ置きましょう。ネコ同士は斜めも含めて隣り合えません。1回タップで×、もう1回でネコを置きます。まちがえるとハートが1つ減ります。

特徴
• かんたん・ふつう・むずかしい・エキスパートの4段階、パズルは無制限
• どのパズルも答えはひとつ。運ではなく論理で解ける
• 毎日の新作パズル、連続記録、60日分のアーカイブ
• ★1〜3で評価、8つのカラーテーマと12個のトロフィー
• タイマー、ベストタイム、詳しい記録
• 行きづまったらヒント
• 広告なし。オフラインOK。アカウント不要。

無制限パック
一度の購入で、むずかしい・エキスパートが無制限、ヒント無制限、過去のパズル全部、すべてのテーマが使えます。サブスクではありません。
```

</details>

<details><summary>Portuguese (Brazil) – pt-BR: bấm để mở</summary>

**Portuguese (Brazil) – pt-BR**

App name (28/30)
```
Meow Queens: Lógica de Gatos
```
Short description (71/80)
```
Um gato por linha, coluna e cor. Os gatos não se tocam! Desafio diário.
```
Full description
```
Um gato por linha, coluna e cor. Os gatos não se tocam! Desafio diário.

COMO JOGAR
Coloque um gato em cada linha, cada coluna e cada área colorida. Os gatos nunca podem se tocar, nem na diagonal. Toque uma vez para marcar X e de novo para colocar um gato. Um gato errado custa um coração.

RECURSOS
• Desafios ilimitados em 4 níveis: Fácil, Médio, Difícil e Especialista
• Cada desafio tem uma única solução – lógica pura, sem chute
• Desafio diário novo, sequências e arquivo de 60 dias
• Ganhe de 1 a 3 estrelas, desbloqueie 8 temas e 12 troféus
• Cronômetro, melhores tempos e estatísticas
• Dicas quando você travar
• Sem anúncios. Funciona offline. Sem cadastro.

DESBLOQUEIE O ILIMITADO
Um pagamento único: desafios difíceis e de especialista ilimitados, dicas ilimitadas, arquivo diário completo e todos os temas. Sem assinatura.
```

</details>

<details><summary>Vietnamese – vi: bấm để mở</summary>

**Vietnamese – vi**

App name (24/30)
```
Meow Queens: Giải Đố Mèo
```
Short description (62/80)
```
Mỗi hàng, cột, vùng màu một con mèo. Mèo không được chạm nhau!
```
Full description
```
Mỗi hàng, cột, vùng màu một con mèo. Mèo không được chạm nhau!

CÁCH CHƠI
Đặt đúng 1 con mèo ở mỗi hàng, mỗi cột và mỗi vùng màu. Các con mèo không được chạm nhau, kể cả chéo. Chạm 1 lần để đánh dấu X, chạm lần nữa để đặt mèo. Đặt sai mất 1 tim.

TÍNH NĂNG
• Câu đố không giới hạn ở 4 mức: Dễ, Vừa, Khó, Chuyên gia
• Mỗi câu đố chỉ có đúng một lời giải – thuần logic, không phải đoán
• Câu đố mới mỗi ngày, chuỗi ngày chơi và kho 60 ngày
• Nhận 1–3 sao, mở 8 giao diện màu, sưu tầm 12 huy hiệu
• Bấm giờ, kỷ lục và thống kê chi tiết
• Gợi ý khi bí
• Không quảng cáo. Chơi không cần mạng. Không cần tài khoản.

MỞ KHOÁ KHÔNG GIỚI HẠN
Trả một lần: câu Khó và Chuyên gia không giới hạn, gợi ý không giới hạn, toàn bộ kho câu đố hằng ngày và mọi giao diện. Không thuê bao.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/meowqueens.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Game** → Puzzle/Word; mọi mục bạo lực, cờ bạc, người lớn, tương tác người dùng: **No**; mua hàng kỹ thuật số: **Yes** |
| Target audience | **13–15, 16–17, 18+** (không chọn dưới 13). Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Puzzle** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng chữ "Meowdoku", "Queens" (LinkedIn) làm thương hiệu; "Meow Queens" là tên riêng.
- Cơ chế chơi không được bảo hộ bản quyền; tên, logo, hình ảnh thương hiệu thì có. Tên, icon và đồ hoạ của app là của riêng mình.
- Không thêm tính năng cược hay giải thưởng tiền thật.

### 🚀 Tăng lượt tải

1. Nhật: X (Twitter) tiếng Nhật với hashtag ネコパズル, 脳トレ.
2. Người chơi Meowdoku chán quảng cáo → nhấn mạnh "広告なし" (không quảng cáo).

---

## 13. Patch Grid: Rectangle Logic (patchgrid)

| | |
|---|---|
| Mã app | `com.tuanapps.patchgrid` |
| Loại | Game → **Puzzle** |
| Thị trường | **Tất cả quốc gia** |
| Ngôn ngữ store | `en-US`, `de-DE`, `es-419`, `id`, `ja-JP`, `pt-BR`, `vi` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/patchgrid.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Ăn theo *Patches* của LinkedIn (ra 19/3/2026, kiểu Shikaku). Chỉ có vài app Shikaku cũ, không app nào có huy hiệu hình dạng như Patches.

**Kiếm tiền:** miễn phí Dễ + Vừa không giới hạn; Khó 3 câu/ngày, Chuyên gia 1 câu/ngày, 3 gợi ý + 1/ngày. `premium_lifetime` mở mọi mức, gợi ý không giới hạn, kho 60 ngày, mọi giao diện.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`patchgrid-buildN`** → giải nén → **`app-patchgrid-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = patchgrid` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• Unlimited puzzles in 4 levels: Easy to Expert
• Daily puzzle with streaks
• Stars, themes and trophies – no ads
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlimited: all levels & hints` |
| **Description** | `Unlimited Hard & Expert puzzles, unlimited hints, the daily archive and every theme. One-time purchase.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $2.99** → Update exchange rates → sửa tay: Nhật ¥450, Ấn Độ ₹149 → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`games/store/patchgrid/metadata/android/en-US/images/icon.png` · `games/store/patchgrid/metadata/android/en-US/images/featureGraphic.png` · `games/store/patchgrid/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (27/30)
```
Patch Grid: Rectangle Logic
```
Short description (69/80)
```
Split the grid into rectangles – one clue each, right size and shape.
```
Full description
```
Split the grid into rectangles – one clue each, right size and shape.

HOW TO PLAY
Drag to split the grid into rectangles. Each rectangle holds exactly one clue: the number is its area and the badge shows its shape (square, wide or tall). Tap a rectangle to erase it.

FEATURES
• Unlimited puzzles in 4 levels: Easy, Medium, Hard and Expert
• Every puzzle has exactly one solution – pure logic, no guessing
• A new daily puzzle, streaks and a 60-day archive
• Earn 1–3 stars, unlock 8 color themes, collect 12 trophies
• Timer, best times and detailed stats
• Hints when you're stuck
• No ads. Works offline. No account needed.

GO UNLIMITED
One small one-time purchase: unlimited Hard & Expert puzzles, unlimited hints, the full daily archive and every theme. No subscription.
```

<details><summary>German – de-DE: bấm để mở</summary>

**German – de-DE**

App name (26/30)
```
Patch Grid: Rechteck-Logik
```
Short description (72/80)
```
Teile das Raster in Rechtecke – je ein Hinweis, passende Größe und Form.
```
Full description
```
Teile das Raster in Rechtecke – je ein Hinweis, passende Größe und Form.

SO WIRD GESPIELT
Ziehe, um das Raster in Rechtecke zu teilen. Jedes Rechteck enthält genau einen Hinweis: Die Zahl ist seine Fläche, das Symbol zeigt seine Form (quadratisch, breit oder hoch). Tippe ein Rechteck an, um es zu löschen.

FUNKTIONEN
• Unbegrenzt Rätsel in 4 Stufen: Leicht, Mittel, Schwer, Experte
• Jedes Rätsel hat genau eine Lösung – reine Logik, kein Raten
• Neues Tagesrätsel, Serien und ein 60-Tage-Archiv
• 1–3 Sterne verdienen, 8 Farbdesigns und 12 Trophäen freischalten
• Timer, Bestzeiten und Statistik
• Tipps, wenn du feststeckst
• Keine Werbung. Offline spielbar. Kein Konto nötig.

UNBEGRENZT FREISCHALTEN
Ein kleiner Einmalkauf: unbegrenzt schwere und Experten-Rätsel, unbegrenzt Tipps, das komplette Archiv und alle Designs. Kein Abo.
```

</details>

<details><summary>Spanish (Latin America) – es-419: bấm để mở</summary>

**Spanish (Latin America) – es-419**

App name (23/30)
```
Patch Grid: Rectángulos
```
Short description (72/80)
```
Divide la cuadrícula en rectángulos: una pista en cada uno. Reto diario.
```
Full description
```
Divide la cuadrícula en rectángulos: una pista en cada uno. Reto diario.

CÓMO JUGAR
Arrastra para dividir la cuadrícula en rectángulos. Cada rectángulo contiene exactamente una pista: el número es su área y el icono indica su forma (cuadrado, ancho o alto). Toca un rectángulo para borrarlo.

CARACTERÍSTICAS
• Puzles ilimitados en 4 niveles: Fácil, Medio, Difícil y Experto
• Cada puzle tiene una sola solución: lógica pura, sin adivinar
• Puzle diario nuevo, rachas y archivo de 60 días
• Gana de 1 a 3 estrellas, desbloquea 8 temas y 12 trofeos
• Cronómetro, mejores tiempos y estadísticas
• Pistas cuando te atascas
• Sin anuncios. Funciona sin internet. Sin cuenta.

PÁSATE A ILIMITADO
Un único pago pequeño: puzles difíciles y expertos ilimitados, pistas ilimitadas, archivo diario completo y todos los temas. Sin suscripción.
```

</details>

<details><summary>Indonesian – id: bấm để mở</summary>

**Indonesian – id**

App name (26/30)
```
Patch Grid: Logika Persegi
```
Short description (65/80)
```
Bagi kotak menjadi persegi panjang, satu petunjuk di tiap bagian.
```
Full description
```
Bagi kotak menjadi persegi panjang, satu petunjuk di tiap bagian.

CARA BERMAIN
Seret untuk membagi kotak menjadi persegi panjang. Setiap persegi panjang berisi tepat satu petunjuk: angka adalah luasnya dan ikon menunjukkan bentuknya (persegi, lebar, atau tinggi). Ketuk persegi panjang untuk menghapusnya.

FITUR
• Teka-teki tanpa batas di 4 level: Mudah, Sedang, Sulit, Ahli
• Setiap teka-teki punya tepat satu solusi – murni logika
• Teka-teki harian baru, beruntun, dan arsip 60 hari
• Raih 1–3 bintang, buka 8 tema warna, kumpulkan 12 trofi
• Timer, waktu terbaik, dan statistik
• Petunjuk saat kamu buntu
• Tanpa iklan. Bisa offline. Tanpa akun.

BUKA TANPA BATAS
Sekali bayar: teka-teki Sulit & Ahli tanpa batas, petunjuk tanpa batas, arsip harian lengkap, dan semua tema. Tanpa langganan.
```

</details>

<details><summary>Japanese – ja-JP: bấm để mở</summary>

**Japanese – ja-JP**

App name (20/30)
```
Patch Grid: 四角に切るパズル
```
Short description (34/80)
```
グリッドを長方形に分けよう。ヒントは1つずつ、大きさと形がポイント。
```
Full description
```
グリッドを長方形に分けよう。ヒントは1つずつ、大きさと形がポイント。

遊び方
ドラッグしてグリッドを長方形に分けよう。各長方形にはヒントがちょうど1つ入り、数字は面積、アイコンは形（正方形・横長・縦長）を表します。長方形をタップすると消せます。

特徴
• かんたん・ふつう・むずかしい・エキスパートの4段階、パズルは無制限
• どのパズルも答えはひとつ。運ではなく論理で解ける
• 毎日の新作パズル、連続記録、60日分のアーカイブ
• ★1〜3で評価、8つのカラーテーマと12個のトロフィー
• タイマー、ベストタイム、詳しい記録
• 行きづまったらヒント
• 広告なし。オフラインOK。アカウント不要。

無制限パック
一度の購入で、むずかしい・エキスパートが無制限、ヒント無制限、過去のパズル全部、すべてのテーマが使えます。サブスクではありません。
```

</details>

<details><summary>Portuguese (Brazil) – pt-BR: bấm để mở</summary>

**Portuguese (Brazil) – pt-BR**

App name (22/30)
```
Patch Grid: Retângulos
```
Short description (67/80)
```
Divida a grade em retângulos: uma pista em cada um. Desafio diário.
```
Full description
```
Divida a grade em retângulos: uma pista em cada um. Desafio diário.

COMO JOGAR
Arraste para dividir a grade em retângulos. Cada retângulo contém exatamente uma pista: o número é a sua área e o ícone mostra a forma (quadrado, largo ou alto). Toque num retângulo para apagá-lo.

RECURSOS
• Desafios ilimitados em 4 níveis: Fácil, Médio, Difícil e Especialista
• Cada desafio tem uma única solução – lógica pura, sem chute
• Desafio diário novo, sequências e arquivo de 60 dias
• Ganhe de 1 a 3 estrelas, desbloqueie 8 temas e 12 troféus
• Cronômetro, melhores tempos e estatísticas
• Dicas quando você travar
• Sem anúncios. Funciona offline. Sem cadastro.

DESBLOQUEIE O ILIMITADO
Um pagamento único: desafios difíceis e de especialista ilimitados, dicas ilimitadas, arquivo diário completo e todos os temas. Sem assinatura.
```

</details>

<details><summary>Vietnamese – vi: bấm để mở</summary>

**Vietnamese – vi**

App name (27/30)
```
Patch Grid: Chia Ô Chữ Nhật
```
Short description (73/80)
```
Chia lưới thành các hình chữ nhật, mỗi hình một gợi ý. Đố logic mỗi ngày.
```
Full description
```
Chia lưới thành các hình chữ nhật, mỗi hình một gợi ý. Đố logic mỗi ngày.

CÁCH CHƠI
Kéo để chia lưới thành các hình chữ nhật. Mỗi hình chứa đúng một gợi ý: con số là diện tích, biểu tượng cho biết hình dạng (vuông, ngang hoặc dọc). Chạm vào một hình để xóa.

TÍNH NĂNG
• Câu đố không giới hạn ở 4 mức: Dễ, Vừa, Khó, Chuyên gia
• Mỗi câu đố chỉ có đúng một lời giải – thuần logic, không phải đoán
• Câu đố mới mỗi ngày, chuỗi ngày chơi và kho 60 ngày
• Nhận 1–3 sao, mở 8 giao diện màu, sưu tầm 12 huy hiệu
• Bấm giờ, kỷ lục và thống kê chi tiết
• Gợi ý khi bí
• Không quảng cáo. Chơi không cần mạng. Không cần tài khoản.

MỞ KHOÁ KHÔNG GIỚI HẠN
Trả một lần: câu Khó và Chuyên gia không giới hạn, gợi ý không giới hạn, toàn bộ kho câu đố hằng ngày và mọi giao diện. Không thuê bao.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/patchgrid.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Game** → Puzzle/Word; mọi mục bạo lực, cờ bạc, người lớn, tương tác người dùng: **No**; mua hàng kỹ thuật số: **Yes** |
| Target audience | **13–15, 16–17, 18+** (không chọn dưới 13). Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Puzzle** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng chữ "Patches", "LinkedIn" trong tên, icon, mô tả, ảnh.
- Cơ chế chơi không được bảo hộ bản quyền; tên, logo, hình ảnh thương hiệu thì có. Tên, icon và đồ hoạ của app là của riêng mình.
- Không thêm tính năng cược hay giải thưởng tiền thật.

### 🚀 Tăng lượt tải

1. LinkedIn: chính người chơi Patches dùng LinkedIn hằng ngày; đăng bài "unlimited Patches-style puzzles".
2. Nhật: Shikaku (四角に切れ) là thể loại quen thuộc → ưu tiên listing ja-JP.

---

## 14. Putt Puzzle: Daily Mini Golf (puttpuzzle)

| | |
|---|---|
| Mã app | `com.tuanapps.puttpuzzle` |
| Loại | Game → **Puzzle** |
| Thị trường | **Tất cả quốc gia** |
| Ngôn ngữ store | `en-US`, `de-DE`, `es-419`, `id`, `ja-JP`, `pt-BR`, `vi` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/puttpuzzle.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Ăn theo *putt.day* ("Wordle phiên bản minigolf", ra 13/5/2026). Chỉ có trên web, Android chưa có app thật.

**Kiếm tiền:** miễn phí Dễ + Vừa không giới hạn; Khó 3 câu/ngày, Chuyên gia 1 câu/ngày, 3 gợi ý + 1/ngày. `premium_lifetime` mở mọi mức, gợi ý không giới hạn, kho 60 ngày, mọi giao diện.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`puttpuzzle-buildN`** → giải nén → **`app-puttpuzzle-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = puttpuzzle` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• Unlimited puzzles in 4 levels: Easy to Expert
• Daily puzzle with streaks
• Stars, themes and trophies – no ads
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlimited: all levels & hints` |
| **Description** | `Unlimited Hard & Expert puzzles, unlimited hints, the daily archive and every theme. One-time purchase.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $2.99** → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`games/store/puttpuzzle/metadata/android/en-US/images/icon.png` · `games/store/puttpuzzle/metadata/android/en-US/images/featureGraphic.png` · `games/store/puttpuzzle/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (28/30)
```
Putt Puzzle: Daily Mini Golf
```
Short description (72/80)
```
A new mini golf hole every day. Aim, putt and beat par. No ads, offline.
```
Full description
```
A new mini golf hole every day. Aim, putt and beat par. No ads, offline.

HOW TO PLAY
Drag back from the ball like a slingshot and release to putt — the longer the pull, the harder the shot. Sink the ball in as few strokes as possible: par is the target, and water costs a penalty stroke.

FEATURES
• Unlimited puzzles in 4 levels: Easy, Medium, Hard and Expert
• Every hole is checked by a solver, so par is always reachable
• A new daily puzzle, streaks and a 60-day archive
• Earn 1–3 stars, unlock 8 color themes, collect 12 trophies
• Timer, best times and detailed stats
• Hints when you're stuck
• No ads. Works offline. No account needed.

GO UNLIMITED
One small one-time purchase: unlimited Hard & Expert puzzles, unlimited hints, the full daily archive and every theme. No subscription.
```

<details><summary>German – de-DE: bấm để mở</summary>

**German – de-DE**

App name (29/30)
```
Putt Puzzle: Minigolf täglich
```
Short description (64/80)
```
Jeden Tag ein neues Minigolf-Loch. Zielen, putten, Par schlagen.
```
Full description
```
Jeden Tag ein neues Minigolf-Loch. Zielen, putten, Par schlagen.

SO WIRD GESPIELT
Zieh vom Ball nach hinten wie bei einer Steinschleuder und lass los, um zu putten – je weiter du ziehst, desto fester der Schlag. Versenke den Ball mit möglichst wenigen Schlägen: Par ist das Ziel, Wasser kostet einen Strafschlag.

FUNKTIONEN
• Unbegrenzt Rätsel in 4 Stufen: Leicht, Mittel, Schwer, Experte
• Jedes Loch wird von einem Löser geprüft – Par ist immer machbar
• Neues Tagesrätsel, Serien und ein 60-Tage-Archiv
• 1–3 Sterne verdienen, 8 Farbdesigns und 12 Trophäen freischalten
• Timer, Bestzeiten und Statistik
• Tipps, wenn du feststeckst
• Keine Werbung. Offline spielbar. Kein Konto nötig.

UNBEGRENZT FREISCHALTEN
Ein kleiner Einmalkauf: unbegrenzt schwere und Experten-Rätsel, unbegrenzt Tipps, das komplette Archiv und alle Designs. Kein Abo.
```

</details>

<details><summary>Spanish (Latin America) – es-419: bấm để mở</summary>

**Spanish (Latin America) – es-419**

App name (28/30)
```
Putt Puzzle: Minigolf Diario
```
Short description (65/80)
```
Un hoyo de minigolf nuevo cada día. Apunta, golpea y bate el par.
```
Full description
```
Un hoyo de minigolf nuevo cada día. Apunta, golpea y bate el par.

CÓMO JUGAR
Arrastra hacia atrás desde la bola como un tirachinas y suelta para golpear: cuanto más tires, más fuerte. Mete la bola en el hoyo con los menos golpes posibles; el par es el objetivo y el agua suma un golpe de penalización.

CARACTERÍSTICAS
• Puzles ilimitados en 4 niveles: Fácil, Medio, Difícil y Experto
• Cada hoyo se comprueba con un solucionador: el par siempre es posible
• Puzle diario nuevo, rachas y archivo de 60 días
• Gana de 1 a 3 estrellas, desbloquea 8 temas y 12 trofeos
• Cronómetro, mejores tiempos y estadísticas
• Pistas cuando te atascas
• Sin anuncios. Funciona sin internet. Sin cuenta.

PÁSATE A ILIMITADO
Un único pago pequeño: puzles difíciles y expertos ilimitados, pistas ilimitadas, archivo diario completo y todos los temas. Sin suscripción.
```

</details>

<details><summary>Indonesian – id: bấm để mở</summary>

**Indonesian – id**

App name (29/30)
```
Putt Puzzle: Golf Mini Harian
```
Short description (66/80)
```
Lubang golf mini baru setiap hari. Bidik, pukul, dan kalahkan par.
```
Full description
```
Lubang golf mini baru setiap hari. Bidik, pukul, dan kalahkan par.

CARA BERMAIN
Tarik mundur dari bola seperti ketapel lalu lepaskan untuk memukul — makin panjang tarikan, makin keras pukulannya. Masukkan bola ke lubang dengan pukulan sesedikit mungkin: par adalah targetnya, masuk air kena penalti satu pukulan.

FITUR
• Teka-teki tanpa batas di 4 level: Mudah, Sedang, Sulit, Ahli
• Setiap lubang dicek oleh pemecah otomatis, par selalu bisa dicapai
• Teka-teki harian baru, beruntun, dan arsip 60 hari
• Raih 1–3 bintang, buka 8 tema warna, kumpulkan 12 trofi
• Timer, waktu terbaik, dan statistik
• Petunjuk saat kamu buntu
• Tanpa iklan. Bisa offline. Tanpa akun.

BUKA TANPA BATAS
Sekali bayar: teka-teki Sulit & Ahli tanpa batas, petunjuk tanpa batas, arsip harian lengkap, dan semua tema. Tanpa langganan.
```

</details>

<details><summary>Japanese – ja-JP: bấm để mở</summary>

**Japanese – ja-JP**

App name (20/30)
```
Putt Puzzle: 毎日ミニゴルフ
```
Short description (31/80)
```
毎日新しいミニゴルフのホール。ねらって打って、パーを目指そう。
```
Full description
```
毎日新しいミニゴルフのホール。ねらって打って、パーを目指そう。

遊び方
ボールから後ろへ引っぱって離すとパット。引くほど強く打てます。できるだけ少ない打数でカップインしよう。パーが目標、池に落ちると1打罰です。

特徴
• かんたん・ふつう・むずかしい・エキスパートの4段階、パズルは無制限
• どのホールもソルバーで検証済み。パーは必ず達成できます
• 毎日の新作パズル、連続記録、60日分のアーカイブ
• ★1〜3で評価、8つのカラーテーマと12個のトロフィー
• タイマー、ベストタイム、詳しい記録
• 行きづまったらヒント
• 広告なし。オフラインOK。アカウント不要。

無制限パック
一度の購入で、むずかしい・エキスパートが無制限、ヒント無制限、過去のパズル全部、すべてのテーマが使えます。サブスクではありません。
```

</details>

<details><summary>Portuguese (Brazil) – pt-BR: bấm để mở</summary>

**Portuguese (Brazil) – pt-BR**

App name (29/30)
```
Putt Puzzle: Minigolfe Diário
```
Short description (65/80)
```
Um buraco de minigolfe novo todo dia. Mire, tacada e vença o par.
```
Full description
```
Um buraco de minigolfe novo todo dia. Mire, tacada e vença o par.

COMO JOGAR
Arraste para trás a partir da bola como um estilingue e solte para tacar: quanto maior o puxão, mais forte a tacada. Acerte o buraco com o mínimo de tacadas; o par é a meta e a água custa uma tacada de penalidade.

RECURSOS
• Desafios ilimitados em 4 níveis: Fácil, Médio, Difícil e Especialista
• Cada buraco é verificado por um solucionador: o par é sempre possível
• Desafio diário novo, sequências e arquivo de 60 dias
• Ganhe de 1 a 3 estrelas, desbloqueie 8 temas e 12 troféus
• Cronômetro, melhores tempos e estatísticas
• Dicas quando você travar
• Sem anúncios. Funciona offline. Sem cadastro.

DESBLOQUEIE O ILIMITADO
Um pagamento único: desafios difíceis e de especialista ilimitados, dicas ilimitadas, arquivo diário completo e todos os temas. Sem assinatura.
```

</details>

<details><summary>Vietnamese – vi: bấm để mở</summary>

**Vietnamese – vi**

App name (22/30)
```
Putt Puzzle: Golf Mini
```
Short description (57/80)
```
Mỗi ngày một lỗ golf mini mới. Ngắm, đánh và về dưới par.
```
Full description
```
Mỗi ngày một lỗ golf mini mới. Ngắm, đánh và về dưới par.

CÁCH CHƠI
Kéo ngược từ quả bóng như bắn ná rồi thả tay để đánh — kéo càng dài, cú đánh càng mạnh. Đưa bóng vào lỗ với ít gậy nhất có thể: par là mục tiêu, rơi xuống nước bị phạt thêm một gậy.

TÍNH NĂNG
• Câu đố không giới hạn ở 4 mức: Dễ, Vừa, Khó, Chuyên gia
• Mỗi lỗ đều được máy kiểm tra, luôn có cách về par
• Câu đố mới mỗi ngày, chuỗi ngày chơi và kho 60 ngày
• Nhận 1–3 sao, mở 8 giao diện màu, sưu tầm 12 huy hiệu
• Bấm giờ, kỷ lục và thống kê chi tiết
• Gợi ý khi bí
• Không quảng cáo. Chơi không cần mạng. Không cần tài khoản.

MỞ KHOÁ KHÔNG GIỚI HẠN
Trả một lần: câu Khó và Chuyên gia không giới hạn, gợi ý không giới hạn, toàn bộ kho câu đố hằng ngày và mọi giao diện. Không thuê bao.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/puttpuzzle.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Game** → Puzzle/Word; mọi mục bạo lực, cờ bạc, người lớn, tương tác người dùng: **No**; mua hàng kỹ thuật số: **Yes** |
| Target audience | **13–15, 16–17, 18+** (không chọn dưới 13). Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Puzzle** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng chữ "putt.day" trong tên, icon, mô tả, ảnh.
- Cơ chế chơi không được bảo hộ bản quyền; tên, logo, hình ảnh thương hiệu thì có. Tên, icon và đồ hoạ của app là của riêng mình.
- Không thêm tính năng cược hay giải thưởng tiền thật.

### 🚀 Tăng lượt tải

1. Reddit r/minigolf, r/WebGames, r/AndroidGaming.
2. Video ngắn "hole-in-one" trên Shorts/Reels: game golf rất hợp video.

---

## 15. Word Weave: Hidden Words (wordweave)

| | |
|---|---|
| Mã app | `com.tuanapps.wordweave` |
| Loại | Game → **Word** |
| Thị trường | **Tất cả quốc gia** |
| Ngôn ngữ store | `en-US`, `de-DE`, `es-419`, `id`, `ja-JP`, `pt-BR`, `vi` |
| Privacy policy | https://tuanlt1989.github.io/assignment/privacy/wordweave.html |
| Email hỗ trợ | tuanlt1989@gmail.com |
| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |
| Mua trong app | `premium_lifetime` = mở khoá toàn bộ, trả 1 lần |

**Vì sao làm:** Ăn theo *Wend* của LinkedIn (ra 6/2026). Chưa tìm thấy bản nào trên Android.

**Kiếm tiền:** miễn phí Dễ + Vừa không giới hạn; Khó 3 câu/ngày, Chuyên gia 1 câu/ngày, 3 gợi ý + 1/ngày. `premium_lifetime` mở mọi mức, gợi ý không giới hạn, kho 60 ngày, mọi giao diện.

---

### 📦 File tải lên

- Vào [Actions → Android build](https://github.com/tuanlt1989/assignment/actions/workflows/android.yml) → lần chạy mới nhất có dấu ✅ → **Artifacts** → tải **`wordweave-buildN`** → giải nén → **`app-wordweave-release.aab`**.
- Kiểm tra log bước *Release signing* ghi `Signing with the upload key.`
- Từ lần 2: dùng [Publish to Google Play](https://github.com/tuanlt1989/assignment/actions/workflows/publish.yml) với `apps = wordweave` (xem Phần A, mục A5).

**Release name:** `1.0.0 - First release` (versionCode do CI tự đặt)

**Release notes**
```
<en-US>
First release!
• Unlimited puzzles in 4 levels: Easy to Expert
• Daily puzzle with streaks
• Stars, themes and trophies – no ads
</en-US>
```

### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)

| Ô | Điền |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | `Unlimited: all levels & hints` |
| **Description** | `Unlimited Hard & Expert puzzles, unlimited hints, the daily archive and every theme. One-time purchase.` |
| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |
| **Giá** | **US $2.99** → Update exchange rates → Availability: các nước ở trên |

Các bước chi tiết: Phần A, mục A4.

### 🖼 Hình ảnh

`games/store/wordweave/metadata/android/en-US/images/icon.png` · `games/store/wordweave/metadata/android/en-US/images/featureGraphic.png` · `games/store/wordweave/metadata/android/en-US/images/phoneScreenshots/1.png`→`4.png`

### ✍️ Nội dung trang store

**English (United States) – en-US**

App name (24/30)
```
Word Weave: Hidden Words
```
Short description (72/80)
```
Find the hidden words woven through the grid. Every letter is used once.
```
Full description
```
Find the hidden words woven through the grid. Every letter is used once.

HOW TO PLAY
The grid hides several words that use every letter exactly once. Drag across neighbouring letters (up, down, left or right) to trace a word that fits one of the slots; find them all to win.

FEATURES
• Unlimited puzzles in 4 levels: Easy, Medium, Hard and Expert
• Every puzzle has exactly one solution – pure logic, no guessing
• A new daily puzzle, streaks and a 60-day archive
• Earn 1–3 stars, unlock 8 color themes, collect 12 trophies
• Timer, best times and detailed stats
• Hints when you're stuck
• No ads. Works offline. No account needed.

GO UNLIMITED
One small one-time purchase: unlimited Hard & Expert puzzles, unlimited hints, the full daily archive and every theme. No subscription.
```

<details><summary>German – de-DE: bấm để mở</summary>

**German – de-DE**

App name (29/30)
```
Word Weave: Versteckte Wörter
```
Short description (75/80)
```
Finde die versteckten Wörter im Raster. Jeder Buchstabe zählt genau einmal.
```
Full description
```
Finde die versteckten Wörter im Raster. Jeder Buchstabe zählt genau einmal.

SO WIRD GESPIELT
Im Raster verstecken sich mehrere Wörter, die jeden Buchstaben genau einmal nutzen. Wische über benachbarte Buchstaben (hoch, runter, links, rechts), um ein Wort für eine Lücke zu bilden; finde alle, um zu gewinnen.

FUNKTIONEN
• Unbegrenzt Rätsel in 4 Stufen: Leicht, Mittel, Schwer, Experte
• Jedes Rätsel hat genau eine Lösung – reine Logik, kein Raten
• Neues Tagesrätsel, Serien und ein 60-Tage-Archiv
• 1–3 Sterne verdienen, 8 Farbdesigns und 12 Trophäen freischalten
• Timer, Bestzeiten und Statistik
• Tipps, wenn du feststeckst
• Keine Werbung. Offline spielbar. Kein Konto nötig.

UNBEGRENZT FREISCHALTEN
Ein kleiner Einmalkauf: unbegrenzt schwere und Experten-Rätsel, unbegrenzt Tipps, das komplette Archiv und alle Designs. Kein Abo.
```

</details>

<details><summary>Spanish (Latin America) – es-419: bấm để mở</summary>

**Spanish (Latin America) – es-419**

App name (28/30)
```
Word Weave: Palabras Ocultas
```
Short description (75/80)
```
Encuentra las palabras ocultas en la cuadrícula. Cada letra se usa una vez.
```
Full description
```
Encuentra las palabras ocultas en la cuadrícula. Cada letra se usa una vez.

CÓMO JUGAR
La cuadrícula esconde varias palabras que usan cada letra una sola vez. Desliza el dedo por letras vecinas (arriba, abajo, izquierda o derecha) para formar una palabra que encaje en un hueco; encuéntralas todas para ganar.

CARACTERÍSTICAS
• Puzles ilimitados en 4 niveles: Fácil, Medio, Difícil y Experto
• Cada puzle tiene una sola solución: lógica pura, sin adivinar
• Puzle diario nuevo, rachas y archivo de 60 días
• Gana de 1 a 3 estrellas, desbloquea 8 temas y 12 trofeos
• Cronómetro, mejores tiempos y estadísticas
• Pistas cuando te atascas
• Sin anuncios. Funciona sin internet. Sin cuenta.

PÁSATE A ILIMITADO
Un único pago pequeño: puzles difíciles y expertos ilimitados, pistas ilimitadas, archivo diario completo y todos los temas. Sin suscripción.
```

</details>

<details><summary>Indonesian – id: bấm để mở</summary>

**Indonesian – id**

App name (28/30)
```
Word Weave: Kata Tersembunyi
```
Short description (69/80)
```
Temukan kata tersembunyi di kotak huruf. Setiap huruf dipakai sekali.
```
Full description
```
Temukan kata tersembunyi di kotak huruf. Setiap huruf dipakai sekali.

CARA BERMAIN
Kisi-kisi menyembunyikan beberapa kata yang memakai setiap huruf tepat satu kali. Geser melewati huruf yang bersebelahan (atas, bawah, kiri, kanan) untuk membentuk kata yang cocok dengan kotak kosong; temukan semuanya untuk menang.
Kata-kata dalam bahasa Inggris – main sambil belajar kosakata.

FITUR
• Teka-teki tanpa batas di 4 level: Mudah, Sedang, Sulit, Ahli
• Setiap teka-teki punya tepat satu solusi – murni logika
• Teka-teki harian baru, beruntun, dan arsip 60 hari
• Raih 1–3 bintang, buka 8 tema warna, kumpulkan 12 trofi
• Timer, waktu terbaik, dan statistik
• Petunjuk saat kamu buntu
• Tanpa iklan. Bisa offline. Tanpa akun.

BUKA TANPA BATAS
Sekali bayar: teka-teki Sulit & Ahli tanpa batas, petunjuk tanpa batas, arsip harian lengkap, dan semua tema. Tanpa langganan.
```

</details>

<details><summary>Japanese – ja-JP: bấm để mở</summary>

**Japanese – ja-JP**

App name (20/30)
```
Word Weave: かくれ単語パズル
```
Short description (32/80)
```
文字のグリッドに隠れた単語を探そう。どの文字も1回ずつ使います。
```
Full description
```
文字のグリッドに隠れた単語を探そう。どの文字も1回ずつ使います。

遊び方
グリッドには、すべての文字をちょうど1回ずつ使う単語が隠れています。上下左右に隣り合う文字をなぞって空欄に合う単語を作り、すべて見つければクリアです。
単語は英語です。遊びながら英単語の練習にも。

特徴
• かんたん・ふつう・むずかしい・エキスパートの4段階、パズルは無制限
• どのパズルも答えはひとつ。運ではなく論理で解ける
• 毎日の新作パズル、連続記録、60日分のアーカイブ
• ★1〜3で評価、8つのカラーテーマと12個のトロフィー
• タイマー、ベストタイム、詳しい記録
• 行きづまったらヒント
• 広告なし。オフラインOK。アカウント不要。

無制限パック
一度の購入で、むずかしい・エキスパートが無制限、ヒント無制限、過去のパズル全部、すべてのテーマが使えます。サブスクではありません。
```

</details>

<details><summary>Portuguese (Brazil) – pt-BR: bấm để mở</summary>

**Portuguese (Brazil) – pt-BR**

App name (28/30)
```
Word Weave: Palavras Ocultas
```
Short description (66/80)
```
Encontre as palavras ocultas na grade. Cada letra é usada uma vez.
```
Full description
```
Encontre as palavras ocultas na grade. Cada letra é usada uma vez.

COMO JOGAR
A grade esconde várias palavras que usam cada letra uma única vez. Arraste por letras vizinhas (para cima, baixo, esquerda ou direita) para formar uma palavra que caiba em um espaço; encontre todas para vencer.

RECURSOS
• Desafios ilimitados em 4 níveis: Fácil, Médio, Difícil e Especialista
• Cada desafio tem uma única solução – lógica pura, sem chute
• Desafio diário novo, sequências e arquivo de 60 dias
• Ganhe de 1 a 3 estrelas, desbloqueie 8 temas e 12 troféus
• Cronômetro, melhores tempos e estatísticas
• Dicas quando você travar
• Sem anúncios. Funciona offline. Sem cadastro.

DESBLOQUEIE O ILIMITADO
Um pagamento único: desafios difíceis e de especialista ilimitados, dicas ilimitadas, arquivo diário completo e todos os temas. Sem assinatura.
```

</details>

<details><summary>Vietnamese – vi: bấm để mở</summary>

**Vietnamese – vi**

App name (21/30)
```
Word Weave: Tìm Từ Ẩn
```
Short description (63/80)
```
Tìm các từ ẩn đan trong lưới chữ. Mỗi chữ cái chỉ dùng một lần.
```
Full description
```
Tìm các từ ẩn đan trong lưới chữ. Mỗi chữ cái chỉ dùng một lần.

CÁCH CHƠI
Lưới chữ ẩn nhiều từ, mỗi chữ cái thuộc đúng một từ. Kéo qua các chữ cái kề nhau (lên, xuống, trái, phải) để tạo một từ khớp với ô trống; tìm hết các từ để thắng.
Từ vựng tiếng Anh – vừa chơi vừa học từ.

TÍNH NĂNG
• Câu đố không giới hạn ở 4 mức: Dễ, Vừa, Khó, Chuyên gia
• Mỗi câu đố chỉ có đúng một lời giải – thuần logic, không phải đoán
• Câu đố mới mỗi ngày, chuỗi ngày chơi và kho 60 ngày
• Nhận 1–3 sao, mở 8 giao diện màu, sưu tầm 12 huy hiệu
• Bấm giờ, kỷ lục và thống kê chi tiết
• Gợi ý khi bí
• Không quảng cáo. Chơi không cần mạng. Không cần tài khoản.

MỞ KHOÁ KHÔNG GIỚI HẠN
Trả một lần: câu Khó và Chuyên gia không giới hạn, gợi ý không giới hạn, toàn bộ kho câu đố hằng ngày và mọi giao diện. Không thuê bao.
```

</details>

### 📋 App content

| Mục | Trả lời |
|---|---|
| Privacy policy | `https://tuanlt1989.github.io/assignment/privacy/wordweave.html` |
| App access | All functionality is available without special access |
| Ads | **No, my app does not contain ads** |
| Content rating | IARC → **Game** → Puzzle/Word; mọi mục bạo lực, cờ bạc, người lớn, tương tác người dùng: **No**; mua hàng kỹ thuật số: **Yes** |
| Target audience | **13–15, 16–17, 18+** (không chọn dưới 13). Hấp dẫn trẻ em: **No** |
| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |
| Advertising ID | **No** |
| News / Government / Financial features / Health | No / No / None / None |
| Store settings | Category **Word** · Email tuanlt1989@gmail.com |

### ⚖️ Lưu ý pháp lý

- Không dùng chữ "Wend", "LinkedIn" trong tên, icon, mô tả, ảnh.
- Cơ chế chơi không được bảo hộ bản quyền; tên, logo, hình ảnh thương hiệu thì có. Tên, icon và đồ hoạ của app là của riêng mình.
- Không thêm tính năng cược hay giải thưởng tiền thật.

### 🚀 Tăng lượt tải

1. Reddit r/wordgames, r/WordleGames; nhóm Facebook word puzzle.
2. Người học tiếng Anh (VN, ID, JP): "vừa chơi vừa học từ".

---

## Phụ lục — toàn bộ tài liệu khác

<!-- README.md -->

### Exam Prep Apps — nhà máy app luyện thi (Flutter)

Một codebase Flutter → nhiều app luyện thi chứng chỉ hành nghề trên Google Play.
Mỗi app = **1 file cấu hình** (`apps/<id>.json`) + **1 ngân hàng câu hỏi** (`content/<bank>/`) + **1 bộ nội dung cửa hàng** (`store/<id>/`).

#### 15 app: 10 app luyện thi + 5 game giải đố

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

#### Tính năng app

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

#### Cấu trúc

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

#### Lệnh thường dùng

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

#### Tài liệu

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

#### ⚠️ Phải sửa trước lần upload đầu tiên

- `applicationId` trong `apps/*.json` và `games/apps/*.json`: đã đặt là `com.tuanapps.<id>` (ví dụ `com.tuanapps.nailvi`). **Sau khi đã upload lên Play thì không đổi được nữa.**
- `supportEmail`, `developerName`. Bật GitHub Pages để có trang chính sách bảo mật (docs/08 bước 4).
- Gói mua trong app `premium_lifetime`: tạo theo `docs/06-IN-APP-PURCHASE.md`.

---

<!-- docs/01-SIGNING-AND-BUILD.md -->

### 01 — Khoá ký & build AAB/APK

Google Play bắt buộc file **AAB** phải được ký bằng **upload key** của bạn. Khi bật Play App Signing (mặc định), Google giữ khoá ký thật của app, còn bạn chỉ giữ upload key. Nếu lỡ mất upload key, bạn có thể xin Google đặt lại.

Dùng **một upload key chung cho cả 5 app** cho đơn giản. Mỗi app vẫn có khoá ký riêng do Google quản lý.

#### 1. Tạo upload key (làm 1 lần)

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Cất file `upload-keystore.jks` và mật khẩu ở nơi an toàn, ví dụ trình quản lý mật khẩu. **Không commit file này lên git** (`.gitignore` đã chặn sẵn `*.jks`).

#### 2a. Build trên máy của bạn

Tạo file `android/key.properties` (đã nằm trong `.gitignore`):

```properties
storeFile=/đường/dẫn/tới/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Sau đó build:

```bash
flutter build appbundle --release --flavor nailvi --build-number 2
### file ra: build/app/outputs/bundle/nailviRelease/app-nailvi-release.aab
```

- **`--build-number` phải tăng sau mỗi lần upload.** Play từ chối mã phiên bản (versionCode) đã dùng.
- Nếu không có `key.properties`, bản release sẽ được ký bằng debug key. Bản đó vẫn cài thử trên máy được, nhưng **Play sẽ từ chối**.

#### 2b. Build tự động trên GitHub (khuyên dùng)

Vào repo trên GitHub → **Settings → Secrets and variables → Actions → New repository secret**, thêm 4 secret:

| Secret | Giá trị |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | kết quả lệnh `base64 -w0 upload-keystore.jks` (trên macOS: `base64 -i upload-keystore.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | mật khẩu keystore |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | mật khẩu của key |

Sau đó, mỗi lần push:
1. CI chạy `analyze` và `test`.
2. CI build AAB và APK cho **mọi** file `apps/*.json`.
3. `versionCode` lấy theo số thứ tự lần chạy CI (luôn tăng), nên AAB của lần chạy nào cũng upload được.
4. Tải file về ở tab **Actions → lần chạy → Artifacts** (mỗi app một gói zip).

#### 3. Cài thử APK lên điện thoại Android

Tải `app-<id>-release.apk` từ Artifacts, gửi sang điện thoại, bật "Cài ứng dụng không rõ nguồn gốc" rồi cài.
Hoặc cắm điện thoại vào máy tính và chạy `flutter run --flavor nailvi --release`.

Lưu ý: tính năng mua hàng chỉ chạy khi app được cài **từ Play** (internal testing trở lên) và tài khoản Google trên máy đã được thêm làm tester. Quảng cáo TEST thì hiện ngay.

---

<!-- docs/02-LAUNCH-CHECKLIST.md -->

### 02 — Checklist đưa app lên Google Play

Làm lần lượt từ trên xuống. Phần B–D làm một lần cho cả nhà máy; phần E–H làm cho **từng app**.
Chính sách của Google Play thay đổi thường xuyên, nên luôn đọc lại thông báo trong Play Console. Tài liệu này viết vào tháng 10/2026.

---

#### A. Chọn loại tài khoản Play Console (quan trọng)

| | Tài khoản **Cá nhân** | Tài khoản **Tổ chức** |
|---|---|---|
| Phí | $25 một lần | $25 một lần |
| Giấy tờ | CMND/hộ chiếu | Công ty (LLC…) + **số D-U-N-S** (miễn phí, chờ vài ngày đến vài tuần) |
| **Thử nghiệm kín bắt buộc** | Tài khoản tạo sau 11/2023 phải chạy **closed testing với ≥12 tester liên tục 14 ngày** cho **mỗi app** trước khi được lên production | **Không bắt buộc** |
| Tên hiển thị | Tên thật của bạn | Tên công ty, trông chuyên nghiệp hơn |

👉 Nếu định làm 100 app, nên **mở LLC và lấy số D-U-N-S** để bỏ được bước 12 tester × 14 ngày cho mỗi app.
Nếu dùng tài khoản cá nhân: chạy closed test **cho cả 5 app cùng lúc** với cùng một nhóm tester (12 người trở lên), ví dụ người quen, học viên trường nail hoặc thành viên các nhóm Facebook.

Không tạo nhiều tài khoản developer để lách luật. Google có thể khoá toàn bộ các tài khoản liên quan.

#### B. Sửa cấu hình (một lần, trước lần upload đầu tiên)

Trong mỗi file `apps/*.json`:

- [x] `applicationId`: đã đặt là `com.tuanapps.<id>`, ví dụ `com.tuanapps.nailvi`. **Sau khi upload thì không đổi được nữa.**
- [ ] `developerName`, `supportEmail`: email này hiện công khai trên Play.
- [ ] `privacyPolicyUrl`: xem mục C.
- [ ] Chạy `python3 tool/factory.py`, commit rồi push.

#### C. Đưa trang Chính sách bảo mật lên mạng

`tool/factory.py` đã tạo sẵn `docs/privacy/<id>.html`. Chọn một trong các cách sau để đưa lên mạng:
- **GitHub Pages**: repo phải public (hoặc dùng gói GitHub Pro). Vào Settings → Pages, chọn thư mục `/docs`. URL sẽ là `https://<user>.github.io/<repo>/privacy/<id>.html`.
- **Cloudflare Pages / Netlify**: miễn phí, kéo thả thư mục `docs/privacy` là xong.
- **Google Sites**: dán nội dung trang vào.

Kiểm tra URL mở được trên điện thoại, rồi cập nhật `privacyPolicyUrl` trong `apps/*.json`.

#### D. Khoá ký và build

Làm theo `docs/01-SIGNING-AND-BUILD.md`. Kết quả là có AAB đã ký cho từng app.

---

#### E. Tạo app trong Play Console (làm cho từng app)

1. **Create app**:
   - Tên app: lấy từ `store/<id>/metadata/android/<locale>/title.txt`.
   - Ngôn ngữ mặc định: English (United States).
   - Loại: App. Hình thức: **Free** (vì có mua trong app).
2. **Dashboard → Set up your app**, trả lời từng mục:
   - **App access**: All functionality is available without special access.
   - **Ads**: hiện cả 10 app đặt `"ads": false`, nên khai báo **No, my app does not contain ads**. Chỉ khi bật AdMob (`docs/07`) mới đổi thành Yes.
   - **Content rating**: chọn danh mục Reference/Education. Không có bạo lực hay nội dung người lớn, thường ra mức **Everyone**.
   - **Target audience**: chọn **18 and over**. App dành cho người đi thi chứng chỉ; chọn nhóm dưới 13 tuổi sẽ bị áp chính sách Families rất chặt.
   - **News app**: No. **Government app**: No. **Financial features**: No. **Health**: chọn mục không thuộc nhóm nào. Với app bảo hiểm cũng chọn No vì app chỉ dạy học, không bán bảo hiểm.
   - **Advertising ID**: với app `"ads": false`, chọn **No** (factory đã gỡ quyền `AD_ID`). Với app bật quảng cáo, chọn Yes, mục đích Advertising/Analytics.
   - **Data safety** cho app `"ads": false`: **"No, we do not collect or share user data"**, vì dữ liệu học chỉ lưu trên máy và thanh toán do Google Play xử lý.
   - **Data safety** cho app bật quảng cáo, trả lời theo những gì AdMob thu thập:
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

#### F. Upload bản đầu tiên & thử nghiệm

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
   - Chọn quốc gia theo trường `markets` trong `apps/<id>.json`:
     - Đợt 1 (nail, cosmetology, bảo hiểm): **United States**. App tiếng Tây Ban Nha thêm Puerto Rico.
     - `nursegulf`: Ấn Độ, Philippines, các nước vùng Vịnh…
     - `cscsro` / `cscspl`: United Kingdom.
     - `sachkunde`: Germany.
     - `civilserviceph`: Philippines.
   - Bật rollout. Thời gian duyệt từ vài giờ đến vài ngày.

#### G. Tạo sản phẩm mua trong app (chi tiết đầy đủ: `docs/06-IN-APP-PURCHASE.md`)

Play chỉ cho tạo sản phẩm sau khi đã upload ít nhất một AAB có quyền BILLING. Thư viện `in_app_purchase` đã tự thêm quyền này.

1. **Monetize → Products → In-app products → Create product**:
   - Product ID: **`premium_lifetime`**. ID phải trùng chính xác với `premiumProductId` trong `apps/<id>.json`.
   - Tên: "Unlock all questions". Viết mô tả ngắn.
   - Giá: xem bảng giá gợi ý trong README. Play tự quy đổi sang các nước khác.
   - Bấm **Activate**.
2. **Setup → License testing**: thêm email của bạn để mua thử miễn phí.
3. Mở app (bản cài từ Play) → Mở khoá → mua thử. Kiểm tra quảng cáo biến mất và toàn bộ câu hỏi được mở. Gỡ app, cài lại, bấm "Khôi phục giao dịch" để kiểm tra khôi phục.

#### H. Bật quảng cáo thật (AdMob) — KHÔNG BẮT BUỘC, xem `docs/07-ADMOB.md`

1. Tạo tài khoản tại admob.google.com và điền thông tin thanh toán và thuế (W-8BEN nếu bạn không phải người Mỹ).
2. **Apps → Add app** → chọn Android → liên kết với app trên Play (sau khi app đã được duyệt).
3. Tạo 2 ad unit cho mỗi app: **Banner** và **Interstitial**.
4. Chép App ID (`ca-app-pub-xxx~yyy`) và 2 ad unit ID (`ca-app-pub-xxx/zzz`) vào `apps/<id>.json` → `admob`.
5. Chạy `python3 tool/factory.py --release`. Lệnh phải báo `ok` cho mọi app.
6. Commit, push, tải AAB mới (CI tự tăng versionCode) và upload lên Production.
7. **app-ads.txt**: AdMob yêu cầu đặt file `app-ads.txt` ở **website ghi trong mục Store settings** của Play, ví dụ `https://tenmien.com/app-ads.txt`. Nội dung lấy trong AdMob → Apps → app-ads.txt.
8. **Privacy & messaging** trong AdMob: tạo **GDPR message** (bắt buộc nếu phát hành ở EU/Anh) và **US states message**. App đã gắn sẵn UMP SDK nên form tự hiện khi cần.

⚠️ **Không bao giờ bấm vào quảng cáo thật trên app của chính mình.** Khi tự test, chỉ dùng ID TEST hoặc thêm máy của bạn làm test device trong AdMob.

#### I. Sau khi phát hành

- [ ] Trả lời mọi đánh giá trong vòng 24–48 giờ, đặc biệt các đánh giá 1–3 sao.
- [ ] Xem **Statistics**: tỷ lệ chuyển đổi trang cửa hàng (store listing conversion), số lượt cài, tỷ lệ gỡ app.
- [ ] Mỗi lần cập nhật câu hỏi: sửa `content/`, chạy `build_banks.py`, push, upload AAB mới.
- [ ] Đọc `docs/03-ANDROID-GROWTH-PLAYBOOK.md`.

---

<!-- docs/03-ANDROID-GROWTH-PLAYBOOK.md -->

### 03 — Kế hoạch "đánh mạnh" thị trường Android

Mục tiêu thực tế cho giai đoạn đầu: **mỗi app 5–20 USD/ngày** sau 2–3 tháng.
Mỗi app có hai nguồn thu: người dùng miễn phí xem quảng cáo, và một phần nhỏ người dùng (khoảng 2–5%) trả tiền một lần.
Các con số dưới đây là **ước tính để lên kế hoạch**, không phải cam kết. Hãy đo số liệu thật rồi điều chỉnh.

#### 0. Phép tính cần nhớ

```
Doanh thu/ngày ≈ lượt cài/ngày × tỷ lệ mua × giá × 0,85 (Google thu 15%)  +  doanh thu quảng cáo
Ví dụ app nailvi: 30 lượt cài/ngày × 4% × $14.99 × 0,85 ≈ $15/ngày (chưa tính quảng cáo)
```

Cần khoảng **20–40 lượt cài mỗi ngày cho mỗi app**. Đó là mục tiêu của mọi việc bên dưới.

#### 1. Tối ưu trang cửa hàng (ASO) — miễn phí, làm trước tiên

- **Tiêu đề và mô tả ngắn chứa đúng từ khoá người dùng gõ.** Nội dung trong `store/` đã viết sẵn theo hướng này: "nail exam", "Vietnamese", "manicurist", "state board", "examen de uñas", "cosmetología"…
- **Dịch trang cửa hàng** sang ngôn ngữ người dùng: `vi` cho app tiếng Việt, `es-US` cho app tiếng Tây Ban Nha. Người dùng có điện thoại để tiếng Việt sẽ thấy trang tiếng Việt.
- **Store listing experiments** (Play Console → Grow → Store listing experiments): luôn chạy 1 thử nghiệm A/B, mỗi lần chỉ thử 1 yếu tố. Thứ tự nên thử: icon → ảnh màn hình đầu tiên → mô tả ngắn.
- **Custom store listings**: tạo trang riêng cho từng nhóm người dùng, ví dụ người dùng ở Texas hoặc từ một chiến dịch quảng cáo.
- **Đánh giá trung bình ≥ 4.5 sao** có ảnh hưởng lớn đến thứ hạng trên Play:
  - App đã tự hỏi người dùng đánh giá ngay sau khi họ thi thử đậu.
  - Trả lời mọi review, sửa lỗi người dùng báo rồi nhắn lại cho họ biết.
- Cập nhật app đều đặn (2–4 tuần một lần, thêm câu hỏi mới). Play ưu tiên các app được cập nhật thường xuyên.

#### 2. Cộng đồng — nguồn người dùng miễn phí tốt nhất cho ngách này

##### App tiếng Việt (nail / cosmetology)
- **Nhóm Facebook** của thợ nail và học viên nail người Việt tại Mỹ: đăng **mỗi ngày 1 câu hỏi kèm giải thích** dưới dạng ảnh, cuối bài để link app. Đăng nội dung có giá trị, đừng spam.
- **Trường nail và trường thẩm mỹ** của người Việt ở California, Texas, Georgia, Florida, Virginia…:
  - Tặng **mã khuyến mại (promo code)** của Play. Mỗi app được tạo tối đa 500 mã mỗi quý cho sản phẩm mua trong app.
  - Đề nghị chia hoa hồng nếu trường giới thiệu học viên.
- **TikTok / YouTube Shorts / Reels**: video 15–30 giây dạng "Câu này 70% thí sinh làm sai", quay màn hình app có phụ đề tiếng Việt.
- Đăng bài trên các trang báo và diễn đàn cộng đồng người Việt tại Mỹ.

##### App tiếng Tây Ban Nha
- Cách làm tương tự: nhóm Facebook "manicuristas", "cosmetología", trường beauty school có học viên nói tiếng Tây Ban Nha, video ngắn trên TikTok bằng tiếng Tây Ban Nha.

##### App bảo hiểm
- Reddit r/Insurance, các nhóm "new insurance agents".
- Các công ty bảo hiểm tuyển nhiều agent mới (IMO/agency) thường cần tài liệu ôn thi cho người mới.

#### 3. Quảng cáo trả phí (làm sau khi tỷ lệ chuyển đổi đã tốt)

- Chỉ chạy khi trang cửa hàng có **tỷ lệ chuyển đổi trên 25%** và app có **≥ 4.3 sao**.
- **Google Ads → App campaign (App promotion)**:
  - Ngân sách thử 10–20 USD/ngày/app trong 2 tuần.
  - Nhắm Mỹ, ngôn ngữ vi hoặc es.
  - Ban đầu tối ưu theo lượt cài. Khi đã có dữ liệu mua hàng thì chuyển sang tối ưu theo hành động trong app; muốn vậy cần thêm Firebase Analytics, xem mục 6.
- So sánh chi phí mỗi lượt cài (CPI) với doanh thu trên mỗi lượt cài: chỉ tăng ngân sách khi **CPI < doanh thu/lượt cài**.

#### 4. Giá & khuyến mãi

- Giá gợi ý ghi trong README. Thí sinh vừa trả $100–300 phí thi, nên mức $12.99–19.99 trả một lần dễ được chấp nhận.
- Thử giá bằng **Price experiments** trong Play Console, ví dụ $14.99 so với $19.99.
- Chạy **giảm giá theo mùa**: tháng 1 (đầu năm học mới), mùa hè.

#### 5. Chỉ số theo dõi hằng tuần

| Chỉ số | Ở đâu xem | Mục tiêu |
|---|---|---|
| Tỷ lệ chuyển đổi trang cửa hàng | Play Console → Store performance | > 25% |
| Đánh giá trung bình | Ratings | ≥ 4.5 |
| Tỷ lệ người dùng mua | Doanh thu ÷ lượt cài | 2–5% |
| eCPM quảng cáo | AdMob | Mỹ: banner $0.3–1, interstitial $3–10 |
| Tỷ lệ gỡ app trong ngày đầu | Statistics | < 30% |

#### 6. Lộ trình sản phẩm (theo thứ tự ưu tiên)

1. **Mở rộng ngân hàng câu hỏi lên 300–500 câu mỗi bộ.** Đối thủ quảng cáo "900 câu", nên số lượng câu là điều người dùng so sánh đầu tiên. Cách làm ở `docs/05-CONTENT-GUIDE.md`.
2. **Thêm phần luật riêng từng bang** (state law), ví dụ luật California hoặc Texas cho nail. Có thể bán thành gói riêng hoặc tách thành app riêng.
3. Thêm Firebase Analytics để chạy quảng cáo tối ưu theo lượt mua.
4. **Quảng cáo có thưởng (rewarded ad)**: "Xem 1 quảng cáo để mở khoá 24 giờ", giúp tăng doanh thu từ người dùng miễn phí.
5. Thêm chế độ flashcard và đọc câu hỏi thành tiếng.

#### 7. Nhân rộng nhà máy (sau khi 5 app đầu có số liệu)

Chỉ nhân rộng **ngách nào đã có doanh thu**. Các hướng dễ làm nhất:
- **Thêm ngôn ngữ cho bộ nail và cosmetology**: tiếng Hàn (`ko`), tiếng Trung (`zh`). Nhiều bang cho thi bằng các thứ tiếng này. Mỗi ngôn ngữ chỉ cần thêm file `ko.txt`, không phải viết code.
- **Thêm loại bằng mới**: Esthetician (chăm sóc da), Barber (cắt tóc nam). Mỗi loại bằng là một ngân hàng câu hỏi mới, dịch sang 3–4 thứ tiếng thì ra 3–4 app.
- **Bảo hiểm**: thêm Property & Casualty, sau đó làm phần luật riêng cho từng bang (50 bang × 2 loại bằng).
- **Bất động sản** (real estate): thị trường lớn nhưng cạnh tranh mạnh, cần chất lượng nội dung cao.

⚠️ **Chính sách spam của Google Play**: không đăng hàng loạt app gần như giống hệt nhau. Mỗi app phải có nội dung thật sự khác (ngân hàng câu hỏi khác, ngôn ngữ khác, kỳ thi khác), có icon, ảnh màn hình và mô tả riêng. Nhà máy này được thiết kế để mỗi app khác nhau ở **nội dung**, không chỉ đổi màu và đổi tên.

#### 8. Kênh tiếp cận cho 5 app thị trường quốc tế

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

---

<!-- docs/04-ADD-NEW-APP.md -->

### 04 — Thêm app mới (app thứ 6 đến thứ 100)

Thêm một app **không cần viết code**. Các bước:

#### 1. Ngân hàng câu hỏi

- **Dùng lại ngân hàng có sẵn, chỉ thêm ngôn ngữ** (ví dụ nail tiếng Hàn): tạo `content/nail/ko.txt` với cùng id và cùng thứ tự đáp án như `en.txt`, rồi thêm tên tiếng Hàn của các chủ đề vào `content/nail/meta.json`.
- **Ngân hàng mới** (ví dụ `esthetics`): tạo thư mục `content/esthetics/` gồm `meta.json` (danh sách chủ đề) và `en.txt`, sau đó thêm file các ngôn ngữ khác. Định dạng xem `docs/05-CONTENT-GUIDE.md`.

```bash
python3 tool/build_banks.py      # phải chạy không lỗi
```

#### 2. File cấu hình app

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

#### 3. Nội dung cửa hàng

Tạo `store/<id>/metadata/android/en-US/` (và `vi/`, `es-US/`, `ko-KR/`… nếu có) với 3 file:
- `title.txt` (≤ 30 ký tự)
- `short_description.txt` (≤ 80 ký tự)
- `full_description.txt` (≤ 4000 ký tự)

#### 4. Sinh tài nguyên & ảnh

```bash
python3 tool/factory.py                       # flavor, icon, feature graphic, privacy policy
flutter build web --release --no-web-resources-cdn --dart-define=NO_ADS=true
(cd build/web && python3 -m http.server 8765) &
(cd tool/screenshots && npm install && node shoot.js)
python3 tool/frame_screenshots.py             # ảnh màn hình 1080×1920 có chú thích
flutter test
```

#### 5. Build & phát hành

Commit rồi push. CI tự nhận app mới (mỗi file `apps/*.json` là một job build).
Sau đó làm theo `02-LAUNCH-CHECKLIST.md` từ mục E.

#### Thứ tự nên làm tiếp (gợi ý)

1. `nailko`, `nailzh`: nail tiếng Hàn và tiếng Trung (chỉ cần dịch)
2. `cosmoko`, `cosmozh`
3. `esthvi`, `esthes`: ngân hàng Esthetician mới
4. `barbervi`, `barberes`
5. `insurancepc`: bảo hiểm Property & Casualty

---

<!-- docs/05-CONTENT-GUIDE.md -->

### 05 — Soạn, dịch & kiểm duyệt câu hỏi

Chất lượng câu hỏi quyết định số sao đánh giá, mà số sao quyết định thứ hạng trên Play. Đây là phần đáng đầu tư nhất.

#### Định dạng file

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

#### Quy tắc nội dung (bắt buộc)

1. **Không sao chép** câu hỏi từ đề thi thật, sách Milady/Pivot Point, sách luyện thi hay app của người khác. Tất cả đều có bản quyền. Hãy tự viết câu hỏi dựa trên **kiến thức chung** và **đề cương thi công khai** (candidate handbook, content outline của PSI/NIC/Pearson VUE/Prometric).
2. Mỗi câu chỉ có **một đáp án đúng rõ ràng**. Các đáp án sai phải hợp lý nhưng sai rõ ràng.
3. Với số liệu khác nhau giữa các bang (thời gian ngâm, giờ học, thời gian free look…), viết "thường là", "theo nhãn sản phẩm" hoặc "theo luật tiểu bang". Phần luật riêng của từng bang nên tách thành bộ câu hỏi riêng.
4. Giải thích ngắn gọn (1–3 câu) và nêu được **lý do** đáp án đúng.
5. Bản dịch tiếng Việt hoặc Tây Ban Nha: ghi kèm **thuật ngữ tiếng Anh trong ngoặc** ở những chỗ quan trọng, ví dụ "Mầm móng (matrix)". Người thi cần biết cả hai.

#### Quy trình mở rộng lên 300–500 câu mỗi bộ

1. Lấy đề cương (content outline) chính thức của kỳ thi để biết tỷ lệ phần trăm từng chủ đề, rồi chia số câu theo đúng tỷ lệ đó.
2. Soạn bản nháp tiếng Anh, theo từng lô 20 câu cho mỗi chủ đề. Có thể dùng AI hỗ trợ viết nháp, **nhưng phải có người có chuyên môn duyệt lại từng câu**, ví dụ thợ nail hoặc giáo viên đã có bằng.
3. `python3 tool/build_banks.py` kiểm tra định dạng.
4. Dịch sang các ngôn ngữ khác. Nhờ người bản ngữ trong nghề đọc lại khoảng 10% số câu dịch, chọn ngẫu nhiên.
5. Tăng `version` trong `meta.json`, rồi build và phát hành bản cập nhật. Trong release notes ghi rõ "Thêm 100 câu mới".

#### Xử lý khi người dùng báo câu sai

- Sửa ngay trong `en.txt` và các bản dịch, **giữ nguyên id**.
- Trả lời review của người đó: "Cảm ơn bạn, đã sửa trong bản x.y".

---

<!-- docs/06-IN-APP-PURCHASE.md -->

### 06 — Cấu hình mua trong app (Google Play Billing) từng bước

Mỗi app bán **1 gói mua một lần** với mã `premium_lifetime`. Gói này mở khoá toàn bộ câu hỏi và cho thi thử không giới hạn; với app có bật quảng cáo thì còn tắt quảng cáo.
Code đã làm sẵn mọi thứ: hiển thị giá theo tiền địa phương, mua, khôi phục khi cài lại, xử lý thanh toán đang chờ, thử lại khi chưa tải được giá. Phần **bạn phải làm là cấu hình trong Play Console**.

> App dùng thư viện `in_app_purchase_android` 0.5.x, bên trong là **Play Billing Library 8**. Đây là phiên bản dùng mô hình "one-time product" mới của Google (có 2025), nên không cần bật chế độ tương thích ngược.

---

#### Bước 0 — Hồ sơ thanh toán (payments profile): làm 1 lần

1. Vào Play Console, chọn **Setup → Payments profile** (hoặc làm theo lời nhắc ở phần *Monetize*). Liên kết hoặc tạo **payments profile**.
2. Điền đầy đủ:
   - Tên pháp lý, địa chỉ.
   - **Tài khoản ngân hàng nhận tiền**: tên chủ tài khoản phải khớp với payments profile.
   - **Thông tin thuế**: với người không ở Mỹ, Google thường yêu cầu tờ khai W-8BEN.
3. Google sẽ gửi một khoản tiền nhỏ vào tài khoản ngân hàng để xác minh. Bạn nhập đúng số tiền đó vào Play Console.
4. Kiểm tra danh sách nước được phép bán ứng dụng (*supported locations for merchants*) trong trang trợ giúp Play Console. **Chưa xong payments profile thì không tạo được sản phẩm có giá.**

#### Bước 1 — Upload AAB lên kênh Internal testing

Play Console chỉ cho tạo sản phẩm sau khi app đã có một bản build chứa quyền `com.android.vending.BILLING`. Plugin đã tự thêm quyền này.

1. Lấy file AAB đã ký: tải từ GitHub Actions hoặc build trên máy, xem `docs/01`.
2. Vào **Testing → Internal testing → Create new release**, upload AAB, bấm **Save → Review → Start rollout**.
3. Ở tab **Testers**, thêm email Gmail của bạn và copy **link opt-in**. Mở link đó trên điện thoại, bấm *Accept*, rồi cài app **từ Play Store**.

> ⚠️ Mua trong app **chỉ chạy khi app được cài từ Play** (qua link tester). Nếu cài APK bằng tay, app sẽ báo "Cửa hàng tạm thời không khả dụng". Đó là hành vi bình thường.

#### Bước 2 — Tạo sản phẩm `premium_lifetime`

1. Vào **Monetize with Play → Products → One-time products → Create one-time product**.
2. Điền thông tin:
   - **Product ID**: `premium_lifetime`. Phải trùng chính xác với `premiumProductId` trong `apps/<id>.json`. **Sau khi tạo thì không đổi được, và cũng không dùng lại được nếu đã xoá.**
   - **Name**: tên hiển thị ở màn hình thanh toán của Google, ví dụ:
     - nailvi: "Mở khoá toàn bộ câu hỏi"
     - sachkunde: "Alle Fragen freischalten"
     - cscsro: "Deblochează toate întrebările"
     - các app tiếng Anh: "Unlock all questions"
   - **Description**: một câu ngắn, ví dụ "All questions and unlimited mock exams. One-time payment."
   - **Tax / compliance category** (nếu được hỏi): Digital content / app features.
3. **Purchase options → Add purchase option**:
   - ID ví dụ `lifetime`, loại **Buy** (mua đứt).
   - Nếu Play Console hỏi "**Backwards compatible**" thì có thể bật cho chắc. App dùng PBL 8 nên không bắt buộc.
4. **Prices → Set prices**:
   - Nhập giá gốc bằng USD (bảng gợi ý bên dưới), Play tự quy đổi sang các nước.
   - Sau đó **sửa tay giá ở các thị trường chính** để có số đẹp và hợp sức mua, ví dụ ₹499, ₱249, €14,99, £7,99.
5. Bấm **Save**, sau đó **Activate**. Purchase option phải ở trạng thái **Active**: ở trạng thái Draft thì app không nhìn thấy sản phẩm.
6. Chờ khoảng 15 phút đến vài giờ để sản phẩm có hiệu lực.

##### Bảng giá gợi ý

| App | Giá gốc | Giá chỉnh tay ở thị trường chính |
|---|---|---|
| nailvi, cosmovi | $14.99 | US $14.99 |
| nailes, cosmoes | $12.99 | US $12.99 |
| insurancelh | $19.99 | US $19.99 |
| **nursegulf** | $14.99 | Ấn Độ ₹499–799 · Philippines ₱599 · UAE AED 49.99 · Saudi SAR 49.99 |
| **cscsro / cscspl** | $9.99 | Anh £7.99 |
| **sachkunde** | $14.99 | Đức €14,99 (lệ phí thi ở IHK khoảng €150–240) |
| **civilserviceph** | $4.99 | Philippines ₱199–249 |

Mẹo: sau 2–4 tuần có số liệu thật, dùng **Monetize → Price experiments** để thử A/B giá, ví dụ €9,99 so với €14,99.

#### Bước 3 — Mua thử miễn phí (license testing)

1. Vào trang **Settings → License testing** ở cấp tài khoản developer (không phải trong từng app). Thêm email Gmail đang đăng nhập trên điện thoại test và đặt License response là **RESPOND_NORMALLY**.
2. Mở app (cài từ link Internal testing), vào **Mở khoá** và bấm nút mua. Màn hình thanh toán sẽ có các thẻ test như "Test card, always approves".
3. Kiểm tra:
   - [ ] Màn hình Mở khoá hiện giá đúng tiền địa phương.
   - [ ] Mua xong, app báo "Đã mở khoá toàn bộ" và các ổ khoá ở từng chủ đề biến mất.
   - [ ] Thử thẻ "**Slow test card**" để thấy thông báo thanh toán đang chờ. App tự mở khoá khi thanh toán xong.
   - [ ] Gỡ app, cài lại, mở app: quyền mua được **tự khôi phục**. Nếu không, vào Cài đặt và bấm **Khôi phục giao dịch**.
4. Muốn mua thử lại thì vào **Order management**, chọn đơn test rồi **Refund** và tick **Remove entitlement**.

#### Bước 4 — Phát hành

- Làm tiếp closed testing nếu dùng tài khoản cá nhân, rồi lên Production theo `docs/02`.
- Ở **Production → Countries/regions**, chọn đúng thị trường của từng app. Danh sách gợi ý nằm trong trường `markets` của `apps/<id>.json`.
- **Promo codes** (Monetize → Promo codes): tặng mã cho trường dạy nghề, KOL hoặc nhóm cộng đồng. Đây là kênh kéo người dùng rất hiệu quả.

---

#### Sửa lỗi thường gặp

| Hiện tượng | Nguyên nhân và cách sửa |
|---|---|
| App báo "Cửa hàng tạm thời không khả dụng" | App không được cài từ Play, hoặc tài khoản trên máy chưa opt-in làm tester. Cài lại bằng link Internal testing. |
| Không hiện giá, nút mua bị mờ | Sản phẩm chưa Active, Product ID sai (phải là `premium_lifetime`), sản phẩm mới tạo (chờ vài giờ), hoặc chưa có payments profile. Bấm **Thử lại** trên màn hình Mở khoá. |
| "This version of the application is not configured for billing" | `applicationId` hoặc versionCode trên máy khác với bản đã upload, hoặc app được ký bằng khoá debug. Cài đúng bản từ Play. |
| "Item not available for purchase" | Quốc gia của tài khoản Google không nằm trong danh sách được phát hành, hoặc sản phẩm chưa có giá cho nước đó. |
| Mua xong nhưng chưa mở khoá | Thanh toán đang chờ (pending). Đợi xong rồi mở lại app, hoặc bấm Khôi phục giao dịch. |
| Bị hoàn tiền sau 3 ngày | Code đã tự gọi `completePurchase` (acknowledge). Nếu vẫn bị hoàn, kiểm tra lại xem bản đang chạy có đúng code mới nhất không. |

#### (Tuỳ chọn) Nâng cấp sau này

- **Xác minh giao dịch phía server** bằng Google Play Developer API để chống crack. Chỉ cần làm khi doanh thu đã lớn.
- **Thêm gói thuê bao** (ví dụ 1 tháng $4.99) bên cạnh gói trọn đời. Muốn vậy phải thêm logic kiểm tra gói còn hạn, nên tạm thời chưa làm.

---

<!-- docs/07-ADMOB.md -->

### 07 — AdMob: xử lý lỗi đăng ký & cách bật quảng cáo (không bắt buộc)

**Hiện tại cả 10 app đều đặt `"ads": false`, tức chỉ bán gói và không cần AdMob.** Khi tắt quảng cáo:
- App không khởi động thư viện quảng cáo và không hiện form đồng ý quảng cáo (consent).
- Người dùng miễn phí thấy màn hình **Mở khoá** sau mỗi 2 lượt làm bài, thay cho quảng cáo xen kẽ.
- Công cụ `tool/factory.py` tự **gỡ quyền Advertising ID** (`AD_ID`) khỏi app và viết trang chính sách bảo mật thành "không quảng cáo, không theo dõi".
- Trong Play Console khai báo như sau:
  - **Ads: No**
  - **Advertising ID: No**
  - **Data safety: "No data collected"**, vì dữ liệu học chỉ lưu trên máy, còn thanh toán do Google Play xử lý.

Vì vậy **bạn có thể phát hành ngay mà không cần AdMob.** Khi tài khoản AdMob đã chạy được, bật lại theo mục C.

#### A. Các lỗi đăng ký AdMob hay gặp và cách xử lý

| Lỗi / hiện tượng | Cách xử lý |
|---|---|
| Form đăng ký báo lỗi hoặc không cho bấm tiếp | Dùng **Gmail cá nhân** (không dùng email Google Workspace của công ty). Tắt VPN. Dùng Chrome ẩn danh. Chọn **Quốc gia: Việt Nam** và **múi giờ đúng**, vì 2 mục này **không đổi được sau khi tạo**. |
| "You already have an AdSense/AdMob account" | Mỗi người chỉ được có **1 tài khoản AdSense**, dùng chung cho AdMob. Đăng nhập đúng Gmail đã có AdSense, hoặc đóng tài khoản AdSense cũ trước. |
| Tài khoản bị từ chối hoặc vô hiệu (disapproved / disabled) | Thường do tài khoản AdSense cũ từng vi phạm, hoặc thông tin trùng với tài khoản đã bị khoá. Bạn chỉ được gửi **kháng nghị (appeal)** 1 lần, và không nên tạo tài khoản mới để lách vì sẽ bị khoá tiếp. |
| "Your account is being reviewed" / quảng cáo bị giới hạn | Tài khoản mới được xét duyệt trong vài ngày đến khoảng 2 tuần. App nên đã có trên Play và có file **app-ads.txt**, xem mục C. |
| Không thêm được app vì app chưa có trên Play | Khi thêm app, chọn "**No, the app is not listed on a supported app store**". Sau khi app lên Play thì liên kết lại. |
| Lỗi xác minh địa chỉ (PIN) hoặc thanh toán | Google gửi mã PIN qua bưu điện khi thu nhập đạt ngưỡng xác minh. Tên người nhận tiền phải khớp với tên chủ tài khoản ngân hàng. |

👉 **Gửi mình ảnh chụp chính xác dòng báo lỗi** (bằng tiếng Anh hoặc tiếng Việt), mình sẽ chỉ cách sửa cụ thể.

#### B. Phương án khác nếu AdMob vẫn không được

- **Chỉ bán gói**: cấu hình hiện tại. Với app luyện thi, doanh thu chủ yếu đến từ việc người dùng mua gói.
- Mạng quảng cáo khác (cần sửa code, chỉ làm khi thật sự cần):
  - AppLovin MAX
  - Unity LevelPlay
  - Pangle (của ByteDance), dễ duyệt cho tài khoản ở châu Á

#### C. Bật quảng cáo AdMob cho một app

1. Trong AdMob, vào **Apps → Add app → Android**, rồi tạo 2 ad unit: **Banner** và **Interstitial**.
2. Sửa file `apps/<id>.json`:
   ```json
   "ads": true,
   "admob": {
     "appId": "ca-app-pub-XXXXXXXX~YYYYYYYY",
     "banner": "ca-app-pub-XXXXXXXX/1111111111",
     "interstitial": "ca-app-pub-XXXXXXXX/2222222222"
   }
   ```
3. Chạy `python3 tool/factory.py --release`. Lệnh phải báo `ok`. Sau đó commit, push và upload AAB mới.
4. Trong Play Console, đổi khai báo sang **Ads: Yes**, **Advertising ID: Yes** và cập nhật **Data safety** theo mục E của `docs/02`.
5. Đặt file **app-ads.txt** ở website ghi trong mục Store settings, rồi tạo **GDPR message** trong AdMob → Privacy & messaging.

---

<!-- docs/08-PUBLISH-FIRST-APP.md -->

### 08 — Đưa app đầu tiên (`nailvi`) lên Google Play: làm theo từng cú bấm

Tài liệu này đi **một app cụ thể từ đầu đến cuối**: Luyện Thi Nail Tiếng Việt (`nailvi`).
Làm xong app này thì 14 app còn lại chỉ lặp lại từ bước 5 (mỗi app khoảng 30–45 phút).
`docs/02-LAUNCH-CHECKLIST.md` là bản tóm tắt; tài liệu này là bản chi tiết. Viết tháng 10/2026. Giao diện Play Console có thể đổi tên menu, nhưng thứ tự các bước giữ nguyên.

Thời gian tổng cộng (tài khoản cá nhân): khoảng **1 buổi làm** + **14 ngày chạy thử kín** + 1–7 ngày Google duyệt.

---

#### Bước 1 — Tạo tài khoản Google Play Console (1 lần)

1. Mở <https://play.google.com/console/signup> bằng Gmail bạn muốn dùng lâu dài. Nên dùng Gmail riêng cho công việc, bật xác minh 2 bước.
2. Chọn loại tài khoản:
   - **Yourself (cá nhân)**: nhanh, chỉ cần CCCD/hộ chiếu. Mỗi app mới phải chạy **closed test ≥12 người × 14 ngày** trước khi lên production.
   - **An organization (tổ chức)**: cần công ty + số **D-U-N-S**, nhưng **không** phải chạy 12 người × 14 ngày. Nên chuyển sang loại này khi đã có vài app ra tiền.
3. Trả phí **$25** (một lần, dùng thẻ Visa/Master quốc tế).
4. Xác minh danh tính: chụp giấy tờ, điền địa chỉ trùng với giấy tờ. Google duyệt trong vài giờ đến vài ngày.
5. Xác minh **có điện thoại Android thật**: cài app **Google Play Console** trên điện thoại Android, đăng nhập cùng Gmail. Play Console sẽ yêu cầu bước này với tài khoản mới.
6. Xác minh số điện thoại và email liên hệ.

#### Bước 2 — Hồ sơ thanh toán để nhận tiền (1 lần)

**Setup → Payments profile** (hoặc menu *Monetize* sẽ nhắc). Làm đúng theo `docs/06-IN-APP-PURCHASE.md` bước 0:
tên pháp lý, địa chỉ, tài khoản ngân hàng (tên chủ tài khoản trùng tên hồ sơ), thông tin thuế (người Việt Nam: khai W-8BEN, chọn không phải công dân Mỹ).
Chưa xong bước này thì **không tạo được sản phẩm có giá** ở bước 9.

#### Bước 3 — Sửa thông tin cá nhân trong cấu hình (1 lần cho cả 15 app)

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

#### Bước 4 — Bật trang Chính sách bảo mật (1 lần, miễn phí)

Repo `tuanlt1989/assignment` đang public, nên dùng GitHub Pages:

1. Mở <https://github.com/tuanlt1989/assignment/settings/pages>.
2. **Source**: *Deploy from a branch*. **Branch**: `exam-prep-apps`, thư mục **`/docs`** → **Save**.
3. Chờ 1–3 phút, mở thử <https://tuanlt1989.github.io/assignment/privacy/nailvi.html> trên điện thoại.

Cả 15 app đã được cấu hình sẵn URL dạng `https://tuanlt1989.github.io/assignment/privacy/<id>.html`. Trang này cũng nằm trong mục *Cài đặt* của từng app.

#### Bước 5 — Lấy file AAB đã ký

1. Cài 4 secrets khoá ký vào GitHub (đã gửi bạn file `SIGNING-SECRETS.txt` + `upload-keystore.jks`):
   <https://github.com/tuanlt1989/assignment/settings/secrets/actions> → **New repository secret**, tạo đúng 4 tên:
   `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
2. Push một commit bất kỳ (hoặc vào tab **Actions → Android build → Run workflow**, chọn branch `exam-prep-apps`).
3. Chờ lần chạy có dấu ✅ → kéo xuống **Artifacts** → tải `nailvi-buildN` → giải nén, lấy `app-nailvi-release.aab`.
4. Kiểm tra log bước *Release signing* phải ghi `Signing with the upload key.` Nếu thấy cảnh báo *debug-signed* thì secrets chưa đúng, Play sẽ từ chối file.

> ⚠️ Cất **file .jks + mật khẩu** ở 2 nơi an toàn (ví dụ Google Drive riêng + USB). Mất khoá upload vẫn xin Google reset được, nhưng mất vài ngày.

#### Bước 6 — Tạo app trong Play Console

1. **Home → Create app**:
   - **App name**: `Nail Exam Prep (Vietnamese)` (lấy từ `store/nailvi/metadata/android/en-US/title.txt`).
   - **Default language**: English (United States) – en-US.
   - **App or game**: App. **Free or paid**: **Free** (tiền đến từ gói mua trong app).
   - Tích 2 ô cam kết (Developer Program Policies, US export laws) → **Create app**.
2. Mở **Dashboard**, kéo xuống mục *Set up your app*. Làm lần lượt các mục dưới đây.

#### Bước 7 — Khai báo nội dung app (App content)

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

#### Bước 8 — Trang cửa hàng (Store listing)

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

#### Bước 9 — Bản thử nội bộ + tạo gói mua

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

#### Bước 10 — Tự kiểm tra trên điện thoại (15 phút)

- [ ] Mở app lần đầu: hiện màn hình chọn **ngày thi → số câu mỗi ngày → kế hoạch + nhắc học** rồi màn hình mở khoá.
- [ ] Trang chủ có chuỗi ngày học, mục tiêu hôm nay, đếm ngược ngày thi và 6 ô: thi thử, 10 câu nhanh, thẻ ghi nhớ, chủ đề yếu nhất, câu sai, câu đã lưu.
- [ ] Chạm câu hỏi tiếng Việt → hiện bản tiếng Anh.
- [ ] Bật nhắc học, đặt giờ sau 2 phút, tắt app → có thông báo.
- [ ] Màn hình mở khoá hiện **giá thật** (không phải "Cửa hàng tạm thời không khả dụng").
- [ ] Mua thử → mọi câu được mở, thi thử đủ 50 câu.
- [ ] Gỡ app, cài lại → **Khôi phục giao dịch** → lại là bản đầy đủ.

#### Bước 11 — Chạy thử kín 12 người × 14 ngày (chỉ tài khoản cá nhân)

1. **Testing → Closed testing → Create track** (hoặc dùng track *Alpha* có sẵn) → **Create new release** → **Add from library** chọn AAB đã upload → **Save and publish**.
2. **Countries/regions**: chọn United States + Vietnam (để người quen ở Việt Nam cũng cài được).
3. **Testers**: tạo **Google Group** (<https://groups.google.com>, ví dụ `nail-testers@googlegroups.com`) rồi dán email nhóm vào. Ai tham gia nhóm là thành tester — tiện dùng chung cho **cả 15 app**.
4. Gửi link tham gia cho **ít nhất 15 người** (dư ra phòng người bỏ ngang): bạn bè, người làm nail, nhóm Facebook "Thợ Nail Việt tại Mỹ"… Nhờ họ **giữ app cài trên máy 14 ngày** và mở vài lần.
5. Thu góp ý: tester có thể gửi phản hồi riêng ngay trên trang Play của app. Ghi lại để trả lời câu hỏi ở bước 12.
6. **Mẹo tiết kiệm thời gian**: upload AAB và mở closed test cho **cả 15 app cùng ngày**, dùng chung một Google Group.

#### Bước 12 — Xin lên Production và phát hành

1. Sau 14 ngày, Dashboard hiện nút **Apply for production**. Trả lời bảng hỏi:
   - Cách tuyển tester, số người, họ đã dùng tính năng nào.
   - App dành cho ai (người Việt thi bằng nail ở Mỹ), giá trị (song ngữ, thi thử, giải thích).
   - Bạn đã sửa gì sau phản hồi. Viết thật, cụ thể, tiếng Anh đơn giản.
2. Được duyệt (thường 1–7 ngày) → **Production → Countries/regions**: thêm **United States** (`nailes`/`cosmoes` thêm Puerto Rico; các app khác theo trường `markets` trong `apps/<id>.json`).
3. **Create new release** → *Add from library* chọn AAB mới nhất → Release notes → **Next → Save → Send for review**.
4. **Staged rollout**: bắt đầu **20%**, sau 2 ngày không có crash (xem *Quality → Android vitals*) thì tăng **100%**.

#### Bước 13 — Tuần đầu sau khi lên Store

- [ ] Nhờ 5–10 tester đầu tiên **đánh giá thật** (Play cấm mua/đổi quà lấy đánh giá).
- [ ] Đăng bài giới thiệu trong các nhóm Facebook/Zalo thợ nail (xem `docs/03-ANDROID-GROWTH-PLAYBOOK.md`).
- [ ] *Grow users → Store listing experiments*: thử 2 icon hoặc 2 ảnh đầu tiên.
- [ ] Theo dõi *Monetize → Financial reports* và tỷ lệ chuyển đổi trang cửa hàng. Mục tiêu: ≥25% người xem trang cài app, ≥3% người cài mua gói.
- [ ] Trả lời mọi đánh giá trong 24–48 giờ.
- [ ] Lặp lại từ **bước 5** cho app tiếp theo.

---

##### Lỗi hay gặp

| Thông báo | Cách xử lý |
|---|---|
| *You uploaded an APK or Android App Bundle that was signed in debug mode* | Secrets khoá ký chưa đúng (bước 5). |
| *Version code 1 has already been used* | Tải AAB của lần chạy CI mới hơn (CI tự tăng versionCode). |
| *Your app currently has no in-app products* / không tạo được sản phẩm | Phải upload AAB lên một track trước, và hoàn tất payments profile. |
| App báo "Cửa hàng tạm thời không khả dụng" | Cài app **từ link tester trên Play**, không cài APK tay; Gmail trên máy phải là tester. |
| *Policy: misleading claims* | Không viết "đề thi thật", "official", "guaranteed pass" trong mô tả. Nội dung mẫu đã tránh các từ này. |
| *Target API level* | Flutter 3.47 build với targetSdk 36, đạt yêu cầu năm 2026. Năm sau chỉ cần nâng Flutter. |

---

<!-- docs/09-AUTO-PUBLISH.md -->

### 09 — Tự động đưa app lên Google Play (bấm 1 nút)

Sau khi cài đặt một lần, mỗi lần muốn cập nhật app bạn chỉ cần vào **GitHub → Actions → Publish to Google Play → Run workflow**, hoặc nhắn Claude "up nailvi lên internal". Workflow sẽ tự:

1. Build file AAB đã ký cho từng app bạn chọn (một app, nhiều app, hoặc `all` cho cả 15).
2. Upload lên kênh bạn chọn: internal, closed (`alpha`), open (`beta`) hoặc production.
3. Upload trang cửa hàng: tiêu đề, mô tả, icon, feature graphic và ảnh màn hình cho mọi ngôn ngữ trong `store/<id>/`.
4. Tạo hoặc cập nhật gói `premium_lifetime` kèm giá USD gợi ý; Play tự quy đổi sang tiền các nước. Phần này tuỳ chọn.

Workflow dùng **API chính thức của Google** (Google Play Developer API) qua một *service account*. Nó **không đăng nhập bằng mật khẩu Gmail của bạn**. Dùng bot đăng nhập web Play Console bằng mật khẩu sẽ gặp 2 vấn đề: Google chặn đăng nhập tự động và xác minh 2 bước, và có rủi ro bị khoá tài khoản developer. Service account thì an toàn hơn: chỉ được quyền bạn cấp, và bạn thu hồi lúc nào cũng được.

#### Những việc Google bắt buộc làm tay (một lần cho mỗi app)

API không làm được các việc sau:
- Tạo tài khoản developer, xác minh danh tính, hồ sơ thanh toán (`docs/08` bước 1–2).
- **Tạo app** trong Play Console (`docs/08` bước 6).
- **Upload bản AAB đầu tiên bằng tay** lên Internal testing. Lấy file từ artifact của CI.
- Khai báo **App content**: chính sách bảo mật, quảng cáo, phân loại độ tuổi, đối tượng, an toàn dữ liệu (`docs/08` bước 7).
- Chạy thử kín 12 người × 14 ngày rồi xin lên production (nếu là tài khoản cá nhân).

Từ lần thứ 2 trở đi, mọi việc upload đều làm bằng workflow.

---

#### Cài đặt một lần (khoảng 15 phút)

##### Bước 1 — Tạo service account trên Google Cloud

1. Mở <https://console.cloud.google.com/>, đăng nhập bằng Gmail dùng cho Play Console. Tạo project mới, ví dụ `play-publisher`.
2. Vào **APIs & Services → Library**, tìm **Google Play Android Developer API** và bấm **Enable**.
3. Vào **IAM & Admin → Service Accounts → Create service account**:
   - Tên: `github-publisher`. Bấm **Create and continue**, bỏ qua bước cấp role, rồi **Done**.
4. Bấm vào service account vừa tạo → tab **Keys** → **Add key → Create new key → JSON**. Một file `.json` sẽ được tải về.
   - ⚠️ File này giống mật khẩu: **không gửi cho ai và không commit lên git**.
5. Chép **email** của service account, có dạng `github-publisher@play-publisher.iam.gserviceaccount.com`.

##### Bước 2 — Cấp quyền trong Play Console

1. Vào Play Console → **Users and permissions → Invite new users**.
2. Dán email của service account.
3. Cấp quyền: cách đơn giản nhất là tab **Account permissions → Admin (all permissions)**. Nếu muốn ít quyền hơn, tick tối thiểu:
   - **Release apps to testing tracks** và **Release to production, exclude devices, and use Play App Signing**
   - **Manage store presence** (trang cửa hàng)
   - **Manage store presence** của phần sản phẩm trong app / **Manage orders and subscriptions** (tên menu có thể khác theo thời điểm)
4. Bấm **Invite user**. Service account không cần chấp nhận lời mời.
5. Nếu Play Console còn trang **Setup → API access**, hãy liên kết project Google Cloud ở bước 1 tại đó. Tài khoản mới thường không cần bước này.

> Quyền có thể mất vài phút đến vài giờ mới có hiệu lực. Nếu lần chạy đầu báo `permission`, đợi một lúc rồi chạy lại.

##### Bước 3 — Thêm secret vào GitHub

1. Mở <https://github.com/tuanlt1989/assignment/settings/secrets/actions> → **New repository secret**.
2. Name: `PLAY_SERVICE_ACCOUNT_JSON`. Value: dán **toàn bộ nội dung** file `.json` ở bước 1.
3. Kiểm tra đã có đủ 4 secret khoá ký từ `docs/01`: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Workflow sẽ dừng nếu thiếu, vì Play từ chối bản ký debug.

##### Bước 4 — Làm phần bắt buộc bằng tay cho từng app

Làm theo `docs/08` các bước 6–7 và upload AAB đầu tiên ở bước 9: tải artifact `nailvi-buildN` trong tab **Actions → Android build**.

---

#### Dùng hằng ngày

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

##### Chạy trên máy của bạn (không bắt buộc)

```bash
pip install google-api-python-client google-auth
export PLAY_SERVICE_ACCOUNT_JSON="$(cat ~/Downloads/play-publisher-xxxx.json)"
python3 tool/play_publish.py --app nailvi --listing --dry-run        # chỉ kiểm tra, không gửi gì
python3 tool/play_publish.py --app nailvi --aab path/to/app.aab --track internal
python3 tool/play_publish.py --app nailvi --product                   # tạo gói premium_lifetime
```

#### Lỗi hay gặp

| Lỗi | Cách xử lý |
|---|---|
| `Package not found` | App chưa được tạo trong Play Console, hoặc chưa upload tay bản đầu tiên (bước 4). |
| `The caller does not have permission` | Service account chưa được mời, hoặc chưa được cấp quyền cho app này (bước 2). Đợi vài phút rồi chạy lại. |
| `Only releases with status draft may be created on draft app` | Script tự xử lý: release được lưu ở dạng draft. |
| `APK specifies a version code that has already been used` | Chạy lại workflow; versionCode mới sẽ lớn hơn. |
| Lỗi khi tạo product | Hồ sơ thanh toán chưa xong, hoặc API sản phẩm của Google thay đổi. Tạo `premium_lifetime` bằng tay theo `docs/06`; phần bundle và listing vẫn chạy bình thường. |

---

<!-- games/README.md -->

### Puzzle Games — 5 game giải đố ngách, ăn theo trend (Flutter)

Project Flutter riêng (`games/`), cùng kiểu "nhà máy" với app luyện thi: mỗi game = 1 file `apps/<id>.json` + 1 bộ nội dung cửa hàng `store/<id>/`.
Mọi câu đố được **sinh tự động, đã kiểm chứng giải được** (logic: đúng **1 lời giải duy nhất**; golf: bộ giải tìm được đường về par), nên số câu đố là vô hạn.

#### Cách chọn game: trend mới + gần như chưa có đối thủ trên Android

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

#### Tính năng chung (đủ chơi 30 phút mỗi lượt)

- **4 độ khó**: Dễ, Vừa, Khó, Chuyên gia. Mỗi mức có câu đố đánh số, không giới hạn (#1, #2…), và mọi người chơi cùng một câu ở cùng số.
- **Câu đố hằng ngày**: dễ đầu tuần, khó nhất cuối tuần, có chuỗi ngày chơi 🔥 và **kho 60 ngày** để chơi lại.
- **1–3 sao** mỗi câu: trừ sao khi sai hoặc dùng gợi ý; golf thì tính theo par.
- **8 giao diện màu** mở bằng sao, có 2 giao diện nền tối. **12 huy hiệu** (giải 1/25/100/500 câu, chuỗi 3/7/30 ngày, giải không gợi ý…).
- **Thống kê**: số câu đã giải, sao, chuỗi ngày, tổng thời gian chơi, kỷ lục thời gian theo từng mức.
- Bấm giờ, gợi ý, chơi lại miễn phí, hướng dẫn "Cách chơi" hiện ở lần chơi đầu tiên.
- **7 ngôn ngữ**: Anh, Tây Ban Nha, Bồ Đào Nha, Việt, Indonesia, Đức, **Nhật**. Word Weave có từ điển tiếng Anh, Tây Ban Nha, Bồ Đào Nha và Đức.
- Không quảng cáo, chạy offline, không cần tài khoản.

#### Kiếm tiền: mua một lần `premium_lifetime` (gợi ý $2.99)

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

#### Thị trường

Phát hành toàn cầu. Nội dung cửa hàng có sẵn 7 ngôn ngữ (`en-US, es-419, pt-BR, vi, id, de-DE, ja-JP`).
Ưu tiên Mỹ, Nhật (Meowdoku đang đứng đầu, người chơi Nhật quen mua game giải đố), Đức, Brazil, Mỹ Latin.

#### Lệnh

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

#### Thêm game mới

1. Viết `lib/games/<ten>.dart`, theo hợp đồng `GameSession` trong `lib/games/session.dart`:
   - Sinh câu đố tất định từ (difficulty, level, seed).
   - Gọi `onWin` khi giải xong và `addMistake` mỗi lần sai.
   - Lắng nghe `hint` để hiện gợi ý.
   Sau đó đăng ký game trong `buildGame`.
2. Thêm luật chơi vào `_rules` trong `lib/i18n.dart` (đủ 7 ngôn ngữ), icon vào `GameBadge` và glyph trong `tool/graphics.py`.
3. Tạo `apps/<id>.json`, viết short description, rồi chạy `python3 tool/factory.py --root games`.
4. Viết test chứng minh câu đố luôn giải được và nhanh (dưới 300 ms).

---
