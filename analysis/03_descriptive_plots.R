# =====================================================================
# Bước 3 – Mục 5.2: Mô tả dữ liệu bằng đồ thị (Hình 1 – 4)
# Vào : data/processed/cereal_cleaned.rds   (bước 1)
# Ra  : results/figures/Hinh_1 ... Hinh_4 (.png)
#       results/tables/ma_tran_tuong_quan_pearson.csv (số liệu của Hình 4a)
# Chạy từ thư mục gốc: Rscript analysis/03_descriptive_plots.R
# =====================================================================

if (!file.exists("src/config.R")) stop("Hãy chạy từ thư mục gốc dự án: mở cereal-rating.Rproj bằng RStudio, hoặc setwd() về thư mục chứa README.md.", call. = FALSE)
source("src/config.R")
source("src/preprocess.R")
source("src/descriptive.R")
source("src/plots.R")

cereal_final <- load_clean_data()

# --- 5.2.1. Histogram + KDE (Hình 1) ---
hinh_1 <- plot_hist_kde(cereal_final, vars_10)
show_plot(hinh_1)
save_figure(hinh_1, "Hinh_1_Histogram_KDE.png", width = 10, height = 6)

# --- 5.2.2. Boxplot đơn biến (Hình 2) ---
hinh_2 <- plot_box_univariate(cereal_final, vars_11)
show_plot(hinh_2)
save_figure(hinh_2, "Hinh_2_Boxplot.png", width = 10, height = 6)

# --- 5.2.3. Boxplot rating theo mfr và shelf (Hình 3; số liệu ở Bảng 7, bước 2) ---
hinh_3 <- plot_rating_by_group(cereal_final)
show_plot(hinh_3)
save_figure(hinh_3, "Hinh_3_GroupedBoxplot.png", width = 10, height = 4.5)

# --- 5.2.4. Ma trận tương quan và biểu đồ phân tán (Hình 4) ---
corr_matrix <- cor(cereal_final[vars_11], use = "complete.obs")
cat("\nHệ số tương quan Pearson của rating với các biến:\n")
print(round(sort(corr_matrix["rating", -1]), 3))
save_table(data.frame(Bien = rownames(corr_matrix), round(corr_matrix, 3), row.names = NULL),
           "ma_tran_tuong_quan_pearson.csv")

hinh_4 <- plot_corr_scatter(cereal_final, corr_matrix)
show_plot(hinh_4)
save_figure(hinh_4, "Hinh_4_Correlation_Scatter.png", width = 12, height = 7.5)
