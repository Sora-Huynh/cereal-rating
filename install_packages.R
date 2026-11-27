# =====================================================================
# Cài các thư viện R mà dự án cần (chỉ cài những gói còn thiếu).
# Chạy một lần:  Rscript install_packages.R   hoặc   source("install_packages.R")
# =====================================================================

pkgs <- c("dplyr", "tidyr", "e1071", "ggplot2", "ggcorrplot", "patchwork")

missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
} else {
  cat("Đã có đủ thư viện:", paste(pkgs, collapse = ", "), "\n")
}
