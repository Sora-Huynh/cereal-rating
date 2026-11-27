# =====================================================================
# Bước 2 – Mục 5.1 và Bảng 7: Bảng thống kê mô tả
# Vào : data/processed/cereal_cleaned.rds   (bước 1)
# Ra  : results/tables/bang_4 ... bang_9 (.csv)
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

# --- 5.2.3. Lượng đường trung bình theo kệ (căn cứ cho nhận xét về kệ 2) ---
bang_8 <- cereal_final %>%
  group_by(shelf) %>%
  summarise(n = n(), sugars_Mean = round(mean(sugars), 2),
            sugars_Median = round(median(sugars), 2),
            fiber_Mean = round(mean(fiber), 2), .groups = "drop")
cat("
Bảng 8: sugars và fiber (trên 1 oz) theo vị trí kệ
")
print(as.data.frame(bang_8))
save_table(bang_8, "bang_8_duong_theo_shelf.csv")

# --- 5.2.4. Pearson, Spearman và Pearson khi bỏ 3 sản phẩm cám ---
others <- setdiff(vars_11, "rating")
no_bran <- cereal_final[!(rownames(cereal_final) %in% bran_products), ]
bang_9 <- data.frame(
  Bien = others,
  Pearson = sapply(others, function(v) cor(cereal_final$rating, cereal_final[[v]])),
  Spearman = sapply(others, function(v) cor(cereal_final$rating, cereal_final[[v]],
                                            method = "spearman")),
  Pearson_bo_cam = sapply(others, function(v) cor(no_bran$rating, no_bran[[v]])),
  row.names = NULL
)
bang_9[-1] <- round(bang_9[-1], 3)
bang_9 <- bang_9[order(bang_9$Pearson), ]
cat("
Bảng 9: Tương quan của rating với từng biến (N = 76; bỏ cám: N =", nrow(no_bran), ")
")
print(bang_9, row.names = FALSE)
save_table(bang_9, "bang_9_tuong_quan_pearson_spearman.csv")
