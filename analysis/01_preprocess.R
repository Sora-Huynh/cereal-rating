# =====================================================================
# Bước 1 – Phần 4: Tiền xử lý số liệu
# Vào : data/raw/cereal.csv                 (77 dòng x 16 cột)
# Ra  : data/processed/cereal_cleaned.csv   (76 dòng x 13 cột, để xem / nộp)
#       data/processed/cereal_cleaned.rds   (cùng dữ liệu, giữ kiểu factor và
#                                            tên sản phẩm; bước 2, 3 đọc file này)
# Chạy từ thư mục gốc: Rscript analysis/01_preprocess.R
# =====================================================================

if (!file.exists("src/config.R")) stop("Hãy chạy từ thư mục gốc dự án: mở cereal-rating.Rproj bằng RStudio, hoặc setwd() về thư mục chứa README.md.", call. = FALSE)
source("src/config.R")
source("src/preprocess.R")

# 4.1. Đọc dữ liệu gốc, đổi mã -1 thành NA
cereal_raw <- read_raw_cereal()
na_count <- colSums(is.na(cereal_raw[num_cols]))
cat("Số giá trị khuyết (mã -1) theo biến:\n")
print(na_count[na_count > 0])

# 4.2 – 4.5. Lọc hãng A, điền trung vị, chuẩn hóa 1 oz, định dạng factor
cereal_final <- preprocess_cereal(cereal_raw)

dir.create(dirname(paths$clean_csv), recursive = TRUE, showWarnings = FALSE)
write.csv(cereal_final, paths$clean_csv, row.names = FALSE)
saveRDS(cereal_final, paths$clean_rds)

cat(sprintf("\nDữ liệu sạch: %d dòng x %d cột\n", nrow(cereal_final), ncol(cereal_final)))
cat("  -> đã lưu", paths$clean_csv, "\n")
cat("  -> đã lưu", paths$clean_rds, "\n\n")
str(cereal_final)
