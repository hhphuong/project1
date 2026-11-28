# API Contract & Error Code Catalog (`API-01` ~ `API-16`)

> **Nguồn chuẩn:** Đồng bộ 100% giữa `API_Specification_HeThongChamCong_v1.2.xlsx` và source code thực tế `project1-main` (`ApiResponse<T>`, `GlobalExceptionHandler.java`, `axiosClient.ts`, `SecurityConfig.java`).
> **Base URL:** `http://localhost:8080/api/v1`
> **Format:** RESTful JSON (`Content-Type: application/json; charset=UTF-8`), JSON dùng `camelCase` <-> MySQL dùng `snake_case`, múi giờ `Asia/Ho_Chi_Minh` (`+07:00`).

---

## 1. Quy ước Kỹ thuật Chung & Wrapper `ApiResponse<T>`

- **Wrapper bắt buộc cho mọi API JSON (trừ `API-11` xuất CSV):**
  - Thành công:
    ```json
    {
      "success": true,
      "message": "Success",
      "data": { ... },
      "timestamp": "2026-11-28T14:30:00"
    }
    ```
  - Lỗi (`4xx` / `5xx`):
    ```json
    {
      "success": false,
      "errorCode": "EFFORT_MISMATCH",
      "message": "Tổng thời gian công việc không khớp thời gian làm việc thực tế",
      "data": { "details": "SUM(effortMinutes) != T" },
      "timestamp": "2026-11-28T14:30:00"
    }
    ```
  *(Trong mục 2 dưới đây, phần `Response` minh họa trực tiếp nội dung bên trong trường **`data`** của `ApiResponse<T>`.)*
- **Xác thực & Phân quyền:** Header `Authorization: Bearer <accessToken>`. Role chuẩn hóa in hoa: `"MANAGER"` hoặc `"STAFF"`. Backend luôn lấy `currentUser` từ JWT `SecurityContext`, không tin tưởng `userId` từ Client cho các thao tác ghi/sửa.
- **Định dạng ngày & giờ:**
  - Ngày: `YYYY-MM-DD` (VD: `2026-11-20`).
  - Tháng: `YYYY-MM` (VD: `2026-11`).
  - Giờ đến / giờ về trên JSON: `"HH:mm"` (phút thuộc `{00, 10, 20, 30, 40, 50}`).
  - Thời lượng (`breakMinutes`, `effortMinutes`, `regularMinutes`, `overtimeMinutes`, `actualMinutes`, `totalMinutes`): **số nguyên phút (`INT`)**.
- **Phân trang chuẩn (`API-04`, `API-10`, `API-12`):**
  - Query params: `page` (mặc định `1`, bắt đầu từ 1), `size` (VD: `10`, `20`, `31`).
  - Trong `data` trả kèm object:
    ```json
    "pagination": {
      "page": 1,
      "size": 20,
      "totalElements": 30,
      "totalPages": 2
    }
    ```
- **Soft Delete:** Mọi truy vấn chỉ lấy bản ghi có `deleted_at IS NULL`.

---

## 2. Chi tiết 16 Endpoints (`API-01` ~ `API-16`)

### Nhóm 1: Đăng nhập & Xác thực (`SCR-01`)

#### `API-01` — Đăng nhập (`POST /api/v1/auth/login`)
- **Role:** Public
- **Request Body:**
  ```json
  {
    "userName": "sato kenji",
    "password": "Pass@123"
  }
  ```
- **Response `200 OK` (`ApiResponse.data`):**
  ```json
  {
    "accessToken": "eyJhbGci...",
    "tokenType": "Bearer",
    "user": {
      "userId": 1,
      "userName": "sato kenji",
      "fullname": "佐藤 健司",
      "role": "MANAGER",
      "departmentId": 1,
      "departmentName": "開発部"
    }
  }
  ```
- **Lưu ý BE & FE:** `userName` **cho phép khoảng trắng** (khớp dữ liệu mẫu `'sato kenji'`). Kiểm tra `deleted_at IS NULL`, đối chiếu mật khẩu qua `BCryptPasswordEncoder`, chuẩn hóa `role.toUpperCase()`, tuyệt đối không trả `password`.
- **Lỗi:** `400 VALIDATION_ERROR`, `401 INVALID_CREDENTIALS`.

#### `API-02` — Đăng xuất (`POST /api/v1/auth/logout`)
- **Role:** `MANAGER`, `STAFF`
- **Response `200 OK`:** `ApiResponse.success("Logged out successfully", null)`
- **Lỗi:** `401 UNAUTHORIZED`.

#### `API-03` — Lấy thông tin phiên hiện tại (`GET /api/v1/auth/me`)
- **Role:** `MANAGER`, `STAFF`
- **Response `200 OK` (`ApiResponse.data`):** Trả object `user` (giống `API-01`: `userId`, `userName`, `fullname`, `role`, `departmentId`, `departmentName`).
- **Lỗi:** `401 UNAUTHORIZED`.

---

### Nhóm 2: Danh sách chấm công tháng (`SCR-02`, `SCR-05`)

#### `API-04` — Lấy bảng chấm công theo tháng (`GET /api/v1/daily-logs`)
- **Role:** `MANAGER`, `STAFF`
- **Query Params:**
  - `month`: `YYYY-MM` (tùy chọn, mặc định tháng hiện tại).
  - `userId`: `Long` (tùy chọn, mặc định của user đang đăng nhập; nếu `STAFF` truyền `userId != currentUser.userId` -> `403 FORBIDDEN_ACCESS`).
  - `page`: `Integer` (mặc định `1`), `size`: `Integer` (mặc định `31`).
- **Response `200 OK` (`ApiResponse.data`):**
  ```json
  {
    "yearMonth": "2026-11",
    "isLocked": false,
    "lockDeadline": "2026-12-01T23:59:59",
    "summary": {
      "workingDays": 18,
      "totalRegularMinutes": 8640,
      "totalOvertimeMinutes": 420,
      "totalActualMinutes": 9060
    },
    "days": [
      {
        "workDate": "2026-11-02",
        "dayOfWeek": "MON",
        "dayType": "WORKDAY",
        "holidayName": null,
        "dailyId": 101,
        "checkInTime": "09:00",
        "checkOutTime": "18:30",
        "breakMinutes": 60,
        "regularMinutes": 480,
        "overtimeMinutes": 30,
        "actualMinutes": 510,
        "canEdit": true
      }
    ],
    "pagination": { "page": 1, "size": 31, "totalElements": 30, "totalPages": 1 }
  }
  ```
- **Lưu ý BE:**
  - **`summary` luôn tính trên toàn bộ tháng `YYYY-MM`**, không cộng dồn riêng các dòng trên trang `page` hiện tại.
  - `dayType` gồm `WORKDAY`, `WEEKEND` (T7/CN), `HOLIDAY` (tra bảng `holidays`).
  - `canEdit = !isLocked && (targetUserId == currentUser.userId)`.
- **Lỗi:** `400 VALIDATION_ERROR`, `401 UNAUTHORIZED`, `403 FORBIDDEN_ACCESS`.

---

### Nhóm 3: Đăng ký & Chỉnh sửa chấm công ngày (`POP-01`, `SCR-03`, `POP-05`)

#### `API-05` — Lấy chi tiết chấm công 1 ngày (`GET /api/v1/daily-logs/{workDate}`)
- **Role:** `MANAGER`, `STAFF`
- **Path Param:** `workDate` (`YYYY-MM-DD`).
- **Query Param:** `userId` (`Long`, tùy chọn — chỉ `MANAGER` được truyền để xem chi tiết nhân viên khác trên `POP-05`; `STAFF` truyền `userId` khác mình -> `403 FORBIDDEN_ACCESS`).
- **Response `200 OK` (`ApiResponse.data`):**
  ```json
  {
    "workDate": "2026-11-20",
    "isLocked": false,
    "exists": true,
    "dailyId": 101,
    "checkInTime": "09:00",
    "checkOutTime": "18:30",
    "breakMinutes": 60,
    "regularMinutes": 480,
    "overtimeMinutes": 30,
    "actualMinutes": 510,
    "details": [
      {
        "logDetailId": 501,
        "projectId": 10,
        "projectCode": "PRJ-001",
        "projectName": "Hệ thống HR",
        "taskId": 5,
        "taskCode": "01",
        "taskName": "要件定義",
        "effortMinutes": 360
      }
    ]
  }
  ```
- **Lưu ý BE:** Nếu ngày đó chưa có bản ghi -> trả `exists: false, dailyId: null, details: []`.

#### `API-06` — Lấy danh sách Task theo phòng ban (`GET /api/v1/master/tasks`)
- **Role:** `MANAGER`, `STAFF`
- **Query Param:** `departmentId` (`Integer`, tùy chọn, mặc định theo `currentUser.departmentId`).
- **Response `200 OK` (`ApiResponse.data`):**
  ```json
  {
    "departmentId": 1,
    "tasks": [
      { "taskId": 1, "taskCode": "01", "taskName": "要件定義", "isCommon": false },
      { "taskId": 91, "taskCode": "91", "taskName": "朝礼", "isCommon": true }
    ]
  }
  ```
- **Lưu ý BE:** `WHERE (department_id = :deptId OR department_id IS NULL) AND deleted_at IS NULL ORDER BY task_code ASC`.

#### `API-07` — Tạo mới chấm công ngày (`POST /api/v1/daily-logs`)
- **Role:** `MANAGER`, `STAFF` (tạo cho chính mình trên `POP-01`)
- **Request Body:**
  ```json
  {
    "workDate": "2026-11-20",
    "checkInTime": "09:00",
    "checkOutTime": "18:30",
    "breakMinutes": 60,
    "details": [
      { "projectId": 10, "taskId": 1, "effortMinutes": 360 },
      { "projectId": 10, "taskId": 91, "effortMinutes": 150 }
    ]
  }
  ```
- **Response `201 Created` (`ApiResponse.data`):**
  ```json
  {
    "dailyId": 105,
    "workDate": "2026-11-20",
    "regularMinutes": 480,
    "overtimeMinutes": 30,
    "actualMinutes": 510
  }
  ```
- **Lỗi:** `400 VALIDATION_ERROR`, `400 EFFORT_MISMATCH`, `409 DUPLICATE_WORK_DATE`, `422 FUTURE_DATE_NOT_ALLOWED`, `422 MONTH_LOCKED`.

#### `API-08` — Cập nhật chấm công ngày (`PUT /api/v1/daily-logs/{dailyId}`)
- **Role:** `MANAGER`, `STAFF` (chỉ sửa bản ghi của chính mình trên `SCR-03`)
- **Path Param:** `dailyId` (`Long`).
- **Request Body:** Giống `API-07` (không cần `workDate`).
- **Response `200 OK` (`ApiResponse.data`):** Giống `API-07`.
- **Lỗi:** `400 VALIDATION_ERROR`, `400 EFFORT_MISMATCH`, `403 FORBIDDEN_ACCESS`, `404 RESOURCE_NOT_FOUND`, `422 MONTH_LOCKED`.

---

### Nhóm 4: Thống kê công sức & Xuất CSV (`SCR-05`, `SCR-06`, `POP-06`)

#### `API-09` — Lấy dữ liệu bộ lọc Phòng ban & Nhân viên (`GET /api/v1/reports/filters`)
- **Role:** `MANAGER`
- **Query Params:** `departmentId` (`Integer`, tùy chọn), `userId` (`Long`, tùy chọn).
- **Response `200 OK` (`ApiResponse.data`):**
  ```json
  {
    "departments": [
      { "departmentId": 1, "departmentCode": "DEV", "departmentName": "開発部" }
    ],
    "users": [
      { "userId": 1, "userName": "sato kenji", "fullname": "佐藤 健司", "departmentId": 1 }
    ],
    "selectedDepartmentId": 1
  }
  ```
- **Lưu ý BE:** Hỗ trợ liên động 2 chiều (chọn `departmentId` -> lọc `users`; chọn `userId` -> trả `selectedDepartmentId`).

#### `API-10` — Tổng hợp Man-hours 3 chế độ (`GET /api/v1/reports/man-hours`)
- **Role:** `MANAGER`
- **Query Params:**
  - `month`: `YYYY-MM` (**bắt buộc**, VD: `2026-11`).
  - `departmentId`: `Integer` (tùy chọn; `null` = `全社` Toàn công ty).
  - `userId`: `Long` (tùy chọn; `null` = Tất cả nhân viên).
  - `type`: `PROJECT_TASK | DEPT_TASK | DEPT_PROJECT` (tùy chọn để phân trang theo tab đang xem).
  - `page`: `Integer` (mặc định `1`), `size`: `Integer` (mặc định `20`).
- **Response `200 OK` (`ApiResponse.data`):**
  ```json
  {
    "yearMonth": "2026-11",
    "grandTotalMinutes": 3600,
    "grandTotalFormatted": "60:00",
    "byProjectTask": [
      { "projectCode": "PRJ-001", "projectName": "Hệ thống HR", "taskCode": "01", "taskName": "要件定義", "totalMinutes": 1200, "formattedHours": "20:00" }
    ],
    "byDepartmentTask": [
      { "departmentCode": "DEV", "departmentName": "開発部", "taskCode": "01", "taskName": "要件定義", "totalMinutes": 2400, "formattedHours": "40:00" }
    ],
    "byDepartmentProject": [
      { "departmentCode": "DEV", "departmentName": "開発部", "projectCode": "PRJ-001", "projectName": "Hệ thống HR", "totalMinutes": 3600, "formattedHours": "60:00" }
    ],
    "pagination": { "page": 1, "size": 20, "totalElements": 15, "totalPages": 1 }
  }
  ```

#### `API-11` — Xuất file CSV Shift-JIS (`GET /api/v1/reports/man-hours/export`)
- **Role:** `MANAGER`
- **Query Params:** `type` (`PROJECT_TASK | DEPT_TASK | DEPT_PROJECT`, bắt buộc), `month` (`YYYY-MM`, bắt buộc), `departmentId` (tùy chọn), `userId` (tùy chọn).
- **Response `200 OK` (Binary Stream — KHÔNG bọc `ApiResponse`):**
  - `Content-Type: text/csv; charset=Shift_JIS`
  - `Content-Disposition: attachment; filename="manhours_YYYYMM.csv"` (VD: `manhours_202611.csv`).
  - Mã hóa bằng `Charset.forName("MS932")`, xuất toàn bộ dữ liệu khớp bộ lọc (không cắt trang).

---

### Nhóm 5: Quản lý Dự án (`SCR-04`, `POP-02`, `POP-03`, `POP-04`)

#### `API-12` — Lấy danh sách dự án tham gia (`GET /api/v1/projects`)
- **Role:** `MANAGER`, `STAFF`
- **Query Params:** `isActive` (`Boolean`, mặc định `true`), `page` (mặc định `1`), `size` (mặc định `10`).
- **Response `200 OK` (`ApiResponse.data`):**
  ```json
  {
    "canCreateProject": true,
    "projects": [
      {
        "projectId": 10,
        "projectCode": "PRJ-001",
        "projectName": "Hệ thống Quản lý Chấm công",
        "isActive": true,
        "isManager": true,
        "memberCount": 4,
        "memberPreviews": [
          { "userId": 1, "fullname": "佐藤 健司" }
        ]
      }
    ],
    "pagination": { "page": 1, "size": 10, "totalElements": 12, "totalPages": 2 }
  }
  ```
- **Lưu ý BE:** `canCreateProject = (currentUser.role == "MANAGER")`.

#### `API-13` — Xem chi tiết dự án & thành viên (`GET /api/v1/projects/{projectId}`)
- **Role:** `MANAGER`, `STAFF`
- **Path Param:** `projectId` (`Long`).
- **Response `200 OK` (`ApiResponse.data`):** Trả `projectId`, `projectCode`, `projectName`, `isActive`, `canAddMember` (`true` nếu `role == "MANAGER"`), và danh sách `members[]` (`userId`, `userName`, `fullname`, `departmentName`, `isManager`).
- **Lỗi:** `403 FORBIDDEN_ACCESS` (không thuộc dự án), `404 RESOURCE_NOT_FOUND`.

#### `API-14` — Tạo dự án mới (`POST /api/v1/projects`)
- **Role:** `MANAGER`
- **Request Body:**
  ```json
  {
    "projectCode": "PRJ-005",
    "projectName": "Website Quảng cáo 2027",
    "memberIds": [2, 3]
  }
  ```
- **Validation:** `projectCode` nhập tay bắt buộc (<= 20 ký tự, `UNIQUE`), `projectName` nhập tay bắt buộc (<= 75 ký tự).
- **Response `201 Created` (`ApiResponse.data`):** Trả `projectId`, `projectCode`, `projectName`, `isActive`.
- **Lỗi:** `400 VALIDATION_ERROR`, `403 FORBIDDEN_ACCESS`, `409 DUPLICATE_PROJECT_CODE`.

#### `API-15` — Tìm kiếm nhân viên để thêm vào dự án (`GET /api/v1/users/selectable`)
- **Role:** `MANAGER`
- **Query Params:** `excludeProjectId` (`Long`, tùy chọn), `keyword` (`String`, tùy chọn).
- **Response `200 OK` (`ApiResponse.data`):** `{ "users": [ { "userId", "userName", "fullname", "departmentName" } ] }`.

#### `API-16` — Thêm thành viên vào dự án (`POST /api/v1/projects/{projectId}/members`)
- **Role:** `MANAGER`
- **Request Body:**
  ```json
  {
    "members": [
      { "userId": 4, "isManager": false },
      { "userId": 5, "isManager": true }
    ]
  }
  ```
- **Response `200 OK` (`ApiResponse.data`):** `{ "projectId": 10, "addedCount": 2 }`.
- **Lỗi:** `400 VALIDATION_ERROR`, `403 FORBIDDEN_ACCESS`, `404 RESOURCE_NOT_FOUND`, `409 DUPLICATE_PROJECT_MEMBER`.

---

## 3. Danh mục Mã lỗi chuẩn (Error Code Catalog)

| Error Code | HTTP Status | API phát sinh | Điều kiện kích hoạt (BE) & Xử lý (FE) |
| :--- | :---: | :--- | :--- |
| `VALIDATION_ERROR` | `400` | Tất cả `POST`/`PUT`/`GET` có param | Thiếu trường bắt buộc, sai format ngày/tháng/giờ, không chia hết cho 10p, `T <= 0`, số dòng Task `< 1` hoặc `> 20`, Task vượt `30:50` (`1850`p), hoặc `taskId` ngoài phòng ban. FE hiển thị lỗi theo từng field trong `data`. |
| `EFFORT_MISMATCH` | `400` | `API-07`, `API-08` | `SUM(details[].effortMinutes) != T`. FE chặn lưu, hiển thị lỗi tại khu vực tổng thời gian `合計時間`. |
| `INVALID_CREDENTIALS` | `401` | `API-01` | Sai `userName` / `password` hoặc tài khoản đã bị soft-delete. FE giữ `userName`, xóa trống `password`, hiện thông báo lỗi. |
| `UNAUTHORIZED` | `401` | `API-02` ~ `API-16` | Thiếu JWT Token, token sai hoặc hết hạn. `axiosClient.ts` tự xóa token và chuyển về `/login` (`SCR-01`). |
| `FORBIDDEN_ACCESS` | `403` | `API-04, 05, 08, 09~16` | `STAFF` gọi API của `MANAGER`, xem/sửa dữ liệu của user khác, hoặc truy cập dự án mình không tham gia. |
| `RESOURCE_NOT_FOUND` | `404` | `API-08, 13, 16` | Không tìm thấy `dailyId`, `projectId`, `userId` hoặc bản ghi đã bị `deleted_at IS NOT NULL`. |
| `DUPLICATE_WORK_DATE` | `409` | `API-07` | Ngày `workDate` đã có bản ghi chấm công active của user này. FE báo lỗi dưới Date Picker `対象日`. |
| `DUPLICATE_PROJECT_CODE` | `409` | `API-14` | Mã dự án `projectCode` đã tồn tại trong bảng `projects`. FE báo lỗi dưới ô `プロジェクトコード`. |
| `DUPLICATE_PROJECT_MEMBER` | `409` | `API-16` | Nhân viên đã tồn tại active trong dự án `projectId`. |
| `MONTH_LOCKED` | `422` | `API-07`, `API-08` | Thời điểm hiện tại đã quá `23:59:59` ngày `01` tháng `M+1` (`Asia/Ho_Chi_Minh`). FE thông báo tháng đã khóa sổ và vô hiệu hóa thao tác. |
| `FUTURE_DATE_NOT_ALLOWED` | `422` | `API-07` | `workDate > LocalDate.now()`. FE báo lỗi dưới Date Picker `対象日`. |
| `INTERNAL_SERVER_ERROR` | `500` | Tất cả | Lỗi hệ thống không mong muốn. FE hiện Toast lỗi chung và giữ nguyên dữ liệu đang nhập trên form. |