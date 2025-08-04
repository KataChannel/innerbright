import type { NextAuthConfig } from 'next-auth';

export const authConfig: NextAuthConfig = {
  pages: {
    signIn: '/login',
  },
  providers: [
    // added later in auth.ts since it requires bcrypt which is only compatible with Node.js
    // while this file is also used in non-Node.js environments
  ],
  callbacks: {
    authorized({ auth, request: { nextUrl } }: any) {
      console.log('Checking authorization...');
      console.log('User:', auth?.user);
      console.log('Next URL:', nextUrl);
      const isLoggedIn = !!auth?.user;
      const isOnAdmin = nextUrl.pathname.startsWith('/admin');
      const isOnRoot = nextUrl.pathname === '/';
      
      // Cho phép truy cập trang chủ mà không cần đăng nhập
      if (isOnRoot) {
        return true;
      }
      
      // Yêu cầu đăng nhập cho trang admin
      if (isOnAdmin) {
        if (isLoggedIn) return true;
        return false; // Redirect unauthenticated users to login page
      }
      
      // Các trang khác có thể truy cập tự do
      return true;
    },
  },
};
