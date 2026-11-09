# Color difference in the README figure

<a id="english"></a>
## English

**In one sentence: the bottom curve is the CIELAB distance between neighboring colors in the colormap.**

### What is calculated

Each RGB row is treated as display-encoded sRGB. The code removes the sRGB transfer curve, converts linear RGB to CIE XYZ, and then converts XYZ to CIELAB with D65 reference white and the CIE 1931 2-degree standard observer. This defines the assumed colorimetric conditions; it does not measure the visitor's monitor. Once the sRGB encoding and reference white are specified, the conversion is a defined numerical calculation. Using it to describe an actual display assumes that the display pipeline reproduces those sRGB values. A different gamut, transfer curve or rendering pipeline can violate that assumption. Even measured display XYZ values would still be summarized by an approximate perceptual metric when converted to ΔE76.

CIELAB represents a color with three coordinates: L* for lightness, a* for the red–green axis, and b* for the yellow–blue axis. For adjacent rows i and i+1, the plotted value is the Euclidean distance:

$$
\Delta E_{76,i}=\sqrt{(L^*_{i+1}-L^*_i)^2+(a^*_{i+1}-a^*_i)^2+(b^*_{i+1}-b^*_i)^2}.
$$

The figure uses 360 equally spaced HSV hue positions, before 8-bit quantization. Because the map is cyclic, the last color is also compared with the first, giving 360 distances. The horizontal axis is position along the HSV hue cycle. The vertical axis is a color-space distance.

### Reading the curve and CV

A peak means a larger CIELAB distance for that single increment of the colormap coordinate; a trough means a smaller distance. A flat curve would mean equally sized steps according to ΔE76 at this sampling density.

CV is a summary of the relative variation in those distances: population standard deviation divided by their mean. The implementation uses `std(steps,1)/max(eps,mean(steps))` to guard against division by zero. Compare maps with the same sampling and colorimetric assumptions. CV alone ignores the overall span of colors: a constant-color table has zero differences and is not useful for distinguishing values, even if its reported CV is zero.

In this particular comparison, CV is approximately 0.488 for MATLAB HSV and 0.782 after the component S-curve. The S-curve produces smoother RGB joins and more variable ΔE76 steps. RGB regularity and CIELAB step uniformity are separate properties.

### What the number can tell you

ΔE76 provides a reproducible first approximation to the relative size of color differences. CIELAB is only approximately perceptually uniform; known nonuniformities motivated improved formulas such as CIEDE2000. A different metric can change the numerical values and comparisons.

This calculation uses the LUT alone. It does not include a measured display profile, surround, spatial layout, color-vision differences or the viewer's task. A small CV is therefore not proof of readability, accessibility or accurate data interpretation. The curve is a diagnostic, not an overall quality score.

<a id="japanese"></a>
## 日本語

**ひと言でいうと、下段の曲線は「カラーマップで隣り合う色の、CIELAB上の距離」です。**

### 計算しているもの

RGBの各行を表示符号化されたsRGBとして扱います。sRGBの伝達関数を逆変換して線形RGBに戻し、CIE XYZ、CIELABの順に変換します。基準白色はD65、等色関数はCIE 1931の2度標準観測者を前提としています。これは計算条件の指定であり、訪問者のモニターを実測した結果ではありません。sRGBの符号化と基準白色を指定すれば、変換は定義された数値計算です。ただし、実際の表示色を表すには、表示系がそのsRGB値を再現するという仮定が加わります。色域、伝達特性、描画処理が異なれば、この仮定から外れることがあります。さらに、装置のXYZを実測しても、ΔE76で知覚差を表す部分には近似が残ります。

CIELABでは、一つの色を明度L*、赤–緑方向のa*、黄–青方向のb*で表します。隣接する2色について、この3次元空間の直線距離を求めた値がΔE76です。式は上の英語節と共通です。

図ではHSVの色相周期を360等分し、8ビット量子化前の色を使います。循環する配色なので、末尾と先頭の組も含め、360個の色差を求めます。横軸はHSVの色相周期上の位置、縦軸は色空間上の距離です。

### 曲線とCVの読み方

山はカラーマップ座標が一段階進んだときのCIELAB色差が大きい場所、谷は小さい場所です。平らなら、その標本数ではΔE76上の色差が均等という意味です。

CV（変動係数）は、360個の色差の母標準偏差を平均で割った値で、相対的なばらつきを表します。実装ではゼロ除算を避けるため、`std(steps,1)/max(eps,mean(steps))`と計算します。比較するときは標本数と色の計算条件を揃えてください。CVだけでは配色全体の変化量が分かりません。例えば全行が同じ色なら色差もCVも0になりますが、値を区別する用途には役立ちません。

今回の例では、MATLAB HSVのCVは約0.488、component S-curveを適用した側は約0.782です。RGBの接続は滑らかになりますが、ΔE76の間隔はむしろ不均等になります。RGB値の滑らかさと、CIELAB上の色差の均等さは別の性質です。

### どこまで信頼できるか

ΔE76は、色の違いの相対的な大きさを近似する、再現可能な診断指標です。ただしCIELABの知覚的な均等性には限界があり、CIEDE2000などの改良された色差式も存在します。指標を変えれば数値や比較結果も変わり得ます。

この計算に使うのはLUTだけです。実測したディスプレイ特性、周囲の色、空間的な配置、色覚の個人差、見る人の作業内容は計算に入りません。CVが小さいことだけで、見やすさ、アクセシビリティ、データ解釈の正確さを結論することはできません。配色を総合的に採点する値ではなく、性質を確認するための指標です。

## Sources

- [CIE: ISO/CIE 11664-6:2022 overview](https://www.cie.co.at/publications/colorimetry-part-6-ciede2000-colour-difference-formula-1): approximate uniformity of CIELAB and the motivation for more refined color-difference formulas.
- [MathWorks: deltaE](https://www.mathworks.com/help/images/ref/deltae.html): CIE76 color difference.
- [MathWorks: rgb2lab](https://www.mathworks.com/help/images/ref/rgb2lab.html): sRGB and reference-white conventions. ColormapTools implements its own conversion and does not require Image Processing Toolbox.

Functions: [analyze_colormap.m](../src/analyze_colormap.m) and [ccmap.rgb2lab](../src/+ccmap/rgb2lab.m).
