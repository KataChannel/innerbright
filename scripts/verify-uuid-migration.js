const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Function để kiểm tra format UUID
function isValidUUID(str) {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(str);
}

async function verifyUuidMigration() {
  console.log('🔍 Verifying UUID migration...');
  
  try {
    // Check Pages
    const pages = await prisma.page.findMany();
    console.log(`\n📄 Pages (${pages.length} total):`);
    pages.forEach(page => {
      const isValid = isValidUUID(page.id);
      console.log(`  ${isValid ? '✅' : '❌'} ${page.id} - "${page.title}"`);
    });

    // Check Categories
    const categories = await prisma.category.findMany();
    console.log(`\n📂 Categories (${categories.length} total):`);
    categories.forEach(category => {
      const isValid = isValidUUID(category.id);
      console.log(`  ${isValid ? '✅' : '❌'} ${category.id} - "${category.name}"`);
    });

    // Check Users
    const users = await prisma.user.findMany();
    console.log(`\n👥 Users (${users.length} total):`);
    users.forEach(user => {
      const isValid = isValidUUID(user.id);
      console.log(`  ${isValid ? '✅' : '❌'} ${user.id} - "${user.displayName || user.email}"`);
    });

    // Check Posts
    const posts = await prisma.post.findMany();
    console.log(`\n📝 Posts (${posts.length} total):`);
    posts.forEach(post => {
      const isValid = isValidUUID(post.id);
      console.log(`  ${isValid ? '✅' : '❌'} ${post.id} - "${post.title}"`);
    });

    // Summary
    const allEntities = [...pages, ...categories, ...users, ...posts];
    const validUUIDs = allEntities.filter(entity => isValidUUID(entity.id));
    const invalidUUIDs = allEntities.filter(entity => !isValidUUID(entity.id));

    console.log(`\n📊 Migration Summary:`);
    console.log(`  ✅ Valid UUIDs: ${validUUIDs.length}`);
    console.log(`  ❌ Invalid UUIDs: ${invalidUUIDs.length}`);
    console.log(`  📈 Success Rate: ${((validUUIDs.length / allEntities.length) * 100).toFixed(1)}%`);

    if (invalidUUIDs.length > 0) {
      console.log(`\n❌ Invalid IDs found:`);
      invalidUUIDs.forEach(entity => {
        console.log(`  - ${entity.id} (Table: ${entity.constructor.name})`);
      });
    } else {
      console.log(`\n🎉 All IDs are valid UUIDs!`);
    }

  } catch (error) {
    console.error('❌ Verification failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

verifyUuidMigration();
