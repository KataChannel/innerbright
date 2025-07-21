#!/usr/bin/env ts-node
// Script tạo Super Administrator với đầy đủ quyền hệ thống
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import readline from 'readline';

const prisma = new PrismaClient();

// Interface để nhập thông tin admin
interface AdminInfo {
  email: string;
  password: string;
  displayName: string;
  username: string;
  phone?: string;
}

// Hỏi thông tin từ user
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function askQuestion(question: string): Promise<string> {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer.trim());
    });
  });
}

// Tất cả quyền cho Super Administrator
const SUPER_ADMIN_PERMISSIONS = [
  // System-wide permissions
  'system:admin',
  'system:manage',
  'system:configure',
  'system:audit',
  'system:backup',

  // User and role management
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

  // All modules admin permissions
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

  // Full CRUD for all modules
  'create:*',
  'read:*',
  'update:*',
  'delete:*',
  'manage:*',
  'admin:*',

  // Module specific permissions
  'manage:sales',
  'approve:sales',
  'export:sales',
  'import:sales',
  'manage:crm',
  'export:crm',
  'import:crm',
  'manage:inventory',
  'approve:inventory',
  'export:inventory',
  'import:inventory',
  'manage:finance',
  'approve:finance',
  'export:finance',
  'audit:finance',
  'manage:hrm',
  'approve:hrm',
  'export:hrm',
  'import:hrm',
  'manage:projects',
  'approve:projects',
  'export:projects',
  'manage:manufacturing',
  'approve:manufacturing',
  'export:manufacturing',
  'manage:marketing',
  'approve:marketing',
  'export:marketing',
  'manage:support',
  'export:support',
  'manage:analytics',
  'export:analytics',
  'manage:ecommerce',
  'approve:ecommerce',
  'export:ecommerce',
];

// Tất cả modules có trong hệ thống
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

async function getAdminInfo(): Promise<AdminInfo> {
  console.log('\n🔧 Tạo Super Administrator cho hệ thống innerbright');
  console.log('====================================================');

  const email = (await askQuestion('📧 Nhập email admin: ')) || 'admin@taza.com';
  const username = (await askQuestion('👤 Nhập username: ')) || 'superadmin';
  const displayName = (await askQuestion('📝 Nhập tên hiển thị: ')) || 'Super Administrator';
  const password =
    (await askQuestion('🔐 Nhập mật khẩu (để trống = TazaAdmin@2024!): ')) || 'TazaAdmin@2024!';
  const phone = (await askQuestion('📱 Nhập số điện thoại (tùy chọn): ')) || '';

  return {
    email,
    username,
    displayName,
    password,
    phone: phone || undefined,
  };
}

async function createSuperAdmin(adminInfo: AdminInfo) {
  try {
    console.log('\n🚀 Đang tạo Super Administrator...');

    // 1. Tạo hoặc cập nhật Super Admin Role
    console.log('📝 Tạo/cập nhật Super Admin Role...');
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

    // 2. Mã hóa mật khẩu
    const hashedPassword = await bcrypt.hash(adminInfo.password, 12);

    // 3. Kiểm tra user đã tồn tại chưa
    const existingUser = await prisma.user.findUnique({
      where: { email: adminInfo.email },
      include: { role: true },
    });

    let superAdmin;

    if (existingUser) {
      // Cập nhật user hiện tại
      console.log('👤 Cập nhật user hiện tại thành Super Admin...');
      superAdmin = await prisma.user.update({
        where: { email: adminInfo.email },
        data: {
          password: hashedPassword,
          displayName: adminInfo.displayName,
          username: adminInfo.username,
          phone: adminInfo.phone,
          roleId: superAdminRole.id,
          isActive: true,
          isVerified: true,
          avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(adminInfo.displayName)}&background=dc2626&color=fff&size=128`,
        },
        include: { role: true },
      });
      console.log('✅ User đã được cập nhật thành Super Admin');
    } else {
      // Tạo user mới
      console.log('👤 Tạo Super Admin user mới...');
      superAdmin = await prisma.user.create({
        data: {
          email: adminInfo.email,
          username: adminInfo.username,
          password: hashedPassword,
          displayName: adminInfo.displayName,
          phone: adminInfo.phone,
          roleId: superAdminRole.id,
          isActive: true,
          isVerified: true,
          avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(adminInfo.displayName)}&background=dc2626&color=fff&size=128`,
        },
        include: { role: true },
      });
      console.log('✅ Super Admin user đã được tạo');
    }

    // 4. Tạo employee record nếu có bảng Employee
    console.log('👨‍💼 Tạo employee record...');
    try {
      await prisma.employee.upsert({
        where: { userId: superAdmin.id },
        update: {
          firstName: adminInfo.displayName.split(' ')[0] || 'Super',
          lastName: adminInfo.displayName.split(' ').slice(1).join(' ') || 'Admin',
          email: adminInfo.email,
          phone: adminInfo.phone || null,
          isActive: true,
        },
        create: {
          userId: superAdmin.id,
          employeeCode: `ADMIN-${Date.now()}`,
          firstName: adminInfo.displayName.split(' ')[0] || 'Super',
          lastName: adminInfo.displayName.split(' ').slice(1).join(' ') || 'Admin',
          email: adminInfo.email,
          phone: adminInfo.phone || null,
          isActive: true,
          hireDate: new Date(),
          status: 'ACTIVE',
          contractType: 'FULL_TIME',
        },
      });
      console.log('✅ Employee record đã được tạo/cập nhật');
    } catch (error) {
      console.log('ℹ️ Employee table chưa có hoặc có lỗi:', (error as Error).message);
    }

    // 5. Hiển thị thông tin đăng nhập
    console.log('\n🎉 Super Administrator đã được tạo thành công!');
    console.log('=====================================');
    console.log(`📧 Email: ${adminInfo.email}`);
    console.log(`👤 Username: ${adminInfo.username}`);
    console.log(`📝 Tên hiển thị: ${adminInfo.displayName}`);
    console.log(`🔐 Mật khẩu: ${adminInfo.password}`);
    console.log(`🎯 Role: ${superAdmin.role.name}`);
    console.log(`🆔 User ID: ${superAdmin.id}`);
    console.log(`📅 Ngày tạo: ${superAdmin.createdAt}`);
    console.log('\n📋 Quyền hạn:');
    console.log('- ✅ Toàn quyền quản trị hệ thống');
    console.log('- ✅ Quản lý tất cả modules (11 modules)');
    console.log('- ✅ Quản lý users và roles');
    console.log('- ✅ Cấu hình hệ thống');
    console.log('- ✅ Backup và restore');
    console.log('- ✅ Audit và security logs');

    console.log('\n🔗 Đường dẫn đăng nhập:');
    console.log('- Admin Panel: http://localhost:3000/admin');
    console.log('- Login Page: http://localhost:3000/auth/login');
    console.log('- Demo Page: http://localhost:3000/auth-demo');

    console.log('\n⚠️ Lưu ý bảo mật:');
    console.log('- Đổi mật khẩu ngay sau lần đăng nhập đầu tiên');
    console.log('- Không chia sẻ thông tin đăng nhập');
    console.log('- Kích hoạt 2FA nếu có thể');
    console.log('- Theo dõi hoạt động tài khoản thường xuyên');

    return superAdmin;
  } catch (error) {
    console.error('💥 Lỗi khi tạo Super Administrator:', error);
    throw error;
  }
}

async function checkExistingSuperAdmin() {
  try {
    const existingSuperAdmin = await prisma.user.findFirst({
      where: {
        role: {
          name: 'Super Administrator',
        },
      },
      include: { role: true },
    });

    if (existingSuperAdmin) {
      console.log('\n⚠️ Đã có Super Administrator trong hệ thống:');
      console.log(`📧 Email: ${existingSuperAdmin.email}`);
      console.log(`👤 Username: ${existingSuperAdmin.username}`);
      console.log(`📝 Tên: ${existingSuperAdmin.displayName}`);
      console.log(`📅 Ngày tạo: ${existingSuperAdmin.createdAt}`);

      const overwrite = await askQuestion(
        '\n❓ Bạn có muốn tạo thêm Super Admin khác không? (y/n): '
      );
      return overwrite.toLowerCase() === 'y' || overwrite.toLowerCase() === 'yes';
    }

    return true;
  } catch (error) {
    console.log('ℹ️ Không thể kiểm tra Super Admin hiện tại, tiếp tục tạo mới...');
    return true;
  }
}

async function main() {
  try {
    console.log('🚀 innerbright Super Administrator Creator');
    console.log('=====================================');

    // Kiểm tra Super Admin hiện tại
    const shouldContinue = await checkExistingSuperAdmin();

    if (!shouldContinue) {
      console.log('❌ Hủy tạo Super Administrator');
      return;
    }

    // Lấy thông tin admin
    const adminInfo = await getAdminInfo();

    // Xác nhận thông tin
    console.log('\n📋 Xác nhận thông tin:');
    console.log(`📧 Email: ${adminInfo.email}`);
    console.log(`👤 Username: ${adminInfo.username}`);
    console.log(`📝 Tên hiển thị: ${adminInfo.displayName}`);
    console.log(`🔐 Mật khẩu: ${'*'.repeat(adminInfo.password.length)}`);
    if (adminInfo.phone) console.log(`📱 Phone: ${adminInfo.phone}`);

    const confirm = await askQuestion('\n❓ Xác nhận tạo Super Administrator? (y/n): ');

    if (confirm.toLowerCase() !== 'y' && confirm.toLowerCase() !== 'yes') {
      console.log('❌ Hủy tạo Super Administrator');
      return;
    }

    // Tạo Super Admin
    await createSuperAdmin(adminInfo);
  } catch (error) {
    console.error('💥 Script thất bại:', error);
    process.exit(1);
  } finally {
    rl.close();
    await prisma.$disconnect();
  }
}

// Chạy script
if (require.main === module) {
  main()
    .then(() => {
      console.log('\n🎉 Script hoàn thành thành công!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('💥 Script thất bại:', error);
      process.exit(1);
    });
}

export default createSuperAdmin;
