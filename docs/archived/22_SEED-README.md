# 🌱 innerbright Master Seed

File seed tổng hợp tạo tất cả dữ liệu ban đầu cho dự án innerbright Enterprise Platform.

## 📋 Dữ liệu được tạo

### 🔑 Roles (8 roles)
- **SUPER_ADMIN**: Quyền tối cao (level 10)
- **ADMIN**: Quản trị viên hệ thống (level 8)  
- **HR_MANAGER**: Quản lý nhân sự (level 7)
- **DEPARTMENT_MANAGER**: Quản lý phòng ban (level 6)
- **MODERATOR**: Điều hành viên chat (level 5)
- **EMPLOYEE**: Nhân viên (level 3)
- **USER**: Người dùng thông thường (level 2)
- **GUEST**: Khách (level 1)

### 👥 Users 
- **System Users**: Super Admin, Admin
- **Managers**: HR Manager, IT Director, Sales Manager, Finance Manager, Operations Manager
- **Employees**: Developers, Sales staff, HR specialists, Accountants

### 🏢 Departments (6 departments)
- **CEO Office**: Văn phòng Tổng Giám đốc
- **Human Resources**: Phòng Nhân sự
- **Information Technology**: Phòng IT
- **Sales & Marketing**: Phòng Kinh doanh
- **Finance & Accounting**: Phòng Tài chính
- **Operations**: Phòng Vận hành

### 💼 Positions (12+ positions)
- CEO, các vị trí quản lý, kỹ sư, chuyên viên, nhân viên...

### 👨‍💼 Employee Records
- Thông tin chi tiết nhân viên
- Mã nhân viên, thông tin cá nhân, lương, hợp đồng

### 💬 Chat Data
- **General Discussion**: Kênh thảo luận chung
- **IT Team**: Kênh team IT
- Messages mẫu

### 📊 HR Sample Data
- **Attendance**: Dữ liệu chấm công mẫu
- **Leave Requests**: Đơn xin nghỉ mẫu

## 🚀 Sử dụng

### 1. Setup và chạy seed đầy đủ
```bash
# Setup từ đầu với seed data
bun run dev:setup

# Hoặc manual
bun run install:all
bun run db:generate  
bun run db:migrate
bun run db:seed:master
bun run dev
```

### 2. Reset và seed lại
```bash
# Reset database và seed lại
bun run dev:reset

# Hoặc hard reset (xóa containers)
bun run db:reset:hard
```

### 3. Chỉ chạy seed
```bash
# Chạy master seed
bun run db:seed:master

# Hoặc 
bun run db:seed
```

### 4. Test seed data
```bash
# Kiểm tra seed data đã tạo thành công
bun run db:seed:test
```

### 5. Fresh start
```bash
# Xóa tất cả và setup lại từ đầu
bun run fresh:seed
```

## 🔑 Tài khoản mặc định

Sau khi seed, bạn có thể đăng nhập với các tài khoản sau:

### Super Admin
- **Email**: `superadmin@innerbright.com`
- **Password**: `SuperAdmin@2024`
- **Quyền**: Toàn quyền hệ thống

### Admin  
- **Email**: `admin@innerbright.com`
- **Password**: `Admin@2024`
- **Quyền**: Quản trị viên

### HR Manager
- **Email**: `hr.manager@innerbright.com` 
- **Password**: `Hr@2024`
- **Quyền**: Quản lý nhân sự

### IT Director
- **Email**: `it.director@innerbright.com`
- **Password**: `It@2024`
- **Quyền**: Quản lý IT

### Sales Manager
- **Email**: `sales.manager@innerbright.com`
- **Password**: `Sales@2024`
- **Quyền**: Quản lý kinh doanh

### Employees
- **Emails**: `john.doe@innerbright.com`, `jane.smith@innerbright.com`, etc.
- **Password**: `Employee@2024`
- **Quyền**: Nhân viên

## 🛠️ Scripts hữu ích

```bash
# Development
bun run dev                    # Start dev server
bun run dev:debug             # Start with debug mode
bun run dev:inspect           # Start dev + Prisma Studio

# Database
bun run db:studio             # Open Prisma Studio
bun run db:inspect            # Pull và format schema
bun run health                # Check health endpoints

# Monitoring
bun run monitor               # Monitor health + logs
bun run logs                  # View logs

# Admin tools
bun run admin:create          # Create admin user
bun run admin:super          # Create super admin
bun run admin:cli            # Admin CLI tool
```

## 📁 Cấu trúc files

```
shared/prisma/seed/
├── master-seed.ts        # 🌟 Master seed (file chính)
├── hrm-seed.ts          # HRM data seed  
├── route.ts             # Chat data seed
└── route copy.ts        # Backup seed files
```

## 🔧 Customization

Để chỉnh sửa dữ liệu seed:

1. **Sửa roles**: Chỉnh sửa function `seedRoles()`
2. **Sửa users**: Chỉnh sửa function `seedSystemUsers()`, `seedHRAndDepartmentUsers()`, `seedEmployees()`
3. **Sửa departments**: Chỉnh sửa function `seedDepartments()`
4. **Sửa positions**: Chỉnh sửa function `seedPositions()`
5. **Sửa chat data**: Chỉnh sửa function `seedChatData()`

## 🐛 Troubleshooting

### Lỗi foreign key constraint
```bash
# Reset database hoàn toàn
bun run db:migrate:reset
bun run db:seed:master
```

### Lỗi Prisma client
```bash
# Generate lại Prisma client  
bun run db:generate
```

### Lỗi connection
```bash
# Kiểm tra database đang chạy
docker-compose ps
# Restart database
docker-compose restart postgres
```

### Kiểm tra dữ liệu
```bash
# Test seed data
bun run db:seed:test

# Hoặc mở Prisma Studio
bun run db:studio
```

## 📝 Notes

- File seed này thay thế các file seed cũ
- Dữ liệu được tạo theo cấu trúc enterprise thực tế
- Passwords đều có độ mạnh cao với bcrypt
- Avatar sử dụng UI Avatars service
- Dữ liệu mẫu phù hợp cho development và demo
