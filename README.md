# Waze HUD - 3.5 inch (ESP32-S3 ST77922 QSPI)

Bản firmware này dành cho module màn hình **3.5 inch độ phân giải 480×320 chạy vi điều khiển ESP32-S3** (như **ES3C35P / JC3248W535**) giao tiếp qua **ST77922 QSPI 40MHz**.

> [!WARNING]
> Mạch **Sunton CYD 3.5" (ESP32-3248S035)** trên thị trường sử dụng chip **ESP32 thường (Xtensa LX6) và màn ST7796 SPI**. Tuyệt đối không nạp file BIN của bản này lên board ESP32 thường vì sẽ gây bootloop do không tương thích kiến trúc CPU.

## Tính năng nổi bật
- Màn hình landscape 480×320, căn chỉnh QSPI 4-pixel.
- HLP Device Config Schema Rev 7 (9 mục cài đặt), hỗ trợ Cố định độ sáng và Đảo ngược màu màn hình.
- Màu khoảng cách biển báo cảnh báo 4 mức độ trực quan (>600m Xanh lá, 300–600m Trắng, 100–300m Cam, <100m Đỏ).
- Độ sáng ban đêm giảm về 20% (từ 19:00 đến 05:00).
- Chống bootloop: bật tự động bỏ qua lỗi Octal PSRAM nếu board chỉ có Quad PSRAM hoặc không có PSRAM (`CONFIG_SPIRAM_IGNORE_NOTFOUND=y`).
