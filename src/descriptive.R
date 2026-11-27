# =====================================================================
# src/descriptive.R
# Các hàm thống kê mô tả dùng ở Phần 5 (Bảng 4 – 7) và hàm lưu bảng.
# Script gọi các hàm này: analysis/02_descriptive_stats.R
# Cần source("src/config.R") trước.
# =====================================================================

# Bảng tần số và tỷ lệ phần trăm của một biến định tính / rời rạc (Bảng 4)
make_freq_table <- function(vec, var_label) {
  freq <- table(vec)
  prop <- round(prop.table(freq) * 100, 2)
  data.frame(
    Bien = var_label,
    Phan_nhom = names(freq),
    Tan_so_nk = as.vector(freq),
    Ty_le_fk = as.vector(prop),
    row.names = NULL
  )
}

# Các đặc trưng mẫu của một biến định lượng
calc_stats <- function(x) {
  c(n        = length(na.omit(x)),
    Mean     = mean(x, na.rm = TRUE),
    SD       = sd(x, na.rm = TRUE),
    Min      = min(x, na.rm = TRUE),
    Q1       = as.numeric(quantile(x, 0.25, na.rm = TRUE)),
    Median   = median(x, na.rm = TRUE),
    Q3       = as.numeric(quantile(x, 0.75, na.rm = TRUE)),
    Max      = max(x, na.rm = TRUE),
    IQR      = IQR(x, na.rm = TRUE),
    Skewness = skewness(x, na.rm = TRUE, type = skew_type))
}

# Bảng thống kê mô tả cho nhiều biến định lượng, mỗi biến một dòng (Bảng 5)
describe_numeric <- function(df, vars) {
  stats <- round(t(sapply(df[vars], calc_stats)), 2)
  data.frame(Bien = rownames(stats), stats, row.names = NULL)
}

# Ngoại lai theo hàng rào Tukey của một biến (một dòng của Bảng 6).
# labels: tên sản phẩm theo đúng thứ tự của x. Trả về NULL nếu không có ngoại lai.
find_outliers <- function(x, var_name, labels, k = tukey_k) {
  Q1 <- as.numeric(quantile(x, 0.25, na.rm = TRUE))
  Q3 <- as.numeric(quantile(x, 0.75, na.rm = TRUE))
  IQR_val <- Q3 - Q1
  L <- Q1 - k * IQR_val
  U <- Q3 + k * IQR_val

  idx <- which(x < L | x > U)
  if (length(idx) == 0) return(NULL)

  ord <- order(x[idx])
  vals <- round(x[idx][ord], 2)
  prods <- labels[idx][ord]
  data.frame(
    Bien = var_name,
    Can_duoi_L = round(L, 2),
    Can_tren_U = round(U, 2),
    So_luong = length(idx),
    Gia_tri_va_San_pham = paste0(vals, " (", prods, ")", collapse = "; "),
    row.names = NULL
  )
}

# Thống kê mô tả của rating theo từng nhóm của một biến phân nhóm (Bảng 7)
summarise_rating_by <- function(df, group_col, value_col = "rating") {
  df %>%
    group_by(across(all_of(group_col))) %>%
    summarise(n = n(),
              Mean = round(mean(.data[[value_col]]), 2),
              SD = round(sd(.data[[value_col]]), 2),
              Median = round(median(.data[[value_col]]), 2),
              IQR = round(IQR(.data[[value_col]]), 2),
              .groups = "drop")
}

# Lưu một bảng ra results/tables/
save_table <- function(df, filename) {
  dir.create(paths$tables_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(paths$tables_dir, filename)
  write.csv(df, path, row.names = FALSE)
  cat("  -> đã lưu", path, "\n")
  invisible(path)
}
