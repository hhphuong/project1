---
trigger: always_on
---

# Business Rules & Domain Invariants (BR-01 ~ BR-15)

> **Phạm vi áp dụng:** Bắt buộc enforce 100% tại **Backend (Java 21 / Spring Boot)** và đồng bộ validation UX tại **Frontend (Vue 3 / TypeScript)**. Mọi lỗi trả về theo chuẩn `ApiResponse` (`success: false`, `errorCode`, `message`, `data`).

## 1. Quy tắc Chấm công, Tính giờ thực tế & Tăng ca (BR-01 ~ BR-05)

### BR-01: Định dạng & Bước nhảy 10 phút
- `checkInTime` (Giờ đến) và `checkOutTime` (Giờ về) là **trường bắt buộc**, nhập qua Dropdown:
  - Giờ: `00` đến `23`.
  - Phút: chỉ chấp nhận `{00, 10, 20, 30, 40, 50}`.
- `breakMinutes` (Thời gian nghỉ) và `effortMinutes` (Thời lượng từng Task) lưu dưới dạng số nguyên phút (`INT`) và bắt buộc chia hết cho `10` (`% 10 == 0`).
- Vi phạm định dạng hoặc bước nhảy 10 phút -> trả về `HTTP 400` (`errorCode: "VALIDATION_ERROR"`).

### BR-02: Thời gian làm việc thực tế (T), Ca qua đêm & Nghỉ tự động
- **Xử lý ca qua đêm:**
  - Ngày chấm công (`workDate`) luôn ghi nhận theo **ngày bắt đầu ca làm việc**.
  - Nếu `checkOutTime < checkInTime`: hệ thống hiểu giờ về thuộc ngày hôm sau và tự động cộng thêm **24 giờ (`+1440` phút)** vào `checkOutMinutes` khi tính toán.
  - *Ví dụ:* `checkInTime = 22:00` (`1320`p), `checkOutTime = 02:00` (`120`p) -> `checkOutMinutes = 120 + 1440 = 1560`p -> tổng ca = `240`p (`4:00`) trước khi trừ nghỉ.
- **Quy tắc xác định thời gian nghỉ (`breakMinutes`):**
  - Nếu ca làm việc không vắt qua khung nghỉ trưa (`12:00` - `13:00`) — tức `checkOutTime <= 12:00` **HOẶC** `checkInTime >= 13:00` (áp dụng cho ca trong ngày không qua đêm) -> hệ thống tự động tính `breakMinutes = 0`.
  - Các trường hợp còn lại: lấy theo giá trị người dùng nhập (`breakMinutes >= 0`, chia hết cho `10`, mặc định UI khi tạo mới là `60` phút).
- **Công thức tính thời gian làm việc thực tế (T):**
  ```text
  T = checkOutMinutes - checkInMinutes - breakMinutes
  ```
- **Ràng buộc:** Nếu `breakMinutes < 0` hoặc `T <= 0` -> từ chối với `HTTP 400` (`errorCode: "VALIDATION_ERROR"`).

### BR-03: Thời gian làm việc định mức (所定内勤務時間)
```text
regularMinutes = Math.min(T, 480)
```
- Tối đa `8` tiếng (`480` phút) mỗi ngày. Nếu `T < 480` thì `regularMinutes = T`.

### BR-04: Thời gian tăng ca (残業時間 / OT)
```text
overtimeMinutes = Math.max(T - 480, 0)
```
- Không đặt giới hạn tối đa trong công thức.
- OT chỉ được tính và quản lý ở cấp **nhân viên / ngày**, tuyệt đối **không** phân bổ OT theo từng dự án.

### BR-05: Tổng thời gian làm việc thực tế (実労働時間)
```text
actualMinutes = regularMinutes + overtimeMinutes == T
```
- **Lưu ý DB:** Bảng `daily_logs` không lưu cứng cột `regular_minutes` và `overtime_minutes`; Backend luôn tính động từ `check_in_time`, `check_out_time`, `break_minutes`.

## 2. Quy tắc Chi tiết Công việc (Task) & Đối chiếu Gokei (BR-06 ~ BR-08, BR-12, BR-13)

### BR-06: Phạm vi thời lượng từng Task
- Thời lượng mỗi dòng Task nhập qua Dropdown: giờ `00` đến `30`, phút `{00, 10, 20, 30, 40, 50}`.
- Quy đổi phút: `0 <= effortMinutes <= 1850` (từ `00:00` đến tối đa `30:50`) và `effortMinutes % 10 == 0`.

### BR-07: Đối chiếu tổng thời gian công việc (作業時間合計 / Gokei) — NGHIÊM NGẶT
```text
SUM(details[].effortMinutes) == T
```
- Tổng thời lượng tất cả các dòng Task trong ngày **bắt buộc bằng chính xác** thời gian làm việc thực tế `T`.
- Nếu lệch -> **chặn lưu**, trả về `HTTP 400` với `errorCode: "EFFORT_MISMATCH"`.

### BR-08: Tổng hợp Effort theo Dự án
- Tổng thời gian công sức của một dự án được tính bằng tổng `effortMinutes` của các dòng Task thuộc dự án đó.

### BR-12: Lọc Task theo Phòng ban trực thuộc
- Khi lấy danh sách Task (`API-06`) hoặc validate khi lưu (`API-07`, `API-08`), chỉ cho phép chọn các Task thỏa mãn:
  `tasks.deleted_at IS NULL AND (tasks.department_id = currentUser.department_id OR tasks.department_id IS NULL)`
- `department_id IS NULL` là các Task chung toàn công ty (`91`, `92`, `93`...).
- Danh sách Task **không phụ thuộc** vào Project được chọn. Nếu Client gửi `taskId` ngoài phạm vi trên -> từ chối `HTTP 400` (`errorCode: "VALIDATION_ERROR"`).

### BR-13: Giới hạn số dòng công việc trong ngày
- Số dòng `details` khi đăng ký mới (`POP-01` / `API-07`) hoặc cập nhật (`SCR-03` / `API-08`) bắt buộc thỏa mãn:
  `1 <= details.size() <= 20`
- Trên UI: không cho phép xóa dòng nếu chỉ còn duy nhất 1 dòng; vô hiệu hóa nút `+ 行を追加` khi đã đạt 20 dòng.

## 3. Quy tắc Ngày hợp lệ, Ngày lễ & Khóa sổ tháng (BR-14)

- **Múi giờ chuẩn:** `Asia/Ho_Chi_Minh` (`+07:00`) đồng bộ với `application.yml`.
- **Cấm ngày tương lai:** Không cho phép tạo/sửa chấm công nếu `workDate > LocalDate.now()` -> trả về `HTTP 422` (`errorCode: "FUTURE_DATE_NOT_ALLOWED"`).
- **Trùng ngày khi tạo mới:** Mỗi nhân viên chỉ có tối đa 1 bản ghi active (`deleted_at IS NULL`) cho mỗi `workDate`. Nếu đã tồn tại khi gọi `POST /api/v1/daily-logs` (`API-07`) -> trả về `HTTP 409` (`errorCode: "DUPLICATE_WORK_DATE"`).
- **Cuối tuần & Ngày lễ:**
  - Bảng chấm công tháng (`API-04`) trả đủ các ngày trong tháng kèm `dayType`: `WORKDAY`, `WEEKEND` (T7/CN), hoặc `HOLIDAY` (tra bảng `holidays` kèm `holidayName`).
  - **Cho phép** đăng ký chấm công vào Thứ Bảy, Chủ Nhật và Ngày lễ; công thức tính `regularMinutes` và `overtimeMinutes` áp dụng giống ngày thường.
- **Quy tắc Khóa sổ tháng (Month Locking):**
  - Dữ liệu chấm công của tháng `M` chỉ được phép tạo mới hoặc chỉnh sửa đến **`23:59:59` ngày `01` của tháng `M+1`**.
  - *Ví dụ:* Dữ liệu tháng `11/2026` được phép tạo/sửa đến `2026-12-01 23:59:59`. Từ `2026-12-02 00:00:00` trở đi, toàn bộ tháng `11/2026` bị khóa (`isLocked = true`, `canEdit = false`).
  - Mọi request `POST` / `PUT` vào tháng đã khóa sổ -> Backend từ chối với `HTTP 422` (`errorCode: "MONTH_LOCKED"`).

## 4. Quy tắc Phân quyền, Bảo mật & Quản lý Dự án (BR-09 ~ BR-11)

- **BR-09 (Bảo mật):** Mật khẩu hash bằng `BCryptPasswordEncoder`. Không bao giờ lưu plain text và không trả về `password` trong bất kỳ response nào.
- **BR-10 (`STAFF`):** Chỉ được xem, tạo, sửa chấm công của **chính mình** (lấy `userId` từ JWT `SecurityContext`). Cố tình truyền `userId` người khác hoặc gọi API dành cho `MANAGER` -> `HTTP 403` (`errorCode: "FORBIDDEN_ACCESS"`).
- **BR-11 (`MANAGER`):**
  - Có toàn bộ quyền tự chấm công cho chính mình (`SCR-02`, `POP-01`, `SCR-03`).
  - Được xem bảng chấm công và chi tiết ngày của toàn bộ nhân viên (`SCR-05`, `POP-05`) ở chế độ **chỉ đọc (Read-only, tuyệt đối không sửa thay)**.
- **Quản lý Dự án (`POP-03`, `POP-04`, `API-14`, `API-16`):**
  - Tạo dự án (`API-14`): Chỉ `MANAGER`. Nhập tay bắt buộc `projectCode` (<= 20 ký tự, `UNIQUE` -> trùng trả `409 DUPLICATE_PROJECT_CODE`) và `projectName` (<= 75 ký tự). Trong cùng 1 `@Transactional`, lưu `projects` (`is_active = true`) và tự động thêm người tạo vào `project_members` với `is_manager = true`.
  - Thêm thành viên (`API-16`): Chỉ `MANAGER`. Khóa chính `project_members` là `(project_id, user_id)`: nếu thành viên đang active -> `409 DUPLICATE_PROJECT_MEMBER`; nếu từng bị xóa mềm (`deleted_at IS NOT NULL`) -> khôi phục `deleted_at = NULL` và cập nhật `is_manager`.

## 5. Quy tắc Thống kê Man-hours & Xuất CSV Shift-JIS (BR-15)

- **Kỳ thống kê (`API-10`, `API-11`):** Bắt buộc truyền `month=YYYY-MM` (VD: `2026-11`), lọc theo tháng/năm của `daily_logs.work_date` (chỉ tính bản ghi có `deleted_at IS NULL`).
- **Bộ lọc liên động 2 chiều (`SCR-06`):**
  - Mặc định khi mở màn: `departmentId = null` (`全社` - Toàn công ty), `userId = null` (trống).
  - Chọn Phòng ban trước -> dropdown Nhân viên chỉ hiện nhân viên thuộc phòng ban đó.
  - Chọn Nhân viên trước -> dropdown Phòng ban tự động cập nhật theo phòng ban của nhân viên đó.
- **3 chế độ tổng hợp chuẩn (Enum `type` dùng thống nhất giữa `API-10` & `API-11`):**
  1. `PROJECT_TASK`: `GROUP BY` Mã DA, Tên DA, Mã CV, Tên CV.
  2. `DEPT_TASK`: `GROUP BY` Mã PB, Tên PB, Mã CV, Tên CV.
  3. `DEPT_PROJECT`: `GROUP BY` Mã PB, Tên PB, Mã DA, Tên DA.
- **BR-15 (Xuất CSV Shift-JIS):**
  - `GET /api/v1/reports/man-hours/export` (`API-11`) xuất toàn bộ dữ liệu khớp bộ lọc (không cắt theo phân trang) sang CSV mã hóa **`Charset.forName("MS932")`** (Shift-JIS).
  - Response headers bắt buộc:
    - `Content-Type: text/csv; charset=Shift_JIS`
    - `Content-Disposition: attachment; filename="manhours_YYYYMM.csv"` (VD: `manhours_202611.csv`).

## 6. Checklist Unit Test Bắt buộc cho Backend Service

1. Ca thường 8 tiếng (`09:00` - `18:00`, nghỉ `60`p) -> `T = 480`, `regular = 480`, `OT = 0`.
2. Ca có OT (`09:00` - `20:30`, nghỉ `60`p) -> `T = 630`, `regular = 480`, `OT = 150`.
3. Ca dưới 8 tiếng (`09:00` - `15:00`, nghỉ `60`p) -> `T = 300`, `regular = 300`, `OT = 0`.
4. Ca qua đêm (`22:00` - `02:00`, nghỉ `0`p) -> `T = 240`, `regular = 240`, `OT = 0`.
5. Ca nửa buổi không vắt qua giờ nghỉ trưa (`09:00` - `12:00` hoặc `13:00` - `17:00`) -> `breakMinutes = 0`.
6. Lệch tổng Gokei (`SUM(effortMinutes) != T`) -> ném lỗi `EFFORT_MISMATCH` (`400`).
7. Vượt quá `20` dòng Task hoặc `0` dòng Task -> ném lỗi `VALIDATION_ERROR` (`400`).
8. Ngày tương lai (`FUTURE_DATE_NOT_ALLOWED` `422`) và ngày thuộc tháng đã khóa sổ sau `23:59:59` ngày `01` tháng sau (`MONTH_LOCKED` `422`).