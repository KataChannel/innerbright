#!/usr/bin/env ts-node
/**
 * innerbright Super Administrator Setup Script
 * Creates a Super Admin with complete system access and sets up permission management
 */

import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { config } from 'dotenv';
import { join } from 'path';

// Load environment variables
config({ path: join(__dirname, '../.env') });

const prisma = new PrismaClient();

// Super Admin Configuration
const SUPER_ADMIN_CONFIG = {
  email: 'admin@taza.com',
  username: 'superadmin',
  password: 'TazaAdmin@2024!',
  displayName: 'innerbright System Administrator',
  phone: '+84-xxx-xxx-xxx',
};

// Complete permission set for Super Administrator
const SUPER_ADMIN_PERMISSIONS = [
  // System-wide permissions
  'system:admin',
  'system:manage',
  'system:configure',
  'system:audit',
  'system:backup',
  'system:restore',

  // User and role management
  'create:user',
  'read:user',
  'update:user',
  'delete:user',
  'manage:user',
  'admin:user',

  'create:role',
  'read:role',
  'update:role',
  'delete:role',
  'manage:role',
  'admin:role',

  // Permission management
  'read:permissions',
  'manage:permissions',
  'admin:permissions',

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

  // Universal permissions (covers all future resources)
  'create:*',
  'read:*',
  'update:*',
  'delete:*',
  'manage:*',
  'admin:*',
  'approve:*',
  'export:*',
  'import:*',
  'audit:*',
  'configure:*',
];

// All available modules
const ALL_MODULES = [
  'admin',
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

// Additional system roles to create
const SYSTEM_ROLES = [
  {
    name: 'Administrator',
    description: 'System Administrator with high-level access',
    level: 9,
    modules: ALL_MODULES,
    permissions: [
      'read:*',
      'create:*',
      'update:*',
      'manage:user',
      'read:role',
      'admin:sales',
      'admin:crm',
      'admin:inventory',
      'admin:hrm',
      'admin:projects',
      'admin:analytics',
    ],
  },
  {
    name: 'Manager',
    description: 'Department Manager with module access',
    level: 7,
    modules: ['sales', 'crm', 'hrm', 'analytics'],
    permissions: [
      'read:*',
      'create:employee',
      'update:employee',
      'read:customer',
      'create:customer',
      'update:customer',
      'read:sales',
      'create:sales',
      'update:sales',
      'read:analytics',
    ],
  },
  {
    name: 'Employee',
    description: 'Standard employee with limited access',
    level: 3,
    modules: ['hrm'],
    permissions: [
      'read:employee',
      'update:employee', // own only
      'read:attendance',
      'create:attendance',
      'read:leave_request',
      'create:leave_request',
    ],
  },
  {
    name: 'Viewer',
    description: 'Read-only access to basic information',
    level: 1,
    modules: ['analytics'],
    permissions: [
      'read:dashboard',
      'read:analytics',
    ],
  },
];

async function setupSuperAdmin() {
  try {
    console.log('🚀 innerbright Super Administrator Setup');
    console.log('=====================================');
    console.log(`📧 Email: ${SUPER_ADMIN_CONFIG.email}`);
    console.log(`👤 Username: ${SUPER_ADMIN_CONFIG.username}`);
    console.log(`🔑 Password: ${SUPER_ADMIN_CONFIG.password}`);
    console.log(`📝 Display Name: ${SUPER_ADMIN_CONFIG.displayName}`);

    // 1. Connect to database
    console.log('\n🔌 Connecting to database...');
    await prisma.$connect();
    console.log('✅ Database connection established');

    // 2. Create Super Administrator Role
    console.log('\n👑 Creating Super Administrator role...');
    const superAdminRole = await prisma.role.upsert({
      where: { name: 'Super Administrator' },
      update: {
        description: 'Super Administrator with complete system access and control',
        permissions: JSON.stringify({
          permissions: SUPER_ADMIN_PERMISSIONS,
          modules: ALL_MODULES,
          level: 10,
          isSystemRole: true,
          scope: 'all',
          createdAt: new Date().toISOString(),
          lastUpdated: new Date().toISOString(),
        }),
        isSystemRole: true,
      },
      create: {
        name: 'Super Administrator',
        description: 'Super Administrator with complete system access and control',
        permissions: JSON.stringify({
          permissions: SUPER_ADMIN_PERMISSIONS,
          modules: ALL_MODULES,
          level: 10,
          isSystemRole: true,
          scope: 'all',
          createdAt: new Date().toISOString(),
          lastUpdated: new Date().toISOString(),
        }),
        isSystemRole: true,
      },
    });
    console.log('✅ Super Administrator role created/updated');

    // 3. Hash password
    console.log('\n🔐 Hashing password...');
    const hashedPassword = await bcrypt.hash(SUPER_ADMIN_CONFIG.password, 12);
    console.log('✅ Password hashed securely');

    // 4. Create or update Super Admin user
    console.log('\n👤 Creating Super Admin user...');
    const existingUser = await prisma.user.findUnique({
      where: { email: SUPER_ADMIN_CONFIG.email },
      include: { role: true },
    });

    let superAdmin;
    if (existingUser) {
      console.log('📝 Updating existing Super Admin user...');
      superAdmin = await prisma.user.update({
        where: { email: SUPER_ADMIN_CONFIG.email },
        data: {
          password: hashedPassword,
          displayName: SUPER_ADMIN_CONFIG.displayName,
          username: SUPER_ADMIN_CONFIG.username,
          phone: SUPER_ADMIN_CONFIG.phone,
          roleId: superAdminRole.id,
          isActive: true,
          isVerified: true,
          avatar: 'https://ui-avatars.com/api/?name=Super+Admin&background=dc2626&color=fff&size=128',
          lastSeen: new Date(),
        },
        include: { role: true },
      });
    } else {
      console.log('🆕 Creating new Super Admin user...');
      superAdmin = await prisma.user.create({
        data: {
          email: SUPER_ADMIN_CONFIG.email,
          username: SUPER_ADMIN_CONFIG.username,
          password: hashedPassword,
          displayName: SUPER_ADMIN_CONFIG.displayName,
          phone: SUPER_ADMIN_CONFIG.phone,
          roleId: superAdminRole.id,
          isActive: true,
          isVerified: true,
          avatar: 'https://ui-avatars.com/api/?name=Super+Admin&background=dc2626&color=fff&size=128',
          provider: 'email',
        },
        include: { role: true },
      });
    }
    console.log('✅ Super Admin user created/updated successfully');

    // 5. Create additional system roles
    console.log('\n🛡️ Creating additional system roles...');
    for (const roleData of SYSTEM_ROLES) {
      await prisma.role.upsert({
        where: { name: roleData.name },
        update: {
          description: roleData.description,
          permissions: JSON.stringify({
            permissions: roleData.permissions,
            modules: roleData.modules,
            level: roleData.level,
            isSystemRole: true,
            scope: 'all',
            lastUpdated: new Date().toISOString(),
          }),
          isSystemRole: true,
        },
        create: {
          name: roleData.name,
          description: roleData.description,
          permissions: JSON.stringify({
            permissions: roleData.permissions,
            modules: roleData.modules,
            level: roleData.level,
            isSystemRole: true,
            scope: 'all',
            createdAt: new Date().toISOString(),
          }),
          isSystemRole: true,
        },
      });
      console.log(`✅ ${roleData.name} role created/updated`);
    }

    // 6. Create employee record if possible
    console.log('\n👨‍💼 Creating employee record...');
    try {
      // Check if Department and Position tables exist
      const departments = await prisma.department.findMany({ take: 1 });
      const positions = await prisma.position.findMany({ take: 1 });

      if (departments.length > 0 && positions.length > 0) {
        await prisma.employee.upsert({
          where: { userId: superAdmin.id },
          update: {
            employeeId: 'ADMIN001',
            firstName: 'Super',
            lastName: 'Administrator',
            fullName: 'Super Administrator',
            hireDate: new Date(),
            status: 'ACTIVE',
            contractType: 'PERMANENT',
            departmentId: departments[0].id,
            positionId: positions[0].id,
          },
          create: {
            userId: superAdmin.id,
            employeeId: 'ADMIN001',
            firstName: 'Super',
            lastName: 'Administrator',
            fullName: 'Super Administrator',
            hireDate: new Date(),
            status: 'ACTIVE',
            contractType: 'PERMANENT',
            departmentId: departments[0].id,
            positionId: positions[0].id,
          },
        });
        console.log('✅ Employee record created/updated');
      } else {
        console.log('ℹ️ Department/Position tables not found, skipping employee record');
      }
    } catch (error) {
      console.log('ℹ️ Employee tables not available, skipping employee record creation');
    }

    // 7. Display success information
    console.log('\n🎉 Super Administrator Setup Complete!');
    console.log('=====================================');
    console.log(`✅ Super Admin User ID: ${superAdmin.id}`);
    console.log(`✅ Role: ${superAdmin.role.name}`);
    console.log(`✅ Total Permissions: ${SUPER_ADMIN_PERMISSIONS.length}`);
    console.log(`✅ Module Access: ${ALL_MODULES.length} modules`);
    console.log(`✅ Additional Roles Created: ${SYSTEM_ROLES.length}`);

    console.log('\n🔐 Login Credentials:');
    console.log(`📧 Email: ${SUPER_ADMIN_CONFIG.email}`);
    console.log(`👤 Username: ${SUPER_ADMIN_CONFIG.username}`);
    console.log(`🔑 Password: ${SUPER_ADMIN_CONFIG.password}`);

    console.log('\n🌐 Access URLs:');
    console.log('🏠 Admin Dashboard: http://localhost:3000/admin');
    console.log('👥 User Management: http://localhost:3000/admin/permissions');
    console.log('🛡️ Role Management: http://localhost:3000/admin/permissions');

    console.log('\n📋 Next Steps:');
    console.log('1. 🔐 Change the default password after first login');
    console.log('2. 👥 Create additional users and assign appropriate roles');
    console.log('3. 🛡️ Review and customize permissions as needed');
    console.log('4. 🔒 Enable two-factor authentication if available');
    console.log('5. 📊 Monitor system access and audit logs');

    console.log('\n⚠️ Security Reminders:');
    console.log('• Never share Super Admin credentials');
    console.log('• Regularly review user permissions');
    console.log('• Monitor system access logs');
    console.log('• Keep the system updated');
    console.log('• Use strong, unique passwords');

  } catch (error: any) {
    console.error('\n❌ Setup failed:', error.message);
    console.error('Full error:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

// Check if this is being run directly
if (require.main === module) {
  setupSuperAdmin()
    .then(() => {
      console.log('\n✅ Setup completed successfully!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('\n❌ Setup failed:', error);
      process.exit(1);
    });
}

export { setupSuperAdmin, SUPER_ADMIN_CONFIG, SUPER_ADMIN_PERMISSIONS, ALL_MODULES };
