import jwt from 'jsonwebtoken';
import { NextRequest } from 'next/server';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

export interface AuthUser {
  userId: string;
  email: string;
  roleId: string;
  roleName: string;
}

export async function verifyToken(request: NextRequest): Promise<AuthUser | null> {
  const token = request.headers.get('authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return null;
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    return {
      userId: decoded.userId,
      email: decoded.email,
      roleId: decoded.roleId,
      roleName: decoded.roleName
    };
  } catch (error) {
    return null;
  }
}

export function generateToken(user: { id: string; email: string; roleId: string; roleName: string }): string {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      roleId: user.roleId,
      roleName: user.roleName
    },
    JWT_SECRET,
    { expiresIn: '24h' }
  );
}
