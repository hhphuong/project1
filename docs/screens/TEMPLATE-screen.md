# [MÃ_MÀN]. [Tên Màn hình / Popup] – [Tên tiếng Nhật]

> **Hướng dẫn:** Nhân bản file này cho từng màn hình/popup (`SCR-01 ~ SCR-06`, `POP-01 ~ POP-06`). Giữ nội dung ngắn gọn, chính xác theo `docs/01-api-contract-and-errors.md` (`/api/v1/...`, bọc `ApiResponse<T>`) và `docs/02-design-system.md`.

## 1. Thông tin chung

- **Mã màn hình / Popup:** `SCR-XX` hoặc `POP-XX`
- **Loại:** Main Screen / Modal (Parent: `SCR-XX`)
- **Role được phép:** `STAFF`, `MANAGER` (hoặc chỉ `MANAGER` — ghi rõ nếu Read-only)
- **Route (nếu là Main Screen):** `/...`
- **Mục đích:** Mô tả ngắn 1-2 câu.

## 2. API sử dụng (`/api/v1/...`)

| Mã API | Method & Endpoint | Mục đích gọi trên màn này |
| :--- | :--- | :--- |
| `API-XX` | `GET /api/v1/...` | Tải dữ liệu ban đầu / lọc / phân trang (unwrap `ApiResponse<T>.data`) |
| `API-YY` | `POST /api/v1/...` | Lưu dữ liệu khi bấm nút Submit |

## 3. Thành phần giao diện & Luồng thao tác

- **Tái sử dụng từ Source Base:** `BaseButton`, `useNotification`, `ApiResponse<T>`, class `.card` / `.data-table` / `.form-input` / `.badge` trong `main.css`.
- **Khu vực Filter / Header:** Liệt kê các ô lọc, nút điều hướng, giá trị mặc định.
- **Khu vực chính (Form / Table / Cards):**
  - Liệt kê các cột bảng hoặc các trường nhập liệu (ghi rõ tên field JSON tương ứng, VD: `projectCode`, `effortMinutes`).
  - Ghi rõ nút nào chỉ hiện cho `MANAGER`, nút nào bị disable khi tháng khóa sổ (`isLocked = true`).
- **Luồng điều hướng:**
  - Bấm nút A -> mở `POP-XX` hoặc chuyển sang `SCR-XX`.
  - Lưu thành công -> đóng modal / quay về màn cha + reload dữ liệu + hiện Toast `notifySuccess`.

## 4. Validation & Trạng thái UI

- **Validation phía Client (đồng bộ BE):** Liệt kê các điều kiện bắt buộc (`必須`), giới hạn độ dài, công thức tính (tham chiếu `BR-01 ~ BR-15`).
- **Xử lý Error Code từ BE:** Ghi rõ cách hiển thị khi nhận `VALIDATION_ERROR`, `EFFORT_MISMATCH`, `MONTH_LOCKED`, `DUPLICATE_*`, `FORBIDDEN_ACCESS`...
- **Trạng thái màn hình:** Default, Loading, Empty State, Validation Error, Error (giữ nguyên dữ liệu đã nhập khi lỗi).