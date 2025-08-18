const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function updateNLPPageData() {
  console.log('🚀 Cập nhật dữ liệu trang NLP...');
  
  try {
    // Nội dung NLP được chuyển đổi thành blocks
    const nlpContent = [
      {
        id: 'nlp_hero',
        type: 'hero',
        content: {
          title: 'NLP',
          subtitle: 'LẬP TRÌNH NGÔN NGỮ TƯ DUY',
          backgroundImage: '/images/NLP/NLP_Section 1.png',
          description: 'Neuro Linguistic Programming - Chìa khóa mở ra cánh cửa cuộc sống vượt trội'
        },
        order: 0
      },
      {
        id: 'nlp_intro',
        type: 'heading',
        content: { level: 2, text: 'CHÌA KHÓA MỞ RA CÁNH CỬA CUỘC SỐNG VƯỢT TRỘI' },
        order: 1
      },
      {
        id: 'nlp_definition_1',
        type: 'paragraph',
        content: { 
          text: 'Lập Trình Ngôn Ngữ Tư Duy NLP (Neuro Linguistic Programming) là chìa khóa giúp khai phá sức mạnh của bản thân. Các nhà khoa học đã công nhận tầm quan trọng của phương pháp NLP. Nếu hiểu rõ về NLP, bạn sẽ có cơ hội phát triển bản thân lên tầm cao mới.'
        },
        order: 2
      },
      {
        id: 'nlp_origin',
        type: 'paragraph',
        content: { 
          text: 'NLP được khởi nguồn tại Mỹ, bởi John Grinder (nhà ngôn ngữ học) và Richard Bandler (nhà toán học và liệu pháp tâm lý Gestalt) với mục đích tạo ra các mô hình học tập rõ ràng về sự xuất sắc của con người.'
        },
        order: 3
      },
      {
        id: 'nlp_questions_title',
        type: 'heading',
        content: { level: 2, text: '3 CÂU HỎI MUỐN BIẾT' },
        order: 4
      },
      {
        id: 'nlp_questions_intro',
        type: 'paragraph',
        content: { 
          text: 'Mỗi ngày, chúng ta đều trăn trở về những câu hỏi sâu sắc về cuộc sống:'
        },
        order: 5
      },
      {
        id: 'nlp_question_1',
        type: 'card',
        content: {
          title: 'Câu hỏi 1',
          text: 'Tại sao tôi trở thành con người mà tôi đang là?',
          image: '/images/NLP/NLP_Section 3.1.png'
        },
        order: 6
      },
      {
        id: 'nlp_question_2',
        type: 'card',
        content: {
          title: 'Câu hỏi 2', 
          text: 'Làm thế nào để tôi thay đổi bản thân?',
          image: '/images/NLP/NLP_Section 3.2.png'
        },
        order: 7
      },
      {
        id: 'nlp_question_3',
        type: 'card',
        content: {
          title: 'Câu hỏi 3',
          text: 'Làm sao để tôi trở thành phiên bản tốt nhất của chính mình?',
          image: '/images/NLP/NLP_Section 3.3.png'
        },
        order: 8
      },
      {
        id: 'nlp_components_title',
        type: 'heading',
        content: { level: 2, text: 'NLP BAO GỒM 3 THÀNH PHẦN' },
        order: 9
      },
      {
        id: 'nlp_neuro',
        type: 'feature',
        content: {
          title: 'Neuro - Hệ thần kinh',
          description: 'Cách não bộ xử lý thông tin thông qua 5 giác quan. Mọi thông tin được tiếp nhận và xử lý qua hệ thần kinh, ảnh hưởng đến suy nghĩ và hành vi của chúng ta.',
          image: '/images/NLP/NLP_Section 3.1.png'
        },
        order: 10
      },
      {
        id: 'nlp_linguistic',
        type: 'feature',
        content: {
          title: 'Linguistic - Ngôn ngữ',
          description: 'Cách chúng ta sử dụng ngôn từ không chỉ đơn thuần diễn đạt ý định mà còn thể hiện niềm tin và thái độ. Ngôn ngữ có thể mang năng lượng tích cực hoặc tiêu cực.',
          image: '/images/NLP/NLP_Section 3.2.png'
        },
        order: 11
      },
      {
        id: 'nlp_programming',
        type: 'feature',
        content: {
          title: 'Programming - Lập trình',
          description: 'Tương tự như hệ điều hành máy tính, lập trình ngôn ngữ tư duy là cách thức điều chỉnh các phản ứng thông tin và hành vi để đạt được hiệu quả tối ưu.',
          image: '/images/NLP/NLP_Section 3.3.png'
        },
        order: 12
      },
      {
        id: 'nlp_restructure_title',
        type: 'heading',
        content: { level: 2, text: 'NLP - Tái cấu trúc hệ điều hành cuộc đời bạn' },
        order: 13
      },
      {
        id: 'nlp_restructure_desc',
        type: 'paragraph',
        content: {
          text: 'NLP dựa trên cơ sở bộ não của chúng ta có thể được tái cấu trúc để biến chúng ta thành những thực thể mới. Hay nói cách khác, bộ não là hệ điều hành của cuộc sống. NLP giúp thay đổi cách chúng ta nghĩ về bản thân, về người khác, về thế giới và thay thế bằng những điều hữu ích cho cuộc sống.'
        },
        order: 14
      },
      {
        id: 'nlp_toolbox_title',
        type: 'heading',
        content: { level: 2, text: 'NLP - Hộp công cụ cuộc sống đa năng' },
        order: 15
      },
      {
        id: 'nlp_toolbox_desc',
        type: 'paragraph',
        content: {
          text: 'NLP là một tập hợp gồm nhiều công cụ và kỹ thuật hữu ích trang bị cho bạn khả năng:'
        },
        order: 16
      },
      {
        id: 'nlp_self_understanding',
        type: 'feature',
        content: {
          title: 'Hiểu rõ bản thân',
          description: 'Hiểu rõ hơn về giá trị, mục tiêu, niềm tin và khả năng của bản thân để phát triển tiềm năng cá nhân.',
          image: '/images/NLP/NLP_Section 7.1.png'
        },
        order: 17
      },
      {
        id: 'nlp_understand_others',
        type: 'feature',
        content: {
          title: 'Hiểu rõ người khác',
          description: 'Nâng cao kỹ năng giao tiếp, tạo ra mối quan hệ tốt đẹp và ảnh hưởng tích cực đến những người xung quanh.',
          image: '/images/NLP/NLP_Section 7.2.png'
        },
        order: 18
      },
      {
        id: 'nlp_communication',
        type: 'feature',
        content: {
          title: 'Giao tiếp hiệu quả',
          description: 'Phát triển kỹ năng giao tiếp, thuyết trình và ảnh hưởng tích cực đến người khác.',
          image: '/images/NLP/NLP_Section 7.3.png'
        },
        order: 19
      },
      {
        id: 'nlp_goal_achievement',
        type: 'feature',
        content: {
          title: 'Đạt được mục tiêu',
          description: 'Sử dụng các kỹ thuật NLP để thiết lập và đạt được các mục tiêu cá nhân và nghề nghiệp.',
          image: '/images/NLP/NLP_Section 7.4.png'
        },
        order: 20
      }
    ];

    // Generate HTML content từ blocks
    const htmlContent = nlpContent.map(block => {
      switch(block.type) {
        case 'hero':
          return `<div class="hero-section relative h-96 bg-cover bg-center rounded-xl overflow-hidden mb-8" style="background-image: url('${block.content.backgroundImage}')">
            <div class="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent"></div>
            <div class="absolute inset-0 flex items-center">
              <div class="container mx-auto px-8">
                <div class="max-w-2xl">
                  <h1 class="text-5xl font-bold text-white mb-6">${block.content.title}</h1>
                  <p class="text-xl text-white/90">${block.content.subtitle}</p>
                  <p class="text-lg text-white/80 mt-4">${block.content.description}</p>
                </div>
              </div>
            </div>
          </div>`;
        case 'heading':
          return `<h${block.content.level} class="text-${block.content.level === 1 ? '4xl' : block.content.level === 2 ? '3xl' : '2xl'} font-bold text-gray-900 mb-6 text-center">${block.content.text}</h${block.content.level}>`;
        case 'paragraph':
          return `<p class="text-lg text-gray-700 leading-relaxed mb-6">${block.content.text}</p>`;
        case 'card':
          return `<div class="bg-white rounded-lg shadow-md p-6 text-center">
            <img src="${block.content.image}" alt="${block.content.title}" class="w-full h-48 object-cover rounded-lg mb-4">
            <h3 class="text-xl font-bold mb-3">${block.content.title}</h3>
            <p class="text-gray-700">${block.content.text}</p>
          </div>`;
        case 'feature':
          return `<div class="bg-white rounded-lg shadow-md overflow-hidden mb-6">
            <img src="${block.content.image}" alt="${block.content.title}" class="w-full h-64 object-cover">
            <div class="p-6">
              <h3 class="text-2xl font-bold mb-3">${block.content.title}</h3>
              <p class="text-gray-700 leading-relaxed">${block.content.description}</p>
            </div>
          </div>`;
        default:
          return '';
      }
    }).join('');

    // Tìm page NLP hiện tại
    const existingPage = await prisma.page.findFirst({
      where: {
        OR: [
          { slug: 'nlp' },
          { path: '/nlp' }
        ]
      }
    });

    if (existingPage) {
      // Cập nhật page hiện tại
      const updatedPage = await prisma.page.update({
        where: { id: existingPage.id },
        data: {
          title: 'NLP - Neuro Linguistic Programming',
          content: nlpContent,
          htmlContent: htmlContent,
          metaTitle: 'NLP - Lập trình ngôn ngữ tư duy | InnerBright',
          metaDescription: 'Khám phá NLP (Neuro Linguistic Programming) - phương pháp lập trình ngôn ngữ tư duy giúp phát triển bản thân và đạt được thành công trong cuộc sống.',
          featuredImage: '/images/NLP/NLP_Section 1.png',
          status: 'PUBLISHED',
          publishedAt: new Date(),
        }
      });

      console.log('✅ Đã cập nhật page NLP:', updatedPage.id);
    } else {
      // Tạo page mới
      const newPage = await prisma.page.create({
        data: {
          title: 'NLP - Neuro Linguistic Programming',
          slug: 'nlp',
          path: '/nlp',
          content: nlpContent,
          htmlContent: htmlContent,
          metaTitle: 'NLP - Lập trình ngôn ngữ tư duy | InnerBright',
          metaDescription: 'Khám phá NLP (Neuro Linguistic Programming) - phương pháp lập trình ngôn ngữ tư duy giúp phát triển bản thân và đạt được thành công trong cuộc sống.',
          featuredImage: '/images/NLP/NLP_Section 1.png',
          status: 'PUBLISHED',
          publishedAt: new Date(),
          views: 0,
          isHomePage: false
        }
      });

      console.log('✅ Đã tạo page NLP mới:', newPage.id);
    }

    console.log('🎉 Cập nhật dữ liệu NLP thành công!');
    console.log('📋 Nội dung bao gồm:');
    console.log('   - Hero section với background image');
    console.log('   - Giới thiệu về NLP');
    console.log('   - 3 câu hỏi cuộc sống');
    console.log('   - 3 thành phần của NLP');
    console.log('   - Ứng dụng và lợi ích');
    console.log('   - Các tính năng chính');

  } catch (error) {
    console.error('❌ Lỗi khi cập nhật page NLP:', error);
  } finally {
    await prisma.$disconnect();
  }
}

updateNLPPageData();
