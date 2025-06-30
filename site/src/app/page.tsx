import Image from "next/image";
import ApiTest from "../components/ApiTest";

export default function Home() {
  return (
    <div className="min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="max-w-4xl mx-auto">
        <div className="flex flex-col gap-8 items-center">
          <div className="flex items-center gap-4">
            <Image
              className="dark:invert"
              src="/next.svg"
              alt="Next.js logo"
              width={180}
              height={38}
              priority
            />
            <span className="text-2xl font-bold">+</span>
            <div className="text-xl font-bold bg-red-500 text-white px-3 py-1 rounded">
              NestJS
            </div>
          </div>
          
          <h1 className="text-4xl font-bold text-center">
            KataCore Full Stack Application
          </h1>
          
          <p className="text-center text-lg text-gray-600 dark:text-gray-300 max-w-2xl">
            A modern full-stack application built with Next.js 15, React 19, NestJS 11, 
            and powered by Bun.js for optimal performance.
          </p>

          <div className="w-full max-w-2xl">
            <ApiTest />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-4xl">
            <div className="border rounded-lg p-6">
              <h2 className="text-xl font-bold mb-2">Frontend Features</h2>
              <ul className="space-y-1 text-sm">
                <li>⚡ Next.js 15 with Turbopack</li>
                <li>⚛️ React 19</li>
                <li>🎨 Tailwind CSS 4</li>
                <li>📱 Responsive Design</li>
                <li>🔄 Hot Reload</li>
              </ul>
            </div>
            
            <div className="border rounded-lg p-6">
              <h2 className="text-xl font-bold mb-2">Backend Features</h2>
              <ul className="space-y-1 text-sm">
                <li>🚀 NestJS 11</li>
                <li>⚡ Bun.js Runtime</li>
                <li>🛡️ TypeScript</li>
                <li>🌐 CORS Enabled</li>
                <li>📊 Health Monitoring</li>
              </ul>
            </div>
          </div>

          <div className="flex gap-4 items-center flex-col sm:flex-row">
            <a
              className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-foreground text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] font-medium text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
              href="http://localhost:3001"
              target="_blank"
              rel="noopener noreferrer"
            >
              View API
            </a>
            <a
              className="rounded-full border border-solid border-black/[.08] dark:border-white/[.145] transition-colors flex items-center justify-center hover:bg-[#f2f2f2] dark:hover:bg-[#1a1a1a] hover:border-transparent text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 sm:min-w-44"
              href="http://localhost:3001/health"
              target="_blank"
              rel="noopener noreferrer"
            >
              API Health Check
            </a>
          </div>
        </div>
      </main>
    </div>
  );
}
