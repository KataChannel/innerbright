export const siteConfig = {
    title: "InnerBright - Học viện NLP Master Coach ABNLP Hoa Kỳ",
    offline: false, // Chỉ sử dụng khi website không cần kết nối internet
    maintenance: {
        enabled: false, // Bật/tắt chế độ bảo trì
        message: "Website đang trong quá trình bảo trì. Vui lòng quay lại sau!",
        allowedUsers: ["admin@example.com", "user@example.com"], // Email được phép truy cập khi bảo trì
        estimatedTime: "8/7/2025"
    },
    auth: {
        loginRequired: true, // Yêu cầu đăng nhập để truy cập
        redirectAfterLogin: "/dashboard", // Trang chuyển hướng sau khi đăng nhập thành công
        redirectAfterLogout: "/login"
    },
    theme: "light", // Chế độ giao diện: 'light', 'dark',
    logo: "/images/logo.png", // Đường dẫn đến logo của website
    logoDark: "/images/logo-dark.png", // Đường dẫn đến logo tối của website
    logoLight: "/images/logo-light.png", // Đường dẫn đến logo sáng của website
    logoWidth: 150, // Chiều rộng của logo
    logoHeight: 50, // Chiều cao của logo
    logoAlt: "InnerBright - Học viện NLP Master Coach ABNLP Hoa Kỳ",
    titleTemplate: "%s | InnerBright - Học viện NLP Master Coach ABNLP Hoa Kỳ",
    titleSeparator: "|",
    titleSuffix: "InnerBright",
    description: "InnerBright tự hào là Học viện đào tạo NLP và NLP Master Coach được bảo chứng bởi ABNLP Hoa Kỳ, hiệp hội lâu đời và uy tín nhất về NLP. Chúng tôi giúp bạn thấu hiểu bản chất con người, xây dựng năng lực lãnh đạo phi quyền lực và kiến tạo sự nghiệp thành công bền vững.",
    keywords: [
        "từ khóa 1",
        "từ khóa 2",
        "từ khóa 3"
    ],
    url: "https://www.tenwebsite.com",
    author: {
        name: "Tên tác giả hoặc công ty",
        url: "https://www.tenwebsite.com/about"
    },
    language: "vi",
    charset: "UTF-8",
    viewport: "width=device-width, initial-scale=1.0",
    og: {
        type: "website",
        title: "Tên Website",
        description: "Mô tả ngắn gọn về website để tối ưu SEO.",
        url: "https://www.tenwebsite.com",
        image: "https://www.tenwebsite.com/og-image.jpg"
    },
    twitter: {
        card: "summary_large_image",
        site: "@twitter_handle",
        title: "Tên Website",
        description: "Mô tả ngắn gọn về website để tối ưu SEO.",
        image: "https://www.tenwebsite.com/twitter-image.jpg"
    },
    favicon: "/favicon.ico"
};