# Cấu trúc Dự án & Quy ước Code (Project Structure & Conventions)

Tài liệu này mô tả chi tiết cách phân chia thư mục, trách nhiệm của từng tầng (layer), quy ước đặt tên và hướng dẫn thêm tính năng mới theo chuẩn của dự án mẫu.

---

## 1. Cấu trúc tổng thể (Directory Tree)

```text
project1/
├── .gitignore
├── docker-compose.yml              # Khởi chạy MySQL 8.0 nhanh bằng Docker
├── README.md                       # Hướng dẫn setup và chạy dự án
├── PROJECT_STRUCTURE.md            # Tài liệu phân chia code & quy ước (file này)
│
├── backend/                        # Mã nguồn Java 21 + Spring Boot 3.3.5
│   ├── .env.example
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/project/app/
│       │   │   ├── Application.java
│       │   │   ├── common/
│       │   │   │   ├── exception/
│       │   │   │   │   ├── GlobalExceptionHandler.java
│       │   │   │   │   └── ResourceNotFoundException.java
│       │   │   │   └── response/
│       │   │   │       └── ApiResponse.java
│       │   │   ├── config/
│       │   │   │   ├── CorsConfig.java
│       │   │   │   └── JpaAuditingConfig.java
│       │   │   ├── controller/
│       │   │   │   └── ProductController.java
│       │   │   ├── dto/
│       │   │   │   ├── request/
│       │   │   │   │   └── ProductRequest.java
│       │   │   │   └── response/
│       │   │   │       └── ProductResponse.java
│       │   │   ├── entity/
│       │   │   │   ├── BaseEntity.java
│       │   │   │   └── Product.java
│       │   │   ├── mapper/
│       │   │   │   └── ProductMapper.java
│       │   │   ├── repository/
│       │   │   │   └── ProductRepository.java
│       │   │   └── service/
│       │   │       ├── ProductService.java
│       │   │       └── impl/
│       │   │           └── ProductServiceImpl.java
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── application-dev.yml
│       │       └── db/
│       │           └── init.sql
│       └── test/
│           └── java/com/project/app/
│               └── service/
│                   └── ProductServiceImplTest.java
│
└── frontend/                       # Mã nguồn Vue 3 + Vite + TypeScript
    ├── .env.development
    ├── .env.example
    ├── .prettierrc
    ├── env.d.ts
    ├── index.html
    ├── package.json
    ├── tsconfig.json
    ├── tsconfig.app.json
    ├── tsconfig.node.json
    ├── vite.config.ts
    └── src/
        ├── App.vue
        ├── main.ts
        ├── api/
        │   ├── axiosClient.ts
        │   └── productApi.ts
        ├── assets/
        │   └── styles/
        │       └── main.css
        ├── components/
        │   ├── common/
        │   │   └── BaseButton.vue
        │   └── product/
        │       ├── ProductForm.vue
        │       └── ProductTable.vue
        ├── composables/
        │   └── useNotification.ts
        ├── router/
        │   └── index.ts
        ├── stores/
        │   └── productStore.ts
        ├── types/
        │   ├── api.ts
        │   └── product.ts
        └── views/
            ├── HomeView.vue
            └── ProductListView.vue
```

---

## 2. Kiến trúc Backend (`backend/`)

Backend áp dụng mô hình **Layered Architecture** (Phân tầng theo trách nhiệm).

### Luồng xử lý Request
```text
Client (Vue 3)
  │
  ▼
Controller  ──(nhận ProductRequest, validate @Valid, trả về ApiResponse)
  │
  ▼
Service     ──(xử lý business logic, transaction @Transactional)
  │
  ▼
Mapper      ──(chuyển đổi giữa Request DTO <-> Entity <-> Response DTO)
  │
  ▼
Repository  ──(giao tiếp Database qua Spring Data JPA)
  │
  ▼
MySQL Database
```

### Vai trò từng package trong `com.project.app`

| Package | Trách nhiệm | Quy tắc |
| :--- | :--- | :--- |
| `controller` | Tiếp nhận HTTP Request, định nghĩa REST endpoints, validate đầu vào (`@Valid`) và trả về `ResponseEntity<ApiResponse<T>>`. | **Không** viết logic nghiệp vụ hoặc gọi trực tiếp `Repository` trong Controller. |
| `service` & `service.impl` | Khai báo interface nghiệp vụ (`ProductService`) và cài đặt logic (`ProductServiceImpl`). Quản lý transaction (`@Transactional`). | Đặt `@Transactional(readOnly = true)` ở class và `@Transactional` cho các method ghi dữ liệu. |
| `repository` | Giao tiếp DB bằng `JpaRepository`. Chỉ chứa các query liên quan đến Entity tương ứng. | Trả về `Optional` hoặc `List`/`Page`, không ném HTTP exception tại đây. |
| `entity` | Ánh xạ bảng trong MySQL (`@Entity`). Mọi entity kế thừa `BaseEntity` để tự động có `id`, `createdAt`, `updatedAt`. | **Không** trả trực tiếp `Entity` ra API response. |
| `dto.request` / `dto.response` | Tách biệt dữ liệu đầu vào (có annotation Validation) và dữ liệu đầu ra. | Luôn dùng DTO để giao tiếp với Controller. |
| `mapper` | Chuyển đổi dữ liệu giữa `DTO` và `Entity`. | Tập trung mapping tại đây để Service gọn gàng. |
| `common.response` | Chứa `ApiResponse<T>` chuẩn hóa format JSON trả về cho toàn bộ hệ thống. | Mọi endpoint đều bọc dữ liệu trong `ApiResponse`. |
| `common.exception` | Chứa Custom Exception (`ResourceNotFoundException`) và `GlobalExceptionHandler` (`@RestControllerAdvice`). | Ném exception ở Service, không `try/catch` tràn lan ở Controller. |
| `config` | Cấu hình chung như `CorsConfig`, `JpaAuditingConfig`. | Tách riêng các cấu hình Spring Boot. |

---

## 3. Kiến trúc Frontend (`frontend/`)

Frontend sử dụng **Vue 3 Composition API** kết hợp **TypeScript**, **Pinia** và **Axios**.

### Luồng dữ liệu (Data Flow)
```text
View (ProductListView.vue)
  ├── render UI bằng Components (ProductTable, ProductForm, BaseButton)
  ├── gọi Store (useProductStore)
  │      │
  │      ▼
  │   API Module (productApi.ts) ──► axiosClient.ts ──► Backend REST API
  │
  └── hiển thị thông báo qua Composable (useNotification)
```

### Vai trò từng thư mục trong `src/`

| Thư mục | Trách nhiệm | Quy ước |
| :--- | :--- | :--- |
| `views/` | Các trang chính gắn trực tiếp với route trong Vue Router (ví dụ: `HomeView.vue`, `ProductListView.vue`). | Chỉ điều phối dữ liệu từ Store/Composable xuống các Component con. |
| `components/common/` | UI component dùng chung toàn dự án (`BaseButton.vue`, Modal, Input...). | Đặt tiền tố `Base...` (ví dụ `BaseButton.vue`). |
| `components/<feature>/` | Component chuyên biệt cho từng nghiệp vụ (`ProductForm.vue`, `ProductTable.vue`). | Tổ chức theo thư mục feature để tránh phình to thư mục gốc. |
| `stores/` | Quản lý state tập trung bằng Pinia (`productStore.ts` -> `useProductStore`). | Dùng Setup Store syntax (`defineStore('name', () => { ... })`). |
| `api/` | Chứa `axiosClient.ts` (cấu hình base URL, timeout, interceptor xử lý lỗi) và các file gọi API theo từng module (`productApi.ts`). | Component/View **không** gọi `axios` trực tiếp, phải đi qua `api/` (hoặc `stores/`). |
| `composables/` | Tái sử dụng logic reactive (`useNotification.ts`). | Đặt tên bắt đầu bằng `use...`. |
| `types/` | Khai báo TypeScript interface/type dùng chung (`api.ts`, `product.ts`). | Đồng bộ kiểu dữ liệu với DTO của Backend. |
| `router/` | Cấu hình route, lazy loading cho các View. | Sử dụng `() => import('@/views/...')` cho các trang chức năng. |
| `assets/` | CSS toàn cục, biến màu (`--color-*`), hình ảnh, font chữ. | Dùng CSS variables trong `main.css` để thống nhất giao diện. |

---

## 4. Quy ước Code (Coding Conventions)

### Backend (Java 21)
1. **Đặt tên REST API:** Dùng danh từ số nhiều, kebab-case, có version: `/api/v1/products`, `/api/v1/order-items`.
2. **Format Response chuẩn (`ApiResponse<T>`):**
   - Thành công: `{ "success": true, "message": "...", "data": ..., "timestamp": "..." }`
   - Thất bại: `{ "success": false, "message": "...", "data": <chi tiết lỗi nếu có>, "timestamp": "..." }`
3. **Constructor Injection:** Dùng `@RequiredArgsConstructor` của Lombok kết hợp biến `private final` (tránh `@Autowired` trên field).
4. **Java 21:** Khuyến khích tận dụng các tính năng hiện đại của Java 21 (như `record` cho các DTO bất biến nếu phù hợp, pattern matching, `var` cho biến cục bộ rõ kiểu).

### Frontend (Vue 3 + TypeScript)
1. **Single File Component:** Luôn dùng `<script setup lang="ts">` và đặt `<script>` -> `<template>` -> `<style scoped>`.
2. **Đặt tên file:**
   - Component & View: `PascalCase` (ví dụ `ProductTable.vue`, `ProductListView.vue`).
   - API, Store, Type, Utility: `camelCase` (ví dụ `productApi.ts`, `productStore.ts`).
   - Composable: `use` + `PascalCase` (ví dụ `useNotification.ts`).
3. **TypeScript nghiêm ngặt:** Luôn khai báo kiểu cho `props`, `emits`, dữ liệu trả về từ API (`ApiResponse<Product>`), tránh dùng `any`.

---

## 5. Hướng dẫn thêm một Module mới (dựa theo mẫu `Product`)

Giả sử bạn cần làm thêm tính năng quản lý **Category** (Danh mục):

### Phía Backend (`backend/src/main/java/com/project/app/`)
1. `entity/Category.java`: Tạo entity kế thừa `BaseEntity`, khai báo `@Table(name = "categories")`.
2. `repository/CategoryRepository.java`: Tạo interface kế thừa `JpaRepository<Category, Long>`.
3. `dto/request/CategoryRequest.java` & `dto/response/CategoryResponse.java`: Tạo DTO + Validation annotations.
4. `mapper/CategoryMapper.java`: Viết các hàm chuyển đổi `toEntity`, `toResponse`, `updateEntity`.
5. `service/CategoryService.java` & `service/impl/CategoryServiceImpl.java`: Implement logic CRUD, dùng `ResourceNotFoundException` khi không tìm thấy ID.
6. `controller/CategoryController.java`: Expose endpoints tại `/api/v1/categories`, trả về `ApiResponse<...>`.
7. `src/test/.../CategoryServiceImplTest.java`: Viết unit test bằng JUnit 5 + Mockito.

### Phía Frontend (`frontend/src/`)
1. `types/category.ts`: Định nghĩa `Category` và `CategoryPayload`.
2. `api/categoryApi.ts`: Gọi endpoint `/categories` thông qua `axiosClient`.
3. `stores/categoryStore.ts`: Tạo Pinia store `useCategoryStore` quản lý danh sách, trạng thái `loading`, `error` và các action CRUD.
4. `components/category/CategoryTable.vue` & `CategoryForm.vue`: Tạo UI hiển thị bảng và form nhập liệu.
5. `views/CategoryListView.vue`: Ghép Table, Form, Store và `useNotification`.
6. `router/index.ts` & `App.vue`: Khai báo route `/categories` và thêm link điều hướng trên menu.
