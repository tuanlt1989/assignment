#!/usr/bin/env python3
"""Writes docs/STORE-GUIDE.md: one upload sheet per app + every
other doc as an appendix, so a single file has everything for Play Console.

    python3 tool/store_guide.py
"""
from __future__ import annotations

import json
import re
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
OUT = REPO / "docs/STORE-GUIDE.md"
GH = "https://github.com/tuanlt1989/assignment"
ACTIONS = f"{GH}/actions/workflows/android.yml"
PUBLISH = f"{GH}/actions/workflows/publish.yml"
RELEASE = f"{GH}/releases/tag/play-upload"

FLAGS = {
    "US": "🇺🇸 Mỹ", "PR": "🇵🇷 Puerto Rico", "GB": "🇬🇧 Anh", "DE": "🇩🇪 Đức", "PH": "🇵🇭 Philippines",
    "IN": "🇮🇳 Ấn Độ", "AE": "🇦🇪 UAE", "SA": "🇸🇦 Ả Rập Xê Út", "QA": "🇶🇦 Qatar", "KW": "🇰🇼 Kuwait",
    "OM": "🇴🇲 Oman", "BH": "🇧🇭 Bahrain", "PK": "🇵🇰 Pakistan", "EG": "🇪🇬 Ai Cập", "NG": "🇳🇬 Nigeria",
    "KE": "🇰🇪 Kenya", "JO": "🇯🇴 Jordan",
}

# Things that are not in apps/*.json: why the app exists, prices, how to grow it.
META = {
    "nailvi": dict(
        markets=["US"], prices="**US $14.99** → Update exchange rates",
        why="Nhiều bang ở Mỹ cho thi lý thuyết Nail bằng tiếng Việt, và phần lớn thợ nail ở Mỹ là người Việt, nhưng app ôn thi tiếng Việt chất lượng gần như không có.",
        bodies="NIC, PSI, Pearson VUE, state board",
        grow=["Nhóm Facebook/Zalo \"Thợ Nail Việt tại Mỹ\", \"Học Nail\", các trường nail của người Việt (xin đặt link/QR ở lớp).",
              "TikTok/YouTube Shorts tiếng Việt: \"3 câu hỏi thi nail hay trượt nhất\".",
              "Cho học viên đầu tiên mã dùng thử qua Internal testing để lấy đánh giá thật."]),
    "nailes": dict(
        markets=["US", "PR"], prices="**US $12.99** → Update exchange rates",
        why="Thợ nail nói tiếng Tây Ban Nha ở Mỹ được thi bằng tiếng Tây Ban Nha ở nhiều bang; app ôn thi song ngữ Tây Ban Nha–Anh còn rất ít.",
        bodies="NIC, PSI, Pearson VUE, state board",
        grow=["Nhóm Facebook \"Manicuristas en USA\", trường thẩm mỹ khu Latino (TX, FL, CA).",
              "Reels/TikTok tiếng Tây Ban Nha: \"Preguntas del examen de uñas\"."]),
    "cosmovi": dict(
        markets=["US"], prices="**US $14.99** → Update exchange rates",
        why="Giống app Nail: kỳ thi Cosmetology có bản tiếng Việt ở nhiều bang, nhưng tài liệu ôn tiếng Việt rất hiếm.",
        bodies="NIC, PSI, Pearson VUE, state board",
        grow=["Nhóm Facebook thợ tóc/thẩm mỹ người Việt ở Mỹ, trường beauty của người Việt.",
              "Bán chéo với app Nail (cùng người dùng)."]),
    "cosmoes": dict(
        markets=["US", "PR"], prices="**US $12.99** → Update exchange rates",
        why="Cosmetology bằng tiếng Tây Ban Nha: thị trường lớn ở TX, FL, CA, NY và Puerto Rico.",
        bodies="NIC, PSI, Pearson VUE, state board",
        grow=["Nhóm Facebook \"Cosmetología en USA\", trường beauty khu Latino."]),
    "insurancelh": dict(
        markets=["US"], prices="**US $19.99** → Update exchange rates",
        why="Mỗi năm hàng trăm nghìn người thi chứng chỉ đại lý bảo hiểm Life & Health ở Mỹ, chịu chi cho tài liệu ôn (khoá học thường $50–$200).",
        bodies="Pearson VUE, PSI, Prometric, NAIC, state Department of Insurance",
        grow=["Reddit r/Insurance, r/InsuranceAgent (đọc luật trước khi đăng).",
              "Nhóm Facebook tuyển đại lý bảo hiểm; người tuyển dụng hay giới thiệu tài liệu ôn cho người mới."]),
    "epa608": dict(
        markets=["US"], prices="**US $14.99** → Update exchange rates",
        why="Ở Mỹ, ai đụng vào gas lạnh (thợ HVAC, điện lạnh, tủ lạnh, ô tô) đều phải có chứng chỉ EPA 608 theo luật liên bang. App đứng đầu (\"608 Practice\") có giao diện cơ bản, quảng cáo nhiều và bị phàn nàn có câu sai đáp án. Khác biệt: thi theo từng phần như thật, tài liệu tóm tắt số liệu, nút báo lỗi câu hỏi, không quảng cáo.",
        bodies="U.S. EPA, ESCO Institute, Mainstream Engineering, RSES",
        grow=["Reddit r/HVAC, r/HVACadvice, r/refrigeration: \"free EPA 608 section exams, no ads\".",
              "Trường nghề HVAC và nhóm Facebook thợ HVAC; YouTube Shorts \"1 câu EPA 608 mỗi ngày\"."]),
    "nhie": dict(
        markets=["US"], prices="**US $24.99** → Update exchange rates",
        why="Phí thi NHIE khoảng $225 và đề dài 200 câu, nên người thi sẵn sàng trả tiền. Android gần như không có app; đối thủ bên iOS thu $12.99/tuần và bị chê chấm đúng/sai lẫn lộn. Khác biệt: trả 1 lần, giải thích rõ, tài liệu tóm tắt số liệu theo IRC, nút báo lỗi.",
        bodies="EBPHI, PSI, state home inspector licensing boards, ASHI, InterNACHI",
        grow=["Reddit r/HomeInspections, diễn đàn InterNACHI (forum.nachi.org) mục NHIE.",
              "Trường đào tạo home inspector và nhóm Facebook \"new home inspectors\"."]),
    "nursegulf": dict(
        markets=["IN", "PH", "AE", "SA", "QA", "KW", "OM", "BH", "PK", "EG", "NG", "KE", "JO"],
        prices="**US $14.99** → Update exchange rates → **sửa tay: Ấn Độ ₹499, Philippines ₱599, Pakistan Rs 1,499**",
        why="Điều dưỡng Ấn Độ, Philippines, Pakistan… muốn làm việc ở vùng Vịnh phải thi Prometric (DHA/DOH/MOHAP/SCFHS/QCHP); họ chịu chi vì lương ở Vịnh cao gấp nhiều lần.",
        bodies="DHA, DOH, MOHAP, SCFHS, QCHP, Prometric",
        grow=["Nhóm Facebook/Telegram \"Gulf nurses\", \"DHA exam preparation\", các trung tâm tuyển dụng điều dưỡng ở Kerala, Manila.",
              "YouTube Shorts tiếng Anh: \"5 DHA questions most nurses get wrong\"."]),
    "cscsro": dict(
        markets=["GB"], prices="**£7.99** (Anh) → Update exchange rates",
        why="Hàng trăm nghìn thợ xây Romania làm việc ở Anh phải đậu bài thi HS&E để có thẻ CSCS vào công trường; tài liệu tiếng Romania rất ít.",
        bodies="CITB, CSCS, Pearson VUE",
        grow=["Nhóm Facebook \"Români în UK\", \"Muncă în construcții UK\".",
              "Đại lý tuyển thợ xây sang Anh."]),
    "cscspl": dict(
        markets=["GB"], prices="**£7.99** (Anh) → Update exchange rates",
        why="Thợ xây Ba Lan là nhóm lao động nước ngoài lớn trong ngành xây dựng ở Anh; cần thẻ CSCS để vào công trường.",
        bodies="CITB, CSCS, Pearson VUE",
        grow=["Nhóm Facebook \"Polacy w UK\", \"Praca budowlana UK\".", "Diễn đàn Polish Express / MojaWyspa."]),
    "sachkunde": dict(
        markets=["DE"], prices="**€14.99** (Đức) → Update exchange rates",
        why="Nhân viên bảo vệ ở Đức (rất nhiều người nhập cư) bắt buộc đậu Sachkundeprüfung §34a của IHK; tỷ lệ trượt cao, khoá học offline đắt.",
        bodies="IHK, DIHK",
        grow=["Nhóm Facebook \"Sicherheitsdienst Jobs\", \"Sachkundeprüfung 34a Lerngruppe\".",
              "Các công ty bảo vệ tuyển người mới (họ cần nhân viên đậu nhanh)."]),
    "civilserviceph": dict(
        markets=["PH"], prices="**₱249** (Philippines) → Update exchange rates",
        why="Khoảng 240 nghìn người thi Civil Service Exam mỗi đợt, tỷ lệ đậu chỉ khoảng 14%; Philippines dùng Android là chủ yếu.",
        bodies="Civil Service Commission (CSC)",
        grow=["Nhóm Facebook \"Civil Service Exam Reviewer\" (rất đông thành viên), TikTok PH.",
              "Đăng trước mỗi kỳ thi (tháng 3 và tháng 8 hằng năm) 4–6 tuần."]),
    # Games
    "dominodots": dict(
        markets=["ALL"], prices="**US $2.99** → Update exchange rates → sửa tay: Nhật ¥450, Ấn Độ ₹149, Brazil R$ 11,90",
        why="Ăn theo *Pips* của NYT Games (domino logic). Trên Android gần như chưa có app tương tự: bản duy nhất tìm thấy là app trả phí khoảng 50 lượt cài.",
        legal="Không dùng chữ \"Pips\", \"NYT\", \"New York Times\" trong tên, icon, mô tả, ảnh.",
        grow=["Reddit r/NYTPips, r/puzzles, r/dominoes: \"I made an unlimited domino logic puzzle (no ads)\".",
              "Người chơi Pips chỉ có 3 câu/ngày → nhấn mạnh \"unlimited puzzles\" trong mô tả."]),
    "patchgrid": dict(
        markets=["ALL"], prices="**US $2.99** → Update exchange rates → sửa tay: Nhật ¥450, Ấn Độ ₹149",
        why="Ăn theo *Patches* của LinkedIn (ra 19/3/2026, kiểu Shikaku). Chỉ có vài app Shikaku cũ, không app nào có huy hiệu hình dạng như Patches.",
        legal="Không dùng chữ \"Patches\", \"LinkedIn\" trong tên, icon, mô tả, ảnh.",
        grow=["LinkedIn: chính người chơi Patches dùng LinkedIn hằng ngày; đăng bài \"unlimited Patches-style puzzles\".",
              "Nhật: Shikaku (四角に切れ) là thể loại quen thuộc → ưu tiên listing ja-JP."]),
    "wordweave": dict(
        markets=["ALL"], prices="**US $2.99** → Update exchange rates",
        why="Ăn theo *Wend* của LinkedIn (ra 6/2026). Chưa tìm thấy bản nào trên Android.",
        legal="Không dùng chữ \"Wend\", \"LinkedIn\" trong tên, icon, mô tả, ảnh.",
        grow=["Reddit r/wordgames, r/WordleGames; nhóm Facebook word puzzle.",
              "Người học tiếng Anh (VN, ID, JP): \"vừa chơi vừa học từ\"."]),
    "puttpuzzle": dict(
        markets=["ALL"], prices="**US $2.99** → Update exchange rates",
        why="Ăn theo *putt.day* (\"Wordle phiên bản minigolf\", ra 13/5/2026). Chỉ có trên web, Android chưa có app thật.",
        legal="Không dùng chữ \"putt.day\" trong tên, icon, mô tả, ảnh.",
        grow=["Reddit r/minigolf, r/WebGames, r/AndroidGaming.",
              "Video ngắn \"hole-in-one\" trên Shorts/Reels: game golf rất hợp video."]),
    "meowqueens": dict(
        markets=["ALL"], prices="**US $2.99** → Update exchange rates → sửa tay: **Nhật ¥450**",
        why="*Meowdoku* hơn 43 triệu lượt tải, đứng đầu lượt tải tại Nhật tháng 8–9/2026, nhưng kiếm tiền gần như 100% bằng quảng cáo. Khác biệt: không quảng cáo + tiếng Nhật.",
        legal="Không dùng chữ \"Meowdoku\", \"Queens\" (LinkedIn) làm thương hiệu; \"Meow Queens\" là tên riêng.",
        grow=["Nhật: X (Twitter) tiếng Nhật với hashtag ネコパズル, 脳トレ.",
              "Người chơi Meowdoku chán quảng cáo → nhấn mạnh \"広告なし\" (không quảng cáo)."]),
    "sunmoon": dict(
        markets=["ALL"], prices="**US $2.99** → Update exchange rates",
        why="Ăn theo *Tango* của LinkedIn (game hằng ngày, mỗi ngày chỉ 1 màn). Takuzu có nhiều app nhưng gần như không app nào có luật dấu =/× như Tango.",
        legal="Không dùng chữ \"Tango\", \"LinkedIn\" trong tên, icon, mô tả, ảnh.",
        grow=["LinkedIn: đăng \"unlimited sun & moon puzzles\" cho người chơi Tango hằng ngày.",
              "Quảng cáo chéo với Meow Queens (cùng nhóm người chơi game LinkedIn)."]),
    "whodunit": dict(
        markets=["ALL"], prices="**US $2.99** → Update exchange rates",
        why="Ăn theo *Clues by Sam* (game suy luận hằng ngày viral năm 2025, chỉ có trên web). Gần như chưa có bản Android tử tế.",
        legal="Không dùng chữ \"Clues by Sam\" trong tên, icon, mô tả, ảnh.",
        grow=["Reddit r/CluesBySam, r/puzzles, r/WebGames: \"unlimited cases\".",
              "Video ngắn \"Bạn tìm ra hết tội phạm không?\" trên Shorts/Reels/TikTok."]),
}

GAME_CATEGORY = {"weave": "Game → **Word**"}
LOCALE_NAMES = {
    "en-US": "English (United States) – en-US", "vi": "Vietnamese – vi", "es-US": "Spanish (United States) – es-US",
    "es-419": "Spanish (Latin America) – es-419", "pt-BR": "Portuguese (Brazil) – pt-BR", "id": "Indonesian – id",
    "de-DE": "German – de-DE", "ja-JP": "Japanese – ja-JP", "ro": "Romanian – ro", "pl-PL": "Polish – pl-PL",
}
RELEASE_NOTES = {
    "exam": "First release!\n• 250 original practice questions with explanations\n• Timed mock exams with pass mark\n• Study plan, daily reminder, flashcards and weakest-topic drill",
    "game": "First release!\n• Unlimited puzzles in 4 levels: Easy to Expert\n• Daily puzzle with streaks\n• Stars, themes and trophies – no ads",
}


def gh_slug(heading: str) -> str:
    """GitHub's anchor for a heading."""
    s = heading.strip().lower()
    s = re.sub(r"[^\w\- ]", "", s)
    return s.replace(" ", "-")


def heading(n: int, cfg: dict, root: Path) -> str:
    en = root / "store" / cfg["id"] / "metadata/android/en-US/title.txt"
    return f"{n}. {en.read_text().strip()} ({cfg['id']})"


def load_apps() -> list[tuple[dict, Path]]:
    out = []
    for root in (REPO, REPO / "games"):
        for f in sorted((root / "apps").glob("*.json")):
            out.append((json.loads(f.read_text()), root))
    return out


def rel(p: Path) -> str:
    return str(p.relative_to(REPO))


def code(text: str) -> str:
    return "```\n" + text.strip() + "\n```"


def app_version(root: Path) -> str:
    """versionName from the project's pubspec.yaml (e.g. 1.0.1)."""
    m = re.search(r"^version:\s*([\d.]+)", (root / "pubspec.yaml").read_text(), re.M)
    return m.group(1) if m else "1.0.0"


def app_section(n: int, cfg: dict, root: Path, local: bool = False) -> str:
    """One app's upload sheet. local=True: paths point inside its play-upload/ folder."""
    aid = cfg["id"]
    meta = META[aid]
    game = root.name == "games"
    store = root / "store" / aid / "metadata/android"
    locales = sorted(p.name for p in store.iterdir() if p.is_dir())
    locales.sort(key=lambda l: (l != "en-US", l))
    en = store / "en-US"
    title_en = (en / "title.txt").read_text().strip()
    markets = "**Tất cả quốc gia**" if meta["markets"] == ["ALL"] else ", ".join(FLAGS.get(m, m) for m in meta["markets"])
    category = GAME_CATEGORY.get(cfg.get("game"), "Game → **Puzzle**") if game else "App → **Education**"
    price = meta["prices"]
    lines = [f"## {heading(n, cfg, root)}", ""]
    lines += [
        "| | |", "|---|---|",
        f"| Mã app | `{cfg['applicationId']}` |",
        f"| Loại | {category} |",
        f"| Thị trường | {markets} |",
        f"| Ngôn ngữ store | {', '.join(f'`{l}`' for l in locales)} |",
        f"| Privacy policy | {cfg['privacyPolicyUrl']} |",
        f"| Email hỗ trợ | {cfg['supportEmail']} |",
        "| Quảng cáo | **Không** (AdMob tắt; không cần app-ads.txt) |",
        f"| Mua trong app | `{cfg['premiumProductId']}` = mở khoá toàn bộ, trả 1 lần |",
        "",
        f"**Vì sao làm:** {meta['why']}",
        "",
    ]
    if game:
        lines.append("**Kiếm tiền:** miễn phí Dễ + Vừa không giới hạn; Khó 3 câu/ngày, Chuyên gia 1 câu/ngày, 3 gợi ý + 1/ngày. "
                     f"`{cfg['premiumProductId']}` mở mọi mức, gợi ý không giới hạn, kho 60 ngày, mọi giao diện.")
    else:
        ex = cfg.get("exam", {})
        lines.append(f"**Kiếm tiền:** miễn phí khoảng {int(cfg.get('freeRatio', 0.35) * 100)}% câu mỗi chủ đề + thi thử ngắn; "
                     f"`{cfg['premiumProductId']}` mở 250 câu, thi thử đầy đủ {ex.get('questions')} câu/{ex.get('minutes')} phút "
                     f"(đậu {ex.get('passPercent')}%), thẻ ghi nhớ không giới hạn.")
    lines += ["", "---", "", "### 📦 File tải lên", ""]
    if local:
        lines += [f"- File: **`app-{aid}-release.aab`** (nằm ngay trong thư mục này).",
                  "- Ảnh, chữ store, icon sản phẩm cũng nằm trong thư mục này (xem đường dẫn bên dưới)."]
    else:
        lines += [
            f"- Tải **`{aid}.zip`** ở [Releases → play-upload]({RELEASE}): trong đó có AAB + ảnh + chữ store + icon sản phẩm + hướng dẫn riêng (`UPLOAD.md`).",
            f"- Hoặc [Actions → Android build]({ACTIONS}) → lần chạy mới nhất ✅ → **Artifacts** → `{aid}-buildN` → `app-{aid}-release.aab`.",
        ]
    lines += [
        "- Từ lần 2: dùng [Publish to Google Play]" f"({PUBLISH}) với `apps = {aid}` (xem Phần A, mục A5).",
        "",
        f"**Release name:** `{app_version(root)}` (versionCode do CI tự đặt, luôn tăng sau mỗi lần build)",
        "",
        "**Release notes**",
        code(f"<en-US>\n{RELEASE_NOTES['game' if game else 'exam']}\n</en-US>"),
        "",
        "### 🛒 Sản phẩm mua trong app (làm sau khi đã upload AAB lên Internal testing)",
        "",
        "| Ô | Điền |", "|---|---|",
        f"| **Product ID** | `{cfg['premiumProductId']}` |",
        f"| **Name** | `{'Unlimited: all levels & hints' if game else 'Unlock all questions'}` |",
        f"| **Description** | `{('Unlimited Hard & Expert puzzles, unlimited hints, the daily archive and every theme. One-time purchase.' if game else 'All 250 questions, full mock exams and unlimited flashcards. One-time purchase – keep it forever.')}` |",
        f"| **Icon** | `{('product/' if local else rel(root / 'store' / aid / 'product_icons') + '/') + cfg['premiumProductId'] + '.png'}` (512×512, không chữ) |",
        f"| **Tags** | {' · '.join(f'`{t}`' for t in cfg.get('productTags', []))} |",
        "| **Purchase option** | ID `buy` · Type **Buy** (giữ *Backwards compatible*) |",
        f"| **Giá** | {price} → Availability: các nước ở trên |",
        "",
        "Các bước chi tiết: Phần A, mục A4.",
        "",
        "### 🖼 Hình ảnh",
        "",
        (lambda b: f"`{b}/icon.png` · `{b}/featureGraphic.png` · `{b}/phoneScreenshots/1.png`→`4.png`")(
            "listing/en-US/images" if local else rel(en / "images")),
    ]
    loc_shots = [l for l in locales if l != "en-US" and (store / l / "images/phoneScreenshots").exists()]
    if loc_shots:
        lines.append(f"(Ảnh riêng cho {', '.join(f'`{l}`' for l in loc_shots)} nằm trong thư mục cùng tên.)")
    lines += ["", "### ✍️ Nội dung trang store", ""]
    for i, loc in enumerate(locales):
        d = store / loc
        t = (d / "title.txt").read_text().strip()
        s = (d / "short_description.txt").read_text().strip()
        f = (d / "full_description.txt").read_text().strip()
        block = [f"**{LOCALE_NAMES.get(loc, loc)}**", "", f"App name ({len(t)}/30)", code(t),
                 f"Short description ({len(s)}/80)", code(s), "Full description", code(f)]
        if i == 0:
            lines += block
        else:
            lines += [f"<details><summary>{LOCALE_NAMES.get(loc, loc)}: bấm để mở</summary>", ""] + block + ["", "</details>"]
        lines.append("")
    if game:
        rating = "IARC → **Game** → Puzzle/Word; mọi mục bạo lực, cờ bạc, người lớn, tương tác người dùng: **No**; mua hàng kỹ thuật số: **Yes**"
        audience = "**13–15, 16–17, 18+** (không chọn dưới 13). Hấp dẫn trẻ em: **No**"
        cat = "Puzzle" if cfg.get("game") != "weave" else "Word"
    else:
        rating = "IARC → **Reference, News, or Educational**; mọi mục: **No**; mua hàng kỹ thuật số: **Yes** → thường ra Everyone / PEGI 3"
        audience = "**18 and over**. Hấp dẫn trẻ em: **No**"
        cat = "Education"
    lines += [
        "### 📋 App content",
        "",
        "| Mục | Trả lời |", "|---|---|",
        f"| Privacy policy | `{cfg['privacyPolicyUrl']}` |",
        "| App access | All functionality is available without special access |",
        "| Ads | **No, my app does not contain ads** |",
        f"| Content rating | {rating} |",
        f"| Target audience | {audience} |",
        "| Data safety | **No** – app không thu thập hay chia sẻ dữ liệu (tiến độ chỉ lưu trên máy; thanh toán do Google Play xử lý) |",
        "| Advertising ID | **No** |",
        "| News / Government / Financial features / Health | No / No / None / None |",
        f"| Store settings | Category **{cat}** · Email {cfg['supportEmail']} |",
        "",
        "### ⚖️ Lưu ý pháp lý",
        "",
    ]
    if game:
        lines += [f"- {meta['legal']}", "- Cơ chế chơi không được bảo hộ bản quyền; tên, logo, hình ảnh thương hiệu thì có. Tên, icon và đồ hoạ của app là của riêng mình.",
                  "- Không thêm tính năng cược hay giải thưởng tiền thật."]
    else:
        lines += [f"- Không dùng logo hay chữ \"official\" của {meta['bodies']}; mô tả đã ghi rõ \"not affiliated with or endorsed by\".",
                  "- Không viết \"đề thi thật\", \"guaranteed pass\", \"100% pass\" (Google từ chối vì quảng cáo sai sự thật).",
                  "- Câu hỏi là câu tự biên soạn; nên nhờ người trong nghề duyệt lại trước khi chạy quảng cáo."]
        if aid in ("cscsro", "cscspl"):
            lines.append("- \"CSCS\" là thương hiệu của CSCS Ltd. Nếu Google phản hồi về thương hiệu, đổi tên thành \"Test HS&E pentru construcții\" / \"Test BHP budowa UK\".")
    lines += ["", "### 🚀 Tăng lượt tải", ""] + [f"{i + 1}. {g}" for i, g in enumerate(meta["grow"])] + ["", "---", ""]
    return "\n".join(lines)


def common_part(apps: list[tuple[dict, Path]]) -> str:
    rows = "\n".join(
        f"| {i + 1} | `{c['id']}` | {c['title'].get('en') or next(iter(c['title'].values()))} | `{c['applicationId']}` |"
        for i, (c, _) in enumerate(apps))
    n = len(apps)
    g = sum(1 for _, r in apps if r != REPO)
    return f"""## Phần A — Làm chung cho cả {n} app

### A0. Tình trạng

| Việc | Trạng thái |
|---|---|
| Code {n} app ({n - g} app luyện thi × 250 câu, {g} game) | ✅ |
| Icon, feature graphic, ảnh màn hình, nội dung store mọi ngôn ngữ | ✅ trong `store/` và `games/store/` |
| Email hỗ trợ `tuanlt1989@gmail.com`, tên nhà phát triển `Tuan Apps` | ✅ (đổi trong `apps/*.json` nếu muốn khác, rồi chạy `python3 tool/factory.py`) |
| 4 secrets khoá ký trên GitHub | ✅ bạn đã thêm |
| AAB đã ký cho {n} app | ✅ tự build mỗi lần push: [Actions → Android build]({ACTIONS}) |
| **Gói upload từng app** (AAB + ảnh + chữ store + icon sản phẩm + `UPLOAD.md`) | ✅ [Releases → play-upload]({RELEASE}): tải `<id>.zip` |
| Trang chính sách bảo mật (GitHub Pages) | ⬜ bật 1 lần ở mục A2 |
| `PLAY_SERVICE_ACCOUNT_JSON` (upload tự động) | ⬜ không bắt buộc, mục A5 |

### A1. Danh sách app

| # | id | Tên (en) | Mã app (không đổi được sau khi upload) |
|---|---|---|---|
{rows}

### A2. Bật trang chính sách bảo mật (1 lần)
1. <{GH}/settings/pages> → **Source**: *Deploy from a branch* → **Branch** `exam-prep-apps`, thư mục **`/docs`** → **Save**.
2. Sau 1–3 phút mở thử <https://tuanlt1989.github.io/assignment/privacy/nailvi.html>. Cả {n} trang có dạng `…/privacy/<id>.html`.

### A3. Thứ tự đưa 1 app lên
1. **Create app** → tên (mục "App name" của app) → **English (United States) – en-US** → App/Game theo bảng → **Free** → Create.
2. **App content**: điền theo bảng 📋 của app.
3. **Store settings** + **Main store listing**: dán chữ ✍️, upload ảnh 🖼. **Manage translations → Add your own translations**: thêm các ngôn ngữ còn lại.
4. **Testing → Internal testing → Create new release**: để mặc định Play App Signing, upload `app-<id>-release.aab`, release notes → **Save and publish**. Thêm Gmail của bạn vào Testers.
5. Tạo sản phẩm 🛒 (mục A4) → **Setup → License testing** thêm Gmail → cài từ link tester → mua thử.
6. **Closed testing** ≥12 tester × 14 ngày (tài khoản cá nhân); dùng chung 1 Google Group cho cả {n} app → **Apply for production**.
7. **Production** → chọn quốc gia theo bảng → **Create new release** → *Add from library* → rollout 20% → 100%.

> Mẹo: làm bước 1–5 cho cả {n} app trong cùng 1–2 ngày, để {n} app chạy closed test song song.

### A4. Tạo one-time product `premium_lifetime` (từng bước, giống nhau cho mọi app)
**Bước 0: điều kiện:** đã upload ít nhất 1 file `.aab` (Internal testing là đủ); Payments profile không bị hold.

**Bước 1:** Play Console → chọn app → **Monetize with Play → Products → One-time products** → **Create one-time product**.

**Bước 2:** điền Product ID, Name, Description theo bảng 🛒 của app. Ngôn ngữ mặc định **en-US** → **Save**.

**Bước 2b: Icon và Tags:** trong sản phẩm vừa tạo → **Icon → Upload** file icon trong bảng 🛒 của app (PNG 32-bit 512×512, không chữ, không logo, đúng yêu cầu của Google). **Tags**: gõ từng tag trong bảng rồi bấm Enter. Tag giúp Google gợi ý sản phẩm đúng người; không bắt buộc nhưng nên có.

**Bước 3:** **Add purchase option** → ID `buy` · Type **Buy** (giữ *Backwards compatible*).

**Bước 4:** giá theo bảng của app → **Update exchange rates** → sửa tay các nước được ghi → Availability.

**Bước 5:** **Activate** purchase option → **Activate** sản phẩm. Sau 5–30 phút nút mua trong app hiện giá.

**Bước 6:** **Settings → License testing** → thêm Gmail → cài app **từ link Internal testing** (không cài APK tay) → mua thử ("Test card, always approves").

Chi tiết và cách sửa lỗi: Phụ lục, mục 06.

### A5. Từ lần cập nhật thứ 2: bấm 1 nút
1. Tạo service account và thêm secret `PLAY_SERVICE_ACCOUNT_JSON` (Phụ lục, mục 09).
2. [Actions → Publish to Google Play]({PUBLISH}) → **Run workflow** → `apps` = `nailvi` (hoặc `nailvi,cosmovi` hoặc `all`), `track` = internal/production. Workflow tự build, ký, upload AAB + toàn bộ trang store.
3. Hoặc nhắn Claude: *"up nailvi lên internal"*.

### A6. Release notes chung khi cập nhật
```
<en-US>
• More practice questions and clearer explanations
• Bug fixes and performance improvements
</en-US>
```

---
"""


def appendix() -> str:
    parts = ["## Phụ lục — toàn bộ tài liệu khác", ""]
    files = [REPO / "README.md"] + sorted((REPO / "docs").glob("0*.md")) + [REPO / "games/README.md"]
    for f in files:
        text = f.read_text()
        # Demote headings two levels so they nest under this appendix.
        text = re.sub(r"^(#{1,4}) ", lambda m: "#" * (len(m.group(1)) + 2) + " ", text, flags=re.M)
        parts += [f"<!-- {rel(f)} -->", "", text.strip(), "", "---", ""]
    return "\n".join(parts)


def main() -> None:
    apps = load_apps()
    toc = "\n".join(
        f"{i + 1}. [{heading(i + 1, c, r).split('. ', 1)[1]}](#{gh_slug(heading(i + 1, c, r))})"
        for i, (c, r) in enumerate(apps))
    body = [
        f"# Hướng dẫn đưa {len(apps)} app lên Google Play (tổng hợp)",
        "",
        "> File được tạo tự động bởi `python3 tool/store_guide.py` từ `apps/*.json`, `store/` và `docs/`. "
        "Sửa nguồn rồi chạy lại lệnh, đừng sửa tay file này.",
        "",
        "**Mục lục:** Phần A (làm chung) · Phần B (từng app) · Phụ lục (tài liệu 01–09, README).",
        "",
        "Phần B:",
        toc,
        "",
        common_part(apps),
        "## Phần B — Từng app",
        "",
    ]
    for i, (cfg, root) in enumerate(apps):
        body.append(app_section(i + 1, cfg, root))
    body.append(appendix())
    OUT.write_text("\n".join(body))
    print(f"{rel(OUT)}: {len(apps)} apps, {OUT.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
