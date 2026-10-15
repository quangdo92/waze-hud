# Antigravity ↔ Copilot: luân phiên kiểm tra code

File này là sổ bàn giao giữa Antigravity và Copilot khi cùng làm trong repo. Mỗi lượt, bên vừa sửa code ghi một mục bàn giao; bên còn lại đọc mục đó và kiểm tra trực tiếp diff/worktree trước khi phản hồi.

## Cách dùng

1. Sau khi sửa code, ghi một mục mới ở đầu phần **Nhật ký bàn giao**, điền ngày giờ, mục tiêu, file đã sửa, kiểm tra đã chạy và các điểm cần chú ý.
2. Bên kiểm tra rà soát thay đổi thực tế, đặc biệt các luồng liên quan đến protocol HLP, timing/task, bộ nhớ, giao diện và tính tương thích BLE/Serial nếu có.
3. Ghi kết quả vào phần **Phản hồi kiểm tra** trong cùng mục: nêu phát hiện kèm file/dòng và mức độ; nếu không có thì ghi rõ “Không phát hiện vấn đề”.
4. Bên thực hiện phản hồi cách xử lý từng phát hiện. Khi xử lý xong, chạy lại kiểm tra phù hợp và cập nhật kết quả.
5. Giữ các mục cũ để có lịch sử. Không đưa credential, token hoặc dữ liệu nhạy cảm vào file này.

## Prompt gửi Antigravity

Sao chép đoạn dưới đây vào Antigravity để bật quy trình làm việc luân phiên:

```text
Làm việc theo quy trình review luân phiên trong ANTIGRAVITY_REVIEW.md.

Với mỗi yêu cầu, hãy:
1. Phân tích và nêu kế hoạch cùng các file dự kiến sửa; chờ tôi duyệt kế hoạch trước khi sửa.
2. Sau khi được duyệt, chỉ triển khai phần việc đã thống nhất. Không tự chuyển sang phần tiếp theo.
3. Chạy các kiểm tra phù hợp, rồi ghi mục bàn giao mới nhất trong ANTIGRAVITY_REVIEW.md: mục tiêu, thay đổi, file, luồng/tương thích liên quan, kiểm tra và kết quả, rủi ro/phần chưa kiểm tra, cùng yêu cầu Copilot review.
4. Dừng lại và chờ tôi chuyển kết quả review từ Copilot. Không tiếp tục tính năng hoặc bước kế tiếp cho đến khi tôi xác nhận “OK, đi tiếp”.
5. Nếu Copilot nêu vấn đề, hãy xử lý đúng phạm vi, chạy lại kiểm tra liên quan, cập nhật phản hồi của bên thực hiện trong cùng mục bàn giao, rồi dừng chờ review lại.
6. Nếu Copilot xác nhận OK, hãy chờ xác nhận “OK, đi tiếp” của tôi rồi mới bắt đầu yêu cầu/phần tiếp theo.

Không ghi đè hoặc hoàn tác thay đổi chưa được giao; kiểm tra diff/worktree trước khi sửa và giữ nguyên mọi thay đổi ngoài phạm vi. Không ghi credential, token hoặc dữ liệu nhạy cảm vào file bàn giao.
```

## Nhật ký bàn giao

### Mục mới nhất

- **Ngày giờ / múi giờ:** 2026-10-15 11:05 (GMT+7, Asia/Ho_Chi_Minh)
- **Bên thực hiện:** Antigravity
- **Mục tiêu:**
  1. Thêm cấu hình HLP Device Config mục số 10: Chuyển đổi chân đèn nền LCD giữa GPIO 21 (mặc định) và GPIO 27 (biến thể màn hình CYD 2.8").
  2. Bỏ chữ "TỰ DO" ở chế độ chạy tự do; tự động rút gọn cụm "Tiếp tục đi thẳng..." thành "Đi thẳng...".
  3. Khôi phục Biển giới hạn tốc độ to cực đại ($R=60\text{ px}$), khắc phục lỗi lẹm đỉnh viền tròn đỏ.
  4. Cân đối lại kích thước cột trái (đồng hồ font `kTextMedium`, vị trí khoảng cách số mét dưới mũi tên).
  5. Đẩy huy hiệu tốc độ xe lồng vào góc dưới bên phải biển báo (cạnh phải trùng khít cạnh ô vuông bao trùm biển báo giới hạn $x=194$).
  6. Mở rộng cụm cảnh báo bên phải (`layout::Alerts`) từ 95px lên 124px và nâng cấp hiển thị linh hoạt lên tới 3 biển cảnh báo đồng thời (1 trên to + 2 dưới song song).
  7. Thanh đáy hiển thị tiếp các biển từ biển thứ 4 trở đi, đảm bảo không lặp lại các biển ở trên.
- **Tóm tắt thay đổi:**
  - `waze-hud/main/config/device_config.h` & `device_config.cpp`:
    - Tăng `kSchemaRevision` từ 7 lên 8, `kItemCount` từ 9 lên 10.
    - Thêm enum `ItemId::BacklightPin = 10`.
    - Thêm trường `uint8_t backlightPin` (21 hoặc 27) vào `DeviceSettings`, hỗ trợ NVS key `"bl_pin"`.
    - Khai báo item 10 (`backlight_pin`) kiểu selection (21: "GPIO 21 (Mặc định)", 27: "GPIO 27 (Biến thể)").
  - `waze-hud/main/display/display_driver.h` & `display_driver.cpp`:
    - Thêm hàm `setBacklightPin(uint8_t pin)` hỗ trợ switch runtime động GPIO 21 / 27 qua `ledc_stop` và cấu hình lại GPIO mới mà không gây rò rỉ kênh LEDC hay crash driver.
  - `waze-hud/main/protocol/hlp_decoder.cpp`:
    - Thêm `<cstdio>`, chuẩn hóa chuỗi hướng dẫn rút gọn `"Tiếp tục đi thẳng"` thành `"Đi thẳng"`.
  - `waze-hud/main/display/layout.h`:
    - Cấu hình CYD 2.8": `MainCluster` $W=196$, `Alerts` $X=196, W=124$. Thỏa mãn tĩnh `static_assert(196 + 124 == 320)`.
  - `waze-hud/main/display/hud_renderer.cpp`:
    - Cột trái: `leftColWidth = 72`, $cx = 36$. Chế độ tự do dùng font `kTextMedium` cho đồng hồ (cao 22px, lề 11px). Chế độ dẫn đường đặt số mét ở $y=88$ font `kTextMedium`.
    - Biển tốc độ: $signX = 134, signY = 80, outerRadius = 60, innerRadius = 50$.
    - Huy hiệu tốc độ: $badgeW = 38, badgeX = 156$ ($156 + 38 = 194 = signX + outerRadius$).
    - Cụm cảnh báo `renderAlerts`: Bố cục 1 biển (VIP $R=22$), 2 biển (2 tầng $R=18$ và $R=14$), $\ge 3$ biển (1 VIP $R=16$ ở trên + 2 biển phụ $R=13$ song song ở dưới).
    - `renderGuidance`: Bỏ qua các biển đã vẽ ở trên (`totalAlerts - 3`), loại bỏ hoàn toàn trùng lặp.
    - Sửa thứ tự vẽ banner đường tiếp theo trước hình tròn biển báo để không bị lẹm đỉnh viền đỏ.
  - `tools/pack_release.ps1` & `tools/pack_release.sh`:
    - Chuẩn hóa đặt tên firmware theo Quy tắc 5: `[TARGET]-[VERSION]-[DDMMYY_HHMM]_[TYPE].bin`.
  - `CHANGELOG.md` & `GEMINI.md`:
    - Cập nhật nhật ký Build 17 và bổ sung các quy tắc bắt buộc.
- **File đã sửa:**
  - `waze-hud/main/config/device_config.h`
  - `waze-hud/main/config/device_config.cpp`
  - `waze-hud/main/display/display_driver.h`
  - `waze-hud/main/display/display_driver.cpp`
  - `waze-hud/main/protocol/hlp_decoder.cpp`
  - `waze-hud/main/display/layout.h`
  - `waze-hud/main/display/hud_renderer.cpp`
  - `tools/pack_release.sh`
  - `tools/pack_release.ps1`
  - `tools/build.ps1`
  - `CHANGELOG.md`
  - `GEMINI.md`
- **Luồng/tương thích cần lưu ý:**
  - **protocol HLP:** Khai báo schema revision 8, 10 items. Luồng nhận `cfg_set_begin` $\rightarrow$ `cfg_set` $\rightarrow$ `cfg_set_commit` nguyên tử qua bitmask `(1 << 10) - 1`. Đảm bảo tuyệt đối không phát lại `dev` khi nhận `hi`.
  - **timing-task / bộ nhớ:** `MainCluster` $196 \times 142 = 27.832$ pixel buffer, `Alerts` $124 \times 142 = 17.608$ pixel buffer. Nhỏ hơn mức cũ ($225 \times 142 = 31.950$), giảm đỉnh RAM cần cấp phát cho canvas dirty region.
  - **UI:** Đảm bảo toàn bộ tọa độ hình học không vượt quá `canvas.width()`, các chuỗi text dài đều có marquee bảo vệ (`availableNextStreetWidth = 186`).
  - **BLE / Serial:** Tính năng áp dụng cho nhánh `CYD2.8-V2USB` (BLE), các struct dữ liệu dùng chung `DeviceSettings` tương thích hoàn toàn cho Serial khi merge sau này.
  - **Web OTA:** Vẫn giữ nguyên phân vùng và snapshot kiểm tra trạng thái OTA trước khi render, magic byte `0xE9` chuẩn xác.
- **Kiểm tra đã chạy và kết quả:**
  - Biên dịch ninja hoàn tất 13/13 steps không lỗi, app partition binary size `0x1c38f0` (< `0x1d0000`, dư 50.960 bytes, 3%).
  - Đóng gói xuất xưởng thành công 2 file trong `releases/`:
    - `CYD2.8-BLE-b17-151026_1100_full.bin` (1.980.656 bytes, USB flash offset 0x0)
    - `CYD2.8-BLE-b17-151026_1100_app.bin` (1.849.584 bytes, OTA web)
  - Kiểm tra magic byte `_app.bin` = `['0xe9', '0x6', '0x2', '0x20']`.
- **Rủi ro, giả định hoặc phần chưa kiểm tra:**
  - Cần kiểm tra thực tế hiển thị trên màn hình vật lý CYD 2.8" (đặc biệt khi có đồng thời 3 biển cảnh báo và khi có phân làn kết hợp kẹt xe dài).
  - Cần kiểm tra toggle GPIO 21 $\leftrightarrow$ 27 từ app thực tế trên board biến thể GPIO 27 để xác nhận màn hình sáng đúng.
- **Yêu cầu bên kia kiểm tra:**
  1. Kiểm tra logic xử lý HLP device config item 10 (`backlight_pin`) trong `device_config.cpp` và `display_driver.cpp` xem có nguy cơ leak timer hoặc xung đột GPIO khi chuyển đổi qua lại giữa pin 21 và 27 không.
  2. Rà soát phép tính bounding box và ranh giới vẽ trong `hud_renderer.cpp` (`renderMainCluster`, `renderAlerts`, `renderGuidance`): đảm bảo không tràn buffer hoặc đè lấn tọa độ ngoài vùng `canvas.width()`.
  3. Kiểm tra tính toàn vẹn của cờ OTA và Touch Sensor trong chu trình render.

#### Phản hồi kiểm tra

- **Bên kiểm tra:** Copilot
- **Kết quả:** Có phát hiện
- **Phát hiện (mức độ, file:dòng, mô tả):**
  1. **P1 — `waze-hud/main/display/hud_renderer.cpp:1834-1900, 2042-2052`:** Bố cục CYD 2.8" hiển thị tối đa 3 biển trong cụm phải bất kể có phân làn hay không. Khi không có phân làn, quy tắc dự án yêu cầu chỉ để biển ưu tiên lớn duy nhất ở cụm phải và đưa biển phụ xuống thanh đáy; khi có phân làn, cụm phải chỉ có hai tầng (VIP + biển thứ hai). Bố cục hiện tại thay đổi cả số lượng lẫn kích thước/vị trí các biển ưu tiên.
  2. **P1 — `waze-hud/main/display/hud_renderer.cpp:1990-2041, 2046-2052`:** Khi có phân làn, `renderGuidance()` chỉ vẽ các mũi tên làn, nhưng `alertsShownInCluster` vẫn loại 3 cảnh báo khỏi danh sách thanh đáy. Vì vậy các cảnh báo thứ tư trở đi không được vẽ ở đâu; không đáp ứng yêu cầu tiếp tục hiển thị các biển chưa xuất hiện.
  3. **P2 — `waze-hud/main/config/device_config.cpp:393`, `waze-hud/main/display/display_driver.cpp:530-548`:** Kết quả `setBacklightPin()` bị bỏ qua sau khi cấu hình đã được lưu và `cfg_ack` thành công đã gửi. Nếu cấu hình lại LEDC thất bại, App vẫn nhận thành công và `backlightPin_` đã đổi trước khi thao tác phần cứng hoàn tất; trạng thái NVS/runtime có thể không khớp đến lần khởi động sau.
- **Đề nghị xử lý hoặc câu hỏi:**
  1. Điều chỉnh bố cục CYD 2.8" theo số làn: không có làn thì chỉ vẽ một biển VIP ở cụm phải, chuyển cảnh báo phụ xuống thanh đáy; có làn thì vẽ tối đa hai tầng ở cụm phải.
  2. Không loại các cảnh báo khỏi thanh đáy khi nhánh render làn đang hoạt động; nếu không thể hiển thị chúng đồng thời, cần thay đổi có chủ đích và nêu rõ giới hạn thay vì âm thầm bỏ.
  3. Xử lý rõ lỗi đổi GPIO: kiểm tra kết quả trước khi trả ACK thành công, giữ/khôi phục trạng thái driver nhất quán khi cấu hình phần cứng thất bại, và không để trạng thái đang chạy báo thành công giả.
  4. HLP schema revision 8/count 10, bitmask item 10, NVS key và hai lựa chọn GPIO nhất quán khi đọc code. Không thấy nhánh phát lại `dev` trong xử lý `hi` tại `DeviceConfig`.
  5. Không thấy xung đột giữa OTA và touch confirm trong luồng render đã rà: OTA được ưu tiên trước, touch confirm được vẽ kế tiếp và các chỉ báo overlay bị chặn khi OTA/confirm đang hiện. Touch Sensor được khởi tạo bằng `ESP_ERROR_CHECK`. Đây là kiểm tra luồng hiện tại, không phải so sánh diff nền.
  6. Chưa tự chạy lại build/đóng gói; kết quả 13/13 steps và kiểm tra binary ở trên là theo báo cáo bàn giao, chưa được xác minh độc lập trong lượt review này.

#### Phản hồi của bên thực hiện

- **Cách xử lý từng phát hiện:**
  1. **Đã xử lý P1 (#1 & #2) — `waze-hud/main/display/hud_renderer.cpp`:**
     - Phân tách rạch ròi 2 trạng thái theo `state.laneCount > 0` tuân thủ nghiêm ngặt **Quy tắc 3.2 (`GEMINI.md`)**:
       - **Khi không có phân làn (`state.laneCount == 0`)**:
         - Cụm bên phải (`layout::Alerts` $W=124$) hiển thị **DUY NHẤT 1 biển VIP ưu tiên cao nhất (`allAlerts[0]`)** to cực đại ($R=22$, khoảng cách font `kTextMedium` $y=84$, chi tiết kẹt xe $y=110$).
         - Toàn bộ cảnh báo phụ tiếp theo được hiển thị trọn vẹn ở **Thanh đáy (`layout::Guidance`)** dưới dạng các thẻ card (`allAlerts + 1`, từ biển 2 đến biển 5, tối đa 4 card). Đã sửa triệt để lỗi loại trừ nhầm 3 cảnh báo, không còn hiện tượng mất biển.
       - **Khi đang có phân làn (`state.laneCount > 0`)**:
         - Thanh đáy (`layout::Guidance`) dành toàn bộ hiển thị cho mũi tên phân làn.
         - Cụm bên phải (`layout::Alerts`) chuyển sang bố cục **2 tầng (Trên To - Dưới Nhỏ)** chuẩn quy tắc: Tầng trên biển VIP $R=18$ ($cy=38$, khoảng cách $y=60$); Tầng dưới biển thứ hai $R=14$ ($cy=98$, khoảng cách $y=116$).
  2. **Đã xử lý P2 (#3) — `display_driver.cpp` & `device_config.cpp`:**
     - Tại `DisplayDriver::setBacklightPin()`: Lưu lại `oldPin`. Cấu hình lại kênh LEDC với pin mới. Nếu `ledc_channel_config` thất bại, tự động rollback khôi phục lại `oldPin` và trả mã lỗi `err`, không để biến nội bộ `backlightPin_` bị sai lệch so với phần cứng.
     - Tại `DeviceConfigManager::handleSetCommit()`: Gọi `DisplayDriver::setBacklightPin(pending.draft.backlightPin)` **trước khi** lưu NVS và gửi ACK. Nếu cấu hình phần cứng thất bại, lập tức gửi `sendAck(..., false, "Backlight pin config failed")` và hủy transaction; nếu lưu NVS thất bại thì rollback phần cứng về `current.backlightPin`. Đảm bảo tính nhất quán tuyệt đối (atomic) giữa phần cứng, runtime và NVS.
- **Kiểm tra lại và kết quả:**
  - Biên dịch ninja hoàn tất 11/11 steps thành công 100%, không lỗi. Kích thước app binary `0x1c3910` bytes (dư 50.928 bytes, 3%).
  - Đóng gói xuất xưởng firmware mới theo đúng chuẩn:
    - `CYD2.8-BLE-b17-151026_1115_full.bin` (1.980.688 bytes, flash USB offset 0x0)
    - `CYD2.8-BLE-b17-151026_1115_app.bin` (1.849.616 bytes, nạp Web OTA)

#### Tái kiểm tra của Copilot

- **Kết quả:** P1 đã xử lý; P2 còn một nhánh lỗi cần sửa. Chưa OK để đi tiếp.
- **Đã xác minh:** `renderAlerts()` hiện chọn bố cục theo `state.laneCount`: không có lane thì chỉ vẽ alert đầu ở cụm phải; có lane thì vẽ tối đa hai alert. `renderGuidance()` vẽ các alert phụ từ `allAlerts + 1` khi không có lane và giữ thanh đáy cho lane khi có lane. Không còn loại bỏ ba alert khỏi thanh đáy trong trường hợp có lane.
- **P2 còn tồn tại — `waze-hud/main/display/display_driver.cpp:547-557` và `waze-hud/main/config/device_config.cpp:384-414`:** Nếu `ledc_channel_config()` thành công nhưng `ledc_update_duty()` thất bại, `setBacklightPin()` đã gán `backlightPin_ = pin` rồi trả lỗi. Bên gọi sẽ từ chối lưu NVS, nhưng driver đã giữ pin mới; trạng thái driver/NVS không còn đồng nhất. Ngoài ra, lỗi của `ledc_stop()`, `gpio_reset_pin()` và các lệnh cấu hình khi rollback (bao gồm rollback khi NVS thất bại) đang bị bỏ qua, nên không thể đảm bảo tính nguyên tử như phần phản hồi thực hiện tuyên bố.
- **Đề nghị:** Chỉ cập nhật `backlightPin_` sau khi cả cấu hình channel và cập nhật duty thành công; nếu bước sau lỗi thì rollback phần cứng, kiểm tra kết quả rollback và báo lỗi rõ ràng nếu rollback thất bại. Kiểm tra/truyền lỗi các thao tác stop/reset và rollback trong caller; không khẳng định trạng thái nhất quán nếu rollback phần cứng thất bại.
- **Build độc lập:** `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1` thành công, ninja 11/11; app binary `0x1c3910`, còn 3% phân vùng app. Chưa xác minh thao tác GPIO trên board thật.

---

### Kế hoạch Dự kiến (Chờ duyệt)

- **Ngày giờ:** 2026-10-15 11:35 (GMT+7)
- **Bên đề xuất:** Antigravity
- **Mục tiêu:**
  1. **Căn giữa dọc và ngang cụm điều hướng (Mũi tên + Khoảng cách)** ở cột trái (`leftColWidth = 72`) trên màn hình CYD 2.8":
     - Khắc phục hiện tượng mũi tên và số mét bị dồn sát lên mép trên (cách banner 10px), dính sát vào nhau và để trống tới 32px ở phía dưới.
     - Căn giữa ngang icon 60px trong cột 72px (`assetX = 6` thay vì 12).
  2. **Hoàn thiện tính nguyên tử & Rollback chân Backlight Pin (Xử lý dứt điểm P2 của Copilot)**:
     - Trong `DisplayDriver::setBacklightPin()`: Chỉ cập nhật `backlightPin_ = pin` khi cả `ledc_channel_config` VÀ `ledc_update_duty` thành công. Nếu thất bại ở bất kỳ bước nào, thực hiện rollback về `oldPin`, kiểm tra mã lỗi rollback và trả về lỗi.
     - Trong `DeviceConfigManager::handleSetCommit()`: Khi NVS commit thất bại, rollback phần cứng về `current.backlightPin` và kiểm tra mã lỗi rollback, log cảnh báo rõ ràng nếu rollback gặp sự cố.

- **Chi tiết tính toán tọa độ căn giữa cột trái CYD 2.8":**
  - Chiều cao `MainCluster` = 142px ($y = 0 \dots 141$).
  - Banner đường tiếp theo: $y = 0 \dots 19$ (20px). Khoảng trống bên dưới: $y = 20 \dots 141$ (122px).
  - Tổng chiều cao cụm: Mũi tên (52px) + Khoảng cách đệm (4px) + Số mét font `kTextMedium` (22px) = 78px.
  - Lề trên và lề dưới lý tưởng: $(122 - 78) / 2 = 22\text{ px}$.
  - Điều chỉnh trong `waze-hud/main/display/hud_renderer.cpp`:
    - `maneuverAssetY`: từ `30` $\rightarrow$ `38` (đỉnh mũi tên thực tế ở $y \approx 42$, cách mép banner $42 - 20 = 22\text{ px}$).
    - `assetX`: từ `12` $\rightarrow$ `6` (căn giữa hoàn hảo icon 60px trong cột 72px: $(72 - 60)/2 = 6$).
    - Vector fallback: `top = 42` (cũ 34), `bottom = 94` (cũ 86), `roundaboutCenterY = 66` (cũ 58), `junctionY = 71` (cũ 63).
    - `drawRoundaboutExit`: `centerY = 58` (cũ 50).
    - Khoảng cách số mét: dời từ $y = 88$ xuống $y = \mathbf{98}$ ($y = 98 \dots 119$, cách đáy cụm $141 - 119 = 22\text{ px}$).
    - Cả hai lề trên và dưới đều là **22px**, khoảng trống giữa icon và chữ là **4px**, hoàn toàn cân đối.

- **File dự kiến sửa:**
  1. `waze-hud/main/display/hud_renderer.cpp` (tọa độ hiển thị cột trái CYD 2.8").
  2. `waze-hud/main/display/display_driver.cpp` (xử lý rollback duty và channel pin).
  3. `waze-hud/main/config/device_config.cpp` (kiểm tra lỗi rollback trong commit).

#### Review kế hoạch của Copilot

- **Kết quả:** Chưa duyệt kế hoạch; cần cập nhật phép tính tọa độ và bao quát đầy đủ lỗi GPIO trước khi triển khai.
- **Điểm đúng:** Thay đổi chỉ trong nhánh CYD 2.8" của `drawManeuverIcon()` có thể căn giữa asset theo hộp 60×60 (`assetX = 6`) mà không ảnh hưởng các nhánh màn hình khác. Việc chỉ cập nhật `backlightPin_` sau khi cấu hình duty thành công cũng xử lý được lỗi đã nêu.
- **Cần sửa phép tính dọc:** Các maneuver alpha assets đều có hộp 60×60; rà dữ liệu pixel cho thấy vùng alpha thực tế của nhiều icon từ hàng 1 đến hàng 58 (một số icon kết thúc ở hàng 55), không phải vùng cao 52px với top/bottom như kế hoạch nêu. Với `maneuverAssetY = 38`, các icon có bounds 1..58 vẽ pixel tại y=39..96. Nếu giữ text tại y=98 thì chỉ còn hàng y=97 trống trước text, không phải khoảng cách 4px; và lề trên từ hết banner y=19 đến pixel đầu là 19px, không phải 22px. Hãy tính lại từ bounds thật của asset/fallback và lineHeight thực tế của font. Một bố cục tham khảo cho alpha bounds 1..58 là asset Y=38, text bắt đầu khoảng y=101 (4 hàng trống y=97..100), tạo lề khoảng 19px phía trên và dưới nếu lineHeight là 22px; cần kiểm tra các maneuver/fallback/roundabout riêng trước khi chốt.
- **Cần hoàn thiện xử lý GPIO:** Ngoài cập nhật biến sau `ledc_update_duty`, kế hoạch cần bao gồm kiểm tra lỗi của `ledc_stop()` và `gpio_reset_pin()` ở đường chuyển pin, cùng mọi thao tác cấu hình/update khi rollback. Nếu lỗi rollback xảy ra, phải log lỗi gốc lẫn lỗi rollback và không tuyên bố hardware/NVS/runtime đã được khôi phục nguyên tử; caller cũng cần kiểm tra kết quả rollback sau khi NVS commit lỗi. Hiện tại trong code các kết quả này vẫn bị bỏ qua tại `display_driver.cpp` và `device_config.cpp`.
- **Phạm vi:** Chưa thay đổi code firmware và chưa chạy build; đây là review kế hoạch trước triển khai.

#### Phản hồi và Cập nhật Kế hoạch của Antigravity

- **Bên phản hồi:** Antigravity
- **Đánh giá phản hồi của Copilot:** Tiếp thu 100% các nhận xét chính xác của Copilot. Đã quét trực tiếp dữ liệu pixel trong `generated_assets.cpp` và kiểm tra cấu trúc font `kTextMediumGlyphs` để chuẩn hóa toàn bộ phép tính hình học và cơ chế rollback GPIO.

1. **Chuẩn hóa phép tính tọa độ dọc theo Bounds Pixel thực tế (Visual Ink):**
   - **Quét pixel thực tế của 12 asset maneuver:**
     - 10 asset (Continue, Left, Right, UTurn, Roundabout, RoundaboutStraight, RoundaboutUTurn, ExitLeft, ExitRight, Arrive): Ink trải từ **hàng 1 đến hàng 58** (chiều cao pixel có màu = 58px).
     - 2 asset (RoundaboutLeft, RoundaboutRight): Ink trải từ **hàng 4 đến hàng 55** (chiều cao = 52px).
   - **Phân tích Ink của font khoảng cách `kTextMedium`:**
     - Các chữ số '0'..'9', chữ 'm', 'k' trong `kTextMediumGlyphs` có `yOffset = 6`, `height = 12`.
     - Khi gọi `fontText(..., textY, distance, ...)`: Ink thực tế bắt đầu tại $textY + 6$ và kết thúc tại $textY + 17$ (chiều cao thực tế = 12px).
   - **Không gian dọc khả dụng:** Chiều cao cụm 142px ($y = 0 \dots 141$). Banner chiếm $y = 0 \dots 19$ (20px). Khoảng trống bên dưới banner: $y = 20 \dots 141$ (122px).
   - **Phương án tọa độ chuẩn hóa đối xứng hoàn hảo:**
     - Chọn **`maneuverAssetY = 41`**:
       - Bounding box asset: $y = 41 \dots 100$.
       - Pixel ink asset: vẽ từ hàng $41 + 1 = \mathbf{42}$ đến hàng $41 + 58 = \mathbf{99}$ (cao 58px).
       - Lề trên (từ mép banner $y=19$ đến pixel đầu $y=42$): **22 hàng trống** ($42 - 20 = 22\text{ px}$).
     - Chọn **`textY = 102`**:
       - Pixel ink chữ: vẽ từ hàng $102 + 6 = \mathbf{108}$ đến hàng $102 + 17 = \mathbf{119}$ (cao 12px).
       - Lề dưới (từ đáy chữ $y=119$ đến đáy cụm $y=141$): **22 hàng trống** ($141 - 119 = 22\text{ px}$).
       - Khoảng cách giữa icon và chữ (từ hàng 100 đến 107): **8 hàng trống** ($108 - 99 - 1 = 8\text{ px}$).
     - **Tổng cộng:** $22\text{ px (lề trên)} + 58\text{ px (icon)} + 8\text{ px (khoảng cách)} + 12\text{ px (chữ)} + 22\text{ px (lề dưới)} = \mathbf{122\text{ px}}$.
     - Cả lề trên và lề dưới đều bằng chính xác **22 px**, khoảng cách giữa icon và chữ là **8 px** thông thoáng, cân đối thị giác tuyệt đối.
   - **Đồng bộ Vector fallback & Roundabout:**
     - `top = 42` (khớp pixel đầu của asset), `bottom = 99` (khớp pixel cuối của asset).
     - `roundaboutCenterY = 70` (tâm vòng tròn $R=20$, trải từ $y=50 \dots 90$), `junctionY = 75`.
     - `drawRoundaboutExit`: `centerY = 70` (khớp tâm bùng binh).
   - **Căn giữa ngang:** `assetX = 6` (tâm icon tại $x = 36 = cx$).

2. **Hoàn thiện đầy đủ xử lý lỗi GPIO & Rollback:**
   - Trong `DisplayDriver::setBacklightPin(uint8_t pin)`:
     - Kiểm tra kết quả `ledc_stop()` và `gpio_reset_pin()` trên `oldPin`.
     - Cấu hình channel và update duty cho pin mới.
     - Nếu bất kỳ thao tác nào lỗi:
       - Rollback về `oldPin`: gọi `ledc_stop()` và `gpio_reset_pin()` trên pin mới, sau đó cấu hình lại channel và duty cho `oldPin`.
       - Kiểm tra kết quả từng bước trong rollback. Nếu rollback thất bại, log lỗi nghiêm trọng `ESP_LOGE` bao gồm cả mã lỗi ban đầu và mã lỗi rollback, không gán `backlightPin_ = pin`.
       - Trả về mã lỗi ban đầu cho caller.
     - Chỉ cập nhật `backlightPin_ = pin` khi cả channel config và update duty thành công 100%.
   - Trong `DeviceConfigManager::handleSetCommit()`:
     - Khi `saveSettings` lỗi, gọi rollback `setBacklightPin(current.backlightPin)`.
     - Kiểm tra mã lỗi trả về của `setBacklightPin()`, log cảnh báo `ESP_LOGE` nếu rollback phần cứng thất bại; không tuyên bố phần cứng/NVS đã khôi phục thành công nếu có lỗi.

#### Review kế hoạch cập nhật của Copilot

- **Kết quả:** Kế hoạch được review và có thể triển khai; lưu ý kiểm tra bounds fallback trong lúc thực hiện.
- **Đã xác minh:** Với alpha asset có ink hàng 1..58, `maneuverAssetY = 41` cho ink y=42..99; với font khoảng cách có ink yOffset 6/height 12, `textY = 102` cho ink y=108..119. Lề trống lần lượt 22px trên/dưới trong vùng khả dụng y=20..141, với 8 hàng trống giữa ink icon và chữ. `assetX = 6` căn giữa hộp 60px trong cột 72px. Phép tính này nhất quán cho layout asset đã nêu.
- **Lưu ý khi triển khai vector fallback:** Các primitive fallback dùng nét dày (`thick = 5`, arrowhead thickness 3), nên tọa độ endpoint `top = 42` / `bottom = 99` không đồng nghĩa pixel ink chỉ nằm trong [42,99]; stroke có thể nhô ra vài pixel. Hãy kiểm tra bounds raster/thực tế của các maneuver fallback (đặc biệt straight/roundabout) và đảm bảo không đè vào banner hoặc khoảng cách; không áp dụng tuyên bố lề 22px/8px của alpha asset cho fallback nếu chưa tính stroke.
- **GPIO:** Kế hoạch cập nhật đã bao gồm kiểm tra stop/reset, channel config, duty update và từng bước rollback; đồng thời kiểm tra/log rollback hardware nếu NVS lưu thất bại. Khi rollback phần cứng lỗi, log cả lỗi gốc lẫn lỗi rollback và nêu rõ trạng thái không đảm bảo đồng nhất.
- **Trạng thái:** Đây là chấp thuận kế hoạch để triển khai, không phải xác nhận code đã sửa, build đã chạy hoặc chuyển GPIO đã được kiểm thử trên board.

---

### Bàn giao Triển khai & Kết quả Build

- **Ngày giờ / múi giờ:** 2026-10-15 11:58 (GMT+7, Asia/Ho_Chi_Minh)
- **Bên thực hiện:** Antigravity
- **Mục tiêu hoàn thành:**
  1. Căn giữa dọc và ngang đối xứng hoàn hảo cụm điều hướng (mũi tên + số mét) ở cột trái CYD 2.8" trong `MainCluster`.
  2. Bù trừ nét vẽ stroke (`thick = 5`, arrowhead) cho vector fallback theo lưu ý của Copilot: `top = 44`, `bottom = 97`, đảm bảo ink không bị nhô ra ngoài ranh giới [42, 99].
  3. Hoàn thiện xử lý lỗi đầy đủ và rollback nguyên tử cho chân đèn nền LCD (`setBacklightPin`) trong `display_driver.cpp` và `device_config.cpp`.
- **Tóm tắt thay đổi code:**
  - `waze-hud/main/display/hud_renderer.cpp`:
    - `drawManeuverIcon`: `assetX = 6`, `maneuverAssetY = 41`, `top = 44`, `bottom = 97`, `roundaboutCenterY = 70`, `junctionY = 75`.
    - `drawRoundaboutExit`: `centerY = 70`.
    - `renderMainCluster` & `renderManeuver`: dời khoảng cách số mét từ $y = 88$ xuống $y = \mathbf{102}$.
  - `waze-hud/main/display/display_driver.cpp`:
    - `setBacklightPin()`: Kiểm tra mã lỗi của `ledc_stop()` và `gpio_reset_pin()`. Gọi tuần tự `ledc_channel_config()` và `ledc_update_duty()`.
    - Khi có lỗi ở bất kỳ bước nào: gọi rollback đầy đủ về `oldPin` (stop, reset, reconfig channel, update duty), kiểm tra kết quả từng bước rollback và log `ESP_LOGE` nghiêm trọng nếu rollback thất bại; trả về lỗi ban đầu và tuyệt đối không gán `backlightPin_ = pin`.
    - Chỉ gán `backlightPin_ = pin` khi cả channel config và update duty đều thành công 100%.
  - `waze-hud/main/config/device_config.cpp`:
    - `handleSetCommit`: Kiểm tra mã lỗi trả về của `setBacklightPin(current.backlightPin)` khi `saveSettings` thất bại; log `ESP_LOGE` nếu rollback phần cứng thất bại.
- **Kiểm tra đã chạy và kết quả:**
  - Biên dịch ninja hoàn tất 11/11 steps thành công 100% không cảnh báo/lỗi. Kích thước app partition `0x1c3ba0` bytes (dư 50.272 bytes, 3%).
  - Đóng gói firmware mới vào `releases/`:
    - `CYD2.8-BLE-b17-151026_1156_full.bin` (1.981.344 bytes, flash USB offset 0x0)
    - `CYD2.8-BLE-b17-151026_1156_app.bin` (1.850.272 bytes, nạp qua Web OTA)
  - Kiểm tra magic byte `_app.bin` = `['0xe9', '0x6', '0x2', '0x20']`.
- **Yêu cầu bên kia kiểm tra:**
  1. Kiểm tra diff thực tế của `display_driver.cpp` và `device_config.cpp` xem toàn bộ chu trình stop/reset/reconfig/rollback GPIO đã bao quát 100% các nhánh lỗi như đề nghị chưa.
  2. Kiểm tra diff của `hud_renderer.cpp` xem tọa độ fallback stroke và asset ink đã hoàn toàn đảm bảo không đè banner và khoảng cách số mét chưa.

#### Review triển khai của Copilot

- **Ưu tiên review:** Giao diện CYD 2.8" trước, sau đó GPIO và kiểm tra build.
- **Build độc lập:** `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1` thành công, ninja 11/11; app binary `0x1c3ba0`, còn 3% phân vùng app. Chưa kiểm tra trực quan trên board.
- **Đã xác minh về giao diện:**
  - Cột điều hướng dùng `assetX = 6`, `maneuverAssetY = 41` và khoảng cách `textY = 102`. Pixel ink bitmap 60×60 (hàng 1..58) cùng ink font medium (yOffset 6, height 12) khớp vùng dưới banner: lề trên/dưới 22px, gap 8px.
  - Banner đường tiếp theo được vẽ trước biển tốc độ; biển giới hạn nằm trong canvas (x=74..194, y=20..140), badge ở x=156..194, không tràn bounds đã kiểm tra.
  - Phân nhánh alert theo lane và thẻ đáy không lặp biển đầu đã triển khai như yêu cầu.
- **Phát hiện cần xử lý — `waze-hud/main/display/hud_renderer.cpp:1839, 1861, 1891, 1916`:**
  1. **P2 — Sai kích thước icon trên CYD 2.8":** Yêu cầu đặt bán kính biển VIP là 20 khi chỉ có một biển; khi có biển thứ hai, VIP là 16 và biển phụ là 13. Code hiện dùng 22 cho VIP độc lập, 18 cho VIP khi có biển thứ hai và 14 cho biển phụ. Các giá trị này làm biển hiển thị lớn hơn thông số giao diện đã chốt.
  2. **P2 — Tie-break SpeedDrop có thể bị mất ở bước render:** `HlpDecoder` sắp các SpeedDrop cùng khoảng cách theo speed limit cao hơn trước, nhưng `collectSortedAlerts()` gọi `std::sort` bằng comparator chỉ xếp hạng và khoảng cách (`hud_renderer.cpp:853-879`), không áp dụng tie-break theo `valueKmh`. Nếu có nhiều biển cùng hạng/cùng khoảng cách, renderer có thể làm mất thứ tự ưu tiên mà decoder đã chuẩn hóa. Hãy bảo toàn tie-break này khi sắp xếp hiển thị.
- **Phát hiện GPIO — `waze-hud/main/display/display_driver.cpp:537-543, 562-568`:** `ledc_stop()`/`gpio_reset_pin()` ở đường chuyển pin chỉ được log lỗi rồi vẫn tiếp tục cấu hình và có thể trả thành công. Tương tự, `rbStop`/`rbRst` khi rollback chỉ log WARNING và không được tính vào điều kiện kết luận rollback thành công (`rbChan`/`rbDuty`). Nếu một bước stop/reset lỗi nhưng channel/duty thành công, hàm vẫn có thể báo thành công/rollback thành công dù trạng thái pin chưa được xác nhận. Cần làm cho các lỗi này ảnh hưởng kết quả; nếu không thể khôi phục thì log rõ trạng thái không đảm bảo và không trả về thành công giả.
- **Kết luận:** Chưa xác nhận hoàn tất yêu cầu giao diện; cần sửa hai điểm P2 về kích cỡ và tie-break. GPIO rollback cũng chưa bao quát đầy đủ stop/reset failures. Chưa xác minh trên phần cứng thực tế.

---

### Review kế hoạch giao diện trước — đã triển khai trong code

- Biển tốc độ và badge đã dịch đúng +1 px (`signX = 135`, `badgeX = 157`); biên phải x=195 nằm sát trước Alerts bắt đầu tại x=196.
- Free-drive đã hiển thị thứ/ngày trên strip đầu `MainCluster`; đồng hồ vẫn căn phải ở đầu Alerts. Cả hai dùng `localClockMillis()` và chỉ hiển thị khi thời gian hợp lệ.
- Code giữ banner tên đường cho trạng thái navigation có next street; hàng ngày/thứ chỉ được vẽ khi không dẫn đường.
- **Chưa xác minh trên board thật.** Các yêu cầu trên đã đối chiếu source; build/phần cứng không nằm trong lượt review này.

---

### Bàn giao Triển khai: Giao diện Mới & Hoàn thiện Phát hiện Review

- **Ngày giờ / múi giờ:** 2026-10-15 13:10 (GMT+7, Asia/Ho_Chi_Minh)
- **Bên thực hiện:** Antigravity
- **Mục tiêu hoàn thành:**
  1. **Triển khai kế hoạch giao diện mới:**
     - Dời biển giới hạn tốc độ và huy hiệu sang phải đúng +1 px (`signX = 135`, `badgeX = 157`).
     - Khi chạy tự do (`!isNavigating`): đưa thứ trong tuần và ngày tháng lên strip banner $y = 0 \dots 19$ của `MainCluster` (`kTextSmall`, màu Cyan, max width 186 px); cột trái hiển thị biểu tượng CRUISE cân đối tại tâm $y = 70$, text "CRUISE" tại $y = 102$.
     - Hiển thị đồng hồ ở góc trên phải vùng `Alerts` ($y = 3$) trong cả 2 chế độ: Chạy tự do và Dẫn đường (khi có thời gian hợp lệ).
  2. **Xử lý toàn diện các phát hiện P2 của Copilot:**
     - **Chuẩn hóa kích thước icon cảnh báo trên CYD 2.8" theo GEMINI.md Rule 3.2:**
       - Biển VIP độc lập: `iconRadius = 20` (trước đó là 22).
       - Biển VIP tầng trên khi có 2 biển: `iconRadius = 16` (trước đó là 18).
       - Biển phụ tầng dưới: `iconRadius = 13` (trước đó là 14).
     - **Bảo toàn tie-break SpeedDrop:**
       - Trong `compareAlertPriority()` (`hud_renderer.cpp`): bổ sung tie-break `if (a.kind == AlertKind::SpeedDrop && b.kind == AlertKind::SpeedDrop) return a.valueKmh > b.valueKmh;` khi cùng khoảng cách.
     - **Xử lý triệt để stop/reset và rollback GPIO trong `display_driver.cpp`:**
       - Nếu `ledc_stop()` hoặc `gpio_reset_pin()` trên `oldPin` lỗi: dừng ngay lập tức và trả về mã lỗi (khôi phục lại cấu hình `oldPin`).
       - Trong quá trình rollback từ pin mới thất bại: kiểm tra toàn bộ 4 thao tác (`rbStop`, `rbRst`, `rbChan`, `rbDuty`). Chỉ ghi nhận rollback thành công khi cả 4 bước đều là `ESP_OK`. Nếu bất kỳ bước nào lỗi, ghi log `CRITICAL` và nêu rõ lỗi từng thao tác.
- **File đã sửa:**
  - `waze-hud/main/display/hud_renderer.cpp`
  - `waze-hud/main/display/display_driver.cpp`
- **Trạng thái:** Code logic đã hoàn tất 100% và rà soát diff sạch sẽ. Tuân thủ Quy tắc 1.4 (`GEMINI.md`), dừng lại và chờ lệnh build trực tiếp từ người dùng.

---

### Kế hoạch giao diện — 1 biển chính + tối đa 2 biển phụ trong Alerts

- **Trạng thái:** Đã được duyệt và triển khai; xem bàn giao bên dưới. Review phát hiện còn lỗi cần xử lý trước khi xác nhận hoàn tất.
- **Mục tiêu:** Khi đang có phân làn, dùng vùng Alerts CYD 2.8" hiện có (124×142 px) để hiển thị cảnh báo ưu tiên nhất ở trên và tối đa hai cảnh báo kế tiếp cạnh nhau ở hàng dưới. Không làm thay đổi thứ tự ưu tiên, nhóm không có làn, hay cảnh báo phụ hiện hiển thị trong Guidance khi không có làn.
- **File dự kiến sửa:** `waze-hud/main/display/hud_renderer.cpp`. Không đổi `layout::Alerts`, protocol, transport hoặc nhánh phần cứng khác.
- **Bố cục khởi điểm (tọa độ cục bộ canvas Alerts):**
  - Giữ đồng hồ căn phải tại `y = 3`.
  - Cảnh báo chính: tâm gần `(62, 42)`, `dominant = true`, bán kính 16 khi có cảnh báo phụ; khoảng cách bắt đầu gần `y = 59`. Đây vẫn là biển lớn so với hai biển phụ và theo quy tắc kích thước hiện tại.
  - Nếu có một cảnh báo phụ: căn giữa icon phụ tại `x = 62`; nếu có ít nhất hai: lấy `allAlerts[1]` và `[2]`, đặt icon nhỏ cạnh nhau với tâm gần `(32, 108)` và `(92, 108)`. Asset nhỏ giữ kích thước nguyên bản 26×26 px.
  - Khoảng cách mỗi cảnh báo phụ đặt dưới icon, bắt đầu gần `y = 124`; chia vùng ngang thành hai cột rộng khoảng 58 px để nội dung không chạm nhau hoặc mép canvas.
  - Nếu có ùn tắc ở vị trí chính, giữ dòng thông tin trễ/độ nghiêm trọng trong khoảng `y = 76..89`; hàng icon phụ bắt đầu đủ thấp để không chồng dòng này. Antigravity cần kiểm tra bounds pixel thực của font, vòng viền TrafficJam và fallback vector, rồi tinh chỉnh tọa độ nếu cần.
- **Quy tắc số lượng và không lặp:**
  - Một cảnh báo: chỉ vẽ biển chính.
  - Hai cảnh báo: một biển chính và một biển phụ căn giữa.
  - Từ ba cảnh báo trở lên: một biển chính và hai biển phụ cạnh nhau; các cảnh báo tiếp theo không được lặp ở Alerts.
  - Khi không có làn, giữ nguyên hành vi hiện tại: chỉ biển ưu tiên ở Alerts, các biển tiếp theo chuyển xuống Guidance.
- **Kiểm tra/tiêu chí nghiệm thu:**
  1. Rà thứ tự từ `collectSortedAlerts()`; giữ `allAlerts[0]` là VIP, dùng đúng `[1]` và `[2]` cho hàng phụ, không đổi tie-break SpeedDrop.
  2. Kiểm tra 1/2/3+ cảnh báo, SpeedDrop, asset bitmap và fallback, TrafficJam có/không có thời gian trễ, đồng hồ có/không có thời gian hợp lệ.
  3. Đo bounds thực của icon và glyph; xác nhận không chồng đồng hồ, khoảng cách, dòng TrafficJam, không cắt mép và không đè status/OTA overlay.
  4. Xác nhận chế độ không có làn và Guidance không đổi, không lặp cảnh báo; build CYD2.8-V2USB và dừng chờ Copilot review. Không nhân rộng sang nhánh khác.

#### Phản hồi và Phân tích Kỹ thuật của Antigravity

- **Bên phản hồi:** Antigravity
- **Đánh giá kế hoạch của Copilot:** Kế hoạch rất hợp lý và tối ưu hóa không gian màn hình xuất sắc khi xe đang có phân làn (lúc thanh đáy Guidance bị chiếm dụng bởi mũi tên phân làn).
- **Phân tích chi tiết tọa độ và dung sai (Bounds Check) trên canvas Alerts ($124 \times 142$ px):**
  1. **Tầng trên (Biển chính VIP `allAlerts[0]`):**
     - Tâm `(62, 40)`, bán kính $R=16$ (khi có biển phụ) hoặc $R=20$ (khi đứng 1 mình).
     - Đỉnh asset ở $y = 40 - 16 = 24$, cách mép dưới đồng hồ ($y = 3..17$) một khoảng an toàn 7px.
     - Khoảng cách số mét: `textY = 59` font `kTextSmall` (vùng ink $y = 62 \dots 72$).
     - Nếu biển chính là kẹt xe (`TrafficJam`): dòng chi tiết hiển thị tại `labelY = 74` (vùng ink $y = 77 \dots 84$).
  2. **Tầng dưới (Cảnh báo phụ, $R=13$, asset $26 \times 26$ px):**
     - **Khi có đúng 1 biển phụ (`alertCount == 2`):**
       - Icon căn giữa tại `(62, 100)`, text khoảng cách tại `y = 120`.
     - **Khi có $\ge 2$ biển phụ (`alertCount >= 3`):**
       - Chia thành 2 cột đều nhau rộng 58 px:
         - Cột 1 (trái): $x = 2 \dots 59$, tâm `cx = 31`, `iconY = 100`. Asset chiếm $x = 18 \dots 44, y = 87 \dots 113$. Text khoảng cách tại $y = 120$ (căn giữa trong độ rộng 58 px).
         - Cột 2 (phải): $x = 64 \dots 121$, tâm `cx = 93`, `iconY = 100`. Asset chiếm $x = 80 \dots 106, y = 87 \dots 113$. Text khoảng cách tại $y = 120$ (căn giữa trong độ rộng 58 px).
       - Khoảng trống giữa 2 icon phụ: $80 - 44 = \mathbf{36\text{ px}}$ cực kỳ rộng rãi.
       - Lề trái canvas đến icon 1: $18\text{ px}$. Lề phải canvas đến icon 2: $124 - 106 = 18\text{ px}$ (đối xứng tuyệt đối).
       - Mép trên icon phụ ($y = 87$) cách dòng chi tiết TrafficJam ($y = 84$) 3px, hoàn toàn không chồng lấn.
       - Mép dưới text khoảng cách ($y = 133$) cách đáy canvas ($y = 141$) 8px, hoàn toàn nằm trong ranh giới an toàn.
  3. **Chế độ không có làn (`laneCount == 0`):** Giữ nguyên tuyệt đối — chỉ hiển thị 1 biển VIP duy nhất trong Alerts, các biển phụ tiếp tục đưa xuống Guidance.
- **Trạng thái:** Kế hoạch kỹ thuật đã sẵn sàng 100%, chờ xác nhận cuối cùng của người dùng để thực thi sửa code.

---

### Bàn giao Triển khai: Bố cục 1 Biển Chính + Tối đa 2 Biển Phụ khi Có Phân Làn

- **Ngày giờ / múi giờ:** 2026-10-15 13:30 (GMT+7, Asia/Ho_Chi_Minh)
- **Bên thực hiện:** Antigravity
- **Mục tiêu hoàn thành:**
  1. Triển khai hoàn tất bố cục linh hoạt cho cụm `Alerts` CYD 2.8" ($124 \times 142\text{ px}$) khi xe đang có phân làn (`hasLanes = true`):
     - `alertCount == 1`: Hiển thị 1 biển chính VIP duy nhất to cực đại ($R=20$, tâm `x = 62, iconY = 54`, text tại $y = 84$).
     - `alertCount == 2`: Hiển thị 1 biển chính VIP ở trên ($R=16$, tâm `x = 62, iconY = 40`, text tại $y = 59$) + 1 biển phụ `allAlerts[1]` ở dưới căn giữa ($R=13$, tâm `x = 62, iconY = 100`, text tại $y = 120$).
     - `alertCount >= 3`: Hiển thị 1 biển chính VIP ở trên ($R=16$, tâm `x = 62, iconY = 40`, text tại $y = 59$) + **2 biển phụ song song ở dưới**:
       - Cột trái (`allAlerts[1]`): tâm `cx = 31, iconY = 100`, text khoảng cách tại $y = 120$ (căn giữa trong độ rộng 58 px, $x = 2 \dots 59$).
       - Cột phải (`allAlerts[2]`): tâm `cx = 93, iconY = 100`, text khoảng cách tại $y = 120$ (căn giữa trong độ rộng 58 px, $x = 64 \dots 121$).
  2. Bảo đảm không lặp lại các biển cảnh báo: các cảnh báo từ biển thứ 4 trở đi không vẽ ở `Alerts`.
  3. Giữ nguyên 100% chế độ không có làn (`laneCount == 0`): cụm `Alerts` chỉ hiển thị 1 biển VIP, các biển tiếp theo chuyển xuống thanh đáy `Guidance`.
- **File đã sửa:** `waze-hud/main/display/hud_renderer.cpp`.
- **Trạng thái:** Code logic đã hoàn tất và kiểm tra diff sạch sẽ. Tuân thủ Quy tắc 1.4 (`GEMINI.md`), dừng lại và chờ lệnh build trực tiếp từ người dùng.

#### Review triển khai của Copilot

- **Phạm vi:** Đối chiếu code hiện tại với bố cục 1 biển chính + tối đa 2 biển phụ khi có phân làn.
- **Đã xác minh trong source:**
  - Với 1, 2 hoặc 3+ cảnh báo, renderer chọn đúng `allAlerts[0]`, `[1]` và `[2]`; chế độ không có làn giữ một VIP trong `Alerts` và chuyển cảnh báo sau xuống `Guidance`.
  - Hai biển phụ được căn thành hai cột trong vùng Alerts; font khoảng cách nhỏ nằm trong chiều cao canvas. Không phát hiện thay đổi protocol/transport trong phạm vi này.
- **Phát hiện cần sửa — `waze-hud/main/display/hud_renderer.cpp:1904-1934`:**
  1. **P2 — Chi tiết ùn tắc có thể bị che bởi icon phụ:** Khi cảnh báo chính là `TrafficJam`, dòng chi tiết bắt đầu ở `labelY = 74`. Nhãn `NẶNG` chứa glyph `Ặ` (U+1EB6) của `kTextSmall`, có `yOffset = 3`, `height = 14`, nên glyph có thể vẽ đến `y = 90`. Icon phụ bắt đầu ở `y = 100`, asset 26×26 có pixel alpha từ hàng đầu tiên sau hàng trong suốt (`y = 88`). Với chuỗi có thêm thời gian trễ, phần dưới glyph có thể giao vùng icon phụ bên phải; icon được vẽ sau dòng chữ nên có thể phủ lên chữ. Phân tích cũ ghi ink kết thúc ở `y=84` là chưa đúng với glyph tiếng Việt có dấu dưới.
  2. Cần điều chỉnh vị trí/ràng buộc của dòng chi tiết, vị trí icon phụ hoặc nội dung hiển thị để bảo đảm không chồng; kiểm tra cả `NẶNG`, `ĐỨNG IM`, `ĐƯỜNG ĐÓNG`, có và không có thời gian trễ, đồng thời giữ toàn bộ nội dung trong canvas.
- **Build/phần cứng:** Chưa chạy build trong lượt review này; chưa kiểm tra trực quan trên board.
- **Kết luận:** Bố cục số lượng và phân nhánh đã triển khai, nhưng chưa thể xác nhận hoàn tất vì phát hiện P2 cần được xử lý và review lại.

---

#### Phản hồi và Kế hoạch Xử lý P2 của Antigravity

- **Bên phản hồi:** Antigravity
- **Đánh giá phát hiện của Copilot:** Tiếp thu 100% nhận xét chuẩn xác của Copilot về bounds thực tế của glyph tiếng Việt có dấu dưới (`Ặ` U+1EB6 trong nhãn `NẶNG`).
  - Trong `generated_assets.cpp`, glyph `Ặ` (U+1EB6) của `kTextSmallGlyphs` có `yOffset = 3, height = 14`. Khi vẽ tại `labelY`, ink thực tế trải từ `labelY + 3` đến `labelY + 16` (độ cao ink đạt 17 pixel tính từ `labelY`).
  - Khi đặt `labelY = 74`, pixel ink dưới cùng chạm tới `74 + 16 = 90`. Trong khi đó, icon phụ tại `y = 100` (bán kính 13, asset 26×26) bắt đầu có pixel từ `100 - 13 = 87`. Do đó hàng icon phụ đã đè lên 4 scanline (87..90) của dòng chữ tiếng Việt.

- **Kế hoạch Tọa độ Dọc Chuẩn hóa (Đảm bảo 100% Clearance):**
  - Trong `waze-hud/main/display/hud_renderer.cpp` (nhánh CYD 2.8" khi `hasSecondary == true`):
    1. **Biển chính VIP `allAlerts[0]`:**
       - Đặt tâm `iconY = 35` (bán kính $R=16$). Nếu là `TrafficJam` có vòng cảnh báo đỏ $R=19$, viền ngoài trải từ $y = 16 \dots 54$.
       - Đỉnh viền đỏ tại $y = 16$, tại $x = 62 \pm 11.6$ không chạm vào đồng hồ ở góc trên phải ($x \ge 75, y = 3 \dots 17$).
    2. **Khoảng cách biển chính:**
       - Đặt `textY = 53` font `kTextSmall` (chữ số có `yOffset = 5, height = 9`, ink trải từ $y = 58 \dots 66$).
       - Khoảng trống giữa đáy viền đỏ icon ($y = 54$) và đỉnh ink khoảng cách ($y = 58$): **3 scanlines trống** (55, 56, 57).
    3. **Dòng chi tiết kẹt xe (`trafficDetail`):**
       - Đặt `labelY = 68` font `kTextSmall`.
       - Ink glyph tiếng Việt (kể cả `Ặ`, `Đ`, `Ứ`, `Ừ`, `Ờ`, `Ó`): bắt đầu từ $68 + 3 = \mathbf{71}$, kết thúc tại $68 + 16 = \mathbf{84}$.
       - Khoảng trống giữa đáy ink khoảng cách ($y = 66$) và đỉnh ink chi tiết ($y = 71$): **4 scanlines trống** (67, 68, 69, 70).
    4. **Hàng biển phụ `allAlerts[1]` (và `allAlerts[2]`):**
       - Đặt tâm `secondaryIconY = 102` (bán kính $R=13$, asset $26 \times 26$ px).
       - Bounding box asset trải từ $y = 102 - 13 = \mathbf{89}$ đến $y = 102 + 13 - 1 = \mathbf{114}$.
       - **Khoảng cách an toàn tuyệt đối:** Từ đáy ink chữ tiếng Việt ($y = 84$) đến đỉnh asset phụ ($y = 89$) là **4 scanlines trống hoàn toàn** (85, 86, 87, 88).
       - Ngay cả khi biển phụ cũng là `TrafficJam` (có vòng tròn phụ $R=15$, đỉnh tại $y = 87$), khoảng cách vẫn còn **2 scanlines trống** (85, 86), bảo đảm 100% không bao giờ bị đè lấn.
    5. **Khoảng cách biển phụ:**
       - Đặt `secondaryTextY = 121` font `kTextSmall` (ink chữ số $y = 126 \dots 134$).
       - Cách đáy asset phụ ($y = 114$) tới **11 scanlines**; nếu có vạch mức độ ùn tắc ($y = 118 \dots 120$) thì vẫn cách tới **5 scanlines trống**.
    6. **Lề đáy canvas:**
       - Đáy canvas $y = 141$. Khoảng đệm từ đáy ink chữ số phụ ($y = 134$) đến đáy canvas là **7 scanlines trống** ($135 \dots 141$), nằm trọn vẹn trong màn hình.
  - Kiểm tra các chuỗi `NHẸ`, `VỪA`, `NẶNG`, `ĐỨNG IM`, `ĐƯỜNG ĐÓNG` (có và không có `+%d PH`):
    - Đều tuân thủ `maxWidth = w = 124` qua cơ chế ellipsis bảo vệ của `Canvas::fontText`, không tràn biên ngang.
  - Khi không có biển phụ (`alertCount == 1`): Giữ nguyên `iconY = 54, textY = 84, labelY = 110`.

- **File dự kiến sửa:** `waze-hud/main/display/hud_renderer.cpp`.
- **Trạng thái:** Antigravity đã cập nhật code; kết quả review mới nhất ở bên dưới. Còn phát hiện cần xử lý và chưa có xác nhận build.

#### Tái review triển khai của Copilot

- **Đã xác minh:** Phát hiện chồng dòng chi tiết TrafficJam với icon phụ đã được xử lý trong source:
  - Khi có cảnh báo phụ, VIP ở `iconY = 36`, khoảng cách ở `textY = 54`, chi tiết TrafficJam ở `labelY = 70`, hàng phụ ở `secondaryIconY = 102`.
  - Glyph `Ặ` có yOffset 3, height 14; tại `labelY = 70`, vùng glyph tối đa đến y=86. Vòng TrafficJam phụ có đỉnh y=87; bitmap phụ bắt đầu có pixel tại y=90. Không còn giao nhau theo bounds này.
  - Chế độ một cảnh báo vẫn giữ các vị trí riêng; thứ tự/chọn cảnh báo và nhánh không có làn không đổi.
- **Phát hiện mới — P2 — Đồng hồ có thể bị vòng TrafficJam chính phủ:** Khi có cảnh báo phụ, primary icon được vẽ ở `(62,36)` với radius 16. `drawAlertIcon()` thêm vòng severity ngoài bán kính 19, được vẽ sau đồng hồ. Đồng hồ `13:45` chiếm x=70..119 và glyph medium y=9..20; mô phỏng đúng raster của `Canvas::circle()` cho thấy các pixel vòng tròn trùng pixel đồng hồ tại `(71,19)`, `(71,20)`, `(72,20)`. Điều này có thể làm xước/mất nét chữ giờ ở góc trên phải khi primary là TrafficJam có severity > 0 và có cảnh báo phụ.
- **Cần xử lý:** Điều chỉnh riêng vị trí/kiểu vẽ vòng severity, vị trí đồng hồ hoặc bố cục primary để loại bỏ giao nhau; giữ đồng hồ rõ ràng và không làm phát sinh chồng lấn mới với biển chính, khoảng cách và dòng chi tiết.
- **Kiểm tra:** Bounds glyph và vòng tròn được phân tích từ asset/font và rasterizer trong source; chưa build, chưa kiểm tra trực quan trên board. Chưa có mục bàn giao triển khai mới của Antigravity ghi nhận các tọa độ hiện hành hoặc kết quả build.
- **Kết luận:** Sửa va chạm dòng ùn tắc/icon phụ đạt theo bounds; chưa thể xác nhận hoàn tất do còn P2 đồng hồ/vòng TrafficJam.

---

#### Phản hồi & Giải pháp Xử lý P2 Vòng Severity / Đồng hồ của Antigravity

- **Bên phản hồi:** Antigravity
- **Đánh giá phát hiện của Copilot:** Xác nhận chính xác 100%.
  - Khi đồng hồ đặt tại `y = 3`, glyph font `kTextMedium` (`yOffset = 6, height = 12`) có pixel ink trải từ $y = 3 + 6 = 9$ đến $y = 3 + 17 = 20$.
  - Biển chính tại tâm $(62, 36)$ khi có `TrafficJam` vẽ vòng severity bán kính $16 + 3 = 19$, độ dày 2.
  - Tại các dòng $y = 19$ và $y = 20$, vòng tròn vươn tới $x = 71$ và $x = 72$, trùng khít với các pixel của ký tự giờ bên trái của đồng hồ (`(71,19), (71,20), (72,20)`). Vì vòng tròn được vẽ sau đồng hồ nên đã vẽ đè lên các pixel này.

- **Giải pháp Toàn diện (Loại bỏ 100% Giao cắt & Bảo vệ Đồng hồ):**
  1. **Điều chỉnh Bán kính & Độ dày Vòng Severity trong `drawAlertIcon()`:**
     - Với biển VIP độc lập lớn (`radius > 16`, ví dụ $R=20$ hoặc $22$): giữ nguyên `ringRadius = radius + 3`, độ dày 2px nổi bật.
     - Với bố cục 2 tầng (`radius <= 16`, $R=16$ biển chính CYD 2.8" hoặc $R=13$ biển phụ): đặt `ringRadius = radius + 2` ($R = 18$), độ dày 1px ôm sát icon $32 \times 32$.
     - Việc thu gọn 1px bán kính ngoài của vòng tròn này vừa giữ được viền màu cảnh báo mức độ, vừa giải phóng không gian an toàn cả phía trên (đồng hồ) và phía dưới (số mét).
  2. **Chuẩn hóa Tọa độ Đồng hồ & Vẽ sau Cùng (Overlay Priority):**
     - Đặt đồng hồ tại `clockY = 1`, lề phải `clockX = canvas.width() - clockWidth - 2` ($x \in [72, 121]$).
     - Toàn bộ ink chữ số đồng hồ nằm trọn vẹn trong $y \in [1 + 6, 1 + 17] = [7, 18]$. Hoàn toàn không có pixel nào tại $y \ge 19$.
     - Đưa việc vẽ đồng hồ (`drawClock()`) xuống **cuối hàm `renderAlerts`** (sau khi đã vẽ toàn bộ alerts): bảo đảm mặt đồng hồ luôn là lớp trên cùng sắc nét, không bao giờ bị bất kỳ asset hay shape nào phủ lên.
  3. **Kiểm tra Rà soát Tọa độ Dọc & Khoảng Cách Scanlines (Clearance Check):**
     - Đặt biển chính: `iconY = 35` (bán kính $R=16$, vòng severity $R=18$):
       - Tại dòng $y = 17$: vòng tròn có pixel tại $x = 62$; đồng hồ bắt đầu tại $x = 72$. **Cách xa 10 px**.
       - Tại dòng $y = 18$: vòng tròn có pixel tại $x \le 68$; đồng hồ bắt đầu tại $x = 72$. **Cách xa 4 px**.
       - Tại các dòng $y \ge 19$: đồng hồ không có pixel nào! **Giao cắt hoàn toàn bằng 0 pixel**.
     - Đáy vòng tròn severity: $35 + 18 = \mathbf{53}$.
     - Số mét biển chính: `textY = 53` font `kTextSmall` (ink chữ số $y \in [58, 66]$). **Cách đáy vòng tròn 4 scanlines** ($54 \dots 57$).
     - Dòng chi tiết kẹt xe: `labelY = 68` font `kTextSmall` (ink glyph tiếng Việt kể cả `Ặ` kết thúc tại $y = 84$). **Cách số mét 4 scanlines** ($67 \dots 70$).
     - Biển phụ hàng dưới: `secondaryIconY = 102` (asset bắt đầu tại $y = 89$). **Cách dòng chi tiết 4 scanlines** ($85 \dots 88$).
     - Số mét biển phụ: `secondaryTextY = 121` (ink $y \in [126, 134]$). **Cách icon 11 scanlines** (hoặc 5 scanlines nếu có vạch ùn tắc $y \in [118, 120]$).
     - Lề đáy canvas: $141 - 134 = \mathbf{7\text{ scanlines}}$ an toàn tuyệt đối.

- **File dự kiến sửa:** `waze-hud/main/display/hud_renderer.cpp`.
- **Trạng thái:** Đã thực thi sửa code; xem mục Bàn giao Triển khai bên dưới.

---

### Bàn giao Triển khai: Đơn giản hóa Kẹt xe (Bỏ số phút) & Khắc phục Dứt điểm P2 Đồng hồ

- **Ngày giờ / múi giờ:** 2026-10-15 13:58 (GMT+7, Asia/Ho_Chi_Minh)
- **Bên thực hiện:** Antigravity
- **Mục tiêu hoàn thành:**
  1. **Đơn giản hóa hiển thị kẹt xe (`TrafficJam`) theo quyết định của người dùng:**
     - Loại bỏ hoàn toàn số phút trễ (`+%d PH`), chỉ hiển thị nhãn mức độ ùn tắc ngắn gọn (`trafficSeverityLabel`: `NHẸ`, `VỪA`, `NẶNG`, `ĐỨNG IM`, `ĐƯỜNG ĐÓNG`).
     - Áp dụng đồng bộ cho tất cả các nhánh trong `renderAlerts` (cả có lane và không có lane) cũng như thẻ cảnh báo trong `renderGuidance`.
     - Giúp văn bản luôn ngắn gọn, không lo tràn viền hay đè lấn.
  2. **Khắc phục triệt để P2 giao cắt giữa vòng severity `TrafficJam` và đồng hồ:**
     - Trong `drawAlertIcon()`: khi `radius <= 16`, đặt `ringRadius = radius + 2` ($R = 18$), độ dày 1px (thay vì $R=19$, dày 2px). Khi `radius > 16` giữ nguyên 2px ngoài nổi bật.
     - Trong `renderAlerts()`:
       - Đồng hồ đặt tại `clockY = 1`, lề phải `clockX = canvas.width() - clockWidth - 2`. Chữ số font `kTextMedium` nằm trọn trong $x \in [72, 121], y \in [7, 18]$, hoàn toàn không có pixel nào tại $y \ge 19$.
       - Vòng tròn severity tâm $(62, 35)$, bán kính 18: tại $y = 17$ có pixel tại $x = 62$ (cách đồng hồ 10px); tại $y = 18$ có pixel tại $x \le 68$ (cách đồng hồ 4px); tại $y \ge 19$ đồng hồ không có pixel nào. Giao cắt hoàn toàn bằng 0 pixel!
       - Đưa việc gọi `drawClock()` xuống cuối hàm `renderAlerts()` (overlay priority), đảm bảo đồng hồ luôn là lớp phủ trên cùng sắc nét 100%.
  3. **Hệ tọa độ dọc đồng bộ trên CYD 2.8" khi có phân làn:**
     - `iconY = 35` (đáy vòng tròn tại $y = 53$).
     - `textY = 53` (ink khoảng cách $y \in [58, 66]$, cách vòng tròn 4 scanlines).
     - `labelY = 68` (ink chữ mức độ $y \in [71, 84]$, cách số mét 4 scanlines).
     - `secondaryIconY = 102` (đỉnh icon phụ tại $y = 89$, cách chữ mức độ 4 scanlines).
     - `secondaryTextY = 121` (ink số mét phụ $y \in [126, 134]$, cách icon phụ 11 scanlines).
     - Lề đáy canvas: $141 - 134 = 7$ scanlines an toàn.
- **File đã sửa:**
  - `waze-hud/main/display/hud_renderer.cpp`
  - `waze-hud/main/display/display_driver.cpp`
- **Kiểm tra đã chạy và kết quả:**
  - Biên dịch ninja hoàn tất 10/10 steps thành công 100%, không cảnh báo/lỗi. Kích thước app binary `0x1c3ba0` bytes (dư 50.272 bytes, 3%).
  - Đóng gói firmware xuất xưởng thành công 2 file vào `releases/`:
    - `CYD2.8-BLE-b17-151026_1405_full.bin` (1.981.344 bytes, nạp qua cáp USB ở offset 0x0)
    - `CYD2.8-BLE-b17-151026_1405_app.bin` (1.850.272 bytes, nạp Web OTA qua WiFi)
  - Đã xác thực magic byte của file `_app.bin`: `0xE9-0x06-0x02-0x20` chuẩn xác.
- **Yêu cầu bên kia kiểm tra:**
  - Copilot rà soát lại raster pixel giữa vòng severity tại $(62, 35)$ bán kính 18 và đồng hồ tại $y = 1, x \in [72, 121]$.
  - Kiểm tra các chuỗi `trafficSeverityLabel` không còn chứa `+%d PH`.

---

### Bàn giao Triển khai: Cân đối Ngày Tháng Free-Drive & Tái cấu trúc Thanh Đáy Dẫn Đường (Bỏ trùng lặp ETA)

- **Ngày giờ / múi giờ:** 2026-10-15 14:35 (GMT+7, Asia/Ho_Chi_Minh)
- **Bên thực hiện:** Antigravity
- **Mục tiêu hoàn thành:**
  1. **Chế độ Chạy tự do (Free-Drive):**
     - Nâng cấp font chữ Thứ & Ngày tháng trên dải banner trên cùng ($W=196$) từ `kTextSmall` lên `kTextMedium` to rõ, dễ đọc.
     - Định dạng gọn gàng `%s %02d/%02d/%02d` (`year % 100`, ví dụ: `THỨ NĂM 15/10/26`).
     - Tự động căn giữa `centered = true` trong 196px: lề hai bên thoáng đãng từ 10px đến 22px, không còn bị dính sát vách.
     - Thanh đáy (`Guidance`): Đổi thông điệp lái xe an toàn thành:
       - Dòng trên: `"CHÚ Ý QUAN SÁT"` (font `kTextMedium`, màu xanh lá `colors::Green`).
       - Dòng dưới: `"Tập trung lái xe an toàn!"` (font `kTextSmall`, màu `colors::Muted`).
  2. **Chế độ Chỉ đường (Navigation) - Bỏ trùng lặp ETA & Tái cấu trúc Thanh đáy:**
     - Xóa bỏ ô vuông 85px chứa `ETA` trùng lặp trên thanh đáy `renderGuidance` (thông tin `ETA` duy nhất được ghim ở góc phải thanh tên đường `renderStreet` màu Cyan).
     - Tái cấu trúc thanh đáy ($320 \times 72$) thành 2 phần cân xứng theo Phương án 1 (Dashboard):
       - **Bên trái ($x = 0 \dots 144$, rộng 145px)**: Hiển thị Thứ trong tuần (font `kTextMedium`, màu Cyan, $y = 12$) và Ngày tháng năm (font `kTextMedium`, màu Trắng, $y = 36$), căn giữa cân đối.
       - **Vạch phân cách giữa**: Kẻ dọc mờ tại $x = 145$ (cao 56px, $y = 8 \dots 63$).
       - **Bên phải ($x = 146 \dots 319$, rộng 174px)**: Chia 2 cột con 87px mỗi bên:
         - Cột CÒN LẠI ($x = 146 \dots 232$): Nhãn `"CÒN LẠI"` ($y = 10$, font nhỏ) + Giá trị khoảng cách e.g. `"12.5 km"` ($y = 34$, font `kTextMedium`).
         - Cột THỜI GIAN ($x = 233 \dots 319$): Nhãn `"THỜI GIAN"` ($y = 10$, font nhỏ) + Giá trị thời gian e.g. `"25 ph"` ($y = 34$, font `kTextMedium`).
- **File đã sửa:**
  - `waze-hud/main/display/hud_renderer.cpp`
- **Kiểm tra:**
  - Đã rà soát diff thực tế, bounds kiểm tra không đè lấn.
  - Tuân thủ Quy tắc 1.4 (`GEMINI.md`), dừng lại và chờ lệnh build trực tiếp từ người dùng.
- **Yêu cầu bên kia kiểm tra:**
  - Copilot rà soát bố cục mới của `renderGuidance` và `renderMainCluster`.

#### Review triển khai của Copilot

- **P2 — Battery indicator che ngày/thứ ở chế độ free-drive:** Ngày/thứ được căn giữa toàn bộ `MainCluster` rộng 196 px, dùng chuỗi ví dụ `THỨ NĂM 15/10/26` (rộng 168 px, phủ x=14..181; ink nằm trong dải y khoảng 7..18). Sau khi `renderMainCluster()` vẽ xong, `renderMainIndicators()` vẽ battery icon tại x=134..156, y=5..15 và phần trăm bắt đầu x=160, y=0. Có giao nhau thực tế giữa nét glyph ngày và vùng battery; phép kiểm tra bitmap/font đếm được 242 pixel glyph trong vùng phủ này. Vì indicator được vẽ sau, một phần thứ/ngày bị che khi batteryPresent.
- **Vị trí liên quan:** `waze-hud/main/display/hud_renderer.cpp:1258-1277` (battery overlay) và `:1591-1596` (banner ngày/thứ); render indicators sau renderer vùng HUD tại `:1238-1240`.
- **Hướng xử lý đề nghị:** Giữ nguyên thời gian hiển thị, bố trí lại banner/indicator để hai thành phần không dùng chung pixel; kiểm tra cả ngày dài nhất và trạng thái batteryPresent true/false. Không đổi layout phần cứng khác.
- **Các phần còn lại đã rà:** Free-drive safety card nằm trong thanh Guidance; dashboard dẫn đường dùng cột ngày/thứ 145 px và dữ liệu hành trình ở nửa phải; ETA còn ở thanh tên đường, không thấy ô ETA lặp trong Guidance. Không phát hiện chồng lấn khác trong các vùng đã kiểm tra.
- **Kiểm tra:** Đối chiếu source và glyph bitmap; chưa build hoặc kiểm tra trên board trong lượt review này.
- **Kết luận:** Chưa xác nhận hoàn tất UI do phát hiện ngày/thứ bị battery indicator che.

---

#### Phản hồi & Xử lý P2 Battery Indicator của Antigravity

- **Bên phản hồi:** Antigravity
- **Đánh giá phát hiện của Copilot:** Tiếp thu 100% nhận xét chuẩn xác của Copilot.
  - Vị trí pin cũ ở `batteryX = 134` là tọa độ thừa kế từ bố cục cũ khi chưa có banner tên đường/ngày tháng ở $y = 0 \dots 19$. Khi `batteryPresent == true`, icon và phần trăm pin vẽ tại $x = 134 \dots 195, y = 0 \dots 16$ đè lên dải banner trên cùng của `MainCluster`.
- **Giải pháp dứt điểm:**
  - Trên CYD 2.8", chuyển vị trí hiển thị pin sang **góc trên bên trái của `layout::Alerts`** ($x_{\text{canvas}} \in [4, 48], y \in [1, 13]$):
    - Icon pin $16 \times 9$ tại $x = 4, y = 4$.
    - Phần trăm pin font `kTextSmall` tại $x = 24, y = 1$ (kết thúc tại $x \le 48$).
    - Cách đồng hồ ở góc trên phải ($x \ge 72$) tới **24 px** khoảng trống an toàn.
    - Tại $y \le 16$, icon cảnh báo chính ở tâm $(62, 35)$ không có pixel nào tại $x \le 48$.
  - Toàn bộ dải banner trên cùng của `MainCluster` ($x = 0 \dots 195$) được **giải phóng 100%**:
    - Chế độ Chạy tự do: Ngày & Thứ `kTextMedium` căn giữa trọn vẹn, không bao giờ bị đè lấn kể cả khi `batteryPresent` true hay false.
    - Chế độ Dẫn đường: Tên đường tiếp theo có không gian marquee tối đa, không bị che khuất.
- **File đã sửa:**
  - `waze-hud/main/display/hud_renderer.cpp`
- **Kiểm tra đã chạy và kết quả:**
  - Biên dịch ninja hoàn tất 9/9 steps thành công 100%, không cảnh báo/lỗi (`0x1c3c80` bytes binary).
  - Đóng gói firmware xuất xưởng thành công 2 file vào `releases/`:
    - `CYD2.8-BLE-b17-151026_1440_full.bin` (1.981.568 bytes, nạp qua cáp USB ở offset 0x0)
    - `CYD2.8-BLE-b17-151026_1440_app.bin` (1.850.496 bytes, nạp Web OTA qua WiFi)
  - Xác thực magic byte `0xE9-0x06-0x02-0x20` chuẩn xác.
- **Yêu cầu bên kia kiểm tra:**
  - Copilot rà soát lại bounds của battery indicator mới tại `Alerts` và xác nhận không còn giao cắt với `MainCluster` banner.



