import { NextResponse } from 'next/server';

export async function GET() {
  try {
    return NextResponse.json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'Innerbright Site',
      version: process.env.SITE_VERSION || 'latest',
      nodeEnv: process.env.NODE_ENV || 'development'
    });
  } catch (error) {
    return NextResponse.json({
      status: 'error',
      timestamp: new Date().toISOString(),
      service: 'Innerbright Site',
      error: 'Health check failed'
    }, { status: 500 });
  }
}
