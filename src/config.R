# =====================================================================
# src/config.R
# Cấu hình chung: nạp thư viện, đường dẫn, hằng số và danh sách biến.
# Mọi script trong analysis/ và tests/ đều source file này đầu tiên, nên
# muốn đổi tham số nào thì chỉ sửa ở đây.
# =====================================================================

# Mọi đường dẫn trong dự án đều tính từ thư mục gốc (nơi có README.md). Mỗi
# script chạy được đều kiểm tra điều này trước khi source file này.

# ---- Thư viện ------------------------------------------------------------
required_pkgs <- c("dplyr", "tidyr", "e1071", "ggplot2", "ggcorrplot", "patchwork")

missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace,
                                      logical(1), quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  stop("Thiếu thư viện: ", paste(missing_pkgs, collapse = ", "), ".\n",
       "Chạy source(\"install_packages.R\") một lần để cài.", call. = FALSE)
}

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(e1071)       # skewness()
  library(ggplot2)
  library(ggcorrplot)  # heatmap ma trận tương quan
  library(patchwork)   # ghép nhiều biểu đồ thành một hình
})

# ---- Đường dẫn -----------------------------------------------------------
paths <- list(
  raw_data    = "data/raw/cereal.csv",
  clean_csv   = "data/processed/cereal_cleaned.csv",  # để xem, nộp kèm báo cáo
  clean_rds   = "data/processed/cereal_cleaned.rds",  # các bước sau đọc file này
  tables_dir  = "results/tables",
  figures_dir = "results/figures"
)

# ---- Tiền xử lý (Phần 4) -------------------------------------------------
missing_code <- -1   # mã ẩn của giá trị khuyết trong cereal.csv
excluded_mfr <- "A"  # hãng A chỉ có 1 sản phẩm (Maypo), loại để còn N = 76

# Biến định lượng gốc cần đổi mã -1 thành NA
num_cols <- c("calories", "protein", "fat", "sodium", "fiber",
              "carbo", "sugars", "potass", "weight", "cups", "rating")

# Biến có giá trị khuyết, điền bằng trung vị
impute_cols <- c("carbo", "sugars", "potass")

# 8 biến dinh dưỡng chuẩn hóa về khẩu phần 1 oz (chia cho weight)
nutri_cols <- c("calories", "protein", "fat", "sodium",
                "fiber", "carbo", "sugars", "potass")

mfr_labels <- c("G" = "General Mills", "K" = "Kelloggs", "N" = "Nabisco",
                "P" = "Post", "Q" = "Quaker Oats", "R" = "Ralston Purina")

shelf_labels <- c("Ke 1 (Thap)", "Ke 2 (Vua)", "Ke 3 (Cao)")

# ---- Thống kê mô tả (Phần 5) ---------------------------------------------
# 11 biến định lượng: thống kê mô tả, ngoại lai, tương quan
vars_11 <- c("rating", "calories", "protein", "fat", "sodium",
             "fiber", "carbo", "sugars", "potass", "total_carbs", "vitamins")

# 10 biến liên tục để vẽ histogram (bỏ vitamins vì chỉ có 3 giá trị)
vars_10 <- setdiff(vars_11, "vitamins")

tukey_k   <- 1.5  # hệ số hàng rào Tukey: [Q1 - k*IQR, Q3 + k*IQR]
skew_type <- 2    # công thức skewness có hiệu chỉnh mẫu (giống SPSS/SAS)

# ---- Hình ----------------------------------------------------------------
fig_dpi <- 300
