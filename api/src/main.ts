import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Get environment variables
  const port = process.env.API_PORT || process.env.PORT || 3001;
  const corsOrigin = process.env.CORS_ORIGIN || 'http://localhost:3000';
  
  // Enable CORS for frontend communication
  app.enableCors({
    origin: corsOrigin.split(',').map(origin => origin.trim()),
    credentials: true,
  });

  // Enable graceful shutdown
  app.enableShutdownHooks();

  await app.listen(port, '0.0.0.0');
  console.log(`🚀 API server is running on http://0.0.0.0:${port}`);
  console.log(`🌐 CORS enabled for: ${corsOrigin}`);
}

bootstrap().catch((error) => {
  console.error('❌ Failed to start the application:', error);
  process.exit(1);
});
