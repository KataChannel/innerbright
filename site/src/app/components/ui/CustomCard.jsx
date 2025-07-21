// components/ui/Card.jsx
import dynamic from 'next/dynamic';

const CustomCard = ({ title, description, imageUrl }) => {
  return (
    <div className="border rounded shadow-lg p-4">
      {imageUrl && <img src={imageUrl} alt={title} className="w-full h-48 object-cover" />}
      <h2 className="text-xl font-bold">{title}</h2>
      <p className="text-gray-600">{description}</p>
    </div>
  );
};

export default dynamic(() => Promise.resolve(CustomCard), { ssr: false });