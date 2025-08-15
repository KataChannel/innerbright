import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function POST(
  request: NextRequest,
  { params }: { params: { slug: string } }
) {
  try {
    const slug = params.slug;

    // For simplicity, we'll just increment/decrement likes
    // In a real application, you'd want to track user likes in a separate table
    const post = await prisma.post.findUnique({
      where: { slug },
      select: { id: true, likes: true }
    });

    if (!post) {
      return NextResponse.json(
        {
          success: false,
          error: 'Post not found'
        },
        { status: 404 }
      );
    }

    // Toggle like (increment by 1)
    const updatedPost = await prisma.post.update({
      where: { slug },
      data: {
        likes: {
          increment: 1
        }
      },
      select: {
        id: true,
        slug: true,
        likes: true
      }
    });

    return NextResponse.json({
      success: true,
      data: updatedPost
    });

  } catch (error) {
    console.error('Error toggling like:', error);
    
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to toggle like'
      },
      { status: 500 }
    );
  }
}
