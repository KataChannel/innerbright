import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// GET /api/pages/[slug] - Lấy page theo slug
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const { slug } = await params;
    
    const page = await prisma.page.findFirst({
      where: {
        OR: [
          { id: slug }, // Thêm tìm kiếm theo ID (UUID)
          { slug },
          { path: `/${slug}` },
          { path: slug }
        ]
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

    if (!page) {
      return NextResponse.json(
        { error: 'Page not found' },
        { status: 404 }
      );
    }

    // Tăng view count
    await prisma.page.update({
      where: { id: page.id },
      data: { views: { increment: 1 } }
    });

    return NextResponse.json(page);
  } catch (error) {
    console.error('Error fetching page:', error);
    return NextResponse.json(
      { error: 'Failed to fetch page' },
      { status: 500 }
    );
  }
}

// PUT /api/pages/[slug] - Cập nhật page
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const { slug } = await params;
    const body = await request.json();
    
    const {
      title,
      slug: newSlug,
      path,
      content,
      htmlContent,
      metaTitle,
      metaDescription,
      featuredImage,
      status,
      isHomePage
    } = body;

    // Tìm page hiện tại
    const existingPage = await prisma.page.findFirst({
      where: {
        OR: [
          { slug },
          { id: slug }
        ]
      }
    });

    if (!existingPage) {
      return NextResponse.json(
        { error: 'Page not found' },
        { status: 404 }
      );
    }

    // Kiểm tra slug và path mới có conflict không
    if (newSlug && newSlug !== existingPage.slug) {
      const conflictPage = await prisma.page.findFirst({
        where: {
          AND: [
            { id: { not: existingPage.id } },
            {
              OR: [
                { slug: newSlug },
                { path }
              ]
            }
          ]
        }
      });

      if (conflictPage) {
        return NextResponse.json(
          { error: 'Slug hoặc path đã tồn tại' },
          { status: 400 }
        );
      }
    }

    const updatedPage = await prisma.page.update({
      where: { id: existingPage.id },
      data: {
        title,
        slug: newSlug || existingPage.slug,
        path,
        content,
        htmlContent,
        metaTitle,
        metaDescription,
        featuredImage,
        status,
        isHomePage,
        publishedAt: status === 'PUBLISHED' && !existingPage.publishedAt 
          ? new Date() 
          : existingPage.publishedAt,
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

    return NextResponse.json(updatedPage);
  } catch (error) {
    console.error('Error updating page:', error);
    return NextResponse.json(
      { error: 'Failed to update page' },
      { status: 500 }
    );
  }
}

// DELETE /api/pages/[slug] - Xóa page
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const { slug } = await params;

    const existingPage = await prisma.page.findFirst({
      where: {
        OR: [
          { slug },
          { id: slug }
        ]
      }
    });

    if (!existingPage) {
      return NextResponse.json(
        { error: 'Page not found' },
        { status: 404 }
      );
    }

    await prisma.page.delete({
      where: { id: existingPage.id }
    });

    return NextResponse.json({ message: 'Page deleted successfully' });
  } catch (error) {
    console.error('Error deleting page:', error);
    return NextResponse.json(
      { error: 'Failed to delete page' },
      { status: 500 }
    );
  }
}
