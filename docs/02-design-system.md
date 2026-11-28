# Global Design System & UI Standards (`Design_Definition_v1.0`)

> **Nguồn chuẩn:** Trích xuất trực tiếp từ `Design_Definition_v1.0.docx` và ánh xạ trực tiếp vào `frontend/src/assets/styles/main.css` (CSS Variables + `<style scoped>`, không dùng Tailwind CSS).

---

## 1. Color Palette (CSS Variables trong `frontend/src/assets/styles/main.css`)

### 1.1. Primary & Neutral Colors
| CSS Variable | Color Name | Hex Code | Usage |
| :--- | :--- | :---: | :--- |
| `--color-bg` | Background | `#FFFFFF` | Background chính toàn trang |
| `--color-surface` | Surface | `#F7F9FC` | Nền Card, Section, bảng phụ |
| `--color-accent-bg` | Clouds | `#FFF8E7` | Màu nền phụ, khu vực nhấn nhẹ |
| `--color-table-header` | Clear Skies | `#8CC1E9` | Highlight đầu mục bảng (Table Header) |
| `--color-deep-ocean` | Deep Ocean | `#12284B` | Màu heading, chữ quan trọng, khu vực Sidebar/Menu |
| `--color-primary` | Blueberry | `#0055A0` | Primary Button, Active Navigation, Focus Border |
| `--color-secondary` | Bluebird | `#438BC4` | Secondary accent, icon, link, thành phần phụ |
| `--color-text` | Body Text | `#334155` | Màu chữ nội dung thông thường |
| `--color-border` | Border | `#D5E1ED` | Đường viền mặc định của Input, Card, Table |

### 1.2. Semantic & Calendar Colors
| CSS Variable | State | Hex Code | Usage |
| :--- | :--- | :---: | :--- |
| `--color-success` | Success | `#10B981` | Thành công, giờ làm tiêu chuẩn (`所定内勤務時間`) |
| `--color-warning` | Warning | `#F59E0B` | Cảnh báo, giờ tăng ca OT (`残業時間`) |
| `--color-danger` | Error | `#EF4444` | Lỗi, validation error border & message |
| `--color-disabled` | Disabled | `#94A3B8` | Thành phần bị khóa / tháng đã khóa sổ |
| `--color-weekend-bg` | Weekend Tint | `#FFFBEB` | Nền phân biệt dòng Thứ Bảy (`WEEKEND`) |
| `--color-holiday-bg` | Holiday Tint | `#FEF2F2` | Nền phân biệt dòng Chủ Nhật / Ngày lễ (`HOLIDAY`) |

---

## 2. Typography

- **Font Family:** `'Noto Sans JP', Arial, sans-serif` (nhúng Google Fonts `Noto Sans JP` trong `frontend/index.html`).
- **Số liệu thời gian (`HH:mm`):** Bắt buộc thêm `font-variant-numeric: tabular-nums;` để thẳng hàng trong bảng.

| Text Style | Font Size | Font Weight | Usage |
| :--- | :---: | :---: | :--- |
| `H1` | `24px` | Bold (`700`) | Tiêu đề trang (`#12284B`) |
| `H2` | `20px` | Bold (`700`) | Tiêu đề khu vực (`#12284B`) |
| `H3` | `16px` | Bold (`700`) | Tiêu đề Card / Modal Title (`#12284B`) |
| `Body Large` | `16px` | Regular (`400`) | Nội dung chính |
| `Body` | `14px` | Regular (`400`) | Nội dung thông thường, dữ liệu ô bảng (`#334155`) |
| `Caption` | `12px` | Regular (`400`) | Chú thích, Helper text, Error message |
| `Button` | `14px` | Medium (`500`) | Nhãn nút bấm |
| `Table Header` | `14px` | Bold (`700`) | Tiêu đề cột bảng |

---

## 3. Spacing, Border, Radius & Shadow

- **Spacing Scale (bội số `4px`):**
  - `XS: 4px`, `SM: 8px`, `MD: 12px`, `LG: 16px`, `Card Padding: 20px`, `XL: 24px`, `2XL: 32px`, `3XL: 48px`.
- **Border:**
  - Default: `1px solid var(--color-border)` (`#D5E1ED`)
  - Focus: `1px solid var(--color-primary)` (`#0055A0`)
  - Error: `1px solid var(--color-danger)` (`#EF4444`)
- **Border Radius:**
  - `SM: 4px` (Badge nhỏ), `MD: 8px` (Input, Button, Dropdown), `LG: 12px` (Card, Modal), `XL: 16px` (Container lớn), `Full: 999px` (Avatar, Pill Badge).
- **Shadow & Overlay:**
  - `Shadow SM`: `0 1px 2px rgba(18, 40, 75, 0.08)` (Input, Button)
  - `Shadow MD`: `0 2px 6px rgba(18, 40, 75, 0.10)` (Card)
  - `Shadow LG`: `0 8px 24px rgba(18, 40, 75, 0.12)` (Modal, Dropdown)
  - `Modal Overlay`: `rgba(18, 40, 75, 0.45)`

---

## 4. Icons & Common Components (Tái sử dụng từ Source Base)

- **Class sẵn có trong `main.css`:** Tái sử dụng `.card`, `.badge`, `.form-group`, `.form-input`, `.form-error`, `.data-table` cùng component `BaseButton.vue` và composable `useNotification.ts`.
- **Icons:** Phong cách Outline (`Small: 16px`, `Medium: 20px`, `Large: 24px`, `Extra Large: 32px`). Dùng SVG inline hoặc `lucide-vue-next` (chỉ import khi đã được cài chung trên nhánh nền `main`).
- **Sidebar theo Role:**
  - `STAFF`: `勤怠一覧` (`SCR-02`), `プロジェクト` (`SCR-04`), `ログアウト`.
  - `MANAGER`: `勤怠一覧` (`SCR-02`), `工数集計` (`SCR-06`), `プロジェクト` (`SCR-04`), `社員勤怠情報` (`SCR-05`), `ログアウト`.
  - Chỉ highlight Active (`#0055A0`) 1 mục tại một thời điểm.
- **Button Variants:**
  - `Primary` (`#0055A0`): `登録`, `ログイン`, `追加する`, `CSV出力`, `+ 作成`, `+ 新規プロジェクト`.
  - `Secondary`: `キャンセル`, `閉じる`.
  - `Outline`: `＋ 行を追加`, `＋ メンバー追加`.
  - `Text / Link`: `詳細を見る`, `修正`, `詳細`.
  - `Icon-only` (`×`, xóa dòng, tìm kiếm): bắt buộc có `aria-label` và `title`.
- **Modal chuẩn (`POP-01` ~ `POP-06`):** Luôn gồm 3 phần cố định `Modal Header` (Icon + Title + nút `×`) -> `Modal Body` (cuộn dọc nếu dài) -> `Modal Footer` (Buttons).
- **Responsive & Accessibility:**
  - Desktop (`1280px+`) là chuẩn gốc; viewport hẹp thì Filter Area xếp dọc (`flex-wrap`), bảng rộng cho phép `overflow-x: auto`.
  - Mọi Input/Dropdown bắt buộc có `<label>` hiển thị rõ và ký hiệu `必須` nếu bắt buộc; lỗi validation hiển thị ngay dưới trường bị lỗi.