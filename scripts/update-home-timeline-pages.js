const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function updatePagesData() {
  console.log('🚀 Cập nhật dữ liệu trang Home và Time Line Therapy...');
  
  try {
    // ==================== HOME PAGE ====================
    const homeContent = [
      {
        id: 'home_hero',
        type: 'hero',
        content: {
          title: 'CÂU CHUYỆN Về InnerBright',
          subtitle: 'InnerBright Training & Coaching được thành lập từ năm 2020 bởi nhà đào tạo Chloe Quý Châu',
          backgroundImage: '/images/about/cau-chuyen.jpg',
          description: 'Trung tâm đào tạo và phát triển cá nhân hàng đầu tại Việt Nam'
        },
        order: 0
      },
      {
        id: 'home_vision_title',
        type: 'heading',
        content: { level: 2, text: 'Mang trong mình KHÁT VỌNG' },
        order: 1
      },
      {
        id: 'home_mission',
        type: 'feature',
        content: {
          title: 'SỨ MỆNH',
          description: 'Tạo dựng cuộc sống thịnh vượng hơn cho người Việt Nam bằng việc khai phóng tiềm năng và giúp phát huy tối đa nội lực của mỗi cá nhân.',
          image: '/images/about/su-menh.jpg'
        },
        order: 2
      },
      {
        id: 'home_vision',
        type: 'feature',
        content: {
          title: 'TẦM NHÌN',
          description: 'Trang bị cho mỗi người Việt Nam đủ sở hữu tư duy phát triển bản thân đúng đắn, hiệu quả và bền vững.',
          image: '/images/about/tam-nhin.jpg'
        },
        order: 3
      },
      {
        id: 'home_values',
        type: 'feature',
        content: {
          title: 'GIÁ TRỊ CỐT LÕI',
          description: '• Hệ thống\n• Hợp nhất\n• Tử tế',
          image: '/images/about/gia-tri-cot-loi.jpg'
        },
        order: 4
      },
      {
        id: 'home_development_title',
        type: 'heading',
        content: { level: 2, text: 'PHÁT TRIỂN BẢN THÂN là sức mạnh để thay đổi thế giới' },
        order: 5
      },
      {
        id: 'home_development_desc',
        type: 'paragraph',
        content: {
          text: 'Thế giới của mỗi người chính là hệ sinh thái, nơi mỗi chúng ta sống và làm việc cùng các cộng đồng. Tại InnerBright, điều quan trọng không chỉ là được thành công cá nhân, mà còn là sử dụng sức mạnh này để tạo ra sự khác biệt và ảnh hưởng đến hệ sinh thái của riêng bạn.'
        },
        order: 6
      },
      {
        id: 'home_commitment',
        type: 'paragraph',
        content: {
          text: 'Chúng tôi - những con người tại InnerBright rất tự hào và sẵn sàng đồng hành cùng bạn trên hành trình này để khai phóng tiềm năng và giúp phát huy tối đa nội lực của riêng Bạn'
        },
        order: 7
      }
    ];

    // Generate HTML cho Home page
    const homeHtmlContent = homeContent.map(block => {
      switch(block.type) {
        case 'hero':
          return `<div class="hero-section relative h-96 bg-cover bg-center rounded-xl overflow-hidden mb-8" style="background-image: url('${block.content.backgroundImage}')">
            <div class="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent"></div>
            <div class="absolute inset-0 flex items-center">
              <div class="container mx-auto px-8">
                <div class="max-w-2xl">
                  <h1 class="text-5xl font-bold text-white mb-6">${block.content.title}</h1>
                  <p class="text-xl text-white/90 mb-4">${block.content.subtitle}</p>
                  <p class="text-lg text-white/80">${block.content.description}</p>
                </div>
              </div>
            </div>
          </div>`;
        case 'heading':
          return `<h${block.content.level} class="text-${block.content.level === 1 ? '4xl' : block.content.level === 2 ? '3xl' : '2xl'} font-bold text-gray-900 mb-6 text-center">${block.content.text}</h${block.content.level}>`;
        case 'paragraph':
          return `<p class="text-lg text-gray-700 leading-relaxed mb-6">${block.content.text}</p>`;
        case 'feature':
          return `<div class="bg-white rounded-lg shadow-md overflow-hidden mb-6">
            <img src="${block.content.image}" alt="${block.content.title}" class="w-full h-64 object-cover">
            <div class="p-6">
              <h3 class="text-2xl font-bold mb-3">${block.content.title}</h3>
              <p class="text-gray-700 leading-relaxed whitespace-pre-line">${block.content.description}</p>
            </div>
          </div>`;
        default:
          return '';
      }
    }).join('');

    // ==================== TIME LINE THERAPY PAGE ====================
    const timeLineContent = [
      {
        id: 'tlt_hero',
        type: 'hero',
        content: {
          title: 'Time Line Therapy',
          subtitle: 'Liệu pháp dòng thời gian',
          backgroundImage: '/images/time-line-therapy/co-che-hoat-dong.jpg',
          description: 'Phương pháp trị liệu hiệu quả giúp giải phóng cảm xúc tiêu cực và tạo ra thay đổi tích cực'
        },
        order: 0
      },
      {
        id: 'tlt_intro',
        type: 'heading',
        content: { level: 2, text: 'Time Line Therapy là gì?' },
        order: 1
      },
      {
        id: 'tlt_definition',
        type: 'paragraph',
        content: {
          text: 'Time Line Therapy (TLT) là một kỹ thuật trị liệu mạnh mẽ được phát triển bởi Tad James, dựa trên những nghiên cứu về NLP và liệu pháp tâm lý. Phương pháp này giúp con người làm việc với dòng thời gian cá nhân để giải phóng những cảm xúc tiêu cực, thay đổi niềm tin hạn chế và tạo ra tương lai tích cực.'
        },
        order: 2
      },
      {
        id: 'tlt_benefits_title',
        type: 'heading',
        content: { level: 2, text: 'Lợi ích của Time Line Therapy' },
        order: 3
      },
      {
        id: 'tlt_benefit_1',
        type: 'feature',
        content: {
          title: 'Hiệu quả nhanh chóng',
          description: 'Nhiều người trải nghiệm sự thay đổi đáng kể chỉ sau một vài buổi trị liệu.',
          image: '/images/time-line-therapy/cach-thuc.jpg'
        },
        order: 4
      },
      {
        id: 'tlt_benefit_2',
        type: 'feature',
        content: {
          title: 'Tác động sâu sắc',
          description: 'TLT làm việc trực tiếp với gốc rễ của vấn đề, mang lại sự chuyển hóa bền vững.',
          image: '/images/time-line-therapy/co-che-hoat-dong.jpg'
        },
        order: 5
      },
      {
        id: 'tlt_benefit_3',
        type: 'feature',
        content: {
          title: 'Giải quyết các vấn đề tâm lý',
          description: 'Hiệu quả trong giải tỏa cảm xúc tiêu cực, lo âu, trầm cảm, ám ảnh, rối loạn stress sau sang chấn.',
          image: '/images/time-line-therapy/cach-thuc.jpg'
        },
        order: 6
      },
      {
        id: 'tlt_benefit_4',
        type: 'feature',
        content: {
          title: 'Nâng cao lòng tự trọng',
          description: 'Giúp bạn tin tưởng vào bản thân và khả năng của mình.',
          image: '/images/time-line-therapy/co-che-hoat-dong.jpg'
        },
        order: 7
      },
      {
        id: 'tlt_benefit_5',
        type: 'feature',
        content: {
          title: 'Cải thiện các mối quan hệ',
          description: 'Tăng cường khả năng giao tiếp và thấu hiểu người khác.',
          image: '/images/time-line-therapy/cach-thuc.jpg'
        },
        order: 8
      },
      {
        id: 'tlt_benefit_6',
        type: 'feature',
        content: {
          title: 'Đạt được mục tiêu',
          description: 'Xác định mục tiêu và lập kế hoạch để đạt được chúng.',
          image: '/images/time-line-therapy/co-che-hoat-dong.jpg'
        },
        order: 9
      },
      {
        id: 'tlt_benefit_7',
        type: 'feature',
        content: {
          title: 'Tăng cường sức mạnh nội tại',
          description: 'Giải phóng những rào cản giúp bạn kết nối với nguồn lực và tiềm năng bên trong.',
          image: '/images/time-line-therapy/cach-thuc.jpg'
        },
        order: 10
      },
      {
        id: 'tlt_applications_title',
        type: 'heading',
        content: { level: 2, text: 'Ứng dụng của Time Line Therapy' },
        order: 11
      },
      {
        id: 'tlt_applications',
        type: 'list',
        content: {
          type: 'unordered',
          items: [
            'Giải quyết trauma và căng thẳng',
            'Loại bỏ nỗi sợ và lo lắng',
            'Cải thiện mối quan hệ',
            'Tăng cường động lực và mục tiêu',
            'Phá vỡ thói quen xấu',
            'Xây dựng niềm tin tích cực',
            'Tạo ra tương lai mong muốn'
          ]
        },
        order: 12
      }
    ];

    // Generate HTML cho Time Line Therapy page
    const timeLineHtmlContent = timeLineContent.map(block => {
      switch(block.type) {
        case 'hero':
          return `<div class="hero-section relative h-96 bg-cover bg-center rounded-xl overflow-hidden mb-8" style="background-image: url('${block.content.backgroundImage}')">
            <div class="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent"></div>
            <div class="absolute inset-0 flex items-center">
              <div class="container mx-auto px-8">
                <div class="max-w-2xl">
                  <h1 class="text-5xl font-bold text-white mb-6">${block.content.title}</h1>
                  <p class="text-xl text-white/90 mb-4">${block.content.subtitle}</p>
                  <p class="text-lg text-white/80">${block.content.description}</p>
                </div>
              </div>
            </div>
          </div>`;
        case 'heading':
          return `<h${block.content.level} class="text-${block.content.level === 1 ? '4xl' : block.content.level === 2 ? '3xl' : '2xl'} font-bold text-gray-900 mb-6 text-center">${block.content.text}</h${block.content.level}>`;
        case 'paragraph':
          return `<p class="text-lg text-gray-700 leading-relaxed mb-6">${block.content.text}</p>`;
        case 'feature':
          return `<div class="bg-white rounded-lg shadow-md overflow-hidden mb-6">
            <img src="${block.content.image}" alt="${block.content.title}" class="w-full h-64 object-cover">
            <div class="p-6">
              <h3 class="text-2xl font-bold mb-3">${block.content.title}</h3>
              <p class="text-gray-700 leading-relaxed">${block.content.description}</p>
            </div>
          </div>`;
        case 'list':
          const listItems = block.content.items.map(item => `<li class="mb-2">${item}</li>`).join('');
          return block.content.type === 'ordered' 
            ? `<ol class="list-decimal list-inside mb-6 space-y-2">${listItems}</ol>`
            : `<ul class="list-disc list-inside mb-6 space-y-2">${listItems}</ul>`;
        default:
          return '';
      }
    }).join('');

    // ==================== CẬP NHẬT HOME PAGE ====================
    let homePageResult;
    const existingHomePage = await prisma.page.findFirst({
      where: {
        OR: [
          { isHomePage: true },
          { slug: 'home' },
          { path: '/' }
        ]
      }
    });

    if (existingHomePage) {
      homePageResult = await prisma.page.update({
        where: { id: existingHomePage.id },
        data: {
          title: 'InnerBright - Trung tâm đào tạo NLP & Time Line Therapy',
          slug: 'home',
          path: '/',
          content: homeContent,
          htmlContent: homeHtmlContent,
          metaTitle: 'InnerBright - Trung tâm đào tạo và phát triển cá nhân',
          metaDescription: 'InnerBright Training & Coaching - Trung tâm đào tạo NLP và Time Line Therapy hàng đầu tại Việt Nam. Khai phóng tiềm năng và phát huy tối đa nội lực của bạn.',
          featuredImage: '/images/about/cau-chuyen.jpg',
          status: 'PUBLISHED',
          publishedAt: new Date(),
          isHomePage: true
        }
      });
      console.log('✅ Đã cập nhật Home page:', homePageResult.id);
    } else {
      homePageResult = await prisma.page.create({
        data: {
          title: 'InnerBright - Trung tâm đào tạo NLP & Time Line Therapy',
          slug: 'home',
          path: '/',
          content: homeContent,
          htmlContent: homeHtmlContent,
          metaTitle: 'InnerBright - Trung tâm đào tạo và phát triển cá nhân',
          metaDescription: 'InnerBright Training & Coaching - Trung tâm đào tạo NLP và Time Line Therapy hàng đầu tại Việt Nam. Khai phóng tiềm năng và phát huy tối đa nội lực của bạn.',
          featuredImage: '/images/about/cau-chuyen.jpg',
          status: 'PUBLISHED',
          publishedAt: new Date(),
          views: 0,
          isHomePage: true
        }
      });
      console.log('✅ Đã tạo Home page mới:', homePageResult.id);
    }

    // ==================== CẬP NHẬT TIME LINE THERAPY PAGE ====================
    let timeLinePageResult;
    const existingTimeLinePage = await prisma.page.findFirst({
      where: {
        OR: [
          { slug: 'time-line-therapy' },
          { path: '/time-line-therapy' }
        ]
      }
    });

    if (existingTimeLinePage) {
      timeLinePageResult = await prisma.page.update({
        where: { id: existingTimeLinePage.id },
        data: {
          title: 'Time Line Therapy - Liệu pháp dòng thời gian',
          content: timeLineContent,
          htmlContent: timeLineHtmlContent,
          metaTitle: 'Time Line Therapy - Liệu pháp dòng thời gian | InnerBright',
          metaDescription: 'Khám phá Time Line Therapy - phương pháp trị liệu hiệu quả giúp giải phóng cảm xúc tiêu cực, thay đổi niềm tin hạn chế và tạo ra tương lai tích cực.',
          featuredImage: '/images/time-line-therapy/co-che-hoat-dong.jpg',
          status: 'PUBLISHED',
          publishedAt: new Date(),
        }
      });
      console.log('✅ Đã cập nhật Time Line Therapy page:', timeLinePageResult.id);
    } else {
      timeLinePageResult = await prisma.page.create({
        data: {
          title: 'Time Line Therapy - Liệu pháp dòng thời gian',
          slug: 'time-line-therapy',
          path: '/time-line-therapy',
          content: timeLineContent,
          htmlContent: timeLineHtmlContent,
          metaTitle: 'Time Line Therapy - Liệu pháp dòng thời gian | InnerBright',
          metaDescription: 'Khám phá Time Line Therapy - phương pháp trị liệu hiệu quả giúp giải phóng cảm xúc tiêu cực, thay đổi niềm tin hạn chế và tạo ra tương lai tích cực.',
          featuredImage: '/images/time-line-therapy/co-che-hoat-dong.jpg',
          status: 'PUBLISHED',
          publishedAt: new Date(),
          views: 0,
          isHomePage: false
        }
      });
      console.log('✅ Đã tạo Time Line Therapy page mới:', timeLinePageResult.id);
    }

    console.log('🎉 Cập nhật dữ liệu thành công!');
    console.log('📋 Home Page bao gồm:');
    console.log('   - Hero section về InnerBright');
    console.log('   - Sứ mệnh, Tầm nhìn, Giá trị cốt lõi');
    console.log('   - Triết lý phát triển bản thân');
    console.log('📋 Time Line Therapy Page bao gồm:');
    console.log('   - Giới thiệu về TLT');
    console.log('   - 7 lợi ích chính');
    console.log('   - Ứng dụng thực tế');

  } catch (error) {
    console.error('❌ Lỗi khi cập nhật pages:', error);
  } finally {
    await prisma.$disconnect();
  }
}

updatePagesData();
