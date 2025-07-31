import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();
const BACKUP_ROOT_DIR = 'innerbright_json';
async function getTables(): Promise<string[]> {
  const tables: { tablename: string }[] =
    await prisma.$queryRaw`SELECT tablename FROM pg_tables WHERE schemaname='public'`;
  return tables.map((table) => table.tablename);
}

async function restoreTableFromJson(table: string): Promise<void> {
  try {
    const latestBackupDir = fs.readdirSync(BACKUP_ROOT_DIR).sort().reverse()[0];
    console.log(`Đang khôi phục dữ liệu: ${latestBackupDir}`);
    if (!latestBackupDir) {
      console.error(`❌ Không tìm thấy thư mục backup.`);
      return;
    }
    
    const filePath: string = path.join(
      BACKUP_ROOT_DIR,
      latestBackupDir,
      `${table}.json`,
    );
    if (!fs.existsSync(filePath)) {
      //  console.error(`❌ Không tìm thấy file backup cho bảng ${table}`);
      return;
    }
    const data: any[] = JSON.parse(fs.readFileSync(filePath, 'utf8'));

    if (Array.isArray(data) && data.length > 0) {
      // Convert string numbers to actual numbers, especially for 'size' field
      const processedData = data.map((item) => {
        const newItem = { ...item };
        if (newItem.size && typeof newItem.size === 'string') {
          newItem.size =
            newItem.size.trim() === '' ? null : parseInt(newItem.size, 10);
        }
        return newItem;
      });

      const model = (prisma as any)[table];
      if (!model || typeof model.createMany !== 'function') {
        console.log(
          `Bảng join ${table} không có model. Sử dụng raw SQL để restore dữ liệu.`,
        );

        const columns = Object.keys(processedData[0])
          .map((col) => `"${col}"`)
          .join(', ');

        const values = processedData
          .map((item) => {
            return (
              '(' +
              Object.values(item)
                .map((val) => {
                  if (typeof val === 'string') {
                    // escape single quotes by doubling them
                    return `'${val.replace(/'/g, "''")}'`;
                  } else if (val === null || val === undefined) {
                    return 'NULL';
                  }
                  return val;
                })
                .join(', ') +
              ')'
            );
          })
          .join(', ');

        await prisma.$executeRawUnsafe(
          `INSERT INTO "${table}" (${columns}) VALUES ${values} ON CONFLICT DO NOTHING`,
        );

        return;
      } else {
        await model.createMany({
          data: processedData,
          skipDuplicates: true, // Bỏ qua nếu trùng
        });
      }

      console.log(`✅ Đã nhập dữ liệu vào bảng ${table}`);
    }
  } catch (error) {
    console.error(`❌ Lỗi khôi phục bảng ${table}:`, error);
  }
}

async function restoreAllTablesFromJson(): Promise<void> {
  const tables: string[] = await getTables();
  console.log(`Tìm thấy ${tables.length} bảng trong cơ sở dữ liệu.`);
  
  for (const table of tables) {
    await restoreTableFromJson(table);
  }
}
restoreAllTablesFromJson()
  .then(() => console.log('🎉 Khôi phục dữ liệu JSON hoàn tất!'))
  .catch((err) => console.error('Lỗi:', err))
  .finally(() => prisma.$disconnect());
