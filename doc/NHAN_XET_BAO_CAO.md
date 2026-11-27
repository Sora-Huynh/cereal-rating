# Nhận xét báo cáo `report/L16_NHÓM XVIII.pdf` (bản tới Phần 5)

Số trang ghi theo số in ở cuối trang (i, ii... cho phần đầu; 1, 2... cho phần chính). Các con số được
đối chiếu với kết quả chạy lại code (`results/tables/`) và dữ liệu gốc `data/raw/cereal.csv`.

## Phần đã đối chiếu và khớp

- Mục 1.1, 4.1: 77 quan trắc, 7 hãng, 74 ăn lạnh / 3 ăn nóng; khuyết potass 2, carbo 1, sugars 1;
  hãng A là Maypo; weight từ 0,5 đến 1,5 oz.
- Bảng 4, 5, 6, 7: mọi số liệu khớp với code.
- Hình 4: các hệ số r trên heatmap và ba nhãn r = −0,765; 0,660; −0,648 đều đúng.
- Các nhận xét về ngoại lai (mục 5.1.3, 5.2.2) và phần lớn nhận xét về tương quan (mục 5.2.4).

## A. Nội dung sai hoặc mâu thuẫn với số liệu

1. **Trang 16, mục 5.2.1.** Báo cáo viết rằng với fiber, potass, **fat**, protein và rating, "đường
   trung bình (nét đứt đỏ) nằm bên phải đường trung vị". Điều này sai với fat: trung bình 0,97 nhỏ hơn
   trung vị 1,00 (Bảng 5), nên đường trung bình nằm bên trái. Bỏ fat khỏi câu này.
2. **Trang 14, mục 5.1.2.** Cách chia ba nhóm theo skewness không khớp với chính ngưỡng đã đặt. Nhóm
   "tương đối đối xứng" được định nghĩa là |Skewness| < 0,5, nhưng calories (−0,22) và sodium (−0,41)
   thỏa ngưỡng này lại bị xếp vào nhóm "co cụm / lệch trái". Ngoài ra, tiêu đề nhóm "lệch phải mạnh
   (Skewness > 1)" có rating, mà rating chỉ có 0,94. Nên sửa ngưỡng hoặc sửa cách xếp nhóm.
3. **Trang 19, mục 5.2.4.** Theo thang ở mục 3.5.1 (|r| ≥ 0,7 là mạnh; 0,4 – 0,7 là trung bình):
   - fiber (0,660), protein (0,574), potass (0,524) đều chỉ ở mức **trung bình**, không phải
     "trung bình – mạnh".
   - Trong nhóm tương quan âm, chỉ sugars (−0,765) đạt mức mạnh; calories (−0,648) là trung bình.
4. **Trang 18, mục 5.2.3.**
   - "Kệ 2 ... thấp hơn **đáng kể**": chữ "đáng kể" ngụ ý có ý nghĩa thống kê, trong khi chưa kiểm
     định. Nên viết "thấp hơn" và để ANOVA / Kruskal-Wallis kết luận.
   - "Kệ 2 ... thường trưng bày các loại ngũ cốc nhiều đường": dữ liệu có ủng hộ (đường trung bình
     trên 1 oz: kệ 1 = 5,20; **kệ 2 = 9,80**; kệ 3 = 5,83) nhưng báo cáo không đưa số liệu nào. Nên
     thêm con số này, nếu không thì đây là nhận định không có căn cứ trong bài.
5. **Trang 16, cuối mục 5.2.1.** "Phần lớn các biến định lượng (đặc biệt là rating) vi phạm giả định
   phân phối chuẩn" được kết luận chỉ từ histogram, khi chưa chạy Shapiro-Wilk. Hơn nữa, giả định
   chuẩn của ANOVA áp dụng cho rating **trong từng nhóm** (hoặc phần dư), không phải cho rating gộp cả
   mẫu. Nên viết "có dấu hiệu lệch khỏi phân phối chuẩn, sẽ kiểm định bằng Shapiro-Wilk trên từng
   nhóm". (Chạy thử Shapiro-Wilk trên rating gộp cho p ≈ 0,005.)
6. **Trang 1, Bảng 1.** rating "18–93 điểm", nhưng giá trị lớn nhất là 93,70. Nên ghi 18,04 – 93,70.

## B. Lập luận hoặc thuật ngữ cần chỉnh

7. **Trang 11, mục 4.2 (và mục 1.3).** "Rò rỉ dữ liệu (Data Leakage)" là khái niệm của học máy (thông
   tin từ tập test lọt vào tập train). Ở đây ý đúng là "tính trung vị trên đúng mẫu phân tích N = 76".
   Nên đổi cách diễn đạt.
8. **Trang 11, mục 3.6.5 ý 5.** "DW ≈ 2 biểu thị các sai số hoàn toàn độc lập" là nói quá: Durbin-Watson
   chỉ kiểm tra tự tương quan bậc 1. Thêm nữa, đây là dữ liệu chéo, thứ tự dòng là thứ tự tên sản phẩm
   theo bảng chữ cái, nên DW gần như không có ý nghĩa. Nên ghi chú điều này khi dùng.
9. **Trang 9, công thức (24).** Công thức Spearman 1 − 6Σd²/(n(n²−1)) chỉ đúng khi không có hạng trùng.
   Dữ liệu có rất nhiều giá trị trùng (calories, vitamins, protein...). R tính Spearman bằng hệ số
   Pearson trên thứ hạng nên kết quả vẫn đúng, nhưng nên ghi chú cho công thức.
10. **Trang 7, mục 3.4.3.** Levene tính theo độ lệch so với **trung vị** nhóm là biến thể
    Brown-Forsythe (cũng là mặc định của `car::leveneTest`). Nên nêu tên cho chính xác.
11. **Trang 6, Bảng 2.** Điều kiện cỡ mẫu không thống nhất: tỷ lệ ghi "n > 30", trung bình TH3 ghi
    "n ≥ 30". Với tỷ lệ, điều kiện thường dùng là nf ≥ 5 và n(1 − f) ≥ 5.
12. **Trang 1 – 2, xử lý vitamins.** vitamins cũng là giá trị trên một khẩu phần (% nhu cầu mỗi ngày)
    nhưng không chia cho weight như 8 biến dinh dưỡng khác. Có thể giữ nguyên, nhưng nên thêm một câu
    giải thích vì sao.

## C. Lỗi trình bày

13. **Trang 13, Bảng 4 và trang 17, Bảng 7.** Hiện chữ "6\*Nhà sản xuất (mfr)", "3\*Vị trí kệ
    (shelf)", "3\*Hàm lượng vitamin (%)". Đây là lệnh `\multirow` bị in ra thành chữ (thiếu
    `\usepackage{multirow}` hoặc sai cú pháp).
14. **Trang 14 và 18: ký hiệu trung bình và trung vị bị mất dấu.** Các chỗ "trung bình (x) với trung vị
    (x)", "x=42,51>x=40,25", "trung vị x=21,00g", "(X=68,32; x=67,97)", "(X=36,18; x=34,49)" đều mất
    dấu gạch ngang / dấu ngã, người đọc không phân biệt được đâu là trung bình (x̄), đâu là trung vị
    (x̃). Dùng `\bar{x}` và `\tilde{x}`. Chỗ "(X=68,32; x=67,97)" còn lẫn chữ hoa với chữ thường.
15. **Hình 3 và Bảng 4, 7: nhãn kệ không thống nhất.** Bảng ghi "Kệ 1 (Thấp)", hình ghi "Ke 1 (Thap)"
    (không dấu, do nhãn trong code). Nếu muốn hình có dấu thì sửa `shelf_labels` trong
    `src/config.R`.
16. **Mục lục (trang iii) và trang vi.** Mục lục ghi "Danh sách hình ảnh", trang vi ghi "Danh sách hình
    vẽ". Tiêu đề Phần 5 "Thống kê mô tả" viết thường, trong khi Phần 1 – 4 viết hoa. Có "PHẦN I: GIỚI
    THIỆU" nhưng không có phần II.
17. **Trang 14, chú thích Bảng 5.** "Thống kê mô tả các biến định lượng chuẩn hóa theo 1 oz", nhưng
    bảng có cả rating và vitamins là hai biến không chuẩn hóa.
18. **Trang i, bảng phân công.** "Mục tiêu của BTL ; Thống kê mô tả" thừa dấu cách trước dấu chấm phẩy.
19. **Hình 1 – 4: tiêu đề trong ảnh.** Code hiện tại in tiêu đề "Hình x: ..." ngay trong ảnh, còn ảnh
    trong báo cáo không có tiêu đề này (đã dùng chú thích LaTeX). Khi chép hình mới từ
    `results/figures/` vào báo cáo, tiêu đề sẽ bị lặp với chú thích. Cần cắt ảnh hoặc bỏ `title` trong
    `src/plots.R`.

## D. Cần cập nhật theo cấu trúc code mới

20. **Trang 11 – 13, các đoạn code ở Phần 4.** Code trong báo cáo đọc `"D:/cereal.csv"` và ghi
    `"D:/cereal_cleaned.csv"` (đường dẫn tuyệt đối, máy khác không chạy được). Code mới dùng
    `data/raw/cereal.csv` và `data/processed/cereal_cleaned.csv`, các bước tách thành hàm trong
    `src/preprocess.R`. Các đoạn code này cần chép lại cho khớp.
21. **Trang 12, comment mục 4.4.** Lỗi chính tả "bo **wieght**, cups" (đúng là weight).

## E. Còn thiếu (theo dàn ý đã nêu ở mục 2.2)

- Phần thống kê suy diễn: so sánh nhóm (ANOVA / Kruskal-Wallis), kiểm định tương quan và VIF, hồi
  quy OLS và chẩn đoán phần dư.
- Kết luận.
- Tài liệu tham khảo, trong đó có trích dẫn nguồn dữ liệu (Kaggle *80 Cereals*).
