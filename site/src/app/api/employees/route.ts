import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/prisma/prisma';

export async function GET() {
  try {
    const employees = await prisma.employee.findMany({
      include: {
        user: {
          select: {
            id: true,
            email: true,
            displayName: true,
            avatar: true,
            status: true,
            isActive: true
          }
        },
        department: {
          select: {
            id: true,
            name: true
          }
        },
        position: {
          select: {
            id: true,
            title: true,
            level: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    return NextResponse.json({
      success: true,
      employees: employees.map(emp => ({
        id: emp.id,
        employeeId: emp.employeeId,
        fullName: emp.fullName,
        firstName: emp.firstName,
        lastName: emp.lastName,
        dateOfBirth: emp.dateOfBirth,
        gender: emp.gender,
        phone: emp.phone,
        address: emp.address,
        hireDate: emp.hireDate,
        salary: emp.salary,
        status: emp.status,
        contractType: emp.contractType,
        user: emp.user,
        department: emp.department,
        position: emp.position,
        createdAt: emp.createdAt
      }))
    });

  } catch (error) {
    console.error('Get employees error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const {
      employeeId,
      firstName,
      lastName,
      dateOfBirth,
      gender,
      phone,
      address,
      hireDate,
      salary,
      contractType,
      userId,
      departmentId,
      positionId
    } = await request.json();

    if (!employeeId || !firstName || !lastName || !userId || !departmentId || !positionId) {
      return NextResponse.json(
        { error: 'Required fields missing' },
        { status: 400 }
      );
    }

    // Check if employee ID already exists
    const existingEmployee = await prisma.employee.findUnique({
      where: { employeeId }
    });

    if (existingEmployee) {
      return NextResponse.json(
        { error: 'Employee ID already exists' },
        { status: 409 }
      );
    }

    // Check if user is already an employee
    const existingUserEmployee = await prisma.employee.findUnique({
      where: { userId }
    });

    if (existingUserEmployee) {
      return NextResponse.json(
        { error: 'User is already an employee' },
        { status: 409 }
      );
    }

    const employee = await prisma.employee.create({
      data: {
        employeeId,
        firstName,
        lastName,
        fullName: `${firstName} ${lastName}`,
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,
        gender,
        phone,
        address,
        hireDate: new Date(hireDate || new Date()),
        salary: salary ? parseFloat(salary) : null,
        contractType: contractType || 'FULL_TIME',
        userId,
        departmentId,
        positionId
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            displayName: true,
            avatar: true
          }
        },
        department: {
          select: {
            id: true,
            name: true
          }
        },
        position: {
          select: {
            id: true,
            title: true,
            level: true
          }
        }
      }
    });

    return NextResponse.json({
      success: true,
      message: 'Employee created successfully',
      employee: {
        id: employee.id,
        employeeId: employee.employeeId,
        fullName: employee.fullName,
        user: employee.user,
        department: employee.department,
        position: employee.position
      }
    }, { status: 201 });

  } catch (error) {
    console.error('Create employee error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
