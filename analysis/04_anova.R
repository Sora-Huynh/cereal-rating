# =====================================================================
# Bước 4 – Mục 6.3: Phân tích phương sai một yếu tố (One-way ANOVA)
# Vào : data/processed/cereal_cleaned.rds   (bước 1)
# Ra  : results/tables/anova_*.csv, results/figures/Hinh_6_3_*.png
# Chạy từ thư mục gốc: Rscript analysis/04_anova.R
#
# Bài toán: rating theo mfr (k = 6) và theo shelf (k = 3);
# thêm sugars theo shelf và theo mfr để giải thích nguyên nhân dinh dưỡng.
# =====================================================================

if (!file.exists("src/config.R")) stop("Hãy chạy từ thư mục gốc dự án: mở cereal-rating.Rproj bằng RStudio, hoặc setwd() về thư mục chứa README.md.", call. = FALSE)
source("src/config.R")
source("src/preprocess.R")
source("src/descriptive.R")
source("src/plots.R")
source("src/inference.R")

d <- load_clean_data()
alpha <- 0.05

problems <- list(
  rating_mfr   = list(y = d$rating, g = d$mfr,   label = "rating theo mfr"),
  rating_shelf = list(y = d$rating, g = d$shelf, label = "rating theo shelf"),
  sugars_mfr   = list(y = d$sugars, g = d$mfr,   label = "sugars theo mfr"),
  sugars_shelf = list(y = d$sugars, g = d$shelf, label = "sugars theo shelf")
)

# --- Bước 1: Kiểm tra giả định (Mục 3.4.2 – 3.4.3) ---
shapiro_all <- do.call(rbind, lapply(names(problems), function(nm) {
  p <- problems[[nm]]
  cbind(Bai_toan = p$label, shapiro_by_group(p$y, p$g))
}))
cat("\nShapiro-Wilk theo từng nhóm:\n"); print(shapiro_all, digits = 4)
save_table(shapiro_all, "anova_1_shapiro_theo_nhom.csv")

levene_all <- do.call(rbind, lapply(names(problems), function(nm) {
  p <- problems[[nm]]
  cbind(Bai_toan = p$label, levene_bf(p$y, p$g))
}))
cat("\nLevene (Brown-Forsythe):\n"); print(levene_all, digits = 4)
save_table(levene_all, "anova_2_levene.csv")

# --- Bước 2: Kiểm định chính (Mục 3.4.4, 3.4.6) ---
for (nm in c("rating_mfr", "rating_shelf")) {
  p <- problems[[nm]]
  tab <- anova_table(p$y, p$g)
  cat("\nBảng ANOVA –", p$label, ":\n"); print(tab, digits = 5)
  save_table(tab, paste0("anova_3_bang_anova_", nm, ".csv"))
}

omni <- do.call(rbind, lapply(problems, function(p) omnibus_tests(p$y, p$g, p$label)))
# Hiệu chỉnh Holm cho 4 kiểm định Kruskal-Wallis (Mục 2.2 B: kiểm định nhiều lần)
omni$p_KW_Holm <- p.adjust(omni$p_KW, method = "holm")
rownames(omni) <- NULL
cat("\nANOVA, Welch ANOVA và Kruskal-Wallis:\n"); print(omni, digits = 4)
save_table(omni, "anova_4_kiem_dinh_tong_the.csv")

# --- Bước 3: Hậu nghiệm (Mục 3.4.5 – 3.4.6) ---
tk_mfr   <- tukey_table(d$rating, d$mfr)
tk_shelf <- tukey_table(d$rating, d$shelf)
cat("\nTukey HSD – rating theo mfr:\n");   print(tk_mfr, digits = 4)
cat("\nTukey HSD – rating theo shelf:\n"); print(tk_shelf, digits = 4)
save_table(tk_mfr,   "anova_5_tukey_rating_mfr.csv")
save_table(tk_shelf, "anova_5_tukey_rating_shelf.csv")

for (nm in names(problems)) {
  p <- problems[[nm]]
  dn <- dunn_test(p$y, p$g, method = "bonferroni")
  cat("\nDunn (Bonferroni) –", p$label, ":\n"); print(dn, digits = 4)
  save_table(dn, paste0("anova_6_dunn_", nm, ".csv"))
}

# Lượng đường theo nhóm (giải thích nguyên nhân dinh dưỡng)
sug <- rbind(cbind(Yeu_to = "mfr",   group_summary(d$sugars, d$mfr)),
             cbind(Yeu_to = "shelf", group_summary(d$sugars, d$shelf)))
cat("\nsugars (g/oz) theo nhóm:\n"); print(sug, digits = 4)
save_table(sug, "anova_7_sugars_theo_nhom.csv")

# --- Hình 6.3: KTC đồng thời Tukey HSD ---
hinh_63 <- plot_tukey(tk_mfr, "(a) rating theo Nhà sản xuất (15 cặp)") +
  plot_tukey(tk_shelf, "(b) rating theo Vị trí kệ (3 cặp)") +
  plot_layout(widths = c(1.4, 1), guides = "collect") &
  theme(legend.position = "bottom")
show_plot(hinh_63)
save_figure(hinh_63, "Hinh_6_3_Tukey_HSD.png", width = 11, height = 5)
