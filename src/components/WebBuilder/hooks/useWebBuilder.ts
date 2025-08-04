// 📝 Web Builder Hook - Page Builder Logic
import { useCallback, useState } from 'react';
import { PageData, PageBlockData, PageBlockType, BlockStyles } from '../types';
import { generateUniqueId, getDefaultBlockContent, insertBlockIntoTree, updateBlockInTree, removeBlockFromTree } from '../utils';

export const useWebBuilder = (initialPage: PageData) => {
  const [page, setPage] = useState<PageData>(initialPage);
  const [activeBlockId, setActiveBlockId] = useState<string | null>(null);
  const [isEditMode, setIsEditMode] = useState(true);
  const [selectedBlocks, setSelectedBlocks] = useState<Set<string>>(new Set());
  const [clipboard, setClipboard] = useState<PageBlockData | null>(null);
  const [history, setHistory] = useState<PageData[]>([initialPage]);
  const [historyIndex, setHistoryIndex] = useState(0);

  // Add new block
  const addBlock = useCallback((type: PageBlockType, afterId?: string, parentId?: string) => {
    const newBlock: PageBlockData = {
      id: generateUniqueId(),
      type,
      content: getDefaultBlockContent(type),
      order: afterId ? getBlockOrder(afterId) + 0.5 : getMaxOrder() + 1,
      parentId,
      styles: getDefaultStyles(type),
      animations: {},
      responsiveSettings: {}
    };

    setPage(prev => {
      const newContent = insertBlockIntoTree(prev.content, newBlock, afterId, parentId);
      const newPage = {
        ...prev,
        content: newContent,
        updatedAt: new Date().toISOString()
      };
      addToHistory(newPage);
      return newPage;
    });

    setActiveBlockId(newBlock.id);
  }, [page.content]);

  // Update block content
  const updateBlockContent = useCallback((id: string, content: any) => {
    setPage(prev => {
      const newContent = updateBlockInTree(prev.content, id, { content });
      const newPage = {
        ...prev,
        content: newContent,
        updatedAt: new Date().toISOString()
      };
      return newPage;
    });
  }, []);

  // Update block styles
  const updateBlockStyles = useCallback((id: string, styles: BlockStyles) => {
    setPage(prev => {
      const newContent = updateBlockInTree(prev.content, id, { styles });
      const newPage = {
        ...prev,
        content: newContent,
        updatedAt: new Date().toISOString()
      };
      addToHistory(newPage);
      return newPage;
    });
  }, []);

  // Delete block
  const deleteBlock = useCallback((id: string) => {
    setPage(prev => {
      const newContent = removeBlockFromTree(prev.content, id);
      const newPage = {
        ...prev,
        content: newContent,
        updatedAt: new Date().toISOString()
      };
      addToHistory(newPage);
      return newPage;
    });
    setActiveBlockId(null);
    setSelectedBlocks(prev => {
      const newSet = new Set(prev);
      newSet.delete(id);
      return newSet;
    });
  }, []);

  // Duplicate block
  const duplicateBlock = useCallback((id: string) => {
    const block = findBlockById(id);
    if (!block) return;

    const duplicatedBlock: PageBlockData = {
      ...JSON.parse(JSON.stringify(block)),
      id: generateUniqueId(),
      order: block.order + 0.1
    };

    setPage(prev => {
      const newContent = insertBlockIntoTree(prev.content, duplicatedBlock, id);
      const newPage = {
        ...prev,
        content: newContent,
        updatedAt: new Date().toISOString()
      };
      addToHistory(newPage);
      return newPage;
    });
  }, [page.content]);

  // Copy block to clipboard
  const copyBlock = useCallback((id: string) => {
    const block = findBlockById(id);
    if (block) {
      setClipboard(JSON.parse(JSON.stringify(block)));
    }
  }, [page.content]);

  // Paste block from clipboard
  const pasteBlock = useCallback((afterId?: string) => {
    if (!clipboard) return;

    const pastedBlock: PageBlockData = {
      ...JSON.parse(JSON.stringify(clipboard)),
      id: generateUniqueId(),
      order: afterId ? getBlockOrder(afterId) + 0.5 : getMaxOrder() + 1
    };

    setPage(prev => {
      const newContent = insertBlockIntoTree(prev.content, pastedBlock, afterId);
      const newPage = {
        ...prev,
        content: newContent,
        updatedAt: new Date().toISOString()
      };
      addToHistory(newPage);
      return newPage;
    });
  }, [clipboard, page.content]);

  // Move block up/down
  const moveBlock = useCallback((id: string, direction: 'up' | 'down') => {
    const block = findBlockById(id);
    if (!block) return;

    const siblings = getSiblings(id);
    const currentIndex = siblings.findIndex(b => b.id === id);
    
    if (direction === 'up' && currentIndex > 0) {
      const targetOrder = siblings[currentIndex - 1].order;
      updateBlockOrder(id, targetOrder - 0.1);
    } else if (direction === 'down' && currentIndex < siblings.length - 1) {
      const targetOrder = siblings[currentIndex + 1].order;
      updateBlockOrder(id, targetOrder + 0.1);
    }
  }, [page.content]);

  // Toggle block selection
  const toggleBlockSelection = useCallback((id: string, multi = false) => {
    setSelectedBlocks(prev => {
      const newSet = new Set(multi ? prev : []);
      if (newSet.has(id)) {
        newSet.delete(id);
      } else {
        newSet.add(id);
      }
      return newSet;
    });
  }, []);

  // Clear selection
  const clearSelection = useCallback(() => {
    setSelectedBlocks(new Set());
  }, []);

  // Undo/Redo
  const undo = useCallback(() => {
    if (historyIndex > 0) {
      const newIndex = historyIndex - 1;
      setHistoryIndex(newIndex);
      setPage(history[newIndex]);
    }
  }, [history, historyIndex]);

  const redo = useCallback(() => {
    if (historyIndex < history.length - 1) {
      const newIndex = historyIndex + 1;
      setHistoryIndex(newIndex);
      setPage(history[newIndex]);
    }
  }, [history, historyIndex]);

  // Update page metadata
  const updatePageMeta = useCallback((updates: Partial<PageData>) => {
    setPage(prev => {
      const newPage = {
        ...prev,
        ...updates,
        updatedAt: new Date().toISOString()
      };
      addToHistory(newPage);
      return newPage;
    });
  }, []);

  // Helper functions
  const findBlockById = useCallback((id: string): PageBlockData | null => {
    const findInBlocks = (blocks: PageBlockData[]): PageBlockData | null => {
      for (const block of blocks) {
        if (block.id === id) return block;
        if (block.children) {
          const found = findInBlocks(block.children);
          if (found) return found;
        }
      }
      return null;
    };
    return findInBlocks(page.content);
  }, [page.content]);

  const getBlockOrder = useCallback((id: string): number => {
    const block = findBlockById(id);
    return block ? block.order : 0;
  }, [findBlockById]);

  const getMaxOrder = useCallback((): number => {
    const getAllOrders = (blocks: PageBlockData[]): number[] => {
      const orders: number[] = [];
      blocks.forEach(block => {
        orders.push(block.order);
        if (block.children) {
          orders.push(...getAllOrders(block.children));
        }
      });
      return orders;
    };
    const orders = getAllOrders(page.content);
    return orders.length > 0 ? Math.max(...orders) : 0;
  }, [page.content]);

  const getSiblings = useCallback((id: string): PageBlockData[] => {
    const block = findBlockById(id);
    if (!block) return [];
    
    if (block.parentId) {
      const parent = findBlockById(block.parentId);
      return parent?.children || [];
    }
    return page.content;
  }, [findBlockById, page.content]);

  const updateBlockOrder = useCallback((id: string, newOrder: number) => {
    setPage(prev => {
      const newContent = updateBlockInTree(prev.content, id, { order: newOrder });
      const newPage = {
        ...prev,
        content: newContent,
        updatedAt: new Date().toISOString()
      };
      addToHistory(newPage);
      return newPage;
    });
  }, []);

  const addToHistory = useCallback((newPage: PageData) => {
    setHistory(prev => {
      const newHistory = prev.slice(0, historyIndex + 1);
      newHistory.push(newPage);
      
      // Limit history to 50 items
      if (newHistory.length > 50) {
        newHistory.shift();
      }
      
      return newHistory;
    });
    setHistoryIndex(prev => Math.min(prev + 1, 49));
  }, [historyIndex]);

  const getDefaultStyles = (type: PageBlockType): BlockStyles => {
    const baseStyles: BlockStyles = {
      padding: { top: 20, right: 20, bottom: 20, left: 20 },
      margin: { top: 0, right: 0, bottom: 0, left: 0 }
    };

    switch (type) {
      case 'hero':
        return {
          ...baseStyles,
          backgroundColor: '#1e293b',
          textColor: '#ffffff',
          padding: { top: 100, right: 40, bottom: 100, left: 40 }
        };
      case 'section':
        return {
          ...baseStyles,
          backgroundColor: '#ffffff',
          padding: { top: 60, right: 40, bottom: 60, left: 40 }
        };
      default:
        return baseStyles;
    }
  };

  return {
    // State
    page,
    setPage,
    activeBlockId,
    setActiveBlockId,
    isEditMode,
    setIsEditMode,
    selectedBlocks,
    clipboard,
    canUndo: historyIndex > 0,
    canRedo: historyIndex < history.length - 1,

    // Actions
    addBlock,
    updateBlockContent,
    updateBlockStyles,
    deleteBlock,
    duplicateBlock,
    copyBlock,
    pasteBlock,
    moveBlock,
    toggleBlockSelection,
    clearSelection,
    undo,
    redo,
    updatePageMeta,

    // Helpers
    findBlockById,
    getSiblings
  };
};
