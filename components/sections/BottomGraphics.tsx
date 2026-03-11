import { getAssetUrl } from '@/utils/asset';
export default function BottomGraphics() {
  return (
    <div id="aic">
      <img id="aid" src={getAssetUrl("/aid.png")} srcSet={`${getAssetUrl("/aid.png")} 1x, ${getAssetUrl("/aid@2x.png")} 2x`} alt="Bottom Graphic" />
    </div>
  );
}
