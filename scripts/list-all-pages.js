const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function listAllPages() {
  console.log('📋 Danh sách tất cả các trang trong database...\n');
  
  try {
    const pages = await prisma.page.findMany({
      orderBy: { createdAt: 'asc' },
      select: {
        id: true,
        title: true,
        slug: true,
        path: true,
        status: true,
        isHomePage: true,
        views: true,
        publishedAt: true,
        createdAt: true
      }
    });

    if (pages.length === 0) {
      console.log('❌ Không có trang nào trong database');
      return;
    }

    console.log(`✅ Tìm thấy ${pages.length} trang(s):\n`);

    pages.forEach((page, index) => {
      console.log(`${index + 1}. ${page.title}`);
      console.log(`   📝 ID: ${page.id}`);
      console.log(`   🔗 Slug: ${page.slug}`);
      console.log(`   🌐 Path: ${page.path}`);
      console.log(`   📊 Status: ${page.status}`);
      console.log(`   🏠 Home Page: ${page.isHomePage ? 'Yes' : 'No'}`);
      console.log(`   👁️ Views: ${page.views}`);
      console.log(`   📅 Published: ${page.publishedAt ? page.publishedAt.toISOString().split('T')[0] : 'Not published'}`);
      console.log(`   🕒 Created: ${page.createdAt.toISOString().split('T')[0]}`);
      console.log('');
    });

    console.log('🔗 URLs để truy cập:');
    pages.forEach(page => {
      if (page.status === 'PUBLISHED') {
        console.log(`   ✅ ${page.title}: http://localhost:3000${page.path}`);
        console.log(`   ✏️ Edit: http://localhost:3000/admin/pages/${page.id}/edit`);
      }
    });

    console.log('\n📊 Thống kê:');
    const publishedCount = pages.filter(p => p.status === 'PUBLISHED').length;
    const draftCount = pages.filter(p => p.status === 'DRAFT').length;
    const homePageCount = pages.filter(p => p.isHomePage).length;
    
    console.log(`   📄 Tổng số trang: ${pages.length}`);
    console.log(`   ✅ Đã xuất bản: ${publishedCount}`);
    console.log(`   📝 Bản nháp: ${draftCount}`);
    console.log(`   🏠 Trang chủ: ${homePageCount}`);

  } catch (error) {
    console.error('❌ Lỗi khi lấy danh sách trang:', error);
  } finally {
    await prisma.$disconnect();
  }
}

listAllPages();
