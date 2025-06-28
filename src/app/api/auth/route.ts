import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
    // Example: Fetch data or perform server-side logic
    try {
        // const { searchParams } = new URL(req.url);
        // const id = searchParams.get('id');

        return NextResponse.json({ message: 'Auth API route works!', timestamp: new Date().toISOString() });
    } catch (error) {
        console.error('API Error:', error);
        return NextResponse.json({ message: 'Internal Server Error' }, { status: 500 });
    }
}

// export async function POST(req: NextRequest) {
//     const body = await req.json();
//     return NextResponse.json({ message: 'POST request received', data: body });
// }