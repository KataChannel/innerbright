export const siteConfig = {
  name: "InnerBright",
  description: "Khám phá sức mạnh tiềm ẩn bên trong bạn với các khóa học NLP, Time Line Therapy và Hypnosis chuyên nghiệp.",
  url: "https://innerbright.vn",
  ogImage: "https://innerbright.vn/og.jpg",
  keywords: ["NLP", "Time Line Therapy", "Hypnosis", "Phát triển bản thân", "Coaching"],
  author: {
    name: "InnerBright Team",
    url: "https://innerbright.vn",
  },
  
  // Maintenance mode settings
  offline: false, // Set to true to enable maintenance mode
  maintenance: {
    message: "Chúng tôi đang nâng cấp hệ thống để mang đến trải nghiệm tốt hơn cho bạn.",
    estimatedTime: "2-3 giờ",
    allowedUsers: [
      "admin@innerbright.vn",
      "dev@innerbright.vn"
    ]
  },
  
  navigation: [
    { label: "Về InnerBright", href: "/about" },
    { label: "NLP", href: "/nlp" },
    { label: "Time Line Therapy", href: "/time-line-therapy" },
    { label: "Đào tạo doanh nghiệp", href: "/corporate-training" },
    { label: "Khai vấn cá nhân", href: "/personal-consultation" },
    { label: "Khoá học", href: "/courses" },
    { label: "Bộ thẻ NLP", href: "/nlp-cards" },
    { label: "Thư viện", href: "/library" },
    { label: "Liên hệ", href: "/contact" },
  ],
  social: {
    facebook: "https://facebook.com/innerbright",
    youtube: "https://youtube.com/@innerbright",
    instagram: "https://instagram.com/innerbright",
  },
  contact: {
    email: "contact@innerbright.vn",
    phone: "+84 xxx xxx xxx",
    address: "TP. Hồ Chí Minh, Việt Nam",
  },
  auth: {
    loginRequired: false,
    redirectAfterLogin: "/admin", 
    redirectAfterLogout: "/"
  },
  theme: "light",
  logo: "/images/logo.png",
  logoDark: "/images/logo-dark.png",
  logoLight: "/images/logo-light.png",
  logoWidth: 150,
  logoHeight: 50,
  logoAlt: "InnerBright Training & Coaching",
  titleTemplate: "%s | InnerBright",
  titleSeparator: "|",
  titleSuffix: "InnerBright",
  language: "vi",
  charset: "UTF-8",
  viewport: "width=device-width, initial-scale=1.0",
  og: {
    type: "website",
    title: "InnerBright - Tâm Lý Trị Liệu Tích Cực",
    description: "Trung tâm tâm lý trị liệu chuyên nghiệp với các phương pháp NLP và Time-line Therapy hiệu quả.",
    url: "https://innerbright.vn",
    image: "https://innerbright.vn/og-image.jpg"
  },
  twitter: {
    card: "summary_large_image",
    site: "@innerbright",
    creator: "@innerbright",
    title: "InnerBright - Tâm Lý Trị Liệu Tích Cực",
    description: "Trung tâm tâm lý trị liệu chuyên nghiệp với các phương pháp NLP và Time-line Therapy hiệu quả.",
    image: "https://innerbright.vn/twitter-image.jpg"
  },
  robots: {
    index: true,
    follow: true,
    archive: true,
    imageindex: true,
    snippet: true
  },
  openGraph: {
    type: "website",
    locale: "vi_VN",
    siteName: "InnerBright",
    url: "https://innerbright.vn",
    title: "InnerBright - Tâm Lý Trị Liệu Tích Cực",
    description: "Trung tâm tâm lý trị liệu chuyên nghiệp với các phương pháp NLP và Time-line Therapy hiệu quả.",
    images: [
      {
        url: "https://innerbright.vn/og-image.jpg",
        width: 1200,
        height: 630,
        alt: "InnerBright - Tâm Lý Trị Liệu Tích Cực"
      }
    ]
  },
  favicon: "/favicon.ico"
} as const;
