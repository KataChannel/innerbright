import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// GET /api/pages - Lấy danh sách tất cả pages
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    
    const where = status ? { status: status as any } : {};
    
    const pages = await prisma.page.findMany({
      where,
      include: {
        author: {
          select: {
            id: true,
            displayName: true,
            email: true,
          }
        }
      },
      orderBy: {
        updatedAt: 'desc'
      }
    });

    return NextResponse.json(pages);
  } catch (error) {
    console.error('Error fetching pages:', error);
    return NextResponse.json(
      { error: 'Failed to fetch pages' },
      { status: 500 }
    );
  }
}

// POST /api/pages - Tạo page mới
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      title,
      slug,
      path,
      content,
      htmlContent,
      metaTitle,
      metaDescription,
      featuredImage,
      status = 'DRAFT',
      authorId,
      isHomePage = false
    } = body;

    // Kiểm tra slug và path có unique không
    const existingPage = await prisma.page.findFirst({
      where: {
        OR: [
          { slug },
          { path }
        ]
      }
    });

    if (existingPage) {
      return NextResponse.json(
        { error: 'Slug hoặc path đã tồn tại' },
        { status: 400 }
      );
    }

    const page = await prisma.page.create({
      data: {
        title,
        slug,
        path,
        content,
        htmlContent,
        metaTitle,
        metaDescription,
        featuredImage,
        status,
        authorId,
        isHomePage,
        publishedAt: status === 'PUBLISHED' ? new Date() : null,
      },
      include: {
        author: {
          select: {
            id: true,
            displayName: true,
            email: true,
          }
        }
      }
    });

    return NextResponse.json(page, { status: 201 });
  } catch (error) {
    console.error('Error creating page:', error);
    return NextResponse.json(
      { error: 'Failed to create page' },
      { status: 500 }
    );
  }
}
