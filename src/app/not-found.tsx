'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';

export default function NotFound() {
    const router = useRouter();

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
            <div className="max-w-md w-full text-center space-y-6 p-8">
                <div className="space-y-2">
                    <h1 className="text-6xl font-bold text-gray-900">404</h1>
                    <h2 className="text-2xl font-semibold text-gray-700">Page Not Found</h2>
                    <p className="text-gray-500">
                        The page you are looking for does not exist.
                    </p>
                </div>
                
                <div className="flex gap-4 justify-center">
                    <button
                        onClick={() => router.back()}
                        className="px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors duration-200 font-medium"
                    >
                        Go Back
                    </button>
                    
                    <Link
                        href="/"
                        className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200 font-medium inline-block"
                    >
                        Go Home
                    </Link>
                </div>
            </div>
        </div>
    );
}