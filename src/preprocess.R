# =====================================================================
# src/preprocess.R
# Các hàm tiền xử lý số liệu, mỗi hàm ứng với một mục của Phần 4 báo cáo.
# Script gọi các hàm này: analysis/01_preprocess.R
# Cần source("src/config.R") trước.
# =====================================================================

# 4.1. Đọc dữ liệu gốc và chuyển mã ẩn -1 thành NA
read_raw_cereal <- function(path = paths$raw_data) {
  cereal <- read.csv(path, stringsAsFactors = FALSE)
  cereal[num_cols] <- lapply(cereal[num_cols], function(x) {
    ifelse(x == missing_code, NA, as.numeric(x))
  })
  cereal
}

# 4.2. Lọc bỏ hãng A (n = 1) trước khi điền khuyết, để trung vị ở bước 4.3
# được tính trên đúng mẫu phân tích N = 76. Bỏ biến name, type.
# Tên sản phẩm được giữ làm tên dòng (rownames) để tra cứu ngoại lai ở Phần 5.
filter_sample <- function(cereal) {
  out <- subset(cereal, mfr != excluded_mfr)
  rownames(out) <- out$name
  out[, !(names(out) %in% c("name", "type"))]
}

# 4.3. Điền giá trị khuyết (NA) bằng trung vị tính trên mẫu N = 76
impute_median <- function(cereal, cols = impute_cols) {
  for (col in cols) {
    med_val <- median(cereal[[col]], na.rm = TRUE)
    cereal[[col]][is.na(cereal[[col]])] <- med_val
  }
  cereal
}

# 4.4. Chuẩn hóa 8 biến dinh dưỡng về khẩu phần 1 oz, tạo biến total_carbs,
# rồi bỏ weight và cups
normalize_per_oz <- function(cereal, cols = nutri_cols) {
  for (col in cols) {
    cereal[[col]] <- cereal[[col]] / cereal$weight
  }
  cereal$total_carbs <- cereal$carbo + cereal$sugars
  cereal[, !(names(cereal) %in% c("weight", "cups"))]
}

# 4.5. Đổi mfr và shelf sang factor có nhãn rõ ràng (vitamins giữ dạng số)
format_factors <- function(cereal) {
  cereal$mfr <- factor(mfr_labels[cereal$mfr])
  cereal$shelf <- factor(cereal$shelf, levels = c(1, 2, 3), labels = shelf_labels)
  cereal
}

# Toàn bộ Phần 4: dữ liệu gốc (77 x 16) -> dữ liệu sạch (76 x 13)
preprocess_cereal <- function(cereal_raw) {
  cereal <- filter_sample(cereal_raw)
  cereal <- impute_median(cereal)
  cereal <- normalize_per_oz(cereal)
  format_factors(cereal)
}

# Đọc dữ liệu sạch do analysis/01_preprocess.R lưu (giữ kiểu factor và rownames)
load_clean_data <- function(path = paths$clean_rds) {
  if (!file.exists(path)) {
    stop("Chưa có ", path, ". Hãy chạy analysis/01_preprocess.R trước.", call. = FALSE)
  }
  readRDS(path)
}
