---
trigger: glob
glob: "frontend/src/**/*.{vue,ts,css}"
---

# Frontend Coding Rules (Vue 3 + TypeScript + Vite + Pinia)

> **Căn cứ:** Đồng bộ 100% với source code base thực tế `frontend/` (`package.json`, `.env.development`, `axiosClient.ts`, `types/api.ts`, `main.css`, `BaseButton.vue`, `useNotification.ts`) và `Design_Definition_v1.0`.

## 1. Cấu trúc Thư mục `frontend/src/` (Bắt buộc tuân thủ)

```text
frontend/src/
├── api/                 # axiosClient.ts (đã có) và các file *Api.ts (authApi, attendanceApi, projectApi, reportApi)
├── assets/styles/       # main.css (Design Tokens CSS Variables + class dùng chung .card, .data-table, .form-input...)
├── components/
│   ├── common/          # BaseButton.vue (đã có), BaseModal.vue, BasePagination.vue, AppSidebar.vue, AppHeader.vue
│   ├── attendance/      # Components cho SCR-02, POP-01, SCR-03, SCR-05, POP-05
│   ├── project/         # Components cho SCR-04, POP-02, POP-03, POP-04
│   └── report/          # Components cho SCR-06, POP-06
├── composables/         # useNotification.ts (đã có), useTimeCalculation.ts...
├── router/              # index.ts (Lazy loading routes + Navigation Guard kiểm tra Auth & Role STAFF/MANAGER)
├── stores/              # Pinia Setup Stores (authStore, attendanceStore, projectStore, reportStore)
├── types/               # api.ts (đã có ApiResponse<T>), auth.ts, attendance.ts, project.ts, report.ts
└── views/               # Page views cho 6 màn hình chính (SCR-01 ~ SCR-06)
```

## 2. Quy ước Code Vue 3 & TypeScript

- **Composition API:** Bắt buộc dùng `<script setup lang="ts">` cho mọi file `.vue`, thứ tự khối: `<script setup lang="ts">` -> `<template>` -> `<style scoped>`.
- **Strict TypeScript:** Không dùng `any`. Mọi Request/Response API phải khai báo interface rõ ràng trong `src/types/`. Chạy `npm run type-check` không được có lỗi trước khi commit.
- **Formatting:** Tuân thủ `.prettierrc` có sẵn (`semi: true`, `singleQuote: true`, `tabWidth: 2`, `printWidth: 100`).
- **Tách tầng & Tái sử dụng:**
  - `views/` và `components/` không gọi `axiosClient` trực tiếp -> phải đi qua `stores/` (Pinia Setup Store `defineStore('...', () => { ... })`) hoặc `api/`.
  - Tái sử dụng `BaseButton.vue`, `useNotification()` (`notifySuccess`, `notifyError`), và các class sẵn có trong `main.css` (`.card`, `.badge`, `.form-group`, `.form-input`, `.form-error`, `.data-table`).
  - Dùng path alias `@/` cho mọi import trong `src/`.

## 3. Đồng bộ Axios, Base URL & Chuẩn `ApiResponse<T>`

- **Base URL (KHÔNG đổi về `/api`):** Giữ nguyên cấu hình hiện tại là **`http://localhost:8080/api/v1`** (trong `frontend/.env.development` và fallback `'/api/v1'` của `axiosClient.ts`).
- **Wrapper `ApiResponse<T>`:** Mọi API JSON trả về cấu trúc `{ success, message, data, timestamp, errorCode? }` đã khai báo trong `src/types/api.ts`. File `*Api.ts` luôn unwrap lấy `response.data.data` khi thành công.
- **Auth Interceptors (Đã cài sẵn trong `axiosClient.ts`):**
  - Request Interceptor đã tự động đọc `localStorage.getItem('accessToken')` và gắn header `Authorization: Bearer <token>`.
  - Response Interceptor đã tự xử lý `401 Unauthorized` (xóa `accessToken` và chuyển về `/login`, bỏ qua khi đang gọi `/auth/login`).
  - Khi mở rộng xử lý lỗi business từ Backend, giữ nguyên thông tin `errorCode`, `message` và `data` (map lỗi theo field) để form hiển thị lỗi chính xác tại đúng trường (VD: `EFFORT_MISMATCH`, `MONTH_LOCKED`, `DUPLICATE_WORK_DATE`, `DUPLICATE_PROJECT_CODE`).
- **Download CSV (`API-11`):** Khi gọi `GET /reports/man-hours/export`, bắt buộc truyền `{ responseType: 'blob' }` và tạo link tải file trực tiếp theo tên `manhours_YYYYMM.csv` (không parse `ApiResponse` JSON).

## 4. Styling, Icons & Design System (`Design_Definition_v1.0`)

- **CSS thuần + CSS Variables:** Dự án **không cài Tailwind CSS**. Mọi style viết bằng CSS Variables từ `src/assets/styles/main.css` kết hợp `<style scoped>`.
- **Quản lý thư viện (`package.json`):** Không tự ý chạy `npm install` thêm thư viện trên nhánh tính năng riêng lẻ để tránh xung đột `package-lock.json`. Với Icon, dùng SVG inline hoặc dùng `lucide-vue-next` **chỉ sau khi** đã được cài chung trên nhánh nền `main`.
- **Ánh xạ Token màu trong `main.css`:** Sử dụng đúng bảng biến màu chuẩn trong `docs/02-design-system.md` (`--color-primary: #0055A0`, `--color-deep-ocean: #12284B`, `--color-secondary: #438BC4`, `--color-table-header: #8CC1E9`, `--color-accent-bg: #FFF8E7`, `--color-bg: #FFFFFF`, `--color-surface: #F7F9FC`, `--color-border: #D5E1ED`, `--color-text: #334155`, `--color-success: #10B981`, `--color-warning: #F59E0B`, `--color-danger: #EF4444`, `--color-disabled: #94A3B8`).
- **Font & Số liệu giờ:** Font `'Noto Sans JP', Arial, sans-serif`; các cột hiển thị thời gian (`HH:mm`) bắt buộc dùng `font-variant-numeric: tabular-nums;`.

## 5. Quy tắc UX & Accessibility Bắt buộc

- Mọi ô Input/Dropdown phải có `<label>` hiển thị rõ và ký hiệu `必須` nếu bắt buộc.
- Ô `userName` tại `SCR-01` **cho phép khoảng trắng** (khớp dữ liệu mẫu `'sato kenji'`).
- Nút Icon-only (`×`, xóa dòng, tìm kiếm) bắt buộc có `aria-label` và `title`.
- Modal (`POP-01 ~ POP-06`) luôn gồm 3 phần: `Modal Header` - `Modal Body` - `Modal Footer` trên nền overlay `rgba(18, 40, 75, 0.45)`.
- Khi lưu lỗi (`4xx`/`5xx`): **giữ nguyên toàn bộ dữ liệu người dùng đang nhập trên form**, tuyệt đối không reset form (ngoại trừ ô `password` khi login sai ở `SCR-01`).