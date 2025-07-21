#!/usr/bin/env ts-node
// Script tạo Super Administrator với đầy đủ quyền hệ thống - Fixed version
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { config } from 'dotenv';
import { join } from 'path';

// Load environment variables from .env file
config({ path: join(__dirname, '../.env') });

// Tạo Prisma client
const prisma = new PrismaClient();

// Thông tin mặc định cho Super Admin
const DEFAULT_ADMIN = {
  email: 'admin@taza.com',
  username: 'superadmin',
  password: 'TazaAdmin@2024!',
  displayName: 'innerbright System Administrator',
  phone: '+84-xxx-xxx-xxx',
};

// Tất cả quyền cho Super Administrator
const SUPER_ADMIN_PERMISSIONS = [
  // System permissions
  'system:admin',
  'system:manage',
  'system:configure',
  'system:audit',
  'system:backup',

  // User & Role management
  'create:user',
  'read:user',
  'update:user',
  'delete:user',
  'manage:user',
  'create:role',
  'read:role',
  'update:role',
  'delete:role',
  'manage:role',

  // Module admin permissions
  'admin:sales',
  'admin:crm',
  'admin:inventory',
  'admin:finance',
  'admin:hrm',
  'admin:projects',
  'admin:manufacturing',
  'admin:marketing',
  'admin:support',
  'admin:analytics',
  'admin:ecommerce',

  // Universal permissions
  'create:*',
  'read:*',
  'update:*',
  'delete:*',
  'manage:*',
  'admin:*',
];

const ALL_MODULES = [
  'sales',
  'crm',
  'inventory',
  'finance',
  'hrm',
  'projects',
  'manufacturing',
  'marketing',
  'support',
  'analytics',
  'ecommerce',
];

async function createFixedSuperAdmin() {
  try {
    console.log('🚀 Tạo Super Administrator với đầy đủ quyền...');
    console.log('===============================================');
    console.log(`📧 Email: ${DEFAULT_ADMIN.email}`);
    console.log(`👤 Display Name: ${DEFAULT_ADMIN.displayName}`);
    console.log(`🆔 Username: ${DEFAULT_ADMIN.username}`);
    console.log(`🔑 Password: ${DEFAULT_ADMIN.password}`);

    // 1. Kiểm tra kết nối database
    console.log('\n🔌 Kiểm tra kết nối database...');
    await prisma.$connect();
    console.log('✅ Kết nối database thành công');

    // 2. Tạo Super Admin Role
    console.log('\n📝 Tạo Super Admin Role...');
    const superAdminRole = await prisma.role.upsert({
      where: { name: 'Super Administrator' },
      update: {
        description: 'Quản trị viên cấp cao nhất - có toàn quyền hệ thống innerbright',
        permissions: JSON.stringify({
          permissions: SUPER_ADMIN_PERMISSIONS,
          modules: ALL_MODULES,
          level: 10,
          isSystemRole: true,
          scope: 'all',
        }),
      },
      create: {
        name: 'Super Administrator',
        description: 'Quản trị viên cấp cao nhất - có toàn quyền hệ thống innerbright',
        permissions: JSON.stringify({
          permissions: SUPER_ADMIN_PERMISSIONS,
          modules: ALL_MODULES,
          level: 10,
          isSystemRole: true,
          scope: 'all',
        }),
      },
    });
    console.log('✅ Super Admin Role đã được tạo/cập nhật');

    // 3. Mã hóa mật khẩu
    console.log('\n🔐 Mã hóa mật khẩu...');
    const hashedPassword = await bcrypt.hash(DEFAULT_ADMIN.password, 12);

    // 4. Tạo hoặc cập nhật Super Admin User
    console.log('\n👤 Tạo/cập nhật Super Admin User...');
    const superAdmin = await prisma.user.upsert({
      where: { email: DEFAULT_ADMIN.email },
      update: {
        password: hashedPassword,
        displayName: DEFAULT_ADMIN.displayName,
        username: DEFAULT_ADMIN.username,
        phone: DEFAULT_ADMIN.phone,
        roleId: superAdminRole.id,
        isActive: true,
        isVerified: true,
        avatar: 'https://ui-avatars.com/api/?name=Super+Admin&background=dc2626&color=fff&size=128',
      },
      create: {
        email: DEFAULT_ADMIN.email,
        username: DEFAULT_ADMIN.username,
        password: hashedPassword,
        displayName: DEFAULT_ADMIN.displayName,
        phone: DEFAULT_ADMIN.phone,
        roleId: superAdminRole.id,
        isActive: true,
        isVerified: true,
        avatar: 'https://ui-avatars.com/api/?name=Super+Admin&background=dc2626&color=fff&size=128',
      },
      include: { role: true },
    });
    console.log('✅ Super Admin User đã được tạo/cập nhật');

    // 5. Tạo employee record nếu có bảng Employee
    console.log('\n👨‍💼 Tạo employee record...');
    try {
      // Kiểm tra xem có department và position nào không
      const defaultDepartment = await prisma.department.findFirst();
      const defaultPosition = await prisma.position.findFirst();

      if (defaultDepartment && defaultPosition) {
        await prisma.employee.upsert({
          where: { userId: superAdmin.id },
          update: {
            firstName: 'System',
            lastName: 'Administrator',
            fullName: 'System Administrator',
            status: 'ACTIVE',
          },
          create: {
            employeeId: `ADMIN-${Date.now()}`,
            firstName: 'System',
            lastName: 'Administrator',
            fullName: 'System Administrator',
            status: 'ACTIVE',
            contractType: 'FULL_TIME',
            hireDate: new Date(),
            userId: superAdmin.id,
            departmentId: defaultDepartment.id,
            positionId: defaultPosition.id,
          },
        });
        console.log('✅ Employee record đã được tạo');
      } else {
        console.log('⚠️  Không có department hoặc position mặc định, bỏ qua tạo employee record');
      }
    } catch (error: any) {
      console.log('⚠️  Lỗi tạo employee record:', error.message);
    }

    console.log('\n🎉 HOÀN THÀNH THÀNH CÔNG!');
    console.log('===============================================');
    console.log('🔐 Thông tin đăng nhập:');
    console.log(`   📧 Email: ${DEFAULT_ADMIN.email}`);
    console.log(`   🔑 Password: ${DEFAULT_ADMIN.password}`);
    console.log(`   🌐 URL: http://localhost:3000/login`);
    console.log('\n⚠️  LƯU Ý BẢO MẬT:');
    console.log('   - Đổi mật khẩu ngay sau lần đăng nhập đầu tiên');
    console.log('   - Cập nhật email từ mặc định sang email thực');
    console.log('   - Thêm số điện thoại cho bảo mật 2 lớp');
  } catch (error) {
    console.error('💥 Lỗi khi tạo Super Administrator:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

async function main() {
  try {
    await createFixedSuperAdmin();
    process.exit(0);
  } catch (error) {
    console.error('💥 Script thất bại:', error);
    process.exit(1);
  }
}

// Chạy script
if (require.main === module) {
  main();
}

export { createFixedSuperAdmin };
