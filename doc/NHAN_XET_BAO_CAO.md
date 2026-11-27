# Nhận xét báo cáo `report/L16_NHÓM XVIII.pdf` (bản tới Phần 5)

Số trang ghi theo số in ở cuối trang (i, ii... cho phần đầu; 1, 2... cho phần chính). Các con số được
đối chiếu với kết quả chạy lại code (`results/tables/`) và dữ liệu gốc `data/raw/cereal.csv`.

**Mục A ảnh hưởng tới hướng làm toàn bộ phần suy diễn (Phần 6 trở đi), nên đọc trước.**

## Phần đã đối chiếu và khớp

- Mục 1.1, 4.1: 77 quan trắc, 7 hãng, 74 ăn lạnh / 3 ăn nóng; khuyết potass 2, carbo 1, sugars 1;
  hãng A là Maypo; weight từ 0,5 đến 1,5 oz.
- Bảng 4, 5, 6, 7: mọi số liệu khớp với code.
- Hình 4: các hệ số r trên heatmap và ba nhãn r = −0,765; 0,660; −0,648 đều đúng.
- Các nhận xét về ngoại lai (mục 5.1.3, 5.2.2) và phần lớn nhận xét về tương quan (mục 5.2.4).
- Phần tính toán trong code đúng. Các lỗi dưới đây nằm ở cách chọn phương pháp và cách diễn giải.

## A. Lỗi học thuật nghiêm trọng: rating được tính bằng công thức từ chính dữ liệu

1. **Phát hiện.** Hồi quy `rating` theo 9 biến gốc (tính theo khẩu phần, chưa chia weight): calories,
   protein, fat, sodium, fiber, carbo, sugars, potass, vitamins. Kết quả R² = 1,000000 trên cả 77 dòng,
   phần dư lớn nhất 5,7·10⁻⁷, tức chỉ là sai số làm tròn ở chữ số thập phân thứ 6 của rating. Công thức:

   > rating = 54,93 − 0,223·calories + 3,273·protein − 1,691·fat − 0,0545·sodium + 3,444·fiber
   > \+ 1,093·carbo − 0,725·sugars − 0,034·potass − 0,051·vitamins

   Công thức còn được tính với chính các mã khuyết −1 như số thật. Suy ngược từ công thức, potass của
   Almond Delight và Cream of Wheat (Quick) ra đúng −1; Quaker Oatmeal khớp với carbo = sugars = −1.
   Thêm `mfr`, `shelf`, `weight`, `cups` vào mô hình thì R² vẫn bằng 1.

   Báo cáo (mục 1.1, Bảng 1) đang mô tả rating như một điểm đánh giá chất lượng độc lập. Thực tế
   rating là điểm tính sẵn từ các cột dinh dưỡng.

2. **Hệ quả cho hồi quy OLS (mục 2.2 C, mục 3.6).** Trên dữ liệu gốc, mô hình hồi quy sẽ cho R² = 1 và
   sai số bằng 0. Khi đó kiểm định t, kiểm định F, khoảng tin cậy của hệ số và toàn bộ phần kiểm tra
   giả định phần dư ở mục 3.6.5 (Breusch-Pagan, Shapiro-Wilk trên phần dư, Durbin-Watson, Cook) không
   còn ý nghĩa: không có sai số ngẫu nhiên nào để suy diễn.

3. **Hệ quả cho so sánh nhóm (mục 2.2 B).** `mfr` và `shelf` không có tác động riêng lên rating. Mọi
   chênh lệch rating giữa các hãng và các kệ ở Bảng 7 đều do thành phần dinh dưỡng. ANOVA hay
   Kruskal-Wallis theo hãng vẫn làm được, nhưng kết luận đúng là "các hãng khác nhau về thành phần dinh
   dưỡng", không phải "thương hiệu ảnh hưởng tới rating".

4. **Chuẩn hóa 1 oz (mục 1.3, 4.4) tạo ra sai lệch thay vì loại bỏ nhiễu.** Rating được tính theo khẩu
   phần, nên sau khi chia cho weight, cùng mô hình trên chỉ còn R² = 0,979 và có phần dư tới 7,19
   điểm. Sáu phần dư lớn nhất rơi đúng vào sản phẩm có weight ≠ 1 hoặc bị điền khuyết:

   | Sản phẩm | Phần dư | Nguyên nhân |
   |---|---|---|
   | Quaker Oatmeal | 7,19 | điền khuyết carbo, sugars |
   | Mueslix Crispy Blend | 6,56 | weight = 1,5 |
   | Puffed Wheat | 5,44 | weight = 0,5 |
   | Cream of Wheat (Quick) | 5,10 | điền khuyết potass |
   | Total Raisin Bran | 4,24 | weight = 1,5 |
   | Almond Delight | 3,80 | điền khuyết potass |

   Trong mẫu N = 76 có 13 sản phẩm có weight ≠ 1. Nếu chạy OLS trên dữ liệu 1 oz, phần dư và các kiểm
   định giả định sẽ phân tích một sai lệch do chính bước tiền xử lý tạo ra, không phải sai số ngẫu nhiên.

5. **Điền trung vị (mục 4.3).** Điền trung vị làm 3 dòng trên mâu thuẫn với rating. Ngoài ra, Quaker
   Oatmeal là yến mạch nóng không đường nhưng bị điền sugars = 7 g và carbo = 14 g, không thực tế.

6. **Hướng xử lý gợi ý** (nhóm quyết định, nên hỏi thầy trước khi làm Phần 6):
   - Đưa phát hiện này vào báo cáo như một kết quả: hồi quy trên dữ liệu gốc khôi phục chính xác công
     thức tính rating. Phần hồi quy chuyển sang diễn giải trọng số (dấu, độ lớn, so sánh với tương
     quan đơn biến), nói rõ không có sai số ngẫu nhiên nên không làm suy diễn trên hệ số.
   - Nếu vẫn giữ chuẩn hóa 1 oz: ghi rõ rating được tính theo khẩu phần, và phần dư của mô hình 1 oz
     đến từ chuẩn hóa và điền khuyết.
   - Phần so sánh nhóm vẫn giữ, nhưng diễn giải như ở mục 3.

   Kiểm chứng (chạy trong R từ thư mục gốc dự án):

   ```r
   raw <- read.csv("data/raw/cereal.csv")
   m <- lm(rating ~ calories + protein + fat + sodium + fiber + carbo + sugars + potass + vitamins,
           data = raw)
   summary(m)$r.squared   # 1
   max(abs(resid(m)))     # khoảng 6e-07
   round(coef(m), 4)      # các hệ số của công thức
   ```

## B. Nội dung sai hoặc mâu thuẫn với số liệu

7. **Trang 16, mục 5.2.1.** Báo cáo viết rằng với fiber, potass, **fat**, protein và rating, "đường
   trung bình (nét đứt đỏ) nằm bên phải đường trung vị". Điều này sai với fat: trung bình 0,97 nhỏ hơn
   trung vị 1,00 (Bảng 5), nên đường trung bình nằm bên trái. Bỏ fat khỏi câu này.
8. **Trang 14, mục 5.1.2.** Cách chia ba nhóm theo skewness không khớp với chính ngưỡng đã đặt. Nhóm
   "tương đối đối xứng" được định nghĩa là |Skewness| < 0,5, nhưng calories (−0,22) và sodium (−0,41)
   thỏa ngưỡng này lại bị xếp vào nhóm "co cụm / lệch trái". Ngoài ra, tiêu đề nhóm "lệch phải mạnh
   (Skewness > 1)" có rating, mà rating chỉ có 0,94. Nên sửa ngưỡng hoặc sửa cách xếp nhóm.
9. **Trang 19, mục 5.2.4.** Theo thang ở mục 3.5.1 (|r| ≥ 0,7 là mạnh; 0,4 – 0,7 là trung bình):
   - fiber (0,660), protein (0,574), potass (0,524) đều chỉ ở mức **trung bình**, không phải
     "trung bình – mạnh".
   - Trong nhóm tương quan âm, chỉ sugars (−0,765) đạt mức mạnh; calories (−0,648) là trung bình.
10. **Trang 18, mục 5.2.3.**
    - "Kệ 2 ... thấp hơn **đáng kể**": chữ "đáng kể" ngụ ý có ý nghĩa thống kê, trong khi chưa kiểm
      định. Nên viết "thấp hơn" và để ANOVA / Kruskal-Wallis kết luận.
    - "Kệ 2 ... thường trưng bày các loại ngũ cốc nhiều đường": dữ liệu có ủng hộ (đường trung bình
      trên 1 oz: kệ 1 = 5,20; **kệ 2 = 9,80**; kệ 3 = 5,83) nhưng báo cáo không đưa số liệu nào. Nên
      thêm con số này, nếu không thì đây là nhận định không có căn cứ trong bài.
11. **Trang 16, cuối mục 5.2.1.** "Phần lớn các biến định lượng (đặc biệt là rating) vi phạm giả định
    phân phối chuẩn" được kết luận chỉ từ histogram, khi chưa chạy Shapiro-Wilk. Hơn nữa, giả định
    chuẩn của ANOVA áp dụng cho rating **trong từng nhóm** (hoặc phần dư), không phải cho rating gộp cả
    mẫu. Chạy Shapiro-Wilk theo nhóm thì vi phạm thật ở Kelloggs (p < 0,001), kệ 2 (p = 0,015) và kệ 3
    (p < 0,001), nhưng kết luận phải đến từ kiểm định này. Riêng Nabisco chỉ có n = 6 nên p = 0,795
    không chứng minh được dữ liệu chuẩn (lực kiểm định rất thấp).
12. **Trang 1, Bảng 1.** rating "18–93 điểm", nhưng giá trị lớn nhất là 93,70. Nên ghi 18,04 – 93,70.

## C. Lập luận phương pháp và thuật ngữ

13. **Trang 16 và 19: Pearson bị 3 sản phẩm cám chi phối.** Mục 5.1.3 nói sẽ giữ ngoại lai và ưu tiên
    thước đo vững, nhưng heatmap và các nhận xét ở mục 5.2.4 chỉ dùng Pearson. Khi bỏ 100% Bran,
    All-Bran và All-Bran with Extra Fiber:

    | Cặp biến | Pearson | Spearman | Pearson bỏ 3 sản phẩm cám |
    |---|---|---|---|
    | rating – potass | 0,524 | 0,425 | 0,325 |
    | rating – fiber | 0,660 | 0,584 | 0,518 |
    | rating – calories | −0,648 | −0,648 | −0,511 |
    | rating – sugars | −0,765 | −0,823 | −0,791 |
    | fiber – potass | 0,923 | 0,879 | 0,876 |

    Nên báo cáo thêm Spearman. Nhận định fiber – potass tương quan rất mạnh vẫn đúng.
14. **Trang 19: dấu của tương quan khác dấu của tác động.** potass tương quan thuận với rating
    (r = +0,524), nhưng hệ số của potass trong công thức ở mục 1 lại âm (−0,034), vì potass luôn đi kèm
    fiber. Viết "kali tương quan thuận" là đúng, nhưng khi sang phần hồi quy không được diễn giải là
    "kali làm tăng rating".
15. **Trang 19: đa cộng tuyến nặng.** VIF trên dữ liệu 1 oz: carbo 13,5; sugars 11,7; fiber 10,5 (trên
    10); potass 8,9; calories 7,1 (trên 5). Hướng kiểm tra VIF của báo cáo là đúng, nhưng mức độ nặng
    hơn câu chữ hiện tại.
16. **Trang 1, mục 1.1 và trang bìa: mẫu không phải mẫu ngẫu nhiên.** 77 sản phẩm là danh sách ngũ cốc
    phổ biến, không được chọn ngẫu nhiên từ một tổng thể, trong khi khoảng tin cậy và kiểm định đều giả
    định mẫu ngẫu nhiên. Cần nêu tổng thể là gì và ghi rõ giới hạn này. Tên đề tài dùng chữ "ảnh
    hưởng", mâu thuẫn với câu "không suy rộng thành quan hệ nhân quả" ở mục 1.1.
17. **Trang 2, mục 1.3 ý 3 và trang 11, mục 4.2: loại Maypo.**
    - Câu "n_A = 1 không thể tính phương sai nội bộ nhóm (vi phạm điều kiện ANOVA)" không chính xác:
      ANOVA vẫn tính được (nhóm một phần tử góp 0 bậc tự do vào SSW), chỉ là không kiểm tra được giả
      định cho nhóm đó và không so sánh cặp được.
    - Lý do này chỉ áp dụng khi so sánh theo hãng. Phần tương quan và hồi quy vẫn dùng được N = 77,
      nên loại Maypo khỏi toàn bộ phân tích là thừa (hoặc phải giải thích vì sao muốn dùng chung một
      mẫu).
    - "Rò rỉ dữ liệu (Data Leakage)" là khái niệm của học máy (thông tin từ tập test lọt vào tập train).
      Ở đây ý đúng là "tính trung vị trên đúng mẫu phân tích N = 76". Nên đổi cách diễn đạt.
18. **Trang 3, mục 2.2 B: kiểm định nhiều lần.** Nhóm dự định so sánh rating và 8 chất dinh dưỡng theo
    cả mfr lẫn shelf, tức khoảng 18 kiểm định. Ở α = 0,05, xác suất có ít nhất một kết luận sai cộng
    dồn lên đáng kể. Cần hiệu chỉnh (Bonferroni, Holm) hoặc giới hạn số biến đem kiểm định.
19. **Trang 11, mục 3.6.5 ý 5.** "DW ≈ 2 biểu thị các sai số hoàn toàn độc lập" là nói quá:
    Durbin-Watson chỉ kiểm tra tự tương quan bậc 1. Thêm nữa, đây là dữ liệu chéo, thứ tự dòng là thứ
    tự tên sản phẩm theo bảng chữ cái, nên DW gần như không có ý nghĩa. Nên ghi chú điều này khi dùng.
20. **Trang 9, công thức (24).** Công thức Spearman 1 − 6Σd²/(n(n²−1)) chỉ đúng khi không có hạng trùng.
    Dữ liệu có rất nhiều giá trị trùng (calories, vitamins, protein...). R tính Spearman bằng hệ số
    Pearson trên thứ hạng nên kết quả vẫn đúng, nhưng nên ghi chú cho công thức.
21. **Trang 9, công thức (21).** Công thức H của Kruskal-Wallis chưa có hiệu chỉnh cho hạng trùng. R có
    hiệu chỉnh (`kruskal.test`), nên kết quả chạy ra sẽ khác công thức trong báo cáo. Nên bổ sung hệ số
    hiệu chỉnh hoặc ghi chú.
22. **Trang 7, mục 3.4.3.** Levene tính theo độ lệch so với **trung vị** nhóm là biến thể
    Brown-Forsythe (cũng là mặc định của `car::leveneTest`). Nên nêu tên cho chính xác.
23. **Trang 4 và 14: thiếu định nghĩa skewness và cách tính tứ phân vị.**
    - Bảng 5 và mục 5.1.2 dùng skewness để chia nhóm phân phối, nhưng Phần 3 không có công thức.
      Code dùng `e1071::skewness(type = 2)`, tức hệ số G1 có hiệu chỉnh mẫu.
    - Mục 3.1.2 không nói tứ phân vị tính theo cách nào. R mặc định dùng type 7; cách tính trong giáo
      trình có thể cho Q1, Q3 khác, kéo theo hàng rào Tukey ở Bảng 6 khác.
24. **Trang 6, Bảng 2.** Điều kiện cỡ mẫu không thống nhất: tỷ lệ ghi "n > 30", trung bình TH3 ghi
    "n ≥ 30". Với tỷ lệ, điều kiện thường dùng là nf ≥ 5 và n(1 − f) ≥ 5.
25. **Trang 1 – 2, xử lý vitamins.** vitamins cũng là giá trị trên một khẩu phần (% nhu cầu mỗi ngày)
    nhưng không chia cho weight như 8 biến dinh dưỡng khác. Có thể giữ nguyên, nhưng nên thêm một câu
    giải thích vì sao.

## D. Lỗi trình bày

26. **Trang 13, Bảng 4 và trang 17, Bảng 7.** Hiện chữ "6\*Nhà sản xuất (mfr)", "3\*Vị trí kệ
    (shelf)", "3\*Hàm lượng vitamin (%)". Đây là lệnh `\multirow` bị in ra thành chữ (thiếu
    `\usepackage{multirow}` hoặc sai cú pháp).
27. **Trang 14 và 18: ký hiệu trung bình và trung vị bị mất dấu.** Các chỗ "trung bình (x) với trung vị
    (x)", "x=42,51>x=40,25", "trung vị x=21,00g", "(X=68,32; x=67,97)", "(X=36,18; x=34,49)" đều mất
    dấu gạch ngang / dấu ngã, người đọc không phân biệt được đâu là trung bình (x̄), đâu là trung vị
    (x̃). Dùng `\bar{x}` và `\tilde{x}`. Chỗ "(X=68,32; x=67,97)" còn lẫn chữ hoa với chữ thường.
28. **Hình 3 và Bảng 4, 7: nhãn kệ không thống nhất.** Bảng ghi "Kệ 1 (Thấp)", hình ghi "Ke 1 (Thap)"
    (không dấu, do nhãn trong code). Nếu muốn hình có dấu thì sửa `shelf_labels` trong
    `src/config.R`.
29. **Mục lục (trang iii) và trang vi.** Mục lục ghi "Danh sách hình ảnh", trang vi ghi "Danh sách hình
    vẽ". Tiêu đề Phần 5 "Thống kê mô tả" viết thường, trong khi Phần 1 – 4 viết hoa. Có "PHẦN I: GIỚI
    THIỆU" nhưng không có phần II.
30. **Trang 14, chú thích Bảng 5.** "Thống kê mô tả các biến định lượng chuẩn hóa theo 1 oz", nhưng
    bảng có cả rating và vitamins là hai biến không chuẩn hóa.
31. **Trang i, bảng phân công.** "Mục tiêu của BTL ; Thống kê mô tả" thừa dấu cách trước dấu chấm phẩy.
32. **Hình 1 – 4: tiêu đề trong ảnh.** Code hiện tại in tiêu đề "Hình x: ..." ngay trong ảnh, còn ảnh
    trong báo cáo không có tiêu đề này (đã dùng chú thích LaTeX). Khi chép hình mới từ
    `results/figures/` vào báo cáo, tiêu đề sẽ bị lặp với chú thích. Cần cắt ảnh hoặc bỏ `title` trong
    `src/plots.R`.

## E. Cần cập nhật theo cấu trúc code mới

33. **Trang 11 – 13, các đoạn code ở Phần 4.** Code trong báo cáo đọc `"D:/cereal.csv"` và ghi
    `"D:/cereal_cleaned.csv"` (đường dẫn tuyệt đối, máy khác không chạy được). Code mới dùng
    `data/raw/cereal.csv` và `data/processed/cereal_cleaned.csv`, các bước tách thành hàm trong
    `src/preprocess.R`. Các đoạn code này cần chép lại cho khớp.
34. **Trang 12, comment mục 4.4.** Lỗi chính tả "bo **wieght**, cups" (đúng là weight).

## F. Còn thiếu (theo dàn ý đã nêu ở mục 2.2)

- Phần thống kê suy diễn: so sánh nhóm (ANOVA / Kruskal-Wallis), kiểm định tương quan và VIF, hồi
  quy OLS và chẩn đoán phần dư. Trước khi làm, xem lại mục A.
- Kết luận.
- Tài liệu tham khảo, trong đó có trích dẫn nguồn dữ liệu (Kaggle *80 Cereals*).
