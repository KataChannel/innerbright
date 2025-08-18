const { PrismaClient } = require('@prisma/client');
const { v4: uuidv4 } = require('uuid');

const prisma = new PrismaClient();

// Mapping table để track CUID -> UUID conversion
const idMapping = new Map();

// Function để generate UUID và lưu mapping
function generateUuidWithMapping(oldId) {
  if (idMapping.has(oldId)) {
    return idMapping.get(oldId);
  }
  const newId = uuidv4();
  idMapping.set(oldId, newId);
  return newId;
}

async function migrateToUuid() {
  console.log('🚀 Starting CUID to UUID migration...');
  
  try {
    // Disable foreign key checks temporarily
    await prisma.$executeRaw`SET session_replication_role = replica;`;
    
    console.log('📋 Step 1: Migrating Users...');
    const users = await prisma.$queryRaw`SELECT * FROM users`;
    const userMappings = new Map();
    
    for (const user of users) {
      const newId = generateUuidWithMapping(user.id);
      userMappings.set(user.id, newId);
      
      await prisma.$executeRaw`
        UPDATE users 
        SET id = ${newId}
        WHERE id = ${user.id}
      `;
    }
    console.log(`✅ Migrated ${users.length} users`);

    console.log('📋 Step 2: Migrating Roles...');
    const roles = await prisma.$queryRaw`SELECT * FROM roles`;
    const roleMappings = new Map();
    
    for (const role of roles) {
      const newId = generateUuidWithMapping(role.id);
      roleMappings.set(role.id, newId);
      
      await prisma.$executeRaw`
        UPDATE roles 
        SET id = ${newId}
        WHERE id = ${role.id}
      `;
    }
    console.log(`✅ Migrated ${roles.length} roles`);

    console.log('📋 Step 3: Updating User-Role relationships...');
    for (const user of users) {
      if (user.roleId && roleMappings.has(user.roleId)) {
        const newUserId = userMappings.get(user.id);
        const newRoleId = roleMappings.get(user.roleId);
        
        await prisma.$executeRaw`
          UPDATE users 
          SET "roleId" = ${newRoleId}
          WHERE id = ${newUserId}
        `;
      }
    }

    console.log('📋 Step 4: Migrating Categories...');
    const categories = await prisma.$queryRaw`SELECT * FROM categories`;
    const categoryMappings = new Map();
    
    for (const category of categories) {
      const newId = generateUuidWithMapping(category.id);
      categoryMappings.set(category.id, newId);
      
      await prisma.$executeRaw`
        UPDATE categories 
        SET id = ${newId}
        WHERE id = ${category.id}
      `;
    }
    console.log(`✅ Migrated ${categories.length} categories`);

    console.log('📋 Step 5: Migrating Tags...');
    const tags = await prisma.$queryRaw`SELECT * FROM tags`;
    const tagMappings = new Map();
    
    for (const tag of tags) {
      const newId = generateUuidWithMapping(tag.id);
      tagMappings.set(tag.id, newId);
      
      await prisma.$executeRaw`
        UPDATE tags 
        SET id = ${newId}
        WHERE id = ${tag.id}
      `;
    }
    console.log(`✅ Migrated ${tags.length} tags`);

    console.log('📋 Step 6: Migrating Posts...');
    const posts = await prisma.$queryRaw`SELECT * FROM posts`;
    const postMappings = new Map();
    
    for (const post of posts) {
      const newId = generateUuidWithMapping(post.id);
      postMappings.set(post.id, newId);
      
      const newAuthorId = post.authorId && userMappings.has(post.authorId) 
        ? userMappings.get(post.authorId) 
        : post.authorId;
      
      const newCategoryId = post.categoryId && categoryMappings.has(post.categoryId)
        ? categoryMappings.get(post.categoryId)
        : post.categoryId;
      
      await prisma.$executeRaw`
        UPDATE posts 
        SET id = ${newId},
            "authorId" = ${newAuthorId},
            "categoryId" = ${newCategoryId}
        WHERE id = ${post.id}
      `;
    }
    console.log(`✅ Migrated ${posts.length} posts`);

    console.log('📋 Step 7: Migrating PostTags...');
    const postTags = await prisma.$queryRaw`SELECT * FROM post_tags`;
    
    for (const postTag of postTags) {
      const newPostId = postMappings.has(postTag.postId) 
        ? postMappings.get(postTag.postId) 
        : postTag.postId;
      
      const newTagId = tagMappings.has(postTag.tagId)
        ? tagMappings.get(postTag.tagId)
        : postTag.tagId;
      
      await prisma.$executeRaw`
        UPDATE post_tags 
        SET "postId" = ${newPostId},
            "tagId" = ${newTagId}
        WHERE "postId" = ${postTag.postId} AND "tagId" = ${postTag.tagId}
      `;
    }
    console.log(`✅ Migrated ${postTags.length} post-tag relationships`);

    console.log('📋 Step 8: Migrating Pages...');
    const pages = await prisma.$queryRaw`SELECT * FROM pages`;
    
    for (const page of pages) {
      const newId = generateUuidWithMapping(page.id);
      
      const newAuthorId = page.authorId && userMappings.has(page.authorId)
        ? userMappings.get(page.authorId)
        : page.authorId;
      
      await prisma.$executeRaw`
        UPDATE pages 
        SET id = ${newId},
            "authorId" = ${newAuthorId}
        WHERE id = ${page.id}
      `;
    }
    console.log(`✅ Migrated ${pages.length} pages`);

    console.log('📋 Step 9: Migrating Conversations...');
    const conversations = await prisma.$queryRaw`SELECT * FROM conversations`;
    const conversationMappings = new Map();
    
    for (const conversation of conversations) {
      const newId = generateUuidWithMapping(conversation.id);
      conversationMappings.set(conversation.id, newId);
      
      const newCreatedById = conversation.createdById && userMappings.has(conversation.createdById)
        ? userMappings.get(conversation.createdById)
        : conversation.createdById;
      
      await prisma.$executeRaw`
        UPDATE conversations 
        SET id = ${newId},
            "createdById" = ${newCreatedById}
        WHERE id = ${conversation.id}
      `;
    }
    console.log(`✅ Migrated ${conversations.length} conversations`);

    console.log('📋 Step 10: Migrating Messages...');
    const messages = await prisma.$queryRaw`SELECT * FROM messages`;
    
    for (const message of messages) {
      const newId = generateUuidWithMapping(message.id);
      
      const newUserId = message.userId && userMappings.has(message.userId)
        ? userMappings.get(message.userId)
        : message.userId;
      
      const newConversationId = conversationMappings.has(message.conversationId)
        ? conversationMappings.get(message.conversationId)
        : message.conversationId;
      
      await prisma.$executeRaw`
        UPDATE messages 
        SET id = ${newId},
            "userId" = ${newUserId},
            "conversationId" = ${newConversationId}
        WHERE id = ${message.id}
      `;
    }
    console.log(`✅ Migrated ${messages.length} messages`);

    console.log('📋 Step 11: Migrating WebBuilder Templates...');
    const templates = await prisma.$queryRaw`SELECT * FROM webbuilder_templates`;
    
    for (const template of templates) {
      const newId = generateUuidWithMapping(template.id);
      
      await prisma.$executeRaw`
        UPDATE webbuilder_templates 
        SET id = ${newId}
        WHERE id = ${template.id}
      `;
    }
    console.log(`✅ Migrated ${templates.length} webbuilder templates`);

    // Re-enable foreign key checks
    await prisma.$executeRaw`SET session_replication_role = DEFAULT;`;
    
    console.log('🎉 Migration completed successfully!');
    console.log(`📊 Total mappings created: ${idMapping.size}`);
    
    // Save mapping for reference
    const mappingData = Object.fromEntries(idMapping);
    require('fs').writeFileSync(
      '/mnt/chikiet/Innerbright/innerbright/scripts/cuid-to-uuid-mapping.json',
      JSON.stringify(mappingData, null, 2)
    );
    console.log('💾 ID mapping saved to cuid-to-uuid-mapping.json');
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Run migration
migrateToUuid()
  .then(() => {
    console.log('✅ All done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Fatal error:', error);
    process.exit(1);
  });
