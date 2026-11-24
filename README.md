# Project Template: Java 21 + Vue 3 + MySQL

Template dự án Full-stack được tách biệt rõ ràng giữa **Backend (`backend/`)** và **Frontend (`frontend/`)**, đã cài đặt sẵn các dependency cốt lõi, cấu hình kết nối DB, xử lý lỗi chuẩn hóa và một module mẫu hoàn chỉnh (**Product CRUD**) để các thành viên mới có thể đọc và code theo đúng quy chuẩn.

> Xem chi tiết kiến trúc thư mục và quy ước viết code tại [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md).

---

## 1. Công nghệ sử dụng (Tech Stack)

| Thành phần | Công nghệ / Phiên bản | Ghi chú |
| :--- | :--- | :--- |
| **Backend** | Java 21 (LTS), Spring Boot 3.3.5, Maven | Spring Web, Spring Data JPA, Validation, Lombok, Swagger (Springdoc OpenAPI) |
| **Frontend** | Vue 3, Vite, TypeScript | Composition API (`<script setup>`), Pinia, Vue Router, Axios |
| **Database** | MySQL 8.0 | Hỗ trợ chạy nhanh bằng Docker Compose hoặc cài MySQL cục bộ |

---
## 2. Yêu cầu môi trường (Prerequisites)

Đảm bảo máy phát triển đã cài đặt các công cụ sau:

| Công cụ | Phiên bản tối thiểu | Lệnh kiểm tra |
| :--- | :--- | :--- |
| **JDK** | Java 21 | `java -version` |
| **Maven** | 3.9+ | `mvn -version` |
| **Node.js** | 20.x LTS (hoặc 18.18+) | `node -v` |
| **npm** | 9+ | `npm -v` |
| **MySQL** | 8.0 (hoặc Docker Desktop) | `mysql --version` / `docker --version` |

---

## 3. Hướng dẫn Setup & Chạy dự án

### Bước 1: Chuẩn bị biến môi trường

1. **Backend:** Copy file mẫu môi trường nếu muốn tùy chỉnh thông số DB/Port (hoặc dùng giá trị mặc định trong `application.yml`):
   ```bash
   cd backend
   copy .env.example .env
   ```
   *(Trên Linux/macOS dùng `cp .env.example .env`. Lưu ý: Spring Boot không tự đọc file `.env` trừ khi bạn export biến môi trường hoặc cấu hình trong IDE; các giá trị mặc định đã được thiết lập sẵn trong `src/main/resources/application.yml` để chạy khớp với `docker-compose.yml`.)*

2. **Frontend:** File `frontend/.env.development` đã được tạo sẵn. Nếu cần thay đổi, copy từ `frontend/.env.example`:
   ```bash
   cd frontend
   copy .env.example .env.local
   ```

---

### Bước 2: Khởi tạo Database (MySQL)

Chọn **một trong hai** cách sau:

#### Cách A: Dùng Docker Compose (Khuyến nghị)
Tại thư mục gốc dự án (`project1/`):
```bash
docker compose up -d
```
Container MySQL 8.0 sẽ tự động:
- Tạo database `project_db`
- Tạo user `app_user` / mật khẩu `app_password`
- Chạy file `backend/src/main/resources/db/init.sql` để tạo bảng `products` và thêm sẵn 3 dữ liệu mẫu.

Kiểm tra container đang chạy:
```bash
docker compose ps
```

#### Cách B: Dùng MySQL cài đặt trực tiếp trên máy (Local MySQL)
1. Mở MySQL Workbench hoặc CLI bằng quyền `root`.
2. Tạo user và database (hoặc chỉnh `DB_USERNAME` / `DB_PASSWORD` khớp với máy bạn):
   ```sql
   CREATE USER IF NOT EXISTS 'app_user'@'localhost' IDENTIFIED BY 'app_password';
   GRANT ALL PRIVILEGES ON project_db.* TO 'app_user'@'localhost';
   FLUSH PRIVILEGES;
   ```
3. Chạy script khởi tạo bảng và dữ liệu mẫu tại `backend/src/main/resources/db/init.sql`:
   ```bash
   mysql -u root -p < backend/src/main/resources/db/init.sql
   ```

---

### Bước 3: Chạy Backend (Java 21 + Spring Boot)

Mở terminal tại thư mục gốc và di chuyển vào `backend`:
```bash
cd backend
mvn clean install
mvn spring-boot:run
```
Hoặc chạy với profile `dev` để bật log SQL chi tiết:
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

- **Backend API URL:** `http://localhost:8080`
- **Swagger UI (API Docs):** `http://localhost:8080/swagger-ui.html`

Chạy Unit Test của Backend:
```bash
mvn test
```

---

### Bước 4: Chạy Frontend (Vue 3 + Vite)

Mở một terminal mới, di chuyển vào thư mục `frontend`:
```bash
cd frontend
npm install
npm run dev
```

- **Frontend URL:** `http://localhost:5173`
- Kiểm tra TypeScript & build production:
  ```bash
  npm run type-check
  npm run build
  ```

---

## 4. API Mẫu (Sample Product CRUD)

Backend và Frontend đã được kết nối sẵn qua module mẫu **Product** (`http://localhost:8080/api/v1/products`):

| Method | Endpoint | Mô tả |
| :--- | :--- | :--- |
| `GET` | `/api/v1/products` | Lấy danh sách sản phẩm (hỗ trợ `?keyword=...`) |
| `GET` | `/api/v1/products/{id}` | Lấy chi tiết sản phẩm theo ID |
| `POST` | `/api/v1/products` | Tạo mới sản phẩm (có Validation) |
| `PUT` | `/api/v1/products/{id}` | Cập nhật sản phẩm theo ID |
| `DELETE` | `/api/v1/products/{id}` | Xóa sản phẩm theo ID |

Tất cả API đều trả về cấu trúc chuẩn:
```json
{
  "success": true,
  "message": "Success",
  "data": {},
  "timestamp": "2026-11-24T21:30:00"
}
```
