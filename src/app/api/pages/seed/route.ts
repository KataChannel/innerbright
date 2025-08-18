import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// POST /api/pages/seed - Tạo dữ liệu mẫu cho các trang
export async function POST(request: NextRequest) {
  try {
    // Tạo các trang cơ bản
    const defaultPages = [
      {
        title: 'Về InnerBright',
        slug: 'about',
        path: '/about',
        content: [
          {
            id: 'block_1',
            type: 'heading',
            content: { level: 1, text: 'Về InnerBright' },
            order: 0
          },
          {
            id: 'block_2',
            type: 'paragraph',
            content: { text: 'InnerBright là trung tâm đào tạo và phát triển cá nhân hàng đầu, chuyên về NLP (Neuro-Linguistic Programming) và Time Line Therapy.' },
            order: 1
          },
          {
            id: 'block_3',
            type: 'heading',
            content: { level: 2, text: 'Sứ mệnh' },
            order: 2
          },
          {
            id: 'block_4',
            type: 'paragraph',
            content: { text: 'Chúng tôi cam kết mang đến những phương pháp hiệu quả nhất để giúp mọi người khám phá tiềm năng bên trong và đạt được thành công trong cuộc sống.' },
            order: 3
          }
        ],
        htmlContent: '<h1>Về InnerBright</h1><p>InnerBright là trung tâm đào tạo và phát triển cá nhân hàng đầu...</p>',
        metaTitle: 'Về InnerBright - Trung tâm đào tạo NLP & Time Line Therapy',
        metaDescription: 'Tìm hiểu về InnerBright, trung tâm đào tạo NLP và Time Line Therapy hàng đầu tại Việt Nam.',
        status: 'PUBLISHED' as const
      },
      {
        title: 'NLP - Neuro-Linguistic Programming',
        slug: 'nlp',
        path: '/nlp',
        content: [
          {
            id: 'block_1',
            type: 'heading',
            content: { level: 1, text: 'NLP - Neuro-Linguistic Programming' },
            order: 0
          },
          {
            id: 'block_2',
            type: 'paragraph',
            content: { text: 'NLP là một phương pháp nghiên cứu về cách thức hoạt động của tâm trí con người và cách chúng ta giao tiếp với bản thân và người khác.' },
            order: 1
          },
          {
            id: 'block_3',
            type: 'heading',
            content: { level: 2, text: 'Những lợi ích của NLP' },
            order: 2
          },
          {
            id: 'block_4',
            type: 'list',
            content: { 
              type: 'unordered',
              items: [
                'Cải thiện kỹ năng giao tiếp',
                'Tăng cường sự tự tin',
                'Quản lý cảm xúc hiệu quả',
                'Đạt được mục tiêu cá nhân'
              ]
            },
            order: 3
          }
        ],
        htmlContent: '<h1>NLP - Neuro-Linguistic Programming</h1><p>NLP là một phương pháp nghiên cứu...</p>',
        metaTitle: 'Khóa học NLP - Neuro-Linguistic Programming tại InnerBright',
        metaDescription: 'Tham gia khóa học NLP chuyên nghiệp để phát triển kỹ năng giao tiếp và quản lý cảm xúc hiệu quả.',
        status: 'PUBLISHED' as const
      },
      {
        title: 'Time Line Therapy',
        slug: 'time-line-therapy',
        path: '/time-line-therapy',
        content: [
          {
            id: 'block_1',
            type: 'heading',
            content: { level: 1, text: 'Time Line Therapy' },
            order: 0
          },
          {
            id: 'block_2',
            type: 'paragraph',
            content: { text: 'Time Line Therapy là một kỹ thuật mạnh mẽ giúp giải phóng cảm xúc tiêu cực và tạo ra những thay đổi tích cực trong cuộc sống.' },
            order: 1
          },
          {
            id: 'block_3',
            type: 'heading',
            content: { level: 2, text: 'Ứng dụng của Time Line Therapy' },
            order: 2
          },
          {
            id: 'block_4',
            type: 'list',
            content: { 
              type: 'unordered',
              items: [
                'Giải quyết trauma và căng thẳng',
                'Loại bỏ nỗi sợ và lo lắng',
                'Cải thiện mối quan hệ',
                'Tăng cường động lực và mục tiêu'
              ]
            },
            order: 3
          }
        ],
        htmlContent: '<h1>Time Line Therapy</h1><p>Time Line Therapy là một kỹ thuật mạnh mẽ...</p>',
        metaTitle: 'Time Line Therapy - Liệu pháp thời gian tại InnerBright',
        metaDescription: 'Khám phá Time Line Therapy, kỹ thuật giải phóng cảm xúc tiêu cực và tạo ra thay đổi tích cực.',
        status: 'PUBLISHED' as const
      },
      {
        title: 'Đào tạo doanh nghiệp',
        slug: 'corporate-training',
        path: '/corporate-training',
        content: [
          {
            id: 'block_1',
            type: 'heading',
            content: { level: 1, text: 'Đào tạo doanh nghiệp' },
            order: 0
          },
          {
            id: 'block_2',
            type: 'paragraph',
            content: { text: 'Chúng tôi cung cấp các chương trình đào tạo chuyên nghiệp cho doanh nghiệp, giúp nâng cao năng lực nhân viên và hiệu quả làm việc.' },
            order: 1
          }
        ],
        htmlContent: '<h1>Đào tạo doanh nghiệp</h1><p>Chúng tôi cung cấp các chương trình đào tạo...</p>',
        metaTitle: 'Đào tạo doanh nghiệp - InnerBright',
        metaDescription: 'Các chương trình đào tạo chuyên nghiệp cho doanh nghiệp từ InnerBright.',
        status: 'PUBLISHED' as const
      },
      {
        title: 'Khai vấn cá nhân',
        slug: 'personal-consultation',
        path: '/personal-consultation',
        content: [
          {
            id: 'block_1',
            type: 'heading',
            content: { level: 1, text: 'Khai vấn cá nhân' },
            order: 0
          },
          {
            id: 'block_2',
            type: 'paragraph',
            content: { text: 'Dịch vụ khai vấn cá nhân một-đối-một để giải quyết các vấn đề cụ thể và phát triển cá nhân.' },
            order: 1
          }
        ],
        htmlContent: '<h1>Khai vấn cá nhân</h1><p>Dịch vụ khai vấn cá nhân...</p>',
        metaTitle: 'Khai vấn cá nhân - InnerBright',
        metaDescription: 'Dịch vụ khai vấn cá nhân chuyên nghiệp tại InnerBright.',
        status: 'PUBLISHED' as const
      }
    ];

    const createdPages = [];

    for (const pageData of defaultPages) {
      // Kiểm tra xem page đã tồn tại chưa
      const existingPage = await prisma.page.findFirst({
        where: {
          OR: [
            { slug: pageData.slug },
            { path: pageData.path }
          ]
        }
      });

      if (!existingPage) {
        const page = await prisma.page.create({
          data: {
            ...pageData,
            publishedAt: new Date(),
          }
        });
        createdPages.push(page);
      }
    }

    return NextResponse.json({
      message: `Created ${createdPages.length} pages successfully`,
      pages: createdPages
    });

  } catch (error) {
    console.error('Error seeding pages:', error);
    return NextResponse.json(
      { error: 'Failed to seed pages' },
      { status: 500 }
    );
  }
}
