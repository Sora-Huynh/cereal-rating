# =====================================================================
# Chạy toàn bộ quy trình: dữ liệu gốc -> dữ liệu sạch -> bảng -> hình
# Chạy từ thư mục gốc:  Rscript run_all.R
# Hoặc trong RStudio (đã mở cereal-rating.Rproj):  source("run_all.R")
# =====================================================================

if (!file.exists("src/config.R")) stop("Hãy chạy từ thư mục gốc dự án: mở cereal-rating.Rproj bằng RStudio, hoặc setwd() về thư mục chứa README.md.", call. = FALSE)

steps <- c(
  "analysis/01_preprocess.R",       # Phần 4
  "analysis/02_descriptive_stats.R",  # Mục 5.1, Bảng 4 – 7
  "analysis/03_descriptive_plots.R"   # Mục 5.2, Hình 1 – 4
)

for (step in steps) {
  cat("\n=====", step, "=====\n")
  # Mỗi bước chạy trong môi trường riêng, chỉ trao đổi với nhau qua file
  source(step, local = new.env(), encoding = "UTF-8")
}

cat("\nXong. Bảng ở results/tables/, hình ở results/figures/.\n")
