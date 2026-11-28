# Database Reference — `attendance_db` (MySQL 8.x Local)

> **Nguồn chuẩn:** Trích xuất trực tiếp từ `backend/src/main/resources/db/Database_attendance.sql` và `Database_SampleTest.sql`. DDL 8 bảng và dữ liệu mẫu chạy trực tiếp trên **MySQL 8.0 Local** (không dùng Docker). **Không tự ý thay đổi tên bảng hoặc cột.**

---

## 1. Quy ước chung trên cả 8 bảng

- **Database Name:** `attendance_db` (`CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`, Engine `InnoDB`, múi giờ `Asia/Ho_Chi_Minh`).
- **Hibernate Mode:** `spring.jpa.hibernate.ddl-auto: none` (chuyển sang `validate` sau khi xóa module mẫu `Product` và tạo đủ 8 Entity thật).
- **Audit & Soft Delete:** Cả 8 bảng đều có 3 cột:
  - `created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP`
  - `updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
  - `deleted_at DATETIME NULL` -> **Mọi truy vấn nghiệp vụ bắt buộc lọc `deleted_at IS NULL`.**
- **JPA Entity Base:** Tất cả 8 Entity đều kế thừa trực tiếp **`com.project.app.entity.BaseEntity`** (đã được cập nhật sẵn trong repo: chứa `createdAt`, `updatedAt`, `deletedAt`, không có `@Id`). Mỗi Entity tự khai báo `@Id` khớp đúng tên cột PK bên dưới.

---

## 2. Chi tiết 8 bảng dữ liệu

| STT | Tên bảng | Khóa chính (PK) & Kiểu Java | Các cột nghiệp vụ chính | Ràng buộc FK / UNIQUE & Lưu ý triển khai BE |
| :---: | :--- | :--- | :--- | :--- |
| 1 | `departments` | `department_id` (`INT` AI -> `Integer`) | `department_name` (`VARCHAR(50)`), `department_code` (`VARCHAR(20)`) | `UNIQUE (department_code)`. Sample: `DEV`, `CRE`, `SAL`, `OPS`. |
| 2 | `holidays` | `holiday_id` (`INT` AI -> `Integer`) | `holiday_name` (`VARCHAR(50)`), `holiday_date` (`DATE` -> `LocalDate`) | `UNIQUE (holiday_date)`. Chỉ lưu ngày lễ Nhật / nghỉ công ty; T7/CN tính bằng Java `DayOfWeek`. |
| 3 | `tasks` | `task_id` (`BIGINT` AI -> `Long`) | `task_name` (`VARCHAR(50)`), `task_code` (`VARCHAR(20)`), `department_id` (`INT NULL`) | `UNIQUE (task_code)`, `FK (department_id)`. **`department_id IS NULL` là Task chung toàn công ty** (`91`, `92`, `93`...). |
| 4 | `users` | `user_id` (`BIGINT` AI -> `Long`) | `user_name` (`VARCHAR(50)`), `department_id` (`INT`), `fullname` (`VARCHAR(50)`), `password` (`VARCHAR(255)`), `role` (`VARCHAR(20)`) | `UNIQUE (user_name)`, `FK (department_id)`. **Lưu ý 1:** Sample data insert `role` chữ thường (`'manager'`, `'staff'`) -> BE bắt buộc `.toUpperCase()` sang `"MANAGER"` / `"STAFF"`. **Lưu ý 2:** `user_name` có khoảng trắng (`'sato kenji'`). Không bao giờ trả `password`. |
| 5 | `projects` | `project_id` (`BIGINT` AI -> `Long`) | `project_name` (`VARCHAR(75)`), `project_code` (`VARCHAR(20)`), `is_active` (`BOOLEAN DEFAULT TRUE`) | `UNIQUE (project_code)`. Không có cột `description`. |
| 6 | `project_members` | **Composite PK:** `(project_id, user_id)` (`@EmbeddedId`) | `project_id` (`BIGINT`), `user_id` (`BIGINT`), `is_manager` (`BOOLEAN DEFAULT FALSE`) | `FK (project_id)`, `FK (user_id)`. Khi thêm lại thành viên từng bị soft-delete (`deleted_at IS NOT NULL`), phải `UPDATE deleted_at = NULL, is_manager = ?` thay vì `INSERT` gây lỗi Duplicate PK. |
| 7 | `daily_logs` | `daily_id` (`BIGINT` AI -> `Long`) | `user_id` (`BIGINT`), `work_date` (`DATE`), `check_in_time` (`DATETIME NULL`), `check_out_time` (`DATETIME NULL`), `break_minutes` (`INT DEFAULT 60`) | `FK (user_id)`, `UNIQUE (user_id, work_date)`. **Lưu ý:** `check_in_time`/`check_out_time` là `DATETIME` (Java `LocalDateTime`); ca qua đêm lưu `check_out_time` ở ngày `workDate.plusDays(1)`. Không lưu `regular_minutes` / `overtime_minutes` -> BE tính động. |
| 8 | `daily_log_details` | `log_detail_id` (`BIGINT` AI -> `Long`) | `daily_id` (`BIGINT`), `project_id` (`BIGINT`), `task_id` (`BIGINT`), `effort_minutes` (`INT`) | `FK (daily_id)`, `FK (project_id)`, `FK (task_id)`. Tối thiểu 1, tối đa 20 dòng/ngày; `SUM(effort_minutes) == T`. |

---

## 3. Hướng dẫn kết nối Local & Dữ liệu mẫu (`Database_SampleTest.sql`)

- **Nạp DB trên máy từng thành viên:** Chạy lần lượt `Database_attendance.sql` rồi đến `Database_SampleTest.sql` trong MySQL Workbench (MySQL 8.0, cổng `3306`).
- **Chạy Backend với mật khẩu MySQL riêng từng máy (không sửa `application.yml` chung):**
  ```powershell
  cd backend
  mvn spring-boot:run -Dspring-boot.run.arguments="--spring.datasource.password=MAT_KHAU_MAY_BAN"
  ```
- **Kiểm tra tài khoản mẫu để test `SCR-01`:** Toàn bộ mật khẩu trong `Database_SampleTest.sql` đã được lưu dạng hash BCrypt (`$2a$10$...`). Thành viên kiểm tra đúng cặp `user_name` / `role` (`'manager'` vs `'staff'`) và mật khẩu gốc đã tạo hash trong `Database_SampleTest.sql` trước khi test đăng nhập và phân quyền.