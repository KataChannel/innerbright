# Kata Startkit Monochrome - Dự Án SEO Next.js

Đây là dự án Next.js được xây dựng theo phong cách thiết kế tối giản, monochrome với hỗ trợ dark mode và tối ưu SEO. Dự án này sử dụng Start Kit của Kata, hướng tới trải nghiệm người dùng mượt mà và thân thiện với công cụ tìm kiếm.

## Tính Năng

- Giao diện trực quan theo phong cách monochrome với dark mode.
- Cấu hình sẵn các chuẩn SEO cho các trang.
- Hỗ trợ chuyển đổi chế độ light/dark tự động dựa trên cài đặt hệ thống.
- Phù hợp cho các dự án web SEO chuẩn nhất.

## Cài Đặt

1. Clone dự án về máy:
    ```bash
    git clone https://your-repository-url.git
    cd your-project-directory
    ```

2. Cài đặt các package cần thiết:
    ```bash
    npm install
    # hoặc
    yarn
    ```

3. Chạy server phát triển:
    ```bash
    npm run dev
    # hoặc
    yarn dev
    # hoặc
    pnpm dev
    # hoặc
    bun dev
    ```

Mở [http://localhost:3000](http://localhost:3000) trên trình duyệt để xem kết quả.

## Cấu Hình SEO

Dự án đã được cấu hình sẵn các thẻ meta, tiêu đề trang và cấu trúc URL tối ưu. Bạn có thể tùy chỉnh SEO trong các file cấu hình hoặc trực tiếp trong các thành phần trang:

- Sử dụng layout hoặc Head component có sẵn trong Next.js.
- Tùy chỉnh thông qua tệp cấu hình SEO riêng (ví dụ: seo.config.js).

## Hỗ Trợ Dark Mode

Dự án sử dụng CSS custom properties kết hợp với class `.dark` để hỗ trợ dark mode. Ví dụ, để kích hoạt dark mode thủ công, bạn có thể thêm class `.dark` vào phần tử HTML gốc:

```html
<html class="dark">
  <head>
     <!-- ... -->
  </head>
  <body>
     <!-- Nội dung trang -->
  </body>
</html>
```

## Cấu Trúc Dự Án

- Thư mục `app/`: Chứa các trang và thành phần giao diện được xây dựng theo Next.js.
- Thư mục `styles/`: Bao gồm các file CSS, trong đó có định nghĩa cho dark mode và các biến màu.
- Các file cấu hình gốc (SEO, Next.js, Babel, v.v.) nằm ở thư mục dự án.

## Triển Khai

Dự án có thể được triển khai dễ dàng lên các nền tảng hỗ trợ Next.js như Vercel, Netlify hoặc bất kỳ máy chủ Node.js nào. Tham khảo [tài liệu triển khai](https://example.com/deploy-guide) để biết thêm chi tiết.

## Tài Liệu Tham Khảo

- [Tài liệu Next.js](https://nextjs.org/docs)
- [Hướng dẫn tối ưu SEO với Next.js](https://example.com/seo-guide)
- [Monochrome Design Principles](https://example.com/monochrome-design)


git add .
git commit -m "update"
git push