'use client';
import { useCallback, useState } from 'react';
import { BlockData, BlockType, Post } from '../types';
import { 
  findBlock, 
  getMaxOrder, 
  updateBlockChildren, 
  updateBlockInTree, 
  removeBlockFromTree, 
  moveBlockInTree, 
  cloneBlockRecursive, 
  isContainerBlock,
  getDefaultContent 
} from '../utils';

export const useBlockEditor = (initialPost: Post) => {
  const [post, setPost] = useState<Post>(initialPost);
  const [activeBlockId, setActiveBlockId] = useState<string | null>(null);
  const [expandedBlocks, setExpandedBlocks] = useState<Set<string>>(new Set());

  // Enhanced add block with parent support
  const addBlock = useCallback((type: BlockType, afterId?: string, parentId?: string) => {
    const newBlock: BlockData = {
      id: Date.now().toString(),
      type,
      content: getDefaultContent(type),
      order: afterId ? 
        findBlock(post.content, afterId)?.order! + 0.5 :
        getMaxOrder(post.content, parentId) + 1,
      parentId,
      children: isContainerBlock(type) ? [] : undefined
    };

    if (parentId) {
      setPost((prev: Post) => ({
        ...prev,
        content: updateBlockChildren(prev.content, parentId, newBlock)
      }));
    } else {
      setPost((prev: Post) => ({
        ...prev,
        content: [...prev.content, newBlock].sort((a, b) => a.order - b.order)
      }));
    }
    
    setActiveBlockId(newBlock.id);
    if (isContainerBlock(type)) {
      setExpandedBlocks(prev => new Set([...prev, newBlock.id]));
    }
  }, [post.content]);

  // Enhanced update block
  const updateBlock = useCallback((id: string, content: any) => {
    setPost((prev: Post) => ({
      ...prev,
      content: updateBlockInTree(prev.content, id, content)
    }));
  }, []);

  // Enhanced delete block
  const deleteBlock = useCallback((id: string) => {
    setPost((prev: Post) => ({
      ...prev,
      content: removeBlockFromTree(prev.content, id)
    }));
    setActiveBlockId(null);
  }, []);

  // Move block within container or to different container
  const moveBlock = useCallback((id: string, direction: 'up' | 'down' | 'left' | 'right', targetParentId?: string) => {
    setPost((prev: Post) => ({
      ...prev,
      content: moveBlockInTree(prev.content, id, direction, targetParentId)
    }));
  }, []);

  // Clone block with all children
  const cloneBlock = useCallback((id: string) => {
    const block = findBlock(post.content, id);
    if (!block) return;

    const clonedBlock = cloneBlockRecursive(block, Date.now().toString());
    clonedBlock.order = block.order + 0.1;

    if (block.parentId) {
      setPost((prev: Post) => ({
        ...prev,
        content: updateBlockChildren(prev.content, block.parentId!, clonedBlock)
      }));
    } else {
      setPost((prev: Post) => ({
        ...prev,
        content: [...prev.content, clonedBlock].sort((a, b) => a.order - b.order)
      }));
    }
  }, [post.content]);

  // Toggle block expansion
  const toggleExpanded = useCallback((id: string) => {
    setExpandedBlocks(prev => {
      const newSet = new Set(prev);
      if (newSet.has(id)) {
        newSet.delete(id);
      } else {
        newSet.add(id);
      }
      return newSet;
    });
  }, []);

  return {
    post,
    setPost,
    activeBlockId,
    setActiveBlockId,
    expandedBlocks,
    setExpandedBlocks,
    addBlock,
    updateBlock,
    deleteBlock,
    moveBlock,
    cloneBlock,
    toggleExpanded
  };
};
