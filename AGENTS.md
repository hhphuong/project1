# AGENTS.md — Project-1: Attendance Management System (勤怠管理システム)

> **Vai trò của file này:** Đây là "Hiến pháp dự án" (Single Source of Truth) cho toàn bộ AI Agent (Antigravity và Claude). Mọi hành động phân tích, lập kế hoạch và viết code (Backend & Frontend) **bắt buộc** tuân thủ các quy tắc trong file này để 4 thành viên phát triển song song không xung đột kiến trúc, dữ liệu hay nghiệp vụ.

## 1. Tổng quan Dự án & Phạm vi (Scope)

- **Tên hệ thống:** Attendance Management System (AMS – 勤怠管理システム).
- **Môi trường vận hành:** Chạy hoàn toàn trên **môi trường Local** (MySQL 8.0 cài trực tiếp trên máy, **không sử dụng Docker**).
- **Phạm vi ngoài dự án (Out of Scope — KHÔNG tự ý code thêm):** Quản lý nghỉ phép (Leave Management), tính lương (Payroll), HR nâng cao, tích hợp máy chấm công vật lý, đăng ký tài khoản / tự đặt lại mật khẩu, CRUD danh mục master (`users`, `departments`, `tasks`, `holidays`) trên UI (dữ liệu master được quản lý trực tiếp trong MySQL).
- **Trạng thái nền tảng:** Source code base (`backend/`, `frontend/`) đã khởi tạo và chạy thông suốt; DDL 8 bảng (`Database_attendance.sql`) và dữ liệu mẫu (`Database_SampleTest.sql`) đã được nạp trực tiếp vào MySQL local (`attendance_db`). **Không tự ý thay đổi cấu trúc 8 bảng DB hiện có** khi chưa có sự thống nhất của cả nhóm.

## 2. Tech Stack & Cấu hình thực tế (Locked Stack)

Tuyệt đối không tự ý cài thêm framework/thư viện thay thế ngoài bộ công nghệ của code base hiện tại:

| Thành phần | Công nghệ & Phiên bản chuẩn trong Code Base |
| :--- | :--- |
| **Backend (`backend/`)** | **Java 21**, **Maven**, **Spring Boot 3.3.5**, Spring Web, Spring Data JPA, Spring Security 6 (`BCrypt`), **JJWT `0.12.6`**, Validation, Lombok, Swagger (Springdoc OpenAPI `2.6.0`). |
| **Frontend (`frontend/`)** | **Node.js 20.x**, **Vue.js 3.5** (`<script setup lang="ts">`), TypeScript 5.6, Vite 5.4, Pinia 2.2, Vue Router 4.4, Axios 1.7. |
| **Styling & Icons** | **CSS Variables (`frontend/src/assets/styles/main.css`) + `<style scoped>`** (KHÔNG dùng Tailwind CSS). Tái sử dụng các class có sẵn (`.card`, `.data-table`, `.form-input`, `.badge`) và component `BaseButton.vue`, `useNotification.ts`. |
| **Database** | **MySQL 8.x Local** — Database name: **`attendance_db`** (`utf8mb4` / `utf8mb4_unicode_ci`), `ddl-auto: none`, múi giờ `Asia/Ho_Chi_Minh` (`+07:00`). |
| **API Base URL** | **`http://localhost:8080/api/v1`** (đã cấu hình sẵn trong `frontend/.env.development`, `axiosClient.ts` và `SecurityConfig.java`). |

## 3. Phân quyền Role & Quy ước Định danh chuẩn

### 3.1. Vai trò người dùng (Canonical Roles)

- Chỉ sử dụng đúng 2 giá trị in hoa **`"STAFF"`** và **`"MANAGER"`** xuyên suốt JWT Claims, Backend Security, JSON Response và Frontend Route Guards.
- **Lưu ý dữ liệu mẫu (`Database_SampleTest.sql`):**
  - Cột `users.role` đang insert chữ thường (`'manager'`, `'staff'`). Backend **bắt buộc chuẩn hóa `.toUpperCase()`** (hoặc `equalsIgnoreCase`) khi đọc từ DB và luôn trả về `"MANAGER"` / `"STAFF"` trong API & JWT.
  - Cột `users.user_name` có chứa khoảng trắng (VD: `'sato kenji'`). **Không** đặt regex cấm khoảng trắng trên ô nhập `userName` khi đăng nhập (`SCR-01`).
- **Cấm dùng:** `"Employee"`, `"USER"`, `"Nhân viên"` trong code hoặc DTO.
- **Ma trận quyền cốt lõi:**
  - **`STAFF`:** Xem/tạo/sửa bảng chấm công của **chính mình** (trong hạn khóa sổ); xem danh sách dự án tham gia và thành viên dự án. **Không** được xem/sửa dữ liệu người khác, **không** vào thống kê Man-hours, **không** xuất CSV, **không** tạo dự án hoặc thêm thành viên.
  - **`MANAGER`:** Có toàn bộ quyền tự chấm công như `STAFF` + xem bảng chấm công của toàn bộ nhân viên ở chế độ **chỉ đọc (Read-only, cấm sửa thay)** + xem 3 bảng thống kê Man-hours + xuất CSV (`Shift-JIS`) + tạo dự án mới + thêm thành viên vào dự án.

### 3.2. Bản đồ 12 Màn hình & Popup chuẩn (`SCR-01 ~ SCR-06`, `POP-01 ~ POP-06`)

Mọi tên file, route, component và tài liệu phải ánh xạ đúng 12 mã sau:

| Mã chuẩn | Loại | Tên màn hình / Popup | Role | API liên quan | Lưu ý chốt quan trọng |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`SCR-01`** | Screen | Đăng nhập (Login – ログイン画面) | Public | `API-01, 02, 03` | Không có quên mật khẩu; `userName` cho phép khoảng trắng |
| **`SCR-02`** | Screen | Danh sách chấm công tháng (月次勤怠リスト) | `STAFF`, `MANAGER` | `API-04` | Có phân trang (`summary` tính cả tháng); phân biệt `WORKDAY`/`WEEKEND`/`HOLIDAY` |
| **`POP-01`** | Modal | Đăng ký chấm công ngày – Log Work (日別勤怠登録) | `STAFF`, `MANAGER` | `API-05, 06, 07` | Mở từ `SCR-02`; **chỉ dùng Tạo mới (`POST`)**; kèm Calendar Popup `POP-01A` |
| **`SCR-03`** | Screen | Chỉnh sửa chấm công ngày (日別勤怠詳細・修正) | `STAFF`, `MANAGER` | `API-05, 06, 08` | **Chỉ dùng Chỉnh sửa (`PUT`)**; **KHÔNG có phân trang** |
| **`SCR-04`** | Screen | Danh sách Dự án (プロジェクト一覧) | `STAFF`, `MANAGER` | `API-12` | Có phân trang; Card chỉ hiện `projectCode`, `projectName`, `memberCount`, `memberPreviews` |
| **`POP-02`** | Modal | Chi tiết Dự án & Thành viên (プロジェクト詳細) | `STAFF`, `MANAGER` | `API-13` | Mở từ `SCR-04`; Manager thấy nút `+ メンバー追加` |
| **`POP-03`** | Modal | Thêm thành viên vào Dự án (メンバーを追加する) | `MANAGER` | `API-15, 16` | Mở từ `POP-02`; Searchable Dropdown chọn nhân viên |
| **`POP-04`** | Modal | Thêm mới Dự án (プロジェクトを追加する) | `MANAGER` | `API-14` | Mở từ `SCR-04`; **nhập tay bắt buộc** `projectCode` (<= 20 ký tự, `UNIQUE`) & `projectName` (<= 75 ký tự) |
| **`SCR-05`** | Screen | Danh sách chấm công nhân viên (社員勤怠情報) | `MANAGER` | `API-04, 09` | Có phân trang; tìm theo Account; cột thao tác dùng nút **`詳細` (chỉ xem, không có `修正`)** |
| **`POP-05`** | Modal | Chi tiết chấm công nhân viên (社員勤怠詳細) | `MANAGER` | `API-05` (`?userId=`) | Mở từ `SCR-05`; **Read-only 100%** |
| **`SCR-06`** | Screen | Thống kê công sức – Man-hours (工数集計) | `MANAGER` | `API-09, 10` | Lọc theo `month` (`YYYY-MM`); liên động 2 chiều Phòng ban (`全社` mặc định) <-> Nhân viên; 3 Tab (`PROJECT_TASK`, `DEPT_TASK`, `DEPT_PROJECT`); có phân trang |
| **`POP-06`** | Modal | Xác nhận xuất CSV (CSVファイル出力) | `MANAGER` | `API-11` | Mở từ `SCR-06`; file xuất `manhours_YYYYMM.csv` mã hóa `Shift-JIS` (`MS932`) |

## 4. Quy tắc Nghiệp vụ Bất biến (BR-01 ~ BR-15)

Xem chi tiết công thức và các test case bắt buộc tại `.agents/rules/01-business-rules.md`. Tóm tắt cốt lõi:
- **BR-01:** Bước nhảy 10 phút (`% 10 == 0`).
- **BR-02 ~ BR-05:** `T = checkOutMinutes - checkInMinutes - breakMinutes` (ca qua đêm `checkOut < checkIn` cộng `+1440` phút; `T > 0`); `regularMinutes = Math.min(T, 480)`; `overtimeMinutes = Math.max(T - 480, 0)`; `actualMinutes = T`.
- **BR-06, BR-07, BR-13:** `0 <= effortMinutes <= 1850`, `1 <= details.size() <= 20`, và bắt buộc **`SUM(details[].effortMinutes) == T`** (lệch trả `400 EFFORT_MISMATCH`).
- **BR-12:** Task lọc theo `department_id = currentUser.department_id OR department_id IS NULL`.
- **BR-14:** Cấm ngày tương lai (`422 FUTURE_DATE_NOT_ALLOWED`); khóa sổ tháng `M` sau `23:59:59` ngày `01` tháng `M+1` theo giờ `Asia/Ho_Chi_Minh` (`422 MONTH_LOCKED`).
- **BR-15:** Xuất CSV `GET /api/v1/reports/man-hours/export` mã hóa `Charset.forName("MS932")`.

## 5. Quy ước Kỹ thuật API, Database & Design System

- **Wrapper Response chuẩn (`ApiResponse<T>`):** Mọi API trả JSON (trừ `API-11` trả binary CSV) **bắt buộc** bọc trong `ApiResponse<T>` của source base:
  - Thành công: `{ "success": true, "message": "...", "data": { ... }, "timestamp": "2026-11-28T14:30:00" }`
  - Lỗi: `{ "success": false, "errorCode": "EFFORT_MISMATCH", "message": "...", "data": { ... }, "timestamp": "2026-11-28T14:30:00" }`
- **Entity Base:** Kế thừa trực tiếp `BaseEntity.java` **đã được sửa sẵn** trong repo (chứa `createdAt`, `updatedAt`, `deletedAt` và không có `@Id`). Mỗi Entity tự khai báo `@Id` khớp tên cột PK trong `attendance_db`.
- **Soft Delete (8 bảng):** Mọi truy vấn bắt buộc lọc `deleted_at IS NULL`.
- **Kiểu giờ trong `daily_logs`:** DB lưu `DATETIME` (`LocalDateTime`), API truyền `"HH:mm"`.
- **Transaction:** Lưu `daily_logs` + `daily_log_details` (`API-07`, `API-08`) và tạo `projects` + `project_members` (`API-14`) bắt buộc bọc `@Transactional`.
- **Mã `errorCode` chuẩn:** `VALIDATION_ERROR` (400), `EFFORT_MISMATCH` (400), `INVALID_CREDENTIALS` (401), `UNAUTHORIZED` (401), `FORBIDDEN_ACCESS` (403), `RESOURCE_NOT_FOUND` (404), `DUPLICATE_WORK_DATE` (409), `DUPLICATE_PROJECT_CODE` (409), `DUPLICATE_PROJECT_MEMBER` (409), `MONTH_LOCKED` (422), `FUTURE_DATE_NOT_ALLOWED` (422), `INTERNAL_SERVER_ERROR` (500).

## 6. Bản đồ Tài liệu Tham chiếu trong Repository

- `CLAUDE.md` — File cầu nối nạp ngữ cảnh cho thành viên dùng Claude Code.
- `.agents/rules/01-business-rules.md` — Chi tiết công thức tính giờ, validation, khóa sổ và Shift-JIS.
- `.agents/rules/02-backend-springboot.md` — Quy chuẩn phân tầng `com.project.app` (Java 21 / Spring Boot 3.3.5).
- `.agents/rules/03-frontend-vue3.md` — Quy chuẩn Vue 3 `<script setup>`, Pinia, Axios, CSS Variables.
- `docs/01-api-contract-and-errors.md` — Đặc tả đầy đủ 16 API (`/api/v1/...`, bọc `ApiResponse<T>`) và bảng mã lỗi.
- `docs/02-design-system.md` — Chi tiết token giao diện ánh xạ trực tiếp vào `main.css`.
- `docs/03-db-reference.md` — Tóm tắt 8 bảng MySQL (`attendance_db`), khóa chính/ngoại/unique key.
- `docs/screens/<SCREEN_ID>-*.md` — Đặc tả chi tiết riêng của màn hình/popup đang được giao.

## 7. Quy trình Làm việc Bắt buộc cho AI Agent (AI-First Workflow)

Mọi AI Agent (Antigravity & Claude) **phải** thực hiện đúng 4 bước sau cho mỗi tác vụ:

1. **Bước 1 — Đọc ngữ cảnh (Read Before Write):** Đọc `docs/screens/<MÃ_MÀN>.md`, phần API tương ứng trong `docs/01-api-contract-and-errors.md`, và kiểm tra các file có sẵn trong `backend/` và `frontend/` để tái sử dụng đúng cấu trúc base.
2. **Bước 2 — Trình bày Kế hoạch & Luồng xử lý bằng tiếng Việt (Plan & Flow First):** Trước khi tạo/sửa code, trình bày ngắn gọn luồng `UI -> API -> Controller -> Service -> Repository -> DB`, các `BR-xx` & `errorCode` sẽ kiểm tra, danh sách file dự kiến tạo/sửa, và **chờ thành viên xác nhận**.
3. **Bước 3 — Code sạch & Cô lập phạm vi (Scoped Implementation):** Chỉ tạo/sửa file thuộc màn hình được giao. Không sửa cấu hình chung (`SecurityConfig`, `GlobalExceptionHandler`, `axiosClient`, `router/index.ts`) nếu không được yêu cầu. Viết Unit Test cho Service chứa logic tính toán/validation.
4. **Bước 4 — Báo cáo Luồng sau khi code (Walkthrough):** Tóm tắt bằng tiếng Việt luồng hoạt động thực tế, cách test trên local và lưu ý khi merge Git.