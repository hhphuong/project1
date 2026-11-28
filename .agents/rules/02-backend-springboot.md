---
trigger: glob
glob: "backend/**/*.java"
---

# Backend Coding Rules (Java 21 + Spring Boot 3.3.5 + MySQL 8 Local)

> **Căn cứ:** Đồng bộ 100% với source code base thực tế `com.project.app` (`backend/pom.xml`, `application.yml`, `BaseEntity.java`, `SecurityConfig.java`, `ApiResponse.java`, `GlobalExceptionHandler.java`) và `Database_attendance.sql`.

## 1. Cấu trúc Package & Kiến trúc Phân tầng (Bắt buộc giữ nguyên)

Root package: `com.project.app`

```text
com.project.app/
├── common/
│   ├── exception/       # GlobalExceptionHandler, ResourceNotFoundException, BusinessException
│   └── response/        # ApiResponse<T>, PageMeta (pagination)
├── config/              # CorsConfig, JpaAuditingConfig, SecurityConfig (đã có sẵn)
├── security/            # JwtTokenProvider, JwtAuthenticationFilter, UserPrincipal (tạo ở SCR-01)
├── controller/          # REST Controllers (@RestController, @RequestMapping("/api/v1/..."))
├── dto/
│   ├── request/         # Request DTOs (kèm Jakarta Validation @NotBlank, @NotNull...)
│   └── response/        # Response DTOs (camelCase, tuyệt đối không trả Entity hay password)
├── entity/              # BaseEntity (đã sửa sẵn) + 8 JPA Entities ánh xạ attendance_db
├── mapper/              # Component Mapper chuyển đổi Request <-> Entity <-> Response
├── repository/          # Spring Data JPA Repositories
└── service/
    ├── *Service.java    # Interface nghiệp vụ
    └── impl/
        └── *ServiceImpl.java  # Implementation (@Service, @RequiredArgsConstructor)
```

### Luật phân tầng:
- **Controller:** Prefix bắt buộc là **`/api/v1/...`**. Chỉ nhận request, validate `@Valid`, gọi `Service`, trả `ResponseEntity<ApiResponse<T>>` (ngoại trừ `API-11` xuất CSV trả `ResponseEntity<byte[]>`). **Không** viết logic nghiệp vụ hoặc gọi `Repository` trực tiếp.
- **Service:** Dùng Constructor Injection (`@RequiredArgsConstructor` + `private final`). Đặt `@Transactional(readOnly = true)` ở cấp class và `@Transactional` ở các hàm ghi (`POST`/`PUT`/`DELETE`). Toàn bộ phân quyền (`STAFF`/`MANAGER`), kiểm tra khóa sổ tháng (`MONTH_LOCKED`) và công thức `BR-01 ~ BR-15` phải nằm ở Service.
- **Mapper:** Tách riêng class `@Component` trong `mapper/` (theo mẫu `ProductMapper`), không map thủ công rải rác trong Controller.
- **Repository:** Mọi query nghiệp vụ bắt buộc lọc `deletedAt IS NULL` (`deleted_at IS NULL`).

## 2. Quy ước Entity & ánh xạ `attendance_db`

- **Kế thừa trực tiếp `BaseEntity.java` có sẵn:** File `com.project.app.entity.BaseEntity` **đã được chuẩn hóa** trong repo (chỉ chứa `createdAt`, `updatedAt`, `deletedAt`, hàm `isDeleted()` / `softDelete()`, và **không** chứa `@Id`). **Không** tạo thêm `AuditableEntity` trùng lặp.
- **Khóa chính riêng từng bảng:** Mỗi Entity tự khai báo `@Id` khớp tên cột PK trong `Database_attendance.sql` (`department_id` kiểu `Integer`, `user_id` kiểu `Long`, `daily_id` kiểu `Long`, v.v.). Riêng `ProjectMember` dùng khóa chính phức hợp `@EmbeddedId` cho `(project_id, user_id)`.
- **Cột `check_in_time` & `check_out_time` trong `daily_logs`:** DB lưu kiểu **`DATETIME NULL`** (`LocalDateTime` trong Java), JSON API truyền/nhận chuỗi `"HH:mm"`. Khi lưu: ghép `workDate` + `LocalTime.parse(checkInTime)`; nếu `checkOutTime < checkInTime` (ca qua đêm) thì `check_out_time` lưu ngày `workDate.plusDays(1)`.
- **Cột `users.role` & `users.user_name`:**
  - `Database_SampleTest.sql` insert `role` chữ thường (`'manager'`, `'staff'`) -> Backend bắt buộc chuẩn hóa `.toUpperCase()` (hoặc `equalsIgnoreCase`) khi đọc từ DB và luôn trả `"MANAGER"` / `"STAFF"` trong JSON & JWT Claim.
  - `user_name` có chứa khoảng trắng (VD: `'sato kenji'`) -> **không** đặt regex cấm khoảng trắng trên DTO login.

## 3. Trạng thái Cấu hình Đã có sẵn trong Code Base (KHÔNG ghi đè tùy tiện)

- **Database Local (Không dùng Docker):** `application.yml` đã trỏ vào MySQL local `attendance_db`, múi giờ `Asia/Ho_Chi_Minh`, `ddl-auto: none`. Không tạo lại `docker-compose.yml` và không đổi `ddl-auto` sang `update`/`create`.
- **Security & JWT (`pom.xml` & `SecurityConfig.java`):**
  - `pom.xml` **đã cài sẵn** `spring-boot-starter-security`, `jjwt-api/impl/jackson` (`0.12.6`), `spring-security-test`. Không thêm thư viện JWT khác.
  - `SecurityConfig.java` **đã có sẵn** `BCryptPasswordEncoder`, `STATELESS` session và mở public `/api/v1/auth/login`, `/swagger-ui/**`, `/v3/api-docs/**`.
  - Chỉ thành viên phụ trách **`SCR-01` (Auth)** được phép thêm `JwtAuthenticationFilter` vào `SecurityConfig` và chuyển `.anyRequest().permitAll()` sang `.anyRequest().authenticated()`.
- **Chuẩn `ApiResponse<T>` & `GlobalExceptionHandler`:**
  - Toàn bộ JSON response thành công bọc trong `ApiResponse.success(data)` hoặc `ApiResponse.success(message, data)`.
  - Bổ sung trường `errorCode` (kiểu `String`, `@JsonInclude(NON_NULL)`) vào `ApiResponse<T>` và tạo `BusinessException(HttpStatus status, String errorCode, String message, Object details)` xử lý tập trung trong `GlobalExceptionHandler` để trả đúng các mã lỗi chuẩn (`EFFORT_MISMATCH`, `MONTH_LOCKED`, `DUPLICATE_WORK_DATE`, `FORBIDDEN_ACCESS`...).
- **Swagger / OpenAPI:** Giữ annotation `@Tag`, `@Operation` trên Controller mới để test tại `http://localhost:8080/swagger-ui.html`.
- **Module mẫu `Product*`:** Chỉ dùng làm tài liệu tham khảo mẫu code; chỉ xóa khi nhóm chốt dọn repo sau khi đã có module thật.

## 4. Quy tắc Unit Test (`src/test/java`)

- Viết Unit Test bằng **JUnit 5 + Mockito + AssertJ** theo mẫu `ProductServiceImplTest.java` (`@ExtendWith(MockitoExtension.class)`).
- Bắt buộc bao phủ đủ 8 case trong `.agents/rules/01-business-rules.md` (ca thường, OT, dưới 8h, ca qua đêm, nghỉ tự động `breakMinutes = 0`, lệch Gokei `EFFORT_MISMATCH`, giới hạn `1..20` dòng, ngày tương lai & khóa sổ tháng `MONTH_LOCKED`).
- Chạy xác nhận sạch lỗi trước khi commit: `mvn test`.