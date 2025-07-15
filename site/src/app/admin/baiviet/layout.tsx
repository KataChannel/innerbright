'use client';

import { useState, useEffect } from 'react';
import { Trash2, Edit, Plus } from 'lucide-react';
import { Input, Button } from '@/components';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import Typography from '@mui/material/Typography';

export default function BaiVietLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <div className="container mx-auto p-6 max-w-6xl">
            {children}
        </div>
    );
}
