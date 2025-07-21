#!/usr/bin/env ts-node
import { config } from 'dotenv';
import { join } from 'path';

// Load environment variables
config({ path: join(__dirname, '.env') });
config({ path: join(__dirname, '../shared/.env') });

import { authService } from './src/lib/auth/unified-auth.service';

async function getAccessToken() {
  try {
    const credentials = {
      email: 'superadmin@innerbright.com',
      password: 'SuperAdmin@2024',
      provider: 'email' as const
    };
    
    console.log('🔐 Getting access token...');
    const loginResult = await authService.login(credentials);
    
    console.log('✅ Token generated successfully!');
    console.log('Access Token:');
    console.log(loginResult.tokens.accessToken);
    
    // Also test token verification
    console.log('\n🔍 Testing token verification...');
    const decoded = await authService.verifyToken(loginResult.tokens.accessToken);
    console.log('Token is valid. User ID:', decoded.userId);
    
  } catch (error: any) {
    console.error('❌ Error:', error.message);
  }
}

getAccessToken();
