CREATE DATABASE IF NOT EXISTS attendance_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE attendance_db;

CREATE TABLE departments (
department_id int AUTO_INCREMENT PRIMARY KEY,
department_name varchar(50) NOT NULL,
department_code varchar(20) NOT NULL UNIQUE,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at DATETIME NULL
)
ENGINE= InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE holidays (
holiday_id int AUTO_INCREMENT PRIMARY KEY,
holiday_name varchar(50) NOT NULL,
holiday_date date NOT NULL UNIQUE,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at DATETIME NULL
)
ENGINE= InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tasks (
task_id bigint AUTO_INCREMENT PRIMARY KEY,
task_name varchar(50) NOT NULL,
task_code varchar(20) NOT NULL UNIQUE,
department_id int NULL,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at DATETIME NULL,
CONSTRAINT fk_tasks_department
FOREIGN KEY (department_id) REFERENCES departments (department_id)
)
ENGINE= InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE users (
user_id bigint auto_increment PRIMARY KEY,
user_name varchar(50) NOT NULL UNIQUE,
department_id int NOT NULL,
fullname varchar(50) NOT NULL,
password varchar(255) NOT NULL,
role varchar(20) NOT NULL,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at DATETIME NULL,
CONSTRAINT fk_users_department
FOREIGN KEY (department_id) REFERENCES departments (department_id)
)
ENGINE= InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE projects (
project_id bigint auto_increment PRIMARY KEY,
project_name varchar(75) NOT NULL,
project_code varchar(20) NOT NULL UNIQUE,
is_active boolean NOT NULL default TRUE,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at DATETIME NULL
)
ENGINE= InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE project_members (
project_id bigint NOT NULL,
user_id bigint NOT NULL,
is_manager boolean NOT NULL default FALSE,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at DATETIME NULL,
PRIMARY KEY (project_id, user_id),
CONSTRAINT fk_pm_project
FOREIGN KEY(project_id) REFERENCES projects (project_id),
CONSTRAINT fk_pm_user
FOREIGN KEY(user_id) REFERENCES users(user_id)
)
ENGINE= InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE daily_logs (
daily_id bigint auto_increment PRIMARY KEY,
user_id bigint NOT NULL,
check_in_time datetime null,
check_out_time datetime null,
break_minutes int not null default 60,
work_date date not null,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at DATETIME NULL,
CONSTRAINT fk_daily_logs_user
FOREIGN KEY(user_id) REFERENCES users(user_id),
CONSTRAINT uq_daily_logs_user_work_date
UNIQUE (user_id, work_date)
)
ENGINE= InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE daily_log_details (
log_detail_id bigint auto_increment Primary Key,
project_id bigint not null,
task_id bigint not null,
effort_minutes int not null,
daily_id bigint not null,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
deleted_at DATETIME NULL,
constraint fk_log_details_project
foreign key (project_id) references projects (project_id),
constraint fk_log_details_task
foreign key (task_id) references tasks (task_id),
constraint fk_log_details_daily
foreign key (daily_id) references daily_logs (daily_id)
)
ENGINE= InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


