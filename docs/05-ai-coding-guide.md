# AI Coding Guide — Hướng dẫn Rule khi Code bằng AI cho cả Team

> **Áp dụng cho:** Toàn bộ thành viên (Anh, Thịnh, Uyên, Phương) khi dùng **Antigravity**, **Claude Code** hoặc **OpenAI Codex** trên repository `project1` (Spring Boot 3.3.5 + Vue 3 + MySQL 8.0 Local).

---

## 1. Đọc đúng "Hiến pháp" trước khi ra lệnh

1. **Antigravity:** Tự đọc `AGENTS.md` và `.agents/rules/*.md`.
2. **Claude Code:** Tự đọc `CLAUDE.md` (trỏ sang `AGENTS.md` và `.agents/rules/*.md`).
3. **OpenAI Codex:** Tự đọc `AGENTS.md` — khi giao task nên nhắc thêm `.agents/rules/01-business-rules.md`, `.agents/rules/02-backend-springboot.md`, `.agents/rules/03-frontend-vue3.md` để đảm bảo nạp đủ rule.
4. **Quy tắc "Đọc 1 file spec":** Khi làm màn hình/popup nào (`SCR-01` ~ `SCR-06`, `POP-01` ~ `POP-06`), **chỉ chỉ định đúng 1 file spec của màn đó** trong `docs/screens/` (không bảo AI đọc tràn lan tất cả file spec cùng lúc để tránh lẫn luồng).

---

## 2. Bắt buộc đi qua Luồng 4 Bước (Không để AI code mù)

- **Bước 1 — Đọc ngữ cảnh:** AI đọc file spec của màn đang làm, `docs/01-api-contract-and-errors.md`, `docs/03-db-reference.md` và kiểm tra file base hiện có.
- **Bước 2 — Trình bày kế hoạch & luồng trước khi code:** AI **phải** trình bày bằng tiếng Việt trước khi sửa/tạo code:
  - Luồng `UI -> API -> Controller -> Service -> Repository -> MySQL`.
  - Các `BR-01 ~ BR-15` và `errorCode` cần kiểm tra.
  - Danh sách file dự kiến tạo/sửa.
  - **Bạn xác nhận xong mới cho AI viết code.**
- **Bước 3 — Code đúng phạm vi:** Chỉ tạo/sửa file thuộc màn/chức năng được giao; giữ code gọn, rõ, dễ đọc; viết Unit Test cho logic tính giờ/validation.
- **Bước 4 — Báo cáo luồng sau khi code:** AI tóm tắt luồng thực tế, cách chạy kiểm tra local (`mvn test`, `npm run type-check`) và lưu ý khi merge Git.

---

## 3. Các lỗi cấm tuyệt đối (Zero-Tolerance Rules)

- **Sai Base URL / Wrapper API:** Không đổi prefix khỏi `/api/v1`; mọi JSON response phải bọc trong `ApiResponse<T>` (trừ `API-11` xuất CSV `Shift-JIS` / `MS932`).
- **Sai Entity / DB / Docker:** Không tạo `AuditableEntity` trùng `BaseEntity` (đã có `deletedAt`); không đổi `ddl-auto: none`; không dùng Docker hay tự sửa schema 8 bảng khi chưa thống nhất.
- **Sai Role / Auth:** Chỉ dùng `"STAFF"` và `"MANAGER"` (chuẩn hóa `.toUpperCase()` từ DB); ô `userName` cho phép khoảng trắng; không trả `password`.
- **Sai Nghiệp vụ & UX:** Không bỏ qua `SUM(effortMinutes) == T` (`EFFORT_MISMATCH`), giới hạn `1..20` dòng task, khóa sổ tháng sau `23:59:59` ngày `01` tháng sau (`MONTH_LOCKED`), hoặc reset form khi lỗi (`4xx`/`5xx`).
- **Lấn sân file người khác:** Không tự sửa cấu hình chung (`SecurityConfig`, `GlobalExceptionHandler`, `axiosClient`, `router/index.ts`) hoặc màn hình của thành viên khác nếu chưa báo nhóm.

---

## 4. Thao tác Git & Phiên chat an toàn

- Luôn làm việc trên nhánh riêng (`feat/<screen-id>-<short-name>`) và kéo bản mới từ `main` trước khi code.
- Mỗi khi chuyển sang màn hình/popup mới hoặc sau khi `git pull` bản cập nhật rule/API mới từ `main`, hãy mở **New Chat** mới trên AI để tránh nhớ ngữ cảnh cũ.
- Trước khi tạo PR / Push: chạy `mvn test` (Backend) và `npm run type-check` (Frontend), đảm bảo không dính mật khẩu DB cá nhân.

---

## 5. Mẫu Prompt Giao Task Chuẩn cho Cả Team

```text
Đọc AGENTS.md, .agents/rules/01-business-rules.md, .agents/rules/02-backend-springboot.md,
.agents/rules/03-frontend-vue3.md, docs/01-api-contract-and-errors.md và docs/screens/<FILE_SPEC_CUA_BAN>.md.

Hãy thực hiện Bước 1 & Bước 2 theo quy trình: trình bày kế hoạch, luồng xử lý end-to-end
(UI -> API -> Controller -> Service -> Repository -> MySQL), các BR-xx / errorCode cần xử lý
và danh sách file dự kiến tạo/sửa bằng tiếng Việt.
CHƯA viết code cho đến khi tôi xác nhận. Lưu ý chỉ làm trong phạm vi màn này,
không sửa file màn khác hay cấu hình chung nếu không cần thiết.
```