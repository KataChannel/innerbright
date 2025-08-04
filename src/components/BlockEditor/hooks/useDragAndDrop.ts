// 📝 Drag and Drop Logic cho BlockEditor
'use client';
import { useCallback, useState } from 'react';
import { DragState, BlockData, Post } from '../types';
import { 
  findBlock, 
  removeBlockFromTree, 
  updateBlockChildren, 
  getMaxOrder, 
  reorderBlocks, 
  isContainerBlock 
} from '../utils';

export const useDragAndDrop = (
  post: Post,
  setPost: React.Dispatch<React.SetStateAction<Post>>,
  setExpandedBlocks: React.Dispatch<React.SetStateAction<Set<string>>>
) => {
  const [dragState, setDragState] = useState<DragState>({
    isDragging: false,
    draggedBlockId: null,
    dropTargetId: null,
    dropPosition: null,
    dragOverlay: false
  });

  const handleDragStart = useCallback((e: React.DragEvent, blockId: string) => {
    e.dataTransfer.setData('text/plain', blockId);
    e.dataTransfer.effectAllowed = 'move';
    
    setDragState({
      isDragging: true,
      draggedBlockId: blockId,
      dropTargetId: null,
      dropPosition: null,
      dragOverlay: true
    });

    // Create drag preview
    const dragElement = e.currentTarget as HTMLElement;
    const rect = dragElement.getBoundingClientRect();
    const canvas = document.createElement('canvas');
    canvas.width = rect.width;
    canvas.height = rect.height;
    const ctx = canvas.getContext('2d');
    if (ctx) {
      ctx.fillStyle = 'rgba(59, 130, 246, 0.1)';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.strokeStyle = '#3b82f6';
      ctx.lineWidth = 2;
      ctx.strokeRect(0, 0, canvas.width, canvas.height);
    }
    e.dataTransfer.setDragImage(canvas, rect.width / 2, rect.height / 2);
  }, []);

  const handleDragEnd = useCallback(() => {
    setDragState({
      isDragging: false,
      draggedBlockId: null,
      dropTargetId: null,
      dropPosition: null,
      dragOverlay: false
    });
  }, []);

  const handleDragOver = useCallback((e: React.DragEvent, targetId: string, position: 'before' | 'after' | 'inside') => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    
    if (dragState.draggedBlockId && dragState.draggedBlockId !== targetId) {
      setDragState((prev: DragState) => ({
        ...prev,
        dropTargetId: targetId,
        dropPosition: position
      }));
    }
  }, [dragState.draggedBlockId]);

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
    const { clientX, clientY } = e;
    
    // Only clear drop target if mouse leaves the element bounds
    if (
      clientX < rect.left ||
      clientX > rect.right ||
      clientY < rect.top ||
      clientY > rect.bottom
    ) {
      setDragState((prev: DragState) => ({
        ...prev,
        dropTargetId: null,
        dropPosition: null
      }));
    }
  }, []);

  const handleDrop = useCallback((e: React.DragEvent, targetId: string, position: 'before' | 'after' | 'inside') => {
    e.preventDefault();
    
    const draggedId = e.dataTransfer.getData('text/plain');
    if (!draggedId || draggedId === targetId) return;

    const draggedBlock = findBlock(post.content, draggedId);
    const targetBlock = findBlock(post.content, targetId);
    
    if (!draggedBlock || !targetBlock) return;

    // Remove dragged block from its current position
    const contentWithoutDragged = removeBlockFromTree(post.content, draggedId);
    
    // Calculate new order and parent
    let newOrder: number;
    let newParentId: string | undefined;

    if (position === 'inside' && isContainerBlock(targetBlock.type)) {
      newParentId = targetId;
      newOrder = getMaxOrder(contentWithoutDragged, targetId) + 1;
    } else {
      newParentId = targetBlock.parentId;
      if (position === 'before') {
        newOrder = targetBlock.order - 0.1;
      } else {
        newOrder = targetBlock.order + 0.1;
      }
    }

    // Update dragged block
    const updatedDraggedBlock: BlockData = {
      ...draggedBlock,
      order: newOrder,
      parentId: newParentId
    };

    // Insert block at new position
    let newContent: BlockData[];
    if (newParentId) {
      newContent = updateBlockChildren(contentWithoutDragged, newParentId, updatedDraggedBlock);
    } else {
      newContent = [...contentWithoutDragged, updatedDraggedBlock].sort((a, b) => a.order - b.order);
    }

    // Reorder blocks to maintain sequential order
    newContent = reorderBlocks(newContent);

    setPost((prev: Post) => ({
      ...prev,
      content: newContent
    }));

    // Expand parent container if needed
    if (newParentId && isContainerBlock(targetBlock.type)) {
      setExpandedBlocks(prev => new Set([...prev, newParentId]));
    }

    handleDragEnd();
  }, [post.content, handleDragEnd, setPost, setExpandedBlocks]);

  return {
    dragState,
    handleDragStart,
    handleDragEnd,
    handleDragOver,
    handleDragLeave,
    handleDrop
  };
};
