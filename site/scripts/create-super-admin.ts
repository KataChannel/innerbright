// Script tạo Super Administrator với đầy đủ quyền hệ thống
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

// Configuration from environment variables or defaults
const ADMIN_CONFIG = {
  email: process.env.ADMIN_EMAIL || 'admin@taza.com',
  password: process.env.ADMIN_PASSWORD || 'TazaAdmin@2024!',
  displayName: process.env.ADMIN_DISPLAY_NAME || 'Super Administrator',
  username: process.env.ADMIN_USERNAME || 'superadmin',
};

async function createSuperAdmin() {
  try {
    console.log('🚀 Đang tạo Super Administrator...');
    console.log(`📧 Email: ${ADMIN_CONFIG.email}`);
    console.log(`👤 Display Name: ${ADMIN_CONFIG.displayName}`);
    console.log(`🆔 Username: ${ADMIN_CONFIG.username}`);

    // 1. Tạo hoặc cập nhật Super Admin Role
    const superAdminRole = await prisma.role.upsert({
      where: { name: 'Super Administrator' },
      update: {
        description: 'Quản trị viên cấp cao nhất - có toàn quyền hệ thống innerbright',
        permissions: JSON.stringify([
          // System permissions
          'system:admin',
          'system:manage',
          'system:configure',
          'system:backup',

          // User management - toàn quyền
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
          'create:permission',
          'read:permission',
          'update:permission',
          'delete:permission',

          // Sales Management - toàn quyền
          'admin:sales',
          'manage:sales',
          'create:order',
          'read:order',
          'update:order',
          'delete:order',
          'approve:order',
          'cancel:order',
          'read:pipeline',
          'manage:pipeline',
          'read:revenue',
          'read:sales_reports',
          'read:sales_analytics',
          'create:quote',
          'read:quote',
          'update:quote',
          'approve:quote',
          'read:sales_team',
          'manage:sales_team',

          // CRM - toàn quyền
          'admin:crm',
          'manage:crm',
          'create:customer',
          'read:customer',
          'update:customer',
          'delete:customer',
          'create:lead',
          'read:lead',
          'update:lead',
          'delete:lead',
          'convert:lead',
          'create:campaign',
          'read:campaign',
          'update:campaign',
          'delete:campaign',
          'manage:campaign',
          'read:customer_analytics',
          'read:interaction_history',

          // Inventory Management - toàn quyền
          'admin:inventory',
          'manage:inventory',
          'create:product',
          'read:product',
          'update:product',
          'delete:product',
          'read:stock',
          'update:stock',
          'adjust:stock',
          'create:warehouse',
          'read:warehouse',
          'update:warehouse',
          'delete:warehouse',
          'manage:warehouse',
          'read:inventory_reports',
          'create:stocktake',
          'approve:stocktake',

          // Finance & Accounting - toàn quyền
          'admin:finance',
          'manage:finance',
          'create:invoice',
          'read:invoice',
          'update:invoice',
          'delete:invoice',
          'approve:invoice',
          'create:payment',
          'read:payment',
          'update:payment',
          'delete:payment',
          'process:payment',
          'read:financial_reports',
          'create:financial_reports',
          'export:financial_reports',
          'manage:chart_of_accounts',
          'manage:tax_settings',
          'manage:budget',

          // HRM - toàn quyền
          'admin:hrm',
          'manage:hrm',
          'create:employee',
          'read:employee',
          'update:employee',
          'delete:employee',
          'create:department',
          'read:department',
          'update:department',
          'delete:department',
          'manage:department',
          'create:position',
          'read:position',
          'update:position',
          'delete:position',
          'create:attendance',
          'read:attendance',
          'update:attendance',
          'delete:attendance',
          'approve:attendance',
          'create:payroll',
          'read:payroll',
          'update:payroll',
          'delete:payroll',
          'process:payroll',
          'create:leave_request',
          'read:leave_request',
          'update:leave_request',
          'approve:leave_request',
          'read:performance_review',
          'create:performance_review',
          'update:performance_review',

          // Project Management - toàn quyền
          'admin:projects',
          'manage:projects',
          'create:project',
          'read:project',
          'update:project',
          'delete:project',
          'archive:project',
          'create:task',
          'read:task',
          'update:task',
          'delete:task',
          'assign:task',
          'manage:team',
          'read:team',
          'create:team',
          'update:team',
          'delete:team',
          'read:project_reports',
          'read:time_tracking',
          'manage:project_budget',

          // Manufacturing - toàn quyền
          'admin:manufacturing',
          'manage:manufacturing',
          'create:production_plan',
          'read:production_plan',
          'update:production_plan',
          'delete:production_plan',
          'create:work_order',
          'read:work_order',
          'update:work_order',
          'delete:work_order',
          'approve:work_order',
          'manage:quality_control',
          'read:quality_control',
          'create:quality_check',
          'approve:quality_check',
          'read:production_reports',
          'manage:production_schedule',

          // Marketing - toàn quyền
          'admin:marketing',
          'manage:marketing',
          'create:marketing_campaign',
          'read:marketing_campaign',
          'update:marketing_campaign',
          'delete:marketing_campaign',
          'create:content',
          'read:content',
          'update:content',
          'delete:content',
          'publish:content',
          'manage:social_media',
          'read:social_media',
          'create:social_post',
          'schedule:social_post',
          'read:marketing_analytics',
          'create:marketing_reports',

          // Customer Support - toàn quyền
          'admin:support',
          'manage:support',
          'create:ticket',
          'read:ticket',
          'update:ticket',
          'delete:ticket',
          'assign:ticket',
          'close:ticket',
          'create:knowledge_base',
          'read:knowledge_base',
          'update:knowledge_base',
          'delete:knowledge_base',
          'read:support_analytics',
          'create:support_reports',

          // Analytics & BI - toàn quyền
          'admin:analytics',
          'manage:analytics',
          'create:dashboard',
          'read:dashboard',
          'update:dashboard',
          'delete:dashboard',
          'share:dashboard',
          'create:report',
          'read:report',
          'update:report',
          'delete:report',
          'export:report',
          'schedule:report',
          'read:business_intelligence',
          'create:bi_analysis',
          'read:data_warehouse',

          // E-commerce - toàn quyền
          'admin:ecommerce',
          'manage:ecommerce',
          'manage:catalog',
          'read:catalog',
          'create:product_listing',
          'update:product_listing',
          'read:online_order',
          'update:online_order',
          'process:online_order',
          'refund:online_order',
          'manage:website',
          'update:website_settings',
          'manage:payment_gateway',
          'read:ecommerce_analytics',
          'create:ecommerce_reports',

          // Admin specific permissions
          'read:settings',
          'update:settings',
          'manage:system',
          'read:audit_log',
          'export:audit_log',
          'read:security_log',
          'manage:backup',
          'create:backup',
          'restore:backup',
          'manage:integration',
          'configure:api',
          'manage:webhooks',

          // Global permissions
          'create:*',
          'read:*',
          'update:*',
          'delete:*',
          'manage:*',
          'admin:*',
        ]),
      },
      create: {
        name: 'Super Administrator',
        description: 'Quản trị viên cấp cao nhất - có toàn quyền hệ thống innerbright',
        permissions: JSON.stringify([
          'system:admin',
          'system:manage',
          'system:configure',
          'system:backup',
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
          'create:*',
          'read:*',
          'update:*',
          'delete:*',
          'manage:*',
          'admin:*',
        ]),
      },
    });

    console.log('✅ Super Admin Role tạo thành công:', superAdminRole.name);

    // 2. Tạo Super Admin User
    const hashedPassword = await bcrypt.hash(ADMIN_CONFIG.password, 12);

    // Kiểm tra user đã tồn tại chưa
    const existingUser = await prisma.user.findUnique({
      where: { email: ADMIN_CONFIG.email },
    });

    let superAdmin;

    if (existingUser) {
      // Cập nhật user hiện tại
      superAdmin = await prisma.user.update({
        where: { email: ADMIN_CONFIG.email },
        data: {
          password: hashedPassword,
          displayName: ADMIN_CONFIG.displayName,
          username: ADMIN_CONFIG.username,
          isActive: true,
          isVerified: true,
          roleId: superAdminRole.id,
          avatar:
            'https://ui-avatars.com/api/?name=Super+Admin&background=dc2626&color=fff&size=128',
        },
        include: { role: true },
      });
      console.log('✅ Super Admin User đã được cập nhật:', superAdmin.email);
    } else {
      // Tạo user mới
      superAdmin = await prisma.user.create({
        data: {
          email: ADMIN_CONFIG.email,
          username: ADMIN_CONFIG.username,
          password: hashedPassword,
          displayName: ADMIN_CONFIG.displayName,
          isActive: true,
          isVerified: true,
          roleId: superAdminRole.id,
          avatar:
            'https://ui-avatars.com/api/?name=Super+Admin&background=dc2626&color=fff&size=128',
        },
        include: { role: true },
      });
      console.log('✅ Super Admin User đã được tạo:', superAdmin.email);
    }

    // 3. Tạo employee record nếu có bảng Employee
    try {
      const employeeCreateData = {
        employeeId: `EMP-${Date.now()}`,
        userId: superAdmin.id,
        firstName: 'System',
        lastName: 'Administrator',
        fullName: 'System Administrator',
        email: superAdmin.email,
        hireDate: new Date(),
        isActive: true,
      };

      const employeeUpdateData = {
        employeeId: `EMP-${Date.now()}`,
        firstName: 'System',
        lastName: 'Administrator',
        fullName: 'System Administrator',
        email: superAdmin.email,
        hireDate: new Date(),
        isActive: true,
      };

      await prisma.employee.upsert({
        where: { userId: superAdmin.id },
        update: employeeUpdateData,
        create: employeeCreateData,
      });

      console.log('✅ Employee record đã được tạo/cập nhật');
    } catch (error) {
      console.log('ℹ️ Bảng Employee không tồn tại hoặc có lỗi:', error instanceof Error ? error.message : String(error));
    }

    // 4. Tạo các role khác nếu chưa có
    const additionalRoles = [
      {
        name: 'Manager',
        description: 'Quản lý cấp trung - có quyền quản lý phòng ban và một số module',
        permissions: [
          'read:user',
          'update:user',
          'manage:department',
          'manage:sales',
          'read:sales',
          'create:sales',
          'update:sales',
          'manage:crm',
          'read:crm',
          'create:crm',
          'update:crm',
          'read:inventory',
          'update:inventory',
          'read:finance',
          'read:financial_reports',
          'manage:hrm',
          'read:hrm',
          'create:hrm',
          'update:hrm',
          'manage:projects',
          'read:projects',
          'create:projects',
          'update:projects',
          'read:analytics',
          'read:report',
        ],
      },
      {
        name: 'Employee',
        description: 'Nhân viên - quyền truy cập cơ bản',
        permissions: [
          'read:own_profile',
          'update:own_profile',
          'read:sales',
          'create:sales',
          'update:own_sales',
          'read:crm',
          'create:crm',
          'update:own_crm',
          'read:projects',
          'update:own_tasks',
          'read:ticket',
          'create:ticket',
          'update:own_ticket',
        ],
      },
      {
        name: 'Viewer',
        description: 'Người xem - chỉ có quyền đọc',
        permissions: [
          'read:own_profile',
          'read:sales',
          'read:crm',
          'read:projects',
          'read:analytics',
        ],
      },
    ];

    for (const roleData of additionalRoles) {
      await prisma.role.upsert({
        where: { name: roleData.name },
        update: {
          description: roleData.description,
          permissions: JSON.stringify(roleData.permissions),
        },
        create: {
          name: roleData.name,
          description: roleData.description,
          permissions: JSON.stringify(roleData.permissions),
        },
      });
    }

    console.log('✅ Tất cả các role đã được tạo/cập nhật thành công');

    // 5. Hiển thị thông tin đăng nhập
    console.log('\n🎉 SUPER ADMINISTRATOR ĐÃ ĐƯỢC TẠO THÀNH CÔNG!');
    console.log('='.repeat(60));
    console.log('📧 Email: admin@taza.com');
    console.log('🔑 Mật khẩu: TazaAdmin@2024!');
    console.log('👤 Tên hiển thị: innerbright System Administrator');
    console.log('🛡️ Vai trò: Super Administrator');
    console.log('📈 Cấp độ quyền: 10 (Cao nhất)');
    console.log('🏢 Trạng thái: Hoạt động & Đã xác thực');
    console.log('='.repeat(60));
    console.log('\n✨ Bạn có thể đăng nhập với thông tin trên và có toàn quyền hệ thống!');
    console.log('\n⚠️  LƯU Ý BẢO MẬT:');
    console.log('- Hãy đổi mật khẩu ngay sau lần đăng nhập đầu tiên');
    console.log('- Không chia sẻ thông tin đăng nhập với người khác');
    console.log('- Kích hoạt xác thực 2 yếu tố nếu có thể');
    console.log('- Theo dõi logs hoạt động của tài khoản này');

    // 6. Hiển thị danh sách quyền
    console.log('\n📋 DANH SÁCH QUYỀN SUPER ADMINISTRATOR:');
    console.log('🔹 Quản lý hệ thống (System Management)');
    console.log('🔹 Quản lý người dùng và phân quyền (User & Role Management)');
    console.log('🔹 Quản lý bán hàng (Sales Management)');
    console.log('🔹 Quản lý khách hàng (CRM)');
    console.log('🔹 Quản lý kho (Inventory Management)');
    console.log('🔹 Quản lý tài chính (Finance & Accounting)');
    console.log('🔹 Quản lý nhân sự (HRM)');
    console.log('🔹 Quản lý dự án (Project Management)');
    console.log('🔹 Quản lý sản xuất (Manufacturing)');
    console.log('🔹 Quản lý marketing (Marketing)');
    console.log('🔹 Hỗ trợ khách hàng (Customer Support)');
    console.log('🔹 Phân tích & báo cáo (Analytics & BI)');
    console.log('🔹 Thương mại điện tử (E-commerce)');
  } catch (error) {
    console.error('❌ Lỗi khi tạo Super Administrator:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Chạy script
if (require.main === module) {
  createSuperAdmin()
    .then(() => {
      console.log('\n🚀 Script hoàn thành thành công!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('💥 Script thất bại:', error);
      process.exit(1);
    });
}

export default createSuperAdmin;
