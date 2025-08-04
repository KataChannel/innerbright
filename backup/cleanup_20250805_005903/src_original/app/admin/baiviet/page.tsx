"use client";
import { useState, useEffect } from "react";
import { Trash2, Edit, Plus, Save, X, Eye } from "lucide-react";
import BlockEditor, { Post, BlockData } from '@/components/BlockEditor';

interface BaiViet {
    id: string;
    tieuDe: string;
    noiDung: BlockData[]; // Sử dụng BlockData từ BlockEditor
    noiDungText?: string; // Plain text version for search/preview
    tacGia: string;
    ngayTao: string;
    ngayCapNhat: string;
    trangThai: 'draft' | 'published';
    tags: string[];
    moTa: string;
    anhDaiDien?: string;
}

export default function BaiVietPage() {
    const [baiViets, setBaiViets] = useState<BaiViet[]>([]);
    const [isEditing, setIsEditing] = useState(false);
    const [editingId, setEditingId] = useState<string | null>(null);
    const [showEditor, setShowEditor] = useState(false);
    const [currentPost, setCurrentPost] = useState<Post | null>(null);

    // Load dữ liệu từ localStorage khi component mount
    useEffect(() => {
        const savedBaiViets = localStorage.getItem("baiViets");
        if (savedBaiViets) {
            setBaiViets(JSON.parse(savedBaiViets));
        }
    }, []);

    // Lưu dữ liệu vào localStorage
    const saveBaiViets = (data: BaiViet[]) => {
        localStorage.setItem("baiViets", JSON.stringify(data));
        setBaiViets(data);
    };

    // Convert BlockData to plain text for preview
    const extractTextFromBlocks = (blocks: BlockData[]): string => {
        return blocks.map(block => {
            switch (block.type) {
                case 'heading':
                    return block.content.text;
                case 'paragraph':
                    return block.content.text;
                case 'quote':
                    return `"${block.content.text}" - ${block.content.author || ''}`;
                case 'list':
                    return block.content.items.join(', ');
                case 'code':
                    return block.content.code;
                default:
                    return '';
            }
        }).join(' ').substring(0, 300);
    };

    // Convert Post to BaiViet
    const postToBaiViet = (post: Post): BaiViet => {
        return {
            id: post.id,
            tieuDe: post.title,
            noiDung: post.content,
            noiDungText: extractTextFromBlocks(post.content),
            tacGia: post.author,
            ngayTao: post.publishedAt,
            ngayCapNhat: new Date().toISOString(),
            trangThai: post.status,
            tags: post.tags,
            moTa: post.excerpt,
            anhDaiDien: post.featuredImage
        };
    };

    // Convert BaiViet to Post
    const baiVietToPost = (baiViet: BaiViet): Post => {
        return {
            id: baiViet.id,
            title: baiViet.tieuDe,
            slug: baiViet.tieuDe.toLowerCase()
                .replace(/[^\w\s-]/g, '')
                .replace(/\s+/g, '-'),
            content: baiViet.noiDung,
            author: baiViet.tacGia,
            publishedAt: baiViet.ngayTao,
            tags: baiViet.tags,
            status: baiViet.trangThai,
            excerpt: baiViet.moTa,
            featuredImage: baiViet.anhDaiDien
        };
    };

    // Thêm bài viết mới
    const handleAdd = () => {
        const newPost: Post = {
            id: Date.now().toString(),
            title: 'Bài viết mới',
            slug: 'bai-viet-moi',
            content: [],
            author: 'Admin',
            publishedAt: new Date().toISOString(),
            tags: [],
            status: 'draft',
            excerpt: 'Mô tả ngắn cho bài viết...',
            featuredImage: ''
        };

        setCurrentPost(newPost);
        setIsEditing(false);
        setEditingId(null);
        setShowEditor(true);
    };

    // Sửa bài viết
    const handleEdit = (id: string) => {
        const baiViet = baiViets.find(item => item.id === id);
        if (baiViet) {
            const post = baiVietToPost(baiViet);
            setCurrentPost(post);
            setEditingId(id);
            setIsEditing(true);
            setShowEditor(true);
        }
    };

    // Lưu bài viết từ BlockEditor
    const handleSaveFromEditor = (post: Post) => {
        const baiViet = postToBaiViet(post);

        if (isEditing && editingId) {
            // Cập nhật bài viết
            const updatedBaiViets = baiViets.map(item =>
                item.id === editingId ? baiViet : item
            );
            saveBaiViets(updatedBaiViets);
        } else {
            // Thêm bài viết mới
            const updatedBaiViets = [...baiViets, baiViet];
            saveBaiViets(updatedBaiViets);
        }

        // Đóng editor
        setShowEditor(false);
        setCurrentPost(null);
        setIsEditing(false);
        setEditingId(null);
    };

    // Xem trước bài viết
    const handlePreview = (post: Post) => {
        console.log('Preview post:', post);
    };

    // Xóa bài viết
    const handleDelete = (id: string) => {
        if (confirm("Bạn có chắc chắn muốn xóa bài viết này?")) {
            const updatedBaiViets = baiViets.filter(item => item.id !== id);
            saveBaiViets(updatedBaiViets);
        }
    };

    // Đóng editor
    const handleCloseEditor = () => {
        setShowEditor(false);
        setCurrentPost(null);
        setIsEditing(false);
        setEditingId(null);
    };

    // Hiển thị BlockEditor
    if (showEditor && currentPost) {
        return (
            <div className="max-w-7xl mx-auto p-6">
                <div className="bg-white rounded-lg shadow-md mb-6">
                    <div className="p-4 border-b border-gray-200 flex justify-between items-center">
                        <h2 className="text-xl font-semibold">
                            {isEditing ? "Chỉnh sửa bài viết" : "Tạo bài viết mới"}
                        </h2>
                        <button
                            onClick={handleCloseEditor}
                            className="flex items-center gap-2 px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
                        >
                            <X size={16} />
                            Đóng
                        </button>
                    </div>
                    <div className="p-4">
                        <BlockEditor
                            initialPost={currentPost}
                            onSave={handleSaveFromEditor}
                            onPreview={handlePreview}
                        />
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="max-w-6xl mx-auto p-6">
            <div className="flex justify-between items-center mb-8">
                <h1 className="text-3xl font-bold">Quản lý Bài viết</h1>
                <button
                    onClick={handleAdd}
                    className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                >
                    <Plus size={16} />
                    Thêm bài viết mới
                </button>
            </div>

            {/* Danh sách bài viết */}
            <div className="bg-white rounded-lg shadow-md">
                <div className="p-6 border-b">
                    <h2 className="text-xl font-semibold">Danh sách bài viết ({baiViets.length})</h2>
                </div>

                {baiViets.length === 0 ? (
                    <div className="p-8 text-center text-gray-500">
                        Chưa có bài viết nào. Hãy thêm bài viết đầu tiên!
                    </div>
                ) : (
                    <div className="divide-y">
                        {baiViets.map((baiViet) => (
                            <div key={baiViet.id} className="p-6">
                                <div className="flex justify-between items-start mb-3">
                                    <div className="flex-1">
                                        <h3 className="text-lg font-medium text-gray-900 mb-2">
                                            {baiViet.tieuDe}
                                        </h3>
                                        <p className="text-gray-600 mb-2">{baiViet.moTa}</p>
                                        <div className="flex flex-wrap gap-2 mb-3">
                                            {baiViet.tags && baiViet.tags.length > 0 && baiViet.tags.map((tag, index) => (
                                                <span
                                                    key={index}
                                                    className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full"
                                                >
                                                    {tag}
                                                </span>
                                            ))}
                                        </div>
                                    </div>
                                    <div className="flex gap-2 ml-4">
                                        <span
                                            className={`px-2 py-1 text-xs rounded-full ${
                                                baiViet.trangThai === 'published'
                                                    ? 'bg-green-100 text-green-800'
                                                    : 'bg-yellow-100 text-yellow-800'
                                            }`}
                                        >
                                            {baiViet.trangThai === 'published' ? 'Đã xuất bản' : 'Bản nháp'}
                                        </span>
                                        <button
                                            onClick={() => handleEdit(baiViet.id)}
                                            className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                        >
                                            <Edit size={16} />
                                        </button>
                                        <button
                                            onClick={() => handleDelete(baiViet.id)}
                                            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                                        >
                                            <Trash2 size={16} />
                                        </button>
                                    </div>
                                </div>
                                
                                <div className="text-gray-600 mb-3">
                                    <div className="line-clamp-3 text-sm">
                                        {baiViet.noiDungText || "Nội dung trống"}
                                    </div>
                                </div>
                                
                                <div className="text-sm text-gray-500 flex justify-between">
                                    <div>
                                        <span>Tác giả: {baiViet.tacGia}</span>
                                        <span className="mx-2">•</span>
                                        <span>Tạo: {new Date(baiViet.ngayTao).toLocaleDateString("vi-VN")}</span>
                                        {baiViet.ngayCapNhat !== baiViet.ngayTao && (
                                            <>
                                                <span className="mx-2">•</span>
                                                <span>
                                                    Cập nhật: {new Date(baiViet.ngayCapNhat).toLocaleDateString("vi-VN")}
                                                </span>
                                            </>
                                        )}
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}