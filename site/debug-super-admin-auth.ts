#!/usr/bin/env ts-node
import { config } from 'dotenv';
import { join } from 'path';

// Load environment variables
config({ path: join(__dirname, '.env') });
config({ path: join(__dirname, '../shared/.env') });

import { authService } from './src/lib/auth/unified-auth.service';

async function debugSuperAdminAuth() {
  try {
    console.log('🔍 Debugging Super Admin Authentication...');
    
    // Step 1: Login to get a valid token
    const credentials = {
      email: 'superadmin@innerbright.com',
      password: 'SuperAdmin@2024',
      provider: 'email' as const
    };
    
    console.log('🔐 Step 1: Logging in...');
    const loginResult = await authService.login(credentials);
    console.log('✅ Login successful!');
    console.log('- User ID:', loginResult.user.id);
    console.log('- User Email:', loginResult.user.email);
    console.log('- User Role:', loginResult.user.role?.name);
    console.log('- Access Token (first 50 chars):', loginResult.tokens.accessToken.substring(0, 50) + '...');
    
    // Step 2: Test token verification
    console.log('\n🔍 Step 2: Testing token verification...');
    const decoded = await authService.verifyToken(loginResult.tokens.accessToken);
    console.log('✅ Token verified successfully!');
    console.log('- Decoded userId:', decoded.userId);
    console.log('- Decoded email:', decoded.email);
    console.log('- Decoded role name:', decoded.roleName);
    
    // Step 3: Test getUserById
    console.log('\n👤 Step 3: Testing getUserById...');
    const user = await authService.getUserById(decoded.userId);
    if (user) {
      console.log('✅ User retrieved successfully!');
      console.log('- User ID:', user.id);
      console.log('- User Email:', user.email);
      console.log('- User DisplayName:', user.displayName);
      console.log('- User Role ID:', user.roleId);
      console.log('- User Role Name:', user.role?.name);
      console.log('- User Is Active:', user.isActive);
      console.log('- User Is Verified:', user.isVerified);
      
      // Step 4: Test role check
      console.log('\n🎯 Step 4: Testing role check...');
      const isSuperAdmin = user.role?.name === 'Super Administrator' || user.role?.name === 'super_administrator';
      console.log('- Is Super Admin?', isSuperAdmin);
      
      if (isSuperAdmin) {
        console.log('✅ All authentication checks passed!');
      } else {
        console.log('❌ Role check failed!');
        console.log('Expected: "Super Administrator" or "super_administrator"');
        console.log('Actual:', user.role?.name);
      }
      
    } else {
      console.log('❌ User not found in getUserById!');
    }
    
    // Step 5: Manually test the exact same logic as authenticateSuperAdmin
    console.log('\n🧪 Step 5: Testing authenticateSuperAdmin logic...');
    try {
      const token = loginResult.tokens.accessToken;
      console.log('- Testing with token length:', token.length);
      
      const decoded2 = await authService.verifyToken(token);
      console.log('- Token verification: SUCCESS');
      console.log('- Decoded userId:', decoded2.userId);
      
      const user2 = await authService.getUserById(decoded2.userId);
      console.log('- User retrieval:', user2 ? 'SUCCESS' : 'FAILED');
      
      if (!user2 || !user2.role) {
        throw new Error('User not found');
      }
      
      const isSuperAdmin2 = user2.role.name === 'Super Administrator' || user2.role.name === 'super_administrator';
      
      if (!isSuperAdmin2) {
        throw new Error('Access denied: Super Administrator role required');
      }
      
      console.log('✅ authenticateSuperAdmin logic: SUCCESS');
      
    } catch (authError: any) {
      console.log('❌ authenticateSuperAdmin logic failed:', authError.message);
    }

  } catch (error: any) {
    console.error('❌ Debug failed:', error.message);
    console.error('Full error:', error);
  }
}

debugSuperAdminAuth();
