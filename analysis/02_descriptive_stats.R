# =====================================================================
# Bước 2 – Mục 5.1 và Bảng 7: Bảng thống kê mô tả
# Vào : data/processed/cereal_cleaned.rds   (bước 1)
# Ra  : results/tables/bang_4 ... bang_7b (.csv)
# Chạy từ thư mục gốc: Rscript analysis/02_descriptive_stats.R
# =====================================================================

if (!file.exists("src/config.R")) stop("Hãy chạy từ thư mục gốc dự án: mở cereal-rating.Rproj bằng RStudio, hoặc setwd() về thư mục chứa README.md.", call. = FALSE)
source("src/config.R")
source("src/preprocess.R")
source("src/descriptive.R")

cereal_final <- load_clean_data()
product_names <- rownames(cereal_final)

# --- 5.1.1. Biến định tính và rời rạc (Bảng 4) ---
bang_4 <- rbind(
  make_freq_table(cereal_final$mfr, "Nha san xuat (mfr)"),
  make_freq_table(cereal_final$shelf, "Vi tri ke (shelf)"),
  make_freq_table(cereal_final$vitamins, "Ham luong vitamin (%)")
)
cat("\nBảng 4: Tần số và tỷ lệ của mfr, shelf, vitamins\n")
print(bang_4)
save_table(bang_4, "bang_4_tan_so.csv")

# --- 5.1.2. Biến định lượng (Bảng 5) ---
bang_5 <- describe_numeric(cereal_final, vars_11)
cat("\nBảng 5: Thống kê mô tả các biến định lượng\n")
print(bang_5)
save_table(bang_5, "bang_5_thong_ke_dinh_luong.csv")

# --- 5.1.3. Ngoại lai theo hàng rào Tukey (Bảng 6) ---
bang_6 <- do.call(rbind, lapply(vars_11, function(v) {
  find_outliers(cereal_final[[v]], v, labels = product_names)
}))
cat("\nBảng 6: Ngoại lai theo hàng rào Tukey\n")
print(bang_6)
save_table(bang_6, "bang_6_ngoai_lai_tukey.csv")

# --- 5.2.3. rating theo nhà sản xuất và vị trí kệ (Bảng 7) ---
bang_7a <- summarise_rating_by(cereal_final, "mfr")
bang_7b <- summarise_rating_by(cereal_final, "shelf")
cat("\nBảng 7a: rating theo nhà sản xuất\n")
print(as.data.frame(bang_7a))
cat("\nBảng 7b: rating theo vị trí kệ\n")
print(as.data.frame(bang_7b))
save_table(bang_7a, "bang_7a_rating_theo_mfr.csv")
save_table(bang_7b, "bang_7b_rating_theo_shelf.csv")
