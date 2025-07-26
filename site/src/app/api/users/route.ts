import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/prisma/prisma';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

async function verifyToken(request: NextRequest) {
  const token = request.headers.get('authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return null;
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    return decoded;
  } catch (error) {
    return null;
  }
}

export async function GET(request: NextRequest) {
  try {
    const user = await verifyToken(request);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const users = await prisma.user.findMany({
      include: {
        role: true,
        employee: {
          include: {
            department: true,
            position: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    return NextResponse.json({
      success: true,
      users: users.map(user => ({
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        username: user.username,
        avatar: user.avatar,
        status: user.status,
        isActive: user.isActive,
        isVerified: user.isVerified,
        role: user.role?.name,
        department: user.employee?.department?.name,
        position: user.employee?.position?.title,
        lastSeen: user.lastSeen,
        createdAt: user.createdAt
      }))
    });

  } catch (error) {
    console.error('Get users error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const user = await verifyToken(request);
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Check if user has permission to create users
    const currentUser = await prisma.user.findUnique({
      where: { id: user.userId },
      include: { role: true }
    });

    if (!currentUser?.role.permissions.includes('user.create')) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    const { email, password, displayName, username, roleId } = await request.json();

    if (!email || !password || !displayName) {
      return NextResponse.json(
        { error: 'Required fields missing' },
        { status: 400 }
      );
    }

    // Check if user already exists
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { email },
          { username: username || undefined }
        ]
      }
    });

    if (existingUser) {
      return NextResponse.json(
        { error: 'User already exists' },
        { status: 409 }
      );
    }

    const bcrypt = require('bcryptjs');
    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        displayName,
        username: username || email.split('@')[0],
        roleId,
        isActive: true,
        isVerified: true
      },
      include: {
        role: true,
        employee: {
          include: {
            department: true,
            position: true
          }
        }
      }
    });

    return NextResponse.json({
      success: true,
      message: 'User created successfully',
      user: {
        id: newUser.id,
        email: newUser.email,
        displayName: newUser.displayName,
        username: newUser.username,
        role: newUser.role?.name,
        department: newUser.employee?.department?.name,
        position: newUser.employee?.position?.title
      }
    }, { status: 201 });

  } catch (error) {
    console.error('Create user error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
