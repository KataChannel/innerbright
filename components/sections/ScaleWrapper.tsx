"use client";

import { useEffect, useState, ReactNode } from "react";

/**
 * ScaleWrapper handles fitting a 1920px fixed-width design into the viewport.
 * - If browser < 1920px: It scales the whole content down and sticks to the top-left.
 * - If browser >= 1920px: It keeps at 1:1 scale and centers the content.
 */
export default function ScaleWrapper({ children, height = 8391 }: { children: ReactNode, height?: number }) {
  const [scale, setScale] = useState(1);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
    const handleResize = () => {
      const designWidth = 1920;
      const windowWidth = window.innerWidth;

      // Calculate scale to fit width
      if (windowWidth < designWidth) {
        // eslint-disable-next-line react-hooks/set-state-in-effect
        setScale(windowWidth / designWidth);
      } else {
        setScale(1);
      }
    };

    handleResize();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  if (!mounted) {
    return <div style={{ opacity: 0 }}>{children}</div>;
  }

  const originalHeight = height;

  return (
    <div
      style={{
        width: "100%",
        minHeight: "100vh",
        backgroundColor: "#fff",
        overflowX: "hidden",
        position: "relative",
        height: `${originalHeight * scale}px`,
      }}
    >
      <div
        style={{
          width: "1920px",
          height: `${originalHeight}px`,
          position: "absolute",
          top: 0,
          left: scale < 1 ? "0" : "50%",
          marginLeft: scale < 1 ? "0" : "-960px",
          transform: `scale(${scale})`,
          transformOrigin: "top left",
          transition: "transform 0.05s linear",
        }}
      >
        {children}
      </div>
    </div>
  );
}
