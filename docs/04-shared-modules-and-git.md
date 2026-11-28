# Shared Modules Ownership & Git Workflow (4 Members)

> **Mục tiêu:** Tránh xung đột Git Merge Conflict khi 4 thành viên (dùng song song Antigravity và Claude Code) phát triển cùng lúc 12 màn hình/popup.

---

## 1. Quy tắc Dựng Shared Base trước khi tách nhánh

Trước khi 4 thành viên tách nhánh code song song, các thành phần dùng chung sau **phải được chốt và merge vào `main` trước** (chỉ 1 người đại diện tạo, các nhánh feature khác **chỉ tái sử dụng, không tự tạo trùng**):

| Nhóm Shared Module | Các file cốt lõi | Ghi chú chống xung đột |
| :--- | :--- | :--- |
| **BE Entities & Repositories** | 8 Entity (`Department`, `Holiday`, `Task`, `User`, `Project`, `ProjectMember`, `DailyLog`, `DailyLogDetail`) + 8 Repository | Tất cả kế thừa `BaseEntity.java` có sẵn. Nhánh feature chỉ thêm custom query method nếu cần, không sửa tên trường Entity. |
| **BE Core Exception & Response** | `ApiResponse.java` (thêm `errorCode`), `BusinessException.java`, `GlobalExceptionHandler.java` | Dùng chung 1 bộ mã lỗi `errorCode` trong `docs/01-api-contract-and-errors.md`. |
| **BE Security & JWT (`SCR-01`)** | `SecurityConfig.java`, `JwtTokenProvider.java`, `JwtAuthenticationFilter.java` | Chỉ người phụ trách `SCR-01` chỉnh sửa; các màn khác lấy user hiện tại từ `SecurityContext`. |
| **BE Time Helper (`BR-01~07, 14`)** | `TimeCalculationHelper.java` (tính `T`, `regular`, `OT`, ca qua đêm, khóa sổ tháng) | Dùng chung cho `SCR-02`, `POP-01`, `SCR-03`, `SCR-05`, `POP-05`. |
| **FE Layout & Design Tokens** | `main.css` (CSS Variables), `AppSidebar.vue`, `AppHeader.vue`, `BaseModal.vue`, `BasePagination.vue` | Khai báo sẵn route khung trong `router/index.ts` để các nhánh chỉ gắn View của mình. |

---

## 2. Phân chia Nhánh Git & Phạm vi File (4 Thành viên)

- **Nhánh chính:** `main` (luôn ở trạng thái build sạch `mvn test` & `npm run type-check`).
- **Quy ước đặt tên nhánh tính năng:** `feat/<screen-id>-<short-name>`
  - Ví dụ: `feat/scr-01-auth`, `feat/scr-02-monthly-list`, `feat/pop-01-log-work`, `feat/scr-04-projects`, `feat/scr-05-staff-attendance`, `feat/scr-06-man-hours`.
- **Phạm vi tách biệt theo WBS:**
  - **Anh:** `SCR-01` (Auth), `SCR-04`, `POP-02`, `POP-03`, `POP-04` (Module Dự án).
  - **Thịnh:** `POP-01` (Log Work), `SCR-06` (Man-hours).
  - **Uyên:** `SCR-02` (Bảng công tháng), `SCR-03` (Sửa ngày), `POP-06` (Xuất CSV).
  - **Phương:** `SCR-05`, `POP-05` (Tra cứu nhân viên Manager) & điều phối ghép nhánh.

---

## 3. Checklist Bắt buộc trước khi tạo Pull Request

1. `git pull origin main` và xử lý conflict (nếu có) ngay trên máy local.
2. Backend: chạy `cd backend && mvn test` -> đạt `BUILD SUCCESS`.
3. Frontend: chạy `cd frontend && npm run type-check` -> `0 errors`.
4. **Không commit** mật khẩu MySQL cá nhân vào `application.yml` hoặc file `.env`.
5. Không tự ý sửa file của màn hình khác hoặc cài thêm package ngoài `pom.xml` / `package.json` khi chưa báo cả nhóm.