// File: src/app/components/common/Header.tsx
"use client";
import Link from "next/link";
import Image from "next/image";
import React, { useState } from "react";
import Navbar from "../ui/Navbars";

const Header: React.FC = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const handleAuth = () => {
    setIsLoggedIn(!isLoggedIn);
  };

  return (
    <header className="flex justify-between items-center p-4 border-gray-500 rounded shadow-md bg-white">
      {/* Logo */}
        <Link href="/">
          <Image src="/logo.png" alt="Logo" width={40} height={40} className="h-10 filter grayscale" />
        </Link>

      {/* Navbar */}
      <Navbar />
      {/* Login/Logout Button */}
      <div className="auth">
        <button
          onClick={handleAuth}
          className="px-4 py-2 bg-black text-white rounded"
        >
          {isLoggedIn ? "Đăng xuất" : "Đăng nhập"}
        </button>
      </div>
    </header>
  );
};

export default Header;
