// File: src/app/components/common/Header.tsx
"use client";
import Link from "next/link";
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
      <div className="logo">
        <Link href="/">
          <img src="/logo.png" alt="Logo" className="h-10 filter grayscale" />
        </Link>
      </div>

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
