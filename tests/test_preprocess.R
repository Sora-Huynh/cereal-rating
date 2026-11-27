# =====================================================================
# Kiểm tra nhanh: dữ liệu sau tiền xử lý có đúng như mô tả ở Phần 4 không.
# Chạy từ thư mục gốc: Rscript tests/test_preprocess.R
# =====================================================================

if (!file.exists("src/config.R")) stop("Hãy chạy từ thư mục gốc dự án: mở cereal-rating.Rproj bằng RStudio, hoặc setwd() về thư mục chứa README.md.", call. = FALSE)
source("src/config.R")
source("src/preprocess.R")

failures <- 0
check <- function(desc, ok) {
  cat(if (isTRUE(ok)) "[OK]  " else "[SAI] ", desc, "\n", sep = "")
  if (!isTRUE(ok)) failures <<- failures + 1
}

raw   <- read_raw_cereal()
clean <- preprocess_cereal(raw)
raw76 <- raw[raw$mfr != excluded_mfr, ]

check("Dữ liệu gốc có 77 dòng, 16 cột",
      identical(dim(raw), c(77L, 16L)))
check("Có 4 giá trị khuyết mã -1 (carbo 1, sugars 1, potass 2)",
      sum(is.na(raw[num_cols])) == 4)
check("Sau tiền xử lý còn 76 dòng, 13 cột",
      identical(dim(clean), c(76L, 13L)))
check("Không còn giá trị NA",
      !anyNA(clean))
check("mfr có 6 hãng (đã bỏ hãng A), shelf có 3 mức",
      nlevels(clean$mfr) == 6 && !anyNA(clean$mfr) && nlevels(clean$shelf) == 3)
check("Tên sản phẩm nằm ở rownames, đúng thứ tự dữ liệu gốc",
      identical(rownames(clean), raw76$name))
check("Biến dinh dưỡng đã chia cho weight (so với dữ liệu gốc)",
      isTRUE(all.equal(clean$sodium, raw76$sodium / raw76$weight)))
check("NA được điền bằng trung vị của mẫu N = 76 trước khi chia weight",
      isTRUE(all.equal(clean["Quaker Oatmeal", "carbo"],
                       median(raw76$carbo, na.rm = TRUE) /
                         raw76$weight[raw76$name == "Quaker Oatmeal"])))
check("total_carbs = carbo + sugars",
      isTRUE(all.equal(clean$total_carbs, clean$carbo + clean$sugars)))
check("rating và vitamins giữ nguyên giá trị gốc",
      isTRUE(all.equal(clean$rating, raw76$rating)) &&
        isTRUE(all.equal(clean$vitamins, raw76$vitamins)))

if (failures > 0) {
  stop(failures, " kiểm tra không đạt.", call. = FALSE)
}
cat("\nTất cả kiểm tra đều đạt.\n")
