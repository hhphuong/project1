USE attendance_db;
-- 1. Đăng ký các phòng ban (departments)
INSERT INTO departments (department_code, department_name) VALUES
('DEV', '開発部'),
('CRE', 'クリエイティブ・制作部'),
('SAL', '営業部'),
('OPS', '管理・共通部門');

-- 2. Tài khoản người dùng (users)
-- Lưu ý: password ở đây là chuỗi hash mẫu (ví dụ BCrypt), thực tế khi chạy API cần hash đúng thuật toán của backend
-- role quy ước: manager hoặc user
INSERT INTO users (department_id, user_name, fullname, password, role) VALUES
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    'sato kenji',
    '佐藤 健司',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'manager'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    'suzuki haruka',
    '鈴木 春香',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'CRE'),
    'takahashi aoi',
    '高橋 葵',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'manager'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'CRE'),
    'alex mckenzie',
    'アレキサンダー・マッケンジー',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'SAL'),
    'ito naoki',
    '伊藤 直樹',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
 (SELECT department_id FROM departments WHERE department_code = 'SAL'),
    'yamada michiko',
    '山田　道子',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'SAL'),
    'tanaka daisuke',
    '田中 大介',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'manager'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    'watanabe yumi',
    '渡辺 優美',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'manager'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'CRE'),
    'kobayashi ren',
    '小林 蓮',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'manager'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    'takahashi kaito',
    '高橋 海斗',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    'sato sakura',
    '佐藤 さくら',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    'suzuki takumi',
    '鈴木 拓海',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'CRE'),
    'ito hinata',
    '伊藤 ひなた',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'CRE'),
    'yamada sora',
    '山田 宙',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'CRE'),
    'tanaka mei',
    '田中 芽衣',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'SAL'),
    'watanabe kenta',
    '渡辺 健太',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'SAL'),
    'kobayashi nana',
    '小林 菜々',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'SAL'),
    'nakamura ryota',
    '中村 亮太',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    'yoshida akari',
    '吉田 明里',
    '$2a$10$KZXlavGydm.h8xU4E5JYrOthOUY6GUujGH/79vfrZGBYUp3yajipi',
    'staff'
);

-- 3. Danh mục công việc / tasks
-- department_id = NULL: áp dụng cho các task dùng chung toàn công ty (ví dụ: 9999 - 共通)
-- department_id có giá trị: gắn với phòng ban cụ thể

INSERT INTO tasks (department_id, task_code, task_name) VALUES
-- Task dùng chung (không phụ thuộc phòng ban)
(null, '91', '朝礼'),
(null, '92', '社内連絡'),
(null, '93', '清掃'),
-- Task thuộc phòng 開発部 (DEV)
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    '10',
    '要件確認・設計'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    '20',
    '実装・単体テスト'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'DEV'),
    '30',
    'レビュー・結合テスト・保守'
),
-- Task thuộc phòng クリエイティブ・制作部 (CRE)
(
    (SELECT department_id FROM departments WHERE department_code = 'CRE'),
    '40',
    '企画・構成'
),
(
    (SELECT department_id FROM departments WHERE department_code = 'CRE'),
    '50',
    'デザイン・制作'
),
-- Task thuộc phòng 営業部 (SAL)
(
    (SELECT department_id FROM departments WHERE department_code = 'SAL'),
    '60',
    '顧客折衝・提案・見積作成'
);

INSERT INTO holidays (holiday_date, holiday_name) VALUES
('2026-01-01', '元日'),
('2026-01-02', '年末年始休暇'),
('2026-01-12', '成人の日'),
('2026-02-11', '建国記念の日'),
('2026-02-23', '天皇誕生日'),
('2026-03-20', '春分の日'),
('2026-04-29', '昭和の日'),
('2026-05-04', 'みどりの日'),
('2026-05-05', 'こどもの日'),
('2026-05-06', '振替休日'),
('2026-07-20', '海の日'),
('2026-08-11', '山の日'),
('2026-09-21', '敬老の日'),
('2026-09-23', '秋分の日'),
('2026-10-12', 'スポーツの日'),
('2026-11-03', '文化の日'),
('2026-11-23', '勤労感謝の日'),
('2026-12-30', '年末年始休暇'),
('2026-12-31', '年末年始休暇');
