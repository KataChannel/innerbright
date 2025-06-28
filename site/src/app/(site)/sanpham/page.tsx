import ProductList from '@/app/components/common/ProductList';
export default function Products() {
  const products = [
    { id: 1, name: 'Laptop', price: 999, image: '/laptop.jpg' },
    { id: 2, name: 'Phone', price: 499, image: '/phone.jpg' },
  ];

  return (
    <div>
      <h1>Our Products</h1>
      <ProductList products={products} />
    </div>
  );
}