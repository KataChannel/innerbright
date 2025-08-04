// 📝 Utility Functions cho BlockEditor
import { BlockData, BlockType } from './types';
import { CONTAINER_BLOCK_TYPES, DEFAULT_BLOCK_CONTENT, BLOCK_TYPE_ICONS } from './constants';

// Check if block type is container
export const isContainerBlock = (type: BlockType): boolean => {
  return CONTAINER_BLOCK_TYPES.includes(type);
};

// Get default content for block type
export const getDefaultContent = (type: BlockType) => {
  return DEFAULT_BLOCK_CONTENT[type] || {};
};

// Get block type icon
export const getBlockTypeIcon = (type: BlockType): string => {
  return BLOCK_TYPE_ICONS[type] || '•';
};

// Find block in tree by ID
export const findBlock = (blocks: BlockData[], id: string): BlockData | null => {
  for (const block of blocks) {
    if (block.id === id) return block;
    if (block.children) {
      const found = findBlock(block.children, id);
      if (found) return found;
    }
  }
  return null;
};

// Get maximum order in blocks array
export const getMaxOrder = (blocks: BlockData[], parentId?: string): number => {
  if (parentId) {
    const parent = findBlock(blocks, parentId);
    if (parent?.children) {
      return Math.max(...parent.children.map(b => b.order), 0);
    }
  }
  return Math.max(...blocks.map(b => b.order), 0);
};

// Update block content in tree
export const updateBlockInTree = (blocks: BlockData[], id: string, content: any): BlockData[] => {
  return blocks.map(block => {
    if (block.id === id) {
      return { ...block, content };
    }
    if (block.children) {
      return { ...block, children: updateBlockInTree(block.children, id, content) };
    }
    return block;
  });
};

// Remove block from tree
export const removeBlockFromTree = (blocks: BlockData[], id: string): BlockData[] => {
  return blocks
    .filter(block => block.id !== id)
    .map(block => ({
      ...block,
      children: block.children ? removeBlockFromTree(block.children, id) : block.children
    }));
};

// Update block children
export const updateBlockChildren = (blocks: BlockData[], parentId: string, newChild: BlockData): BlockData[] => {
  return blocks.map(block => {
    if (block.id === parentId) {
      return {
        ...block,
        children: [...(block.children || []), newChild].sort((a, b) => a.order - b.order)
      };
    }
    if (block.children) {
      return { ...block, children: updateBlockChildren(block.children, parentId, newChild) };
    }
    return block;
  });
};

// Move block in tree
export const moveBlockInTree = (blocks: BlockData[], id: string, direction: 'up' | 'down' | 'left' | 'right', targetParentId?: string): BlockData[] => {
  const block = findBlock(blocks, id);
  if (!block) return blocks;

  const siblings = block.parentId 
    ? findBlock(blocks, block.parentId)?.children || []
    : blocks.filter(b => !b.parentId);

  const currentIndex = siblings.findIndex(b => b.id === id);
  if (currentIndex === -1) return blocks;

  let newOrder = block.order;
  
  switch (direction) {
    case 'up':
      if (currentIndex > 0) {
        newOrder = siblings[currentIndex - 1].order - 0.1;
      }
      break;
    case 'down':
      if (currentIndex < siblings.length - 1) {
        newOrder = siblings[currentIndex + 1].order + 0.1;
      }
      break;
  }

  return updateBlockInTree(blocks, id, { ...block.content, order: newOrder });
};

// Clone block recursively
export const cloneBlockRecursive = (block: BlockData, newId: string): BlockData => {
  return {
    ...block,
    id: newId,
    children: block.children?.map((child, index) => 
      cloneBlockRecursive(child, `${newId}-${index}`)
    )
  };
};

// Reorder blocks to maintain sequential order
export const reorderBlocks = (blocks: BlockData[]): BlockData[] => {
  const reorderRecursive = (blockList: BlockData[]): BlockData[] => {
    return blockList
      .sort((a, b) => a.order - b.order)
      .map((block, index) => ({
        ...block,
        order: index + 1,
        children: block.children ? reorderRecursive(block.children) : block.children
      }));
  };

  return reorderRecursive(blocks);
};
