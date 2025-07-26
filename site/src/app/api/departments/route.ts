import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/prisma/prisma';

export async function GET() {
  try {
    const departments = await prisma.department.findMany({
      include: {
        manager: {
          select: {
            id: true,
            displayName: true,
            email: true
          }
        },
        employees: {
          select: {
            id: true,
            fullName: true,
            status: true
          }
        },
        _count: {
          select: {
            employees: true
          }
        }
      },
      orderBy: {
        name: 'asc'
      }
    });

    return NextResponse.json({
      success: true,
      departments: departments.map(dept => ({
        id: dept.id,
        name: dept.name,
        description: dept.description,
        manager: dept.manager ? {
          id: dept.manager.id,
          name: dept.manager.displayName,
          email: dept.manager.email
        } : null,
        employeeCount: dept._count.employees,
        employees: dept.employees,
        createdAt: dept.createdAt
      }))
    });

  } catch (error) {
    console.error('Get departments error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const { name, description, managerId, parentId } = await request.json();

    if (!name) {
      return NextResponse.json(
        { error: 'Department name is required' },
        { status: 400 }
      );
    }

    // Check if department name already exists
    const existingDepartment = await prisma.department.findFirst({
      where: { name }
    });

    if (existingDepartment) {
      return NextResponse.json(
        { error: 'Department name already exists' },
        { status: 409 }
      );
    }

    const department = await prisma.department.create({
      data: {
        name,
        description,
        code: name.toLowerCase().replace(/\s+/g, '_'),
        ...(managerId && { managerId }),
        ...(parentId && { parentId })
      },
      include: {
        manager: {
          select: {
            id: true,
            displayName: true,
            email: true
          }
        }
      }
    });

    return NextResponse.json({
      success: true,
      message: 'Department created successfully',
      department: {
        id: department.id,
        name: department.name,
        description: department.description,
        manager: department.manager ? {
          id: department.manager.id,
          name: department.manager.displayName,
          email: department.manager.email
        } : null
      }
    }, { status: 201 });

  } catch (error) {
    console.error('Create department error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
