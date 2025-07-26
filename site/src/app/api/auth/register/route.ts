import { NextRequest, NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import { prisma } from '@/prisma/prisma';

export async function POST(request: NextRequest) {
  try {
    const { email, password, displayName, username } = await request.json();

    if (!email || !password || !displayName) {
      return NextResponse.json(
        { error: 'Email, password and display name are required' },
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

    // Get default user role
    const userRole = await prisma.role.findFirst({
      where: { name: 'user' }
    });

    if (!userRole) {
      return NextResponse.json(
        { error: 'Default role not found' },
        { status: 500 }
      );
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        displayName,
        username: username || email.split('@')[0],
        roleId: userRole.id,
        isVerified: false,
        isActive: true
      },
      include: {
        role: true
      }
    });

    return NextResponse.json({
      success: true,
      message: 'User created successfully',
      user: {
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        username: user.username,
        role: user.role.name
      }
    }, { status: 201 });

  } catch (error) {
    console.error('Registration error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
