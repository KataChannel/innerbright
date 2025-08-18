import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { notFound } from 'next/navigation';

const prisma = new PrismaClient();

interface Block {
  id: string;
  type: 'heading' | 'paragraph' | 'image' | 'quote' | 'list';
  content: any;
  order: number;
}

// Render block content thành HTML
function renderBlock(block: Block): string {
  switch (block.type) {
    case 'heading':
      const level = block.content.level || 1;
      return `<h${level} class="text-${level === 1 ? '3xl' : level === 2 ? '2xl' : 'xl'} font-bold text-gray-900 mb-4">${block.content.text}</h${level}>`;
    
    case 'paragraph':
      return `<p class="text-gray-700 leading-relaxed mb-4">${block.content.text}</p>`;
    
    case 'image':
      return `<div class="my-6">
        <img src="${block.content.src}" alt="${block.content.alt || ''}" class="w-full rounded-lg shadow-md" />
        ${block.content.caption ? `<p class="text-sm text-gray-600 mt-2 text-center">${block.content.caption}</p>` : ''}
      </div>`;
    
    case 'quote':
      return `<blockquote class="border-l-4 border-primary pl-4 py-2 my-6 bg-gray-50 rounded-r-lg">
        <p class="text-gray-700 italic">"${block.content.text}"</p>
        ${block.content.author ? `<cite class="text-sm text-gray-600 block mt-2">— ${block.content.author}</cite>` : ''}
      </blockquote>`;
    
    case 'list':
      const listItems = block.content.items.map((item: string) => `<li class="mb-1">${item}</li>`).join('');
      return block.content.type === 'ordered' 
        ? `<ol class="list-decimal list-inside mb-4 space-y-1">${listItems}</ol>`
        : `<ul class="list-disc list-inside mb-4 space-y-1">${listItems}</ul>`;
    
    default:
      return '';
  }
}

// Component trang động
export default async function DynamicPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  
  try {
    // Tìm page theo slug hoặc path
    const page = await prisma.page.findFirst({
      where: {
        AND: [
          { status: 'PUBLISHED' },
          {
            OR: [
              { slug },
              { path: `/${slug}` },
              { path: slug }
            ]
          }
        ]
      }
    });

    if (!page) {
      notFound();
    }

    // Tăng view count
    await prisma.page.update({
      where: { id: page.id },
      data: { views: { increment: 1 } }
    });

    // Render content từ blocks
    let htmlContent = page.htmlContent;
    
    if (page.content && Array.isArray(page.content)) {
      const blocks = page.content as unknown as Block[];
      const sortedBlocks = blocks.sort((a, b) => a.order - b.order);
      htmlContent = sortedBlocks.map(renderBlock).join('');
    }

    return (
      <div className="min-h-screen bg-gray-50">
        {/* Hero Section nếu có featured image */}
        {page.featuredImage && (
          <div className="relative h-64 md:h-96 bg-gray-900">
            <img
              src={page.featuredImage}
              alt={page.title}
              className="w-full h-full object-cover opacity-70"
            />
            <div className="absolute inset-0 flex items-center justify-center">
              <h1 className="text-4xl md:text-6xl font-bold text-white text-center">
                {page.title}
              </h1>
            </div>
          </div>
        )}

        {/* Main Content */}
        <div className="container mx-auto px-4 py-8">
          <div className="max-w-4xl mx-auto">
            {!page.featuredImage && (
              <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-8 text-center">
                {page.title}
              </h1>
            )}
            
            <div 
              className="prose prose-lg max-w-none"
              dangerouslySetInnerHTML={{ __html: htmlContent || '' }}
            />
          </div>
        </div>

        {/* Page Meta */}
        <head>
          <title>{page.metaTitle || page.title}</title>
          <meta name="description" content={page.metaDescription || ''} />
          <meta property="og:title" content={page.metaTitle || page.title} />
          <meta property="og:description" content={page.metaDescription || ''} />
          {page.featuredImage && (
            <meta property="og:image" content={page.featuredImage} />
          )}
        </head>
      </div>
    );

  } catch (error) {
    console.error('Error loading page:', error);
    notFound();
  }
}
