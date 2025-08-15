import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function POST(
  request: NextRequest,
  { params }: { params: { slug: string } }
) {
  try {
    const slug = params.slug;

    // Increment view count
    const post = await prisma.post.update({
      where: { slug },
      data: {
        views: {
          increment: 1
        }
      },
      select: {
        id: true,
        slug: true,
        views: true
      }
    });

    return NextResponse.json({
      success: true,
      data: post
    });

  } catch (error) {
    console.error('Error incrementing view count:', error);
    
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to increment view count'
      },
      { status: 500 }
    );
  }
}
