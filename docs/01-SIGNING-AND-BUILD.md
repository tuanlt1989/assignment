# 01 — Khoá ký & build AAB/APK

Google Play bắt buộc file **AAB** phải được ký bằng **upload key** của bạn. Khi bật Play App Signing (mặc định), Google giữ khoá ký thật của app, còn bạn chỉ giữ upload key. Nếu lỡ mất upload key, bạn có thể xin Google đặt lại.

Dùng **một upload key chung cho cả 5 app** cho đơn giản. Mỗi app vẫn có khoá ký riêng do Google quản lý.

## 1. Tạo upload key (làm 1 lần)

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Cất file `upload-keystore.jks` và mật khẩu ở nơi an toàn, ví dụ trình quản lý mật khẩu. **Không commit file này lên git** (`.gitignore` đã chặn sẵn `*.jks`).

## 2a. Build trên máy của bạn

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
# file ra: build/app/outputs/bundle/nailviRelease/app-nailvi-release.aab
```

- **`--build-number` phải tăng sau mỗi lần upload.** Play từ chối mã phiên bản (versionCode) đã dùng.
- Nếu không có `key.properties`, bản release sẽ được ký bằng debug key. Bản đó vẫn cài thử trên máy được, nhưng **Play sẽ từ chối**.

## 2b. Build tự động trên GitHub (khuyên dùng)

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

## 3. Cài thử APK lên điện thoại Android

Tải `app-<id>-release.apk` từ Artifacts, gửi sang điện thoại, bật "Cài ứng dụng không rõ nguồn gốc" rồi cài.
Hoặc cắm điện thoại vào máy tính và chạy `flutter run --flavor nailvi --release`.

Lưu ý: tính năng mua hàng chỉ chạy khi app được cài **từ Play** (internal testing trở lên) và tài khoản Google trên máy đã được thêm làm tester. Quảng cáo TEST thì hiện ngay.
